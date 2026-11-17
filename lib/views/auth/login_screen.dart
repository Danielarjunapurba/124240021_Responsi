import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    _authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardTheme.color ?? colorScheme.surface;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.20),
                    colorScheme.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -70,
            left: -90,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.secondary.withValues(alpha: 0.16),
                    colorScheme.secondary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            gradient: AppTheme.heroGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Responsi',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppConfig.appName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppConfig.appTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.adaptiveBorder(context),
                          ),
                          boxShadow: AppTheme.softShadow(context),
                        ),
                        padding: const EdgeInsets.all(22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Masuk ke Akun',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gunakan email dan password yang sudah terdaftar.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.62,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 22),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'nama@email.com',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Email wajib diisi';
                                  }
                                  if (!GetUtils.isEmail(text)) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              Obx(
                                () => TextFormField(
                                  controller: _passwordController,
                                  obscureText:
                                      _authController.obscurePassword.value,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submitLogin(),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Minimal 6 karakter',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: _authController
                                          .togglePasswordVisibility,
                                      icon: Icon(
                                        _authController.obscurePassword.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    final text = value ?? '';
                                    if (text.isEmpty) {
                                      return 'Password wajib diisi';
                                    }
                                    if (text.length < 6) {
                                      return 'Password minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 22),
                              Obx(
                                () => SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _authController.isLoading.value
                                        ? null
                                        : _submitLogin,
                                    child: _authController.isLoading.value
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Login'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun kah? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed(AppRoutes.register),
                            child: const Text(
                              'Daftar Dulu',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
