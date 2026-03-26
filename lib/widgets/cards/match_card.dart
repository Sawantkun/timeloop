import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/models.dart';
import '../../core/theme.dart';
import '../common/widgets.dart';

class MatchCard extends StatelessWidget {
  final SkillMatch match;
  final VoidCallback? onTap;
  final VoidCallback? onMessage;
  final int index;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.onMessage,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with score
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    match.matchScore >= 0.9
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.1),
                    match.matchScore >= 0.9
                        ? AppColors.success.withOpacity(0.05)
                        : AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    name: match.user.name,
                    size: 44,
                    showOnline: true,
                    isOnline: match.user.isOnline,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.user.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        StarRating(rating: match.user.rating, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skill exchange visual
                  _SkillExchange(
                    theyOffer: match.theyOffer,
                    youNeed: match.youNeed,
                  ),
                  const SizedBox(height: 12),

                  // Match score pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: match.scoreColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: match.scoreColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          match.scoreLabel,
                          style: TextStyle(
                            color: match.scoreColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(match.matchScore * 100).toInt()}%',
                          style: TextStyle(
                            color: match.scoreColor.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Match reasons
                  ...match.matchReasons.take(2).map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            const Text('✓ ', style: TextStyle(color: AppColors.success, fontSize: 11)),
                            Expanded(
                              child: Text(
                                r,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 12),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Book Swap',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onMessage,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
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
    )
        .animate(delay: (index * 80).ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.2, duration: 400.ms, curve: Curves.easeOut);
  }
}

class _SkillExchange extends StatelessWidget {
  final Skill theyOffer;
  final Skill youNeed;

  const _SkillExchange({required this.theyOffer, required this.youNeed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _skillPill(context, theyOffer, 'They offer', isDark),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 16),
          ),
        ),
        Expanded(
          child: _skillPill(context, youNeed, 'You need', isDark),
        ),
      ],
    );
  }

  Widget _skillPill(BuildContext context, Skill skill, String label, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(skill.emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  skill.name.split(' ').first,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
