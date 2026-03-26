import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/mock_data.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});

  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser!.id;
    final bookings = context.watch<BookingsProvider>();
    final disputes = MockDisputes.getForUser(userId);
    final disputedBookings = bookings.disputed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disputes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Disputes'),
            Tab(text: 'File a Dispute'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My disputes
          disputes.isEmpty
              ? EmptyState(
                  emoji: '🕊️',
                  title: 'No disputes',
                  subtitle: 'You have no active or past disputes. Healthy community!',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: disputes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _DisputeCard(dispute: disputes[i], index: i),
                ),

          // File a dispute
          disputedBookings.isEmpty
              ? EmptyState(
                  emoji: '✅',
                  title: 'No eligible bookings',
                  subtitle: 'You can only file disputes for completed or disputed sessions.',
                )
              : _FileDisputeView(bookings: disputedBookings),
        ],
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final Dispute dispute;
  final int index;

  const _DisputeCard({required this.dispute, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: dispute.statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dispute.statusLabel,
                  style: TextStyle(
                    color: dispute.statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightBorder.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dispute.reasonLabel,
                  style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              UserAvatar(name: dispute.complainantName, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs. ${dispute.respondentName}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(dispute.createdAt),
                      style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            dispute.description,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 13,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (dispute.resolution != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dispute.resolution!,
                      style: const TextStyle(color: AppColors.success, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (dispute.refundAmount != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('💰 Refund issued: ', style: TextStyle(fontSize: 13)),
                CreditBadge(amount: dispute.refundAmount!),
              ],
            ),
          ],
        ],
      ),
    ).animate(delay: (index * 80).ms).fadeIn().slideY(begin: 0.1);
  }
}

class _FileDisputeView extends StatefulWidget {
  final List<Booking> bookings;

  const _FileDisputeView({required this.bookings});

  @override
  State<_FileDisputeView> createState() => _FileDisputeViewState();
}

class _FileDisputeViewState extends State<_FileDisputeView> {
  Booking? _selectedBooking;
  DisputeReason? _selectedReason;
  final _descCtrl = TextEditingController();
  bool _submitted = false;

  static const _reasons = [
    (DisputeReason.noShow, '🚫', 'No Show', 'Provider didn\'t attend the session'),
    (DisputeReason.poorQuality, '📉', 'Poor Quality', 'Session quality was far below expected'),
    (DisputeReason.wrongSkill, '🎭', 'Wrong Skill Level', 'Provider misrepresented their skill level'),
    (DisputeReason.paymentIssue, '💳', 'Payment Issue', 'Problem with credit deduction'),
    (DisputeReason.other, '❓', 'Other', 'Something else happened'),
  ];

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📋', style: TextStyle(fontSize: 64))
                  .animate().scale(curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                'Dispute Filed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              const Text(
                'Our team will review your dispute within 24 hours. We\'ll notify you with the outcome.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.lightTextSecondary, height: 1.5),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.info.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.info),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Credits remain in escrow until the dispute is resolved.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Session',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          ...widget.bookings.map((b) {
            final selected = _selectedBooking?.id == b.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedBooking = b),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.error.withOpacity(0.08)
                      : isDark
                          ? AppColors.darkCard
                          : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.error : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(b.skill.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.skill.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            'with ${b.providerName} · ${DateFormat('MMM d').format(b.scheduledAt)}',
                            style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.radio_button_checked, color: AppColors.error),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          Text(
            'Reason',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          ..._reasons.map((r) {
            final selected = _selectedReason == r.$1;
            return GestureDetector(
              onTap: () => setState(() => _selectedReason = r.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withOpacity(0.08)
                      : isDark
                          ? AppColors.darkCard
                          : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(r.$2, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.$3, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                        Text(r.$4, style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          AppTextField(
            label: 'Describe what happened',
            hint: 'Please provide as much detail as possible...',
            controller: _descCtrl,
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          GradientButton(
            label: 'Submit Dispute',
            gradient: const LinearGradient(colors: [AppColors.error, Color(0xFFDC2626)]),
            onPressed: _selectedBooking == null || _selectedReason == null
                ? null
                : () => setState(() => _submitted = true),
          ),
        ],
      ),
    );
  }
}
