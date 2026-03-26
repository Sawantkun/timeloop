import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Wallet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded),
                      onPressed: () => _showInfoSheet(context),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1),
            ),

            // Balance card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _BalanceCard(balance: wallet.balance),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Weekly chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _WeeklyChart(data: wallet.weeklyData),
              ).animate().fadeIn(delay: 200.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Earn Credits',
                        color: AppColors.success,
                        onTap: () => _showEarnSheet(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.send_rounded,
                        label: 'Transfer',
                        color: AppColors.primary,
                        onTap: () => _showTransferSheet(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.history_rounded,
                        label: 'History',
                        color: AppColors.secondary,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 250.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(title: 'Transaction History'),
              ).animate().fadeIn(delay: 300.ms),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _TransactionItem(
                    tx: wallet.transactions[i],
                    index: i,
                  ),
                  childCount: wallet.transactions.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About Time Credits ⏱',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _infoRow('1 hour of teaching = 1 time credit'),
            _infoRow('Credits never expire'),
            _infoRow('Starting bonus: 3 credits'),
            _infoRow('Top-rated teachers earn bonus credits'),
            _infoRow('Dispute resolution protects your credits'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const Text('✓ ', style: TextStyle(color: AppColors.success, fontSize: 16)),
            Expanded(child: Text(text)),
          ],
        ),
      );

  void _showEarnSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ways to Earn Credits',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _earnCard(context, '🎓', 'Teach a Skill', 'Complete a teaching session'),
            _earnCard(context, '⭐', 'Get 5-star review', 'Receive a perfect rating (+0.5 bonus)'),
            _earnCard(context, '👥', 'Refer a friend', 'Earn 1 credit per referral'),
            _earnCard(context, '🏆', 'Streak bonus', 'Swap every week for 4 weeks (+1)'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _earnCard(BuildContext context, String emoji, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(sub, style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  void _showTransferSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transfer Credits',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text('Credits are automatically transferred when a swap is completed. No manual transfers needed!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
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
                      'Credits are held in escrow until a swap is confirmed completed by both parties.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⏱', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              const Text(
                'TimeLoop Wallet',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            balance.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: false))
              .shimmer(duration: 2000.ms, delay: 1000.ms, color: Colors.white.withOpacity(0.2)),
          Text(
            'Time Credits',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _balanceStat(context, '≈ ${balance.toStringAsFixed(0)} hrs', 'Teaching time'),
              const SizedBox(width: 32),
              _balanceStat(context, 'No expiry', 'Credits valid'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceStat(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<double> data;

  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxY = data.reduce((a, b) => a > b ? a : b) + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Credits Earned This Week',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: maxY == 1 ? 3 : maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                        days[v.toInt()],
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: data.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value == 0 ? 0.1 : e.value,
                        gradient: e.value > 0
                            ? AppColors.primaryGradient
                            : LinearGradient(colors: [
                                AppColors.lightBorder,
                                AppColors.lightBorder,
                              ]),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction tx;
  final int index;

  const _TransactionItem({required this.tx, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCredit = tx.isCredit;

    final icons = {
      TransactionType.earned: Icons.arrow_downward_rounded,
      TransactionType.spent: Icons.arrow_upward_rounded,
      TransactionType.bonus: Icons.stars_rounded,
      TransactionType.refund: Icons.replay_rounded,
    };

    final colors = {
      TransactionType.earned: AppColors.success,
      TransactionType.spent: AppColors.error,
      TransactionType.bonus: AppColors.accent,
      TransactionType.refund: AppColors.info,
    };

    final color = colors[tx.type]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icons[tx.type], color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  timeago.format(tx.createdAt),
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${tx.amount} cr',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
  }
}
