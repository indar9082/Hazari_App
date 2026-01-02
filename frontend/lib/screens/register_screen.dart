// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorText;

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (username.isEmpty || phone.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() {
        _errorText = 'Please fill all fields';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Phone validation: 10 digits
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(phone)) {
      setState(() {
        _errorText = 'Please enter a valid 10-digit phone number';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirm) {
      setState(() {
        _errorText = 'Passwords do not match';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // Role is now ALWAYS "CONTRACTOR"
      final result = await ApiService.register(
        username,
        password,
        phone,
        "CONTRACTOR",
      );

      if (result != null) {
        final message = result['message'] ?? 'Registration successful!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );

        // Navigate back to login
        Navigator.popUntil(context, ModalRoute.withName('/login'));
        _clearForm();
      } else {
        setState(() {
          _errorText = 'Registration failed. Please try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorText = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  void _clearForm() {
    _usernameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _errorText = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Icon(Icons.person_add, size: 80, color: Colors.green[700]),
            const SizedBox(height: 16),
            const Text(
              'Create Contractor Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage labour attendance & payments',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Username
            _buildInputField(_usernameController, 'Username', Icons.person),
            const SizedBox(height: 16),

            // Phone
            _buildInputField(
              _phoneController,
              'Phone (10 digits)',
              Icons.phone,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Password with toggle
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
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
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password with toggle
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 8),

            // Inline error
            if (_errorText != null) ...[
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 24),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: _isLoading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text('Creating Account...', style: TextStyle(fontSize: 18)),
                  ],
                )
                    : const Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already have account? Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
