import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms to continue')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
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
                GestureDetector(
                  onTap: () => context.go('/login'),
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

                ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  child: const Text(
                    'Create your\naccount ✨',
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
                  'Join thousands of skill-swappers',
                  style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 16),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 40),

                if (auth.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Text(
                      auth.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ).animate().shake(),
                  const SizedBox(height: 20),
                ],

                AppTextField(
                  label: 'Full Name',
                  hint: 'Alex Rivera',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Name is required';
                    if (v.length < 2) return 'Name is too short';
                    return null;
                  },
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
                const SizedBox(height: 20),

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
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 20),

                AppTextField(
                  label: 'Password',
                  hint: 'Min. 8 characters',
                  controller: _passwordCtrl,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                const SizedBox(height: 20),

                // Terms checkbox
                GestureDetector(
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _agreed ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _agreed ? AppColors.primary : AppColors.lightBorder,
                            width: 2,
                          ),
                        ),
                        child: _agreed
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall,
                            children: const [
                              TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),

                GradientButton(
                  label: 'Create Account',
                  onPressed: isLoading ? null : _signUp,
                  isLoading: isLoading,
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),

                // Stats row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('10K+', 'Members'),
                      _divider(),
                      _statItem('50K+', 'Swaps done'),
                      _divider(),
                      _statItem('4.8★', 'Avg rating'),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),

                Center(
                  child: Row(
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
                ).animate().fadeIn(delay: 450.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            fontSize: 18,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 30, color: AppColors.lightBorder);
  }
}
