import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/mock_data.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel? viewUser; // null = own profile

  const ProfileScreen({super.key, this.viewUser});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = viewUser ?? auth.currentUser!;
    final isOwn = viewUser == null || viewUser!.id == auth.currentUser?.id;
    final reviews = MockReviews.getForUser(user.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header + stats card in one Stack so the card can safely overflow downward
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient background — fills the Stack's natural height
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                  ),
                ),

                // Header content — bottom padding reserves room for the card overlap
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      children: [
                        // Top bar
                        Row(
                          children: [
                            if (!isOwn)
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'My Profile',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            const Spacer(),
                            if (isOwn) ...[
                              GestureDetector(
                                onTap: () => theme.toggleTheme(),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    theme.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _showSettingsSheet(context, auth),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.settings_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Avatar and info
                        Row(
                          children: [
                            UserAvatar(
                              name: user.name,
                              size: 72,
                              borderColor: Colors.white,
                            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.location,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: AppColors.accentLight, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${user.rating} (${user.reviewCount} reviews)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Space so the stats card sits half-inside the gradient
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Stats card — anchored to the bottom of the Stack, overflows downward
                Positioned(
                  bottom: -36,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat(context, '${user.completedSwaps}', 'Swaps'),
                        _divider(),
                        _stat(context, '${user.skillsOffered.length}', 'Skills'),
                        _divider(),
                        _stat(context, '${user.walletBalance} cr', 'Balance'),
                        _divider(),
                        _stat(context, user.rating.toString(), 'Rating'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                ),
              ],
            ),
          ),

          // Spacer that accounts for the stats card overflow (36px below + 16px gap)
          const SliverToBoxAdapter(child: SizedBox(height: 52)),

          // Bio
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.bio,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),
          ),

          // Skills offered
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: 'Skills I Offer'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.skillsOffered.map((s) => _SkillCard(skill: s)).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Skills needed
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: 'Skills I Need'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.skillsNeeded
                        .map((s) => SkillChip(emoji: s.emoji, label: s.name))
                        .toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Availability
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: 'Availability'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                      final available = user.availability.contains(day);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: available
                              ? AppColors.success.withOpacity(0.12)
                              : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: available ? AppColors.success : AppColors.lightBorder,
                          ),
                        ),
                        child: Text(
                          day,
                          style: TextStyle(
                            color: available ? AppColors.success : AppColors.lightTextSecondary,
                            fontWeight: available ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Reviews
          if (reviews.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Reviews',
                  actionLabel: 'See all',
                  onAction: () {},
                ),
              ).animate().fadeIn(delay: 350.ms),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _ReviewCard(review: reviews[i], index: i),
                  childCount: reviews.length,
                ),
              ),
            ),
          ],

          // CTA for other profiles
          if (!isOwn)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final chat = context.read<ChatProvider>();
                          final conv = chat.startConversation(user);
                          context.push('/messages/${conv.id}', extra: conv);
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'Book Swap',
                        icon: Icons.swap_horiz_rounded,
                        onPressed: () => context.push('/booking', extra: user),
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
            )
          else
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 32, color: AppColors.lightBorder);

  void _showSettingsSheet(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _settingItem(context, Icons.edit_outlined, 'Edit Profile', () => Navigator.pop(context)),
            _settingItem(context, Icons.notifications_outlined, 'Notifications', () => Navigator.pop(context)),
            _settingItem(context, Icons.privacy_tip_outlined, 'Privacy', () => Navigator.pop(context)),
            _settingItem(context, Icons.help_outline_rounded, 'Help & Support', () => Navigator.pop(context)),
            const Divider(height: 24),
            _settingItem(
              context,
              Icons.logout_rounded,
              'Sign Out',
              () {
                Navigator.pop(context);
                auth.signOut();
                context.go('/login');
              },
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.lightTextSecondary),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}

class _SkillCard extends StatelessWidget {
  final Skill skill;

  const _SkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: skill.levelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: skill.levelColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                skill.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: skill.levelColor,
                ),
              ),
              Text(
                skill.levelLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: skill.levelColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final int index;

  const _ReviewCard({required this.review, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: review.reviewerName, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        StarRating(rating: review.rating, size: 13),
                        const SizedBox(width: 6),
                        SkillChip(
                          emoji: review.skill.emoji,
                          label: review.skill.name,
                          selected: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn().slideY(begin: 0.1);
  }
}
