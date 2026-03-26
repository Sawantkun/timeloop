import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Text(
                    'Messages',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  if (chat.totalUnread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${chat.totalUnread} new',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {},
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.1),
            ),

            if (chat.conversations.isEmpty)
              Expanded(
                child: EmptyState(
                  emoji: '💬',
                  title: 'No conversations yet',
                  subtitle: 'Find a skill partner and start chatting!',
                  actionLabel: 'Explore Skills',
                  onAction: () => context.go('/search'),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                  itemCount: chat.conversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
                  itemBuilder: (context, i) {
                    final conv = chat.conversations[i];
                    return _ConversationTile(
                      conv: conv,
                      index: i,
                      onTap: () => context.push('/messages/${conv.id}', extra: conv),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conv;
  final int index;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conv,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasUnread = conv.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            UserAvatar(
              name: conv.otherUserName,
              size: 52,
              showOnline: true,
              isOnline: conv.otherUserOnline,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.otherUserName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                              ),
                        ),
                      ),
                      Text(
                        timeago.format(conv.lastMessageAt),
                        style: TextStyle(
                          color: hasUnread
                              ? AppColors.primary
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          fontSize: 11,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          style: TextStyle(
                            color: hasUnread
                                ? (isDark ? AppColors.darkText : AppColors.lightText)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            fontSize: 13,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conv.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.05);
  }
}
