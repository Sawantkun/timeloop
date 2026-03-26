import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/mock_data.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';
import '../../widgets/cards/match_card.dart';
import '../../widgets/cards/swap_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookings = context.watch<BookingsProvider>();
    final wallet = context.watch<WalletProvider>();
    final user = auth.currentUser!;
    final matches = MockMatches.getForUser(user);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_greeting()} 👋',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user.name.split(' ').first,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Wallet balance pill
                    GestureDetector(
                      onTap: () => context.go('/wallet'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text('⏱', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              '${wallet.balance} cr',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ).animate(onPlay: (c) => c.repeat())
                          .shimmer(duration: 2000.ms, delay: 3000.ms, color: Colors.white.withOpacity(0.3)),
                    ),
                    const SizedBox(width: 10),
                    // Notification bell
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(Icons.notifications_none_rounded, size: 22),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Hero stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatsRow(user: user),
              ).animate().fadeIn(delay: 100.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Upcoming swaps
            if (bookings.upcoming.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Upcoming Swaps',
                    actionLabel: 'See all',
                    onAction: () {},
                  ),
                ).animate().fadeIn(delay: 150.ms),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SwapCard(
                    booking: bookings.upcoming.first,
                    currentUserId: user.id,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
            ],

            // AI Recommended Matches
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('✨', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 4),
                          Text(
                            'AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recommended Matches',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/search'),
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 310,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: matches.length,
                  itemBuilder: (context, i) => MatchCard(
                    match: matches[i],
                    index: i,
                    onTap: () => context.push('/booking', extra: matches[i].user),
                    onMessage: () {
                      final chat = context.read<ChatProvider>();
                      final conv = chat.startConversation(matches[i].user);
                      context.push('/messages/${conv.id}', extra: conv);
                    },
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Skill categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Browse Skills',
                  actionLabel: 'View all',
                  onAction: () => context.go('/search'),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _categories.asMap().entries.map((e) {
                    return _CategoryCard(
                      emoji: e.value.$1,
                      name: e.value.$2,
                      color: e.value.$3,
                      index: e.key,
                      onTap: () => context.go('/search'),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Recent activity
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(title: 'Recent Activity'),
              ).animate().fadeIn(delay: 350.ms),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => SwapCard(
                    booking: bookings.bookings[i],
                    currentUserId: user.id,
                  ).animate().fadeIn(delay: (400 + i * 50).ms).slideY(begin: 0.1),
                  childCount: bookings.bookings.take(3).length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  static const _categories = [
    ('💻', 'Tech', Color(0xFF4F46E5)),
    ('🎨', 'Creative', Color(0xFFEC4899)),
    ('🎵', 'Music', Color(0xFF7C3AED)),
    ('🌿', 'Wellness', Color(0xFF10B981)),
    ('🍳', 'Culinary', Color(0xFFF59E0B)),
    ('🌍', 'Languages', Color(0xFF0EA5E9)),
  ];
}

class _StatsRow extends StatelessWidget {
  final UserModel user;

  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          UserAvatar(
            name: user.name,
            size: 52,
            borderColor: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.accentLight, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${user.rating} · ${user.completedSwaps} swaps',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⏱', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${user.walletBalance} cr',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Time Credits',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String name;
  final Color color;
  final int index;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.emoji,
    required this.name,
    required this.color,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate(delay: (300 + index * 60).ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
    );
  }
}
