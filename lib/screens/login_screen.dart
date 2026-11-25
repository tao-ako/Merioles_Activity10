import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../theme/app_theme.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_divider.dart';
import '../widgets/custom_auth_button.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      _showMessage(_firebaseErrorMessage(error));
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await GoogleSignIn.instance.initialize();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw Exception('Google Sign-In did not return an ID token.');
      }
      await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (error) {
      final details = error.description?.trim();
      final message = switch (error.code) {
        GoogleSignInExceptionCode.canceled =>
          'Google Sign-In was canceled or no account was available.',
        GoogleSignInExceptionCode.clientConfigurationError =>
          'Google Sign-In is not configured for this Android app.',
        GoogleSignInExceptionCode.providerConfigurationError =>
          'Google Sign-In provider configuration is incomplete.',
        GoogleSignInExceptionCode.uiUnavailable =>
          'Google Sign-In UI is unavailable. Try again.',
        _ => details ?? 'Google Sign-In failed.',
      };
      _showMessage(message);
    } on FirebaseAuthException catch (error) {
      _showMessage(_firebaseErrorMessage(error));
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Choose a password with at least 6 characters.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email or password is incorrect.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      'operation-not-allowed' =>
        'Enable Email/Password sign-in in Firebase Authentication.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openRegister() async {
    final registered = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (registered == true) {
      _showMessage('Account created. You can now sign in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        body: SafeArea(
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
                      const Padding(
                        padding: EdgeInsets.only(top: 38),
                        child: Text(
                          'Login_Merioles',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.purple,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
                              onFieldSubmitted: _signInWithEmail,
                              validator: validateRequired,
                            ),
                            const SizedBox(height: 22),
                            CustomAuthButton(
                              label: 'Login with Email',
                              isLoading: _isLoading,
                              onPressed: _signInWithEmail,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: AuthDivider(),
                            ),
                            CustomAuthButton(
                              label: 'Sign in with Google',
                              isLoading: _isLoading,
                              onPressed: _signInWithGoogle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18, top: 28),
                        child: TextButton(
                          onPressed: _isLoading ? null : _openRegister,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.purple,
                          ),
                          child: const Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              children: [
                                TextSpan(
                                  text: 'Register',
                                  style: TextStyle(fontWeight: FontWeight.w700),
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
