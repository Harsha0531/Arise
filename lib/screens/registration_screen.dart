import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class RegistrationScreen extends StatefulWidget {
  final Future<void> Function(AppUser user) onRegistered;

  const RegistrationScreen({
    super.key,
    required this.onRegistered,
  });

  @override
  State<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState
    extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isRegistering = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      final user = await UserService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        displayName: _displayNameController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      await widget.onRegistered(user);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration failed: $e',
          ),
        ),
      );

      setState(() {
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF4FC3F7),
                      size: 64,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'SYSTEM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4FC3F7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'AWAKEN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Create your player profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 40),

                    _field(
                      controller: _emailController,
                      label: 'EMAIL',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType:
                      TextInputType.emailAddress,
                      validator: (value) {
                        final text =
                            value?.trim() ?? '';

                        if (text.isEmpty) {
                          return 'Enter your email';
                        }

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(text)) {
                          return 'Enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    _passwordField(),

                    const SizedBox(height: 18),

                    _field(
                      controller: _displayNameController,
                      label: 'PLAYER NAME',
                      hint: 'Enter your name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        final text =
                            value?.trim() ?? '';

                        if (text.isEmpty) {
                          return 'Enter your player name';
                        }

                        if (text.length < 2) {
                          return 'Name must be at least 2 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    _field(
                      controller: _usernameController,
                      label: 'USERNAME',
                      hint: 'Choose a username',
                      icon: Icons.alternate_email,
                      validator: (value) {
                        final text =
                            value?.trim() ?? '';

                        if (text.isEmpty) {
                          return 'Choose a username';
                        }

                        if (text.length < 3) {
                          return 'Username must be at least 3 characters';
                        }

                        if (!RegExp(
                          r'^[a-zA-Z0-9_]+$',
                        ).hasMatch(text)) {
                          return 'Use only letters, numbers and _';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B101C),
                        borderRadius:
                        BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF1D2A42),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.cloud_done_outlined,
                            color: Color(0xFF4FC3F7),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your account is secured with Firebase '
                                  'Authentication. Your Arise player data '
                                  'will be associated with your account.',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                        _isRegistering
                            ? null
                            : _register,
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF4FC3F7),
                          foregroundColor: Colors.black,
                          disabledBackgroundColor:
                          const Color(0xFF26323D),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        child: _isRegistering
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                            : const Text(
                          'INITIALIZE SYSTEM',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'PASSWORD',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            color: Colors.white,
          ),
          validator: (value) {
            final text = value ?? '';

            if (text.isEmpty) {
              return 'Enter a password';
            }

            if (text.length < 6) {
              return 'Password must be at least 6 characters';
            }

            return null;
          },
          decoration: InputDecoration(
            hintText: 'Create a password',
            hintStyle: const TextStyle(
              color: Colors.white30,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFF4FC3F7),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword =
                  !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white54,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFF0B101C),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF1D2A42),
              ),
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF1D2A42),
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF4FC3F7),
                width: 1.5,
              ),
            ),
            errorBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
            focusedErrorBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.white30,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF4FC3F7),
            ),
            filled: true,
            fillColor: const Color(0xFF0B101C),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF1D2A42),
              ),
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF1D2A42),
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF4FC3F7),
                width: 1.5,
              ),
            ),
            errorBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
            focusedErrorBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}