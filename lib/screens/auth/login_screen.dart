import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back button
                GestureDetector(
                  onTap: () => context.go('/onboarding'),
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
                const SizedBox(height: 32),

                // Header
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  child: const Text(
                    'Welcome\nback! 👋',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue swapping skills',
                  style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 16),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 40),

                // Error message
                if (auth.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: AppColors.error, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ).animate().shake(),
                  const SizedBox(height: 20),
                ],

                // Email field
                AppTextField(
                  label: 'Email Address',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
                const SizedBox(height: 20),

                // Password field
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordCtrl,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 12),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => context.push('/forgot-password'),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 32),

                // Sign in button
                GradientButton(
                  label: 'Sign In',
                  onPressed: isLoading ? null : _signIn,
                  isLoading: isLoading,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or continue with',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 20),

                // Demo login button
                OutlinedButton.icon(
                  onPressed: () {
                    _emailCtrl.text = 'alex@timeloop.app';
                    _passwordCtrl.text = 'password123';
                    _signIn();
                  },
                  icon: const Text('⚡', style: TextStyle(fontSize: 18)),
                  label: const Text(
                    'Try Demo Account',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: AppColors.lightBorder),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 32),

                // Sign up link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.lightTextSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
