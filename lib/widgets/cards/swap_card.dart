import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../core/theme.dart';
import '../common/widgets.dart';

class SwapCard extends StatelessWidget {
  final Booking booking;
  final String currentUserId;
  final VoidCallback? onTap;

  const SwapCard({
    super.key,
    required this.booking,
    required this.currentUserId,
    this.onTap,
  });

  bool get _isRequester => booking.requesterId == currentUserId;
  String get _otherName => _isRequester ? booking.providerName : booking.requesterName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('EEE, MMM d • h:mm a').format(booking.scheduledAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // Skill emoji circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: booking.skill.levelColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(booking.skill.emoji, style: const TextStyle(fontSize: 22)),
              ),
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
                          booking.skill.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CreditBadge(amount: booking.creditsAmount),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRequester ? 'with $_otherName' : 'teaching $_otherName',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Status badge
            _StatusBadge(status: booking.status),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SwapStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.statusLabel,
        style: TextStyle(
          color: status.statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

extension on SwapStatus {
  Color get statusColor {
    switch (this) {
      case SwapStatus.pending: return const Color(0xFFF59E0B);
      case SwapStatus.confirmed: return const Color(0xFF3B82F6);
      case SwapStatus.inProgress: return const Color(0xFF7C3AED);
      case SwapStatus.completed: return const Color(0xFF10B981);
      case SwapStatus.cancelled: return const Color(0xFF6B7280);
      case SwapStatus.disputed: return const Color(0xFFEF4444);
    }
  }

  String get statusLabel {
    switch (this) {
      case SwapStatus.pending: return 'Pending';
      case SwapStatus.confirmed: return 'Confirmed';
      case SwapStatus.inProgress: return 'In Progress';
      case SwapStatus.completed: return 'Completed';
      case SwapStatus.cancelled: return 'Cancelled';
      case SwapStatus.disputed: return 'Disputed';
    }
  }
}
