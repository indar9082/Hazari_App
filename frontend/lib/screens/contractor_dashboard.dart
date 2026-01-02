// lib/screens/contractor_dashboard.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class ContractorDashboard extends StatefulWidget {
  const ContractorDashboard({super.key});

  @override
  _ContractorDashboardState createState() => _ContractorDashboardState();
}

class _ContractorDashboardState extends State<ContractorDashboard> {
  Map<String, dynamic>? _contractorProfile;
  List<dynamic> _pendingLeaves = [];
  List<Map<String, dynamic>> _labourSummary = [];
  List<Map<String, dynamic>> _addedLabours = []; // Added Labours List

  // ✅ TODAY'S ATTENDANCE
  List<dynamic> _todayAttendance = [];
  bool _showTodayAttendance = false;
  bool _isAttendanceLoading = false;

  bool _isLoading = true;
  String _error = '';
  int? userId;
  String? role;
  bool _didInitArgs = false;
  bool _showAllLabours = false; // Toggle labour list

  // ✅ For scrolling to Pending Leaves section
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _pendingLeavesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // NOTE: we will call _loadDashboard() after we get arguments in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitArgs) {
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        userId = args['userId'] as int?;
        role = args['role']?.toString();
        print('✅ CONTRACTOR: userId=$userId, role=$role');
      }

      _didInitArgs = true;
      _loadDashboard(); // now we know userId → load data
    }
  }

  // --------------------------------------------------------------------------
  // LOAD DASHBOARD
  // --------------------------------------------------------------------------
  Future<void> _loadDashboard() async {
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = 'No contractor userId found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // 1) Contractor profile
      final profileResponse = await http.get(
        Uri.parse('http://localhost:8080/api/contractor/profile/$userId'),
      );

      debugPrint(
        '📨 CONTRACTOR PROFILE RESP: ${profileResponse.statusCode} | ${profileResponse.body}',
      );

      if (profileResponse.statusCode == 200) {
        _contractorProfile = json.decode(profileResponse.body);
      } else {
        _error = 'Failed to load contractor profile';
      }

      // 2) Pending leaves
      final leavesResponse = await http.get(
        Uri.parse('http://localhost:8080/api/contractor/leaves/pending?contractorId=$userId'),
      );


      if (leavesResponse.statusCode == 200) {
        _pendingLeaves = json.decode(leavesResponse.body);
      } else {
        _error = 'Failed to load pending leaves';
      }

      // 3) Summary card (labours + payments)
      // You can adapt these if you have summary APIs
      // For now, we will make them mock or use simple transformations

      // 3a) My labours summary from your API service (if implemented)
      // (We can reuse existing getLaboursForContractor)
      try {
        final laboursJson = await ApiService.getLaboursForContractor(userId!);

        // Transform backend Labour -> UI map expected by My Labours section
        _addedLabours = laboursJson.map<Map<String, dynamic>>((labour) {
          final isActive = labour['active'] == true || labour['isActive'] == true;
          return {
            'id': labour['id'],
            'name': labour['name'] ?? 'Unknown',
            'phone': labour['phone'] ?? '',
            // Backend field is "active"/"isActive", UI expects "Active"/"Inactive"
            'status': isActive ? 'Active' : 'Inactive',
            // ✅ Now this will be real value from backend
            'days': labour['daysWorked'] ?? 0,
          };
        }).toList();
      } catch (e) {
        print('❌ Error loading labours for contractor: $e');
      }

      // 3b) Quick labour summary: total, active, inactive
      int activeCount = 0;
      int inactiveCount = 0;

      for (final labour in _addedLabours) {
        if (labour['status'] == 'Active') {
          activeCount++;
        } else {
          inactiveCount++;
        }
      }

      _labourSummary = [
        {
          'title': 'Total Labours',
          'value': _addedLabours.length.toString(),
          'color': Colors.blue,
        },
        {
          'title': 'Active Labours',
          'value': activeCount.toString(),
          'color': Colors.green,
        },
        {
          'title': 'Inactive Labours',
          'value': inactiveCount.toString(),
          'color': Colors.orange,
        },
      ];
    } catch (e) {
      _error = 'Something went wrong: $e';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --------------------------------------------------------------------------
  // ✅ TODAY'S ATTENDANCE LOADER
  // --------------------------------------------------------------------------
  Future<void> _loadTodayAttendance() async {
    if (userId == null) {
      // Just in case, we need contractor userId to filter
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing contractorId – cannot load attendance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAttendanceLoading = true;
    });

    try {
      // Use centralized ApiService which handles baseUrl & authorization headers
      final result = await ApiService.getContractorTodayAttendance(userId!);
      debugPrint('📅 TODAY ATTENDANCE (API) => $result');

      if (result != null) {
        // ApiService returns Map<String, dynamic>? — backend may return different shapes.
        // Normalize to List<dynamic> for UI consumption.

        List<dynamic> attendanceList = [];

        // If result is a Map and contains "attendance" list
        if (result is Map && result['attendance'] is List) {
          attendanceList = List<dynamic>.from(result['attendance']);
        }
        // If result is a Map but some other key contains list, try to find first list
        else if (result is Map && result.values.any((v) => v is List)) {
          final listVal = result.values.firstWhere((v) => v is List, orElse: () => []);
          attendanceList = List<dynamic>.from(listVal ?? []);
        }
        // If ApiService returns a List (defensive)
        else if (result is List) {
          attendanceList = List<dynamic>.from(result as Iterable);
        } else {
          // Unknown shape — try to safely parse if it's JSON-ish
          try {
            // sometimes ApiService might return a Map-like string; handle defensively
            final maybeJson = json.encode(result);
            final parsed = json.decode(maybeJson);
            if (parsed is List) {
              attendanceList = List<dynamic>.from(parsed);
            }
          } catch (_) {
            attendanceList = [];
          }
        }

        setState(() {
          _todayAttendance = attendanceList;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load today\'s attendance'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      debugPrint('❌ Error loading today attendance: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading attendance'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAttendanceLoading = false;
      });
    }
  }

  // ✅ Toggle attendance section
  Future<void> _toggleTodayAttendance() async {
    setState(() {
      _showTodayAttendance = !_showTodayAttendance;
    });

    if (_showTodayAttendance && _todayAttendance.isEmpty) {
      await _loadTodayAttendance();
    }
  }

  // ✅ Scroll to Pending Leaves section when "Leave Requests" is pressed
  void _scrollToPendingLeaves() {
    if (_pendingLeavesKey.currentContext != null) {
      Scrollable.ensureVisible(
        _pendingLeavesKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _approveLeave(int index) async {
    try {
      final leaveId = _pendingLeaves[index]['id'];
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/contractor/leaves/$leaveId/approve'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _pendingLeaves.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave approved')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to approve leave')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error approving leave')),
      );
    }
  }

  Future<void> _rejectLeave(int index) async {
    try {
      final leaveId = _pendingLeaves[index]['id'];
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/contractor/leaves/$leaveId/reject'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _pendingLeaves.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave rejected')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reject leave')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error rejecting leave')),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // UI HELPERS
  // --------------------------------------------------------------------------

  Widget _buildContractorHeader() {
    final name = _contractorProfile?['name'] ?? 'Contractor';
    // final company = _contractorProfile?['company'] ?? 'Company Name';
    final active = _contractorProfile?['active'] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade700,
            Colors.teal.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            child: Icon(Icons.person, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withOpacity(0.18)
                        : Colors.red.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    active ? 'Active Contractor' : 'Inactive Contractor',
                    style: TextStyle(
                      fontSize: 12,
                      color: active ? Colors.white : Colors.red[50],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: _labourSummary.map((summary) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      summary['title'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary['value'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: summary['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingLeavesSection() {
    return Container(
      key: _pendingLeavesKey,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Leave Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_pendingLeaves.isEmpty)
            const Text('No pending leave requests')
          else
            ..._pendingLeaves.asMap().entries.map(
                  (entry) {
                final index = entry.key;
                final leave = entry.value;
                final labourName =
                    leave['labour']?['name'] ?? 'Labour ID: ${leave['labour']?['id']}';

                return Card(
                  child: ListTile(
                    title: Text(labourName),
                    subtitle: Text(
                      'From: ${leave['startDate']} To: ${leave['endDate']}\nReason: ${leave['reason']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveLeave(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectLeave(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAddedLaboursSection() {
    if (!_showAllLabours) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Labours (${_addedLabours.length})',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._addedLabours.map(
              (labour) => Card(
            child: ListTile(
              title: Text(labour['name'] ?? 'Unnamed Labour'),
              subtitle: Text('Phone: ${labour['phone'] ?? ''}'),
              trailing: Text(
                labour['status'] ?? 'Unknown',
                style: TextStyle(
                  color: (labour['status'] == 'Active') ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayAttendanceSection() {
    if (!_showTodayAttendance) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Attendance (${_todayAttendance.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_isAttendanceLoading)
          const Center(child: CircularProgressIndicator())
        else if (_todayAttendance.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: const [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text('No attendance data for today'),
                ],
              ),
            ),
          )
        else
          ..._todayAttendance.map(
                (att) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (att['status'] == 'Present') ? Colors.green[100] : Colors.red[100],
                  child: Icon(
                    (att['status'] == 'Present') ? Icons.check : Icons.close,
                    color: (att['status'] == 'Present') ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                title: Text(
                  att['labourName'] ?? 'Labour ID: ${att['labourId'] ?? ''}',
                ),
                subtitle: Text(
                  'Status: ${att['status'] ?? ''}'
                      '${att['checkIn'] != null ? '\nIn: ${att['checkIn']}' : ''}'
                      '${att['checkOut'] != null ? ' | Out: ${att['checkOut']}' : ''}',
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Contractor Dashboard'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              _buildContractorHeader(),
              const SizedBox(height: 16),

              // SUMMARY CARDS
              if (_labourSummary.isNotEmpty) _buildSummaryCards(),
              const SizedBox(height: 20),

              // QUICK ACTIONS - ROW 1
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/add_labour',
                          arguments: {'contractorId': userId},
                        );
                      },
                      icon: const Icon(Icons.group_add),
                      label: const Text('Add Labour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/payment',
                          arguments: {'contractorId': userId},
                        );
                      },
                      icon: const Icon(Icons.payments),
                      label: const Text('Payments'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // QUICK ACTIONS - ROW 2 (Leave Requests + Today Attendance)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _scrollToPendingLeaves,
                      icon: const Icon(Icons.note_alt),
                      label: const Text('Leave Requests'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleTodayAttendance,
                      icon: const Icon(Icons.today),
                      label: Text(
                        _showTodayAttendance ? 'Hide Attendance' : 'Today Attendance',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 1. PENDING LEAVES
              _buildPendingLeavesSection(),
              const SizedBox(height: 24),

              // 2. TODAY'S ATTENDANCE (Toggle section)
              _buildTodayAttendanceSection(),
              const SizedBox(height: 24),

              // 3. SHOW ALL ADDED LABOURS (Toggle)
              Row(
                children: [
                  Text(
                    'My Labours',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllLabours = !_showAllLabours;
                      });
                    },
                    child: Text(
                      _showAllLabours ? 'Hide List' : 'Show All',
                      style: TextStyle(
                        color: _showAllLabours ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAddedLaboursSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
