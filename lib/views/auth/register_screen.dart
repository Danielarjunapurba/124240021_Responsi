import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    _authController.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardTheme.color ?? colorScheme.surface;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Baru')),
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.16),
                    colorScheme.primary.withValues(alpha: 0),
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
                  vertical: 18,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppTheme.brandGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white24,
                              child: Icon(
                                Icons.person_add_alt_1_rounded,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Buat Akun',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Lengkapi data di bawah untuk menyimpan akun ke penyimpanan lokal.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
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
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Lengkap',
                                  hintText: 'Masukkan nama lengkap',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Nama lengkap wajib diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
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
                                  textInputAction: TextInputAction.next,
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
                              const SizedBox(height: 14),
                              Obx(
                                () => TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _authController
                                      .obscureConfirmPassword
                                      .value,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submitRegister(),
                                  decoration: InputDecoration(
                                    labelText: 'Konfirmasi Password',
                                    hintText: 'Ulangi password',
                                    prefixIcon: const Icon(
                                      Icons.lock_reset_rounded,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: _authController
                                          .toggleConfirmPasswordVisibility,
                                      icon: Icon(
                                        _authController
                                                .obscureConfirmPassword
                                                .value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Konfirmasi password wajib diisi';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Konfirmasi password tidak cocok';
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
                                        : _submitRegister,
                                    child: _authController.isLoading.value
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Daftar'),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Sudah ada Akunnya? ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Get.offNamed(AppRoutes.login),
                                    child: const Text(
                                      'Langsung Saja Login',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
