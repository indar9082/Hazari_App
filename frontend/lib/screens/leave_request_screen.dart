import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  final int? labourId;
  final int? contractorId;

  const LeaveRequestScreen({super.key, this.labourId, this.contractorId});

  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  int? _labourId;
  int? _contractorId;

  @override
  void initState() {
    super.initState();
    _labourId = widget.labourId;
    _contractorId = widget.contractorId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_labourId == null || _contractorId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        _labourId ??= (args['labourId'] is int) ? args['labourId'] : int.tryParse('${args['labourId']}');
        _contractorId ??= (args['contractorId'] is int) ? args['contractorId'] : int.tryParse('${args['contractorId']}');
      }
    }
  }

  Future<void> _pickStartDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _pickEndDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _endDate = d);
  }

  Future<void> _submit() async {
    if (_labourId == null || _contractorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Missing labourId or contractorId')));
      debugPrint('LeaveRequestScreen: missing labourId/contractorId. labourId=$_labourId contractorId=$_contractorId');
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select start and end dates')));
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date must be same or after start date')));
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      'labourId': _labourId,
      'contractorId': _contractorId,
      'startDate': _startDate!.toIso8601String().split('T')[0],
      'endDate': _endDate!.toIso8601String().split('T')[0],
      'reason': _reasonController.text.trim(),
    };

    debugPrint('LeaveRequestScreen: sending payload: $payload');

    try {
      final res = await ApiService.postLeaveRequest(payload);
      debugPrint('LeaveRequestScreen: API response: $res');

      if (res != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request sent')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send leave request')));
      }
    } catch (e, st) {
      debugPrint('LeaveRequestScreen: error while posting leave: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error sending leave request')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Widget _dateTile(String label, DateTime? value, VoidCallback onTap) {
    return ListTile(
      title: Text(value == null ? label : value.toLocal().toString().split(' ')[0]),
      trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: onTap),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Leave')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_labourId != null && _contractorId != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text('Labour ID: $_labourId | Contractor ID: $_contractorId', style: const TextStyle(color: Colors.grey)),
                ),
              _dateTile('Start Date', _startDate, _pickStartDate),
              _dateTile('End Date', _endDate, _pickEndDate),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter reason' : null,
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                  child: Text('Send Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
