import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

// ─── Gradient Button ───────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LinearGradient? gradient;
  final double height;
  final double? width;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.height = 52,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final grad = gradient ?? AppColors.primaryGradient;
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null ? null : grad,
          color: onPressed == null ? AppColors.lightBorder : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── App Text Field ────────────────────────────────────────────
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final int maxLines;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixWidget,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20, color: AppColors.lightTextSecondary)
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : widget.suffixWidget,
          ),
        ),
      ],
    );
  }
}

// ─── Skill Chip ────────────────────────────────────────────────
class SkillChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;

  const SkillChip({
    super.key,
    required this.emoji,
    required this.label,
    this.color,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? (color ?? AppColors.primary).withOpacity(0.15)
        : isDark
            ? AppColors.darkSurface
            : AppColors.lightBackground;
    final border = selected ? (color ?? AppColors.primary) : AppColors.lightBorder;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? (color ?? AppColors.primary) : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── User Avatar ───────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;
  final bool showOnline;
  final bool isOnline;
  final Color? borderColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 48,
    this.showOnline = false,
    this.isOnline = false,
    this.borderColor,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _avatarColor() {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      const Color(0xFF0EA5E9),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
    ];
    final idx = name.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_avatarColor(), _avatarColor().withOpacity(0.7)],
            ),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              _initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.35,
              ),
            ),
          ),
        ),
        if (showOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : AppColors.lightTextSecondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Star Rating ───────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showLabel;

  const StarRating({super.key, required this.rating, this.size = 16, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.accent, size: size),
        const SizedBox(width: 3),
        if (showLabel)
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: size - 2,
            ),
          ),
      ],
    );
  }
}

// ─── Section Header ────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Credit Badge ──────────────────────────────────────────────
class CreditBadge extends StatelessWidget {
  final double amount;
  final bool large;

  const CreditBadge({super.key, required this.amount, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '⏱',
            style: TextStyle(fontSize: large ? 16 : 12),
          ),
          const SizedBox(width: 4),
          Text(
            '${amount % 1 == 0 ? amount.toInt() : amount} cr',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: large ? 16 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 60))
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              GradientButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 200,
                height: 44,
              ),
            ],
          ],
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
      ),
    );
  }
}

// ─── Loading Shimmer Card ──────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        borderRadius: BorderRadius.circular(radius),
      ),
    ).animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: isDark ? AppColors.darkSurface : Colors.white);
  }
}
