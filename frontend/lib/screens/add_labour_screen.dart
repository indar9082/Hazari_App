// lib/screens/add_labour_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddLabourScreen extends StatefulWidget {
  const AddLabourScreen({super.key});

  @override
  State<AddLabourScreen> createState() => _AddLabourScreenState();
}

class _AddLabourScreenState extends State<AddLabourScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _rateController = TextEditingController();

  bool _isLoading = false;
  int? _contractorId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _contractorId = args?['contractorId'] as int?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _saveLabour() async {
    if (_contractorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contractor ID not found')),
      );
      return;
    }

    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone are required')),
      );
      return;
    }

    final rateText = _rateController.text.trim();
    final dailyRate = double.tryParse(rateText.isEmpty ? '0' : rateText) ?? 0.0;

    setState(() => _isLoading = true);

    final result = await ApiService.addLabour(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      aadhaarNumber: _aadhaarController.text.trim(),
      dailyRate: dailyRate,
      contractorId: _contractorId!,
    );

    setState(() => _isLoading = false);

    if (result != null) {
      // Read credentials from backend response (with fallbacks)
      final username = result['username'] ?? _phoneController.text.trim();
      final password = result['password'] ?? '123456';

      // Show a dialog with login credentials
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Labour Added'),
          content: Text(
            'Labour has been added successfully.\n\n'
                'Login credentials:\n'
                'Username: $username\n'
                'Password: $password',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Go back to contractor dashboard and trigger refresh
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add labour'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Labour'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Labour Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _aadhaarController,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _rateController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Daily Rate (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLabour,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'SAVE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
