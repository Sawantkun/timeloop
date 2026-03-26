import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  Future<void> _send() async {
    if (_emailCtrl.text.isEmpty || !_emailCtrl.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    await auth.resetPassword(_emailCtrl.text.trim());
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 40),

              if (!_sent) ...[
                const Text('🔐', style: TextStyle(fontSize: 56))
                    .animate()
                    .scale(curve: Curves.elasticOut, duration: 600.ms),
                const SizedBox(height: 24),
                Text(
                  'Reset Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                Text(
                  "Enter your email and we'll send a reset link.",
                  style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 16),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 40),
                AppTextField(
                  label: 'Email Address',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Send Reset Link',
                  onPressed: _loading ? null : _send,
                  isLoading: _loading,
                ).animate().fadeIn(delay: 250.ms),
              ] else ...[
                const Center(
                  child: Text('✅', style: TextStyle(fontSize: 80)),
                ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                const SizedBox(height: 24),
                Text(
                  'Check your inbox!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  "We've sent a password reset link to\n${_emailCtrl.text}",
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 40),
                GradientButton(
                  label: 'Back to Sign In',
                  onPressed: () => context.go('/login'),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
