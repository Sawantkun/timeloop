import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';

class BookingScreen extends StatefulWidget {
  final UserModel provider;

  const BookingScreen({super.key, required this.provider});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Skill? _selectedSkill;
  int _duration = 60; // minutes
  DateTime? _selectedDate;
  String? _selectedTime;
  final _notesCtrl = TextEditingController();
  int _step = 0; // 0=skill, 1=schedule, 2=confirm

  static const _durations = [30, 60, 90, 120];
  static const _timeSlots = ['9:00 AM', '10:00 AM', '11:00 AM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'];

  double get _credits => _duration / 60.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
        ),
        title: Text('Book with ${widget.provider.name.split(' ').first}'),
      ),
      body: Column(
        children: [
          // Step indicator
          _StepIndicator(currentStep: _step),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: [
                _step0_SelectSkill(context, isDark),
                _step1_Schedule(context, isDark),
                _step2_Confirm(context, isDark, wallet),
              ][_step],
            ),
          ),

          // CTA
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: GradientButton(
              label: _step < 2 ? 'Continue' : 'Confirm Booking',
              onPressed: _canContinue ? _handleContinue : null,
              icon: _step < 2 ? null : Icons.check_circle_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }

  bool get _canContinue {
    if (_step == 0) return _selectedSkill != null;
    if (_step == 1) return _selectedDate != null && _selectedTime != null;
    return true;
  }

  Future<void> _handleContinue() async {
    if (_step < 2) {
      setState(() => _step++);
      return;
    }

    // Book
    final bookings = context.read<BookingsProvider>();
    final wallet = context.read<WalletProvider>();

    final dt = _selectedDate!;
    final timeParts = _selectedTime!.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
    var hour = int.parse(timeParts[0]);
    if (_selectedTime!.contains('PM') && hour != 12) hour += 12;
    final scheduled = DateTime(dt.year, dt.month, dt.day, hour, int.parse(timeParts[1]));

    final booked = await wallet.spendCredits(
      _credits,
      '${_selectedSkill!.name} session',
      widget.provider.name,
    );

    if (!booked) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient credits for this booking.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    await bookings.createBooking(
      providerId: widget.provider.id,
      providerName: widget.provider.name,
      skill: _selectedSkill!,
      scheduledAt: scheduled,
      durationMinutes: _duration,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    );

    if (mounted) {
      _showSuccessSheet(context);
    }
  }

  Widget _step0_SelectSkill(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Skill',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ).animate().fadeIn(),
        const SizedBox(height: 4),
        Text(
          'Choose which skill you want to learn from ${widget.provider.name.split(' ').first}',
          style: TextStyle(color: AppColors.lightTextSecondary),
        ).animate().fadeIn(delay: 80.ms),
        const SizedBox(height: 20),
        ...widget.provider.skillsOffered.asMap().entries.map((e) {
          final skill = e.value;
          final selected = _selectedSkill?.id == skill.id;

          return GestureDetector(
            onTap: () => setState(() => _selectedSkill = skill),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected
                    ? skill.levelColor.withOpacity(0.1)
                    : isDark
                        ? AppColors.darkCard
                        : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? skill.levelColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: skill.levelColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(skill.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: skill.levelColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                skill.levelLabel,
                                style: TextStyle(
                                  color: skill.levelColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              skill.category,
                              style: TextStyle(
                                color: AppColors.lightTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: skill.levelColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                    ),
                ],
              ),
            ),
          ).animate(delay: (e.key * 80).ms).fadeIn().slideY(begin: 0.1);
        }),
      ],
    );
  }

  Widget _step1_Schedule(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final dates = List.generate(7, (i) => now.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule Session',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ).animate().fadeIn(),
        const SizedBox(height: 20),

        // Duration
        Text(
          'Duration',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: _durations.map((d) {
            final selected = d == _duration;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _duration = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.12)
                        : isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.lightBorder,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        d >= 60 ? '${d ~/ 60}h${d % 60 > 0 ? ' ${d % 60}m' : ''}' : '${d}m',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.primary : null,
                          fontSize: 13,
                        ),
                      ),
                      CreditBadge(amount: d / 60),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Date picker
        Text(
          'Select Date',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, i) {
              final date = dates[i];
              final selected = _selectedDate?.day == date.day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          fontSize: 11,
                          color: selected ? Colors.white70 : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Time slots
        Text(
          'Select Time',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((t) {
            final selected = t == _selectedTime;
            return GestureDetector(
              onTap: () => setState(() => _selectedTime = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withOpacity(0.12)
                      : isDark
                          ? AppColors.darkCard
                          : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.lightBorder,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primary : null,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Notes
        AppTextField(
          label: 'Notes (optional)',
          hint: 'Any specific topics or preferences...',
          controller: _notesCtrl,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _step2_Confirm(BuildContext context, bool isDark, WalletProvider wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Booking',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ).animate().fadeIn(),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  UserAvatar(name: widget.provider.name, size: 50),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.provider.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      StarRating(rating: widget.provider.rating),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              _confirmRow(context, '📚 Skill', '${_selectedSkill!.emoji} ${_selectedSkill!.name}'),
              _confirmRow(context, '📅 Date', DateFormat('EEEE, MMMM d').format(_selectedDate!)),
              _confirmRow(context, '⏰ Time', _selectedTime!),
              _confirmRow(
                context,
                '⏱ Duration',
                '${_duration}min (${_credits.toStringAsFixed(1)} credits)',
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Text('Total Cost', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const Spacer(),
                  CreditBadge(amount: _credits, large: true),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Wallet balance: ${wallet.balance} cr',
                    style: TextStyle(
                      color: wallet.balance >= _credits ? AppColors.success : AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (wallet.balance >= _credits)
                    Text(
                      '→ ${(wallet.balance - _credits).toStringAsFixed(1)} cr after',
                      style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),

        if (_notesCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Text(
              '"${_notesCtrl.text}"',
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
            ),
          ),
        ],

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.warning.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Credits are held in escrow until both parties confirm the session is complete.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _confirmRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.lightTextSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64))
                .animate()
                .scale(curve: Curves.elasticOut, duration: 600.ms),
            const SizedBox(height: 16),
            Text(
              'Booking Confirmed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'Your session with ${widget.provider.name.split(' ').first} has been booked. They\'ll be notified right away!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.lightTextSecondary, height: 1.5),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Back to Home',
              onPressed: () {
                Navigator.pop(context);
                context.go('/home');
              },
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                final chat = context.read<ChatProvider>();
                final conv = chat.startConversation(widget.provider);
                Navigator.pop(context);
                context.push('/messages/${conv.id}', extra: conv);
              },
              child: const Text('Message them now'),
            ).animate().fadeIn(delay: 450.ms),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  static const _labels = ['Skill', 'Schedule', 'Confirm'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIdx = i ~/ 2;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                color: stepIdx < currentStep ? AppColors.primary : AppColors.lightBorder,
              ),
            );
          }
          final step = i ~/ 2;
          final done = step < currentStep;
          final active = step == currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.primary
                  : active
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.lightBorder.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: active || done ? AppColors.primary : AppColors.lightBorder,
                width: active ? 2 : 1,
              ),
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: active ? AppColors.primary : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}
