import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/auth_validators.dart';
import '../widgets/custom_auth_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? error.code)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            onPressed: _isLoading
                ? null
                : () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text(
            'Register',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 18),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: validateEmail,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: _register,
                              validator: validateRegistrationPassword,
                            ),
                            const SizedBox(height: 26),
                            CustomAuthButton(
                              label: 'Register',
                              isLoading: _isLoading,
                              onPressed: _register,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18, top: 28),
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.purple,
                          ),
                          child: const Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
