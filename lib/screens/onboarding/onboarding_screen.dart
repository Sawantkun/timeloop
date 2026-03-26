import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/common/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      emoji: '⏱',
      title: 'Trade Skills,\nNot Money',
      subtitle: 'Exchange your expertise with others using time credits. 1 hour of your skill = 1 hour of theirs.',
      gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    ),
    _OnboardPage(
      emoji: '🤝',
      title: 'Find Your\nPerfect Match',
      subtitle: 'Our AI connects you with people whose skills you need and who need what you offer.',
      gradient: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    ),
    _OnboardPage(
      emoji: '🌟',
      title: 'Build Real\nConnections',
      subtitle: 'Rate, review, and grow together. TimeLoop is a community that values human skills.',
      gradient: [Color(0xFF7C3AED), Color(0xFFEC4899)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _pages[_page].gradient[0].withOpacity(0.08),
                  _pages[_page].gradient[1].withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _pages.length,
                    itemBuilder: (context, i) => _pages[i],
                  ),
                ),

                // Dots + CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _page ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _page
                                  ? AppColors.primary
                                  : AppColors.lightBorder,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // CTA button
                      GradientButton(
                        label: _page == _pages.length - 1 ? 'Get Started' : 'Continue',
                        onPressed: () {
                          if (_page == _pages.length - 1) {
                            context.go('/login');
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        gradient: LinearGradient(
                          colors: _pages[_page].gradient,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sign in link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(color: AppColors.lightTextSecondary),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
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
        ],
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji in gradient circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 64)),
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .shimmer(duration: 1500.ms, delay: 600.ms),
          const SizedBox(height: 48),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 20),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightTextSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}
