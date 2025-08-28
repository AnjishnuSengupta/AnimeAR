import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth controller for errors
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.when(
        data: (_) {
          // Don't redirect here, let the authStateProvider handle it
        },
        loading: () {},
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    // Listen to actual auth state changes for navigation
    ref.listen(authStateProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            // User is authenticated, navigate to home
            context.go(AppConstants.homeRoute);
          }
        },
        loading: () {},
        error: (error, _) {
          // Auth state errors are handled by the controller listener above
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildForm(),
                const SizedBox(height: 24),
                _buildSignInButton(isLoading),
                const SizedBox(height: 16),
                _buildToggleButton(),
                const SizedBox(height: 32),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildGoogleSignInButton(isLoading),
                if (!_isSignUp) ...[
                  const SizedBox(height: 24),
                  _buildForgotPasswordButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.camera_alt, size: 40, color: Colors.white),
        ).animate().scale(duration: AppConstants.mediumAnimation).fadeIn(),
        const SizedBox(height: 24),
        Text(
              _isSignUp ? 'Create Account' : 'Welcome Back',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            )
            .animate(delay: 200.ms)
            .slideY(begin: 1, end: 0)
            .fadeIn(duration: AppConstants.mediumAnimation),
        const SizedBox(height: 8),
        Text(
              _isSignUp
                  ? 'Start your AR anime journey'
                  : 'Sign in to continue your adventure',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            )
            .animate(delay: 400.ms)
            .slideY(begin: 1, end: 0)
            .fadeIn(duration: AppConstants.mediumAnimation),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        if (_isSignUp)
          CustomTextField(
                controller: _nameController,
                labelText: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              )
              .animate(delay: 600.ms)
              .slideX(begin: -1, end: 0)
              .fadeIn(duration: AppConstants.shortAnimation),
        if (_isSignUp) const SizedBox(height: 16),
        CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            )
            .animate(delay: _isSignUp ? 700.ms : 600.ms)
            .slideX(begin: -1, end: 0)
            .fadeIn(duration: AppConstants.shortAnimation),
        const SizedBox(height: 16),
        CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your password';
                }
                if (_isSignUp && value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            )
            .animate(delay: _isSignUp ? 800.ms : 700.ms)
            .slideX(begin: -1, end: 0)
            .fadeIn(duration: AppConstants.shortAnimation),
      ],
    );
  }

  Widget _buildSignInButton(bool isLoading) {
    return LoadingButton(
          onPressed: isLoading ? null : _handleSignIn,
          isLoading: isLoading,
          child: Text(_isSignUp ? 'Create Account' : 'Sign In'),
        )
        .animate(delay: _isSignUp ? 900.ms : 800.ms)
        .slideY(begin: 1, end: 0)
        .fadeIn(duration: AppConstants.shortAnimation);
  }

  Widget _buildToggleButton() {
    return TextButton(
          onPressed: () {
            setState(() {
              _isSignUp = !_isSignUp;
            });
          },
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: _isSignUp
                      ? 'Already have an account? '
                      : "Don't have an account? ",
                ),
                TextSpan(
                  text: _isSignUp ? 'Sign In' : 'Sign Up',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: _isSignUp ? 1000.ms : 900.ms)
        .fadeIn(duration: AppConstants.shortAnimation);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: Theme.of(context).textTheme.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleSignInButton(bool isLoading) {
    return OutlinedButton.icon(
          onPressed: isLoading ? null : _handleGoogleSignIn,
          icon: const Icon(Icons.g_mobiledata),
          label: Text(
            _isSignUp ? 'Sign up with Google' : 'Sign in with Google',
          ),
        )
        .animate(delay: _isSignUp ? 1100.ms : 1000.ms)
        .slideY(begin: 1, end: 0)
        .fadeIn(duration: AppConstants.shortAnimation);
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: _handleForgotPassword,
      child: const Text('Forgot Password?'),
    ).animate(delay: 1100.ms).fadeIn(duration: AppConstants.shortAnimation);
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(authControllerProvider.notifier);

    if (_isSignUp) {
      await authController.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    } else {
      await authController.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authController = ref.read(authControllerProvider.notifier);
    await authController.signInWithGoogle();
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address first')),
      );
      return;
    }

    final authController = ref.read(authControllerProvider.notifier);
    await authController.resetPassword(_emailController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    }
  }
}
