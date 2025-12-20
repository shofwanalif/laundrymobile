import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../widgets/common/input_field.dart';
import '../../../widgets/common/button.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/logo/cemerlaund.png',
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Akses penuh ke semua fitur dan layanan kami',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Input
                  EmailInputFb1(
                    inputController: _nameController,
                    label: 'Nama',
                    hintText: 'Masukkan nama lengkap',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Phone Input
                  EmailInputFb1(
                    inputController: _phoneController,
                    label: 'No. Telepon',
                    hintText: 'Masukkan nomor telepon',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Email Input
                  EmailInputFb1(
                    inputController: _emailController,
                    label: 'Email',
                    hintText: 'Masukkan email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  EmailInputFb1(
                    inputController: _passwordController,
                    label: 'Password',
                    hintText: 'Masukkan password',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 32),

                  // Register Button
                  Obx(
                    () => controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : Button(
                            text: 'Daftar',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                controller.register(
                                  _emailController.text,
                                  _passwordController.text,
                                  name: _nameController.text,
                                  phone: _phoneController.text,
                                );
                              }
                            },
                            width: double.infinity,
                            height: 50,
                            gradientColors: const [
                              Color(0xFF0072E5),
                              Color(0xFF75D8FC),
                            ],
                            borderRadius: 12,
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun? ",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Obx(
                        () => GestureDetector(
                          onTap: controller.isLoading.value
                              ? null
                              : controller.goToLogin,
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0072E5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
