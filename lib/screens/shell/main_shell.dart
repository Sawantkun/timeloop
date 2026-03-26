import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/providers.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Search'),
    _TabItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
    _TabItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Messages'),
    _TabItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final isActive = current == i;
                return Expanded(
                  child: _NavItem(
                    tab: _tabs[i],
                    isActive: isActive,
                    badge: i == 3 ? chatProvider.totalUnread : 0,
                    onTap: () => navigationShell.goBranch(
                      i,
                      initialLocation: i == current,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool isActive;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? tab.activeIcon : tab.icon,
                  size: 24,
                  color: isActive
                      ? (isDark ? AppColors.primaryLight : AppColors.primary)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
              if (badge > 0)
                Positioned(
                  right: 6,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 800.ms),
                ),
            ],
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            child: Text(tab.label),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
