import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().markAsRead(widget.conversation.id);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    setState(() => _isTyping = true);

    final auth = context.read<AuthProvider>();
    await context.read<ChatProvider>().sendMessage(
          widget.conversation.id,
          auth.currentUser!.id,
          text,
        );

    setState(() => _isTyping = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final conv = chat.getConversation(widget.conversation.otherUserId) ?? widget.conversation;
    final myId = auth.currentUser!.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            UserAvatar(
              name: conv.otherUserName,
              size: 36,
              showOnline: true,
              isOnline: conv.otherUserOnline,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conv.otherUserName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  conv.otherUserOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: conv.otherUserOnline ? AppColors.success : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () {},
            tooltip: 'Book a swap',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: conv.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UserAvatar(name: conv.otherUserName, size: 72),
                        const SizedBox(height: 16),
                        Text(
                          conv.otherUserName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Say hello to start swapping skills!',
                          style: TextStyle(color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: conv.messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (_isTyping && i == conv.messages.length) {
                        return _TypingIndicator(name: conv.otherUserName);
                      }
                      final msg = conv.messages[i];
                      final isMe = msg.senderId == myId;
                      final showTime = i == 0 ||
                          msg.sentAt.difference(conv.messages[i - 1].sentAt).inMinutes > 10;

                      return Column(
                        children: [
                          if (showTime)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                _formatTime(msg.sentAt),
                                style: TextStyle(
                                  color: AppColors.lightTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          _MessageBubble(
                            message: msg,
                            isMe: isMe,
                            index: i,
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () {},
                  color: AppColors.lightTextSecondary,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Message ${conv.otherUserName.split(' ').first}...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day) return 'Today ${DateFormat('h:mm a').format(dt)}';
    if (dt.day == now.day - 1) return 'Yesterday ${DateFormat('h:mm a').format(dt)}';
    return DateFormat('MMM d, h:mm a').format(dt);
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final int index;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const SizedBox(width: 4),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe ? AppColors.primaryGradient : null,
                color: isMe
                    ? null
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
                border: isMe
                    ? null
                    : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : null,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 30).ms).fadeIn().slideY(begin: 0.1);
  }
}

class _TypingIndicator extends StatelessWidget {
  final String name;

  const _TypingIndicator({required this.name});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lightTextSecondary,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat())
                    .fadeIn(delay: (i * 200).ms, duration: 400.ms)
                    .then()
                    .fadeOut(duration: 400.ms);
              }),
            ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
