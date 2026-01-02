// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorText; // inline error message

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
// ✅ Handle Login
// ApiService.login should return: { "token": "...", "role": "CONTRACTOR", "userId": 1, "labourId": 5? }
// --------------------------------------------------------------------------
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorText = 'Please enter username and password';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null; // clear previous error
    });

    try {
      print('🔑 Trying login for $username');
      final result = await ApiService.login(username, password);

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _errorText = 'Invalid username or password';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ Read role, userId, labourId from server response
      final rawRole = result['role'];
      final role = (rawRole ?? '').toString().toUpperCase();
      final userId = result['userId'] as int?;
      final labourId = result['labourId'] as int?; // ⭐ for labour users

      print('✅ Login success: role=$role, userId=$userId, labourId=$labourId');

      if (userId == null) {
        setState(() {
          _errorText = 'Invalid user data from server';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid user data from server'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Decide dashboard based on role
      if (role.contains('CONTRACTOR')) {
        Navigator.pushReplacementNamed(
          context,
          '/contractor_dashboard',
          arguments: {
            'userId': userId,
            'role': role,
          },
        );
      } else if (role.contains('LABOUR')) {
        // Extra safety: make sure labourId is present
        if (labourId == null) {
          setState(() {
            _errorText = 'No labourId received for labour user';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login error: labourId missing from server'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        Navigator.pushReplacementNamed(
          context,
          '/labour_dashboard',
          arguments: {
            'userId': userId,
            'labourId': labourId, // ⭐ send to LabourDashboard
            'role': role,
          },
        );
      } else {
        setState(() {
          _errorText = 'Unknown role: $role';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unknown role: $role'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print('❌ Login error: $e');
      setState(() {
        _errorText = 'Something went wrong during login';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong during login'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot_password');
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: Colors.purple[700],
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to Hazari',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage labour attendance & payments',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text(
                '• Contractors: Login with your registered account.\n'
                    '• Labours: Login using username & password given by contractor.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Card with form
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Username
                      TextField(
                        controller: _usernameController,
                        decoration: _inputDecoration(
                          'Username',
                          Icons.person,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          'Password',
                          Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:
                          _isLoading ? null : _navigateToForgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ),

                      // Inline error
                      if (_errorText != null) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Labours: Ask your contractor for login details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Register (Contractor only)
              TextButton(
                onPressed: _isLoading ? null : _navigateToRegister,
                child: const Text(
                  'Create Contractor Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '(Labour should not register – use account created by contractor)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
