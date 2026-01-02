// lib/screens/labour_dashboard.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LabourDashboard extends StatefulWidget {
  const LabourDashboard({super.key});

  @override
  State<LabourDashboard> createState() => _LabourDashboardState();
}

class _LabourDashboardState extends State<LabourDashboard> {
  final CameraService _cameraService = CameraService();

  bool _didInitArgs = false;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  bool _isLoadingSummary = false;
  bool _isLoadingTodayStatus = false;

  String _status = "Tap CHECK IN to start";
  String _location = "Getting location...";

  int? userId;
  int? labourId;
  String? role;
  int? contractorId; // <-- store contractorId here when fetched

  // Dashboard summary
  String? _labourName;
  String? _labourPhone;
  double? _dailyRate;
  bool? _isActive;
  String? _hireDate;

  // Today status
  bool? _todayCheckedIn;
  bool? _todayCheckedOut;
  String? _hoursWorked;

  bool get _isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();

    // Only initialize camera on mobile, not on Web
    if (!_isWeb) {
      _cameraService.initialize();
    }

    _updateLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitArgs) return;

    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    debugPrint('🔍 RAW LOGIN ARGS (LabourDashboard): $args');

    if (args != null) {
      userId = args['userId'] as int?;
      labourId = args['labourId'] as int? ?? args['labour_id'] as int?;
      role = args['role']?.toString();
      // allow contractorId to be passed in args if available
      contractorId = args['contractorId'] is int
          ? args['contractorId'] as int?
          : (args['contractor_id'] is int ? args['contractor_id'] as int? : contractorId);

      _status =
      "User: ${userId ?? '-'} | Labour: ${labourId ?? '-'} | Role: ${role ?? '-'}";

      if (labourId != null) {
        _loadDashboardSummary();
        _loadTodayStatus();
      }
    } else {
      _status = "❌ No login data received";
    }

    _didInitArgs = true;
    setState(() {});
  }

  // --------------------------------------------------------------------------
  // NEW: Open Leave Request — fetch contractorId if missing then navigate
  // --------------------------------------------------------------------------
  Future<void> _openLeaveRequestScreen() async {
    if (labourId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing labourId — cannot open leave screen'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('LeaveRequest: missing labourId');
      return;
    }

    // If we already have contractorId, just navigate
    if (contractorId != null) {
      Navigator.pushNamed(
        context,
        '/request_leave',
        arguments: {
          'labourId': labourId,
          'contractorId': contractorId,
        },
      );
      return;
    }

    // Otherwise fetch labour profile to get contractorId
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fetching profile...')),
      );
      final profile = await ApiService.getLabourProfile(labourId!);
      debugPrint('LeaveRequest: labour profile: $profile');

      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch profile')),
        );
        return;
      }

      // try multiple key names defensively
      final fetchedContractorId = profile['contractorId'] ??
          profile['contractor_id'] ??
          (profile['contractorId'] is int ? profile['contractorId'] : null);

      if (fetchedContractorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contractor ID not found in profile')),
        );
        debugPrint('LeaveRequest: contractorId missing in profile: $profile');
        return;
      }

      contractorId = (fetchedContractorId is int)
          ? fetchedContractorId
          : int.tryParse(fetchedContractorId.toString());

      if (contractorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid contractorId retrieved')),
        );
        return;
      }

      Navigator.pushNamed(
        context,
        '/request_leave',
        arguments: {
          'labourId': labourId,
          'contractorId': contractorId,
        },
      );
    } catch (e, st) {
      debugPrint('Error fetching labour profile for leave: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching profile')),
      );
    }
  }

  // --------------------------------------------------------------------------
  // DATA LOADERS
  // --------------------------------------------------------------------------
  Future<void> _loadDashboardSummary() async {
    if (labourId == null) return;
    setState(() => _isLoadingSummary = true);

    try {
      final data = await ApiService.getLabourDashboardSummary(labourId!);
      debugPrint('📊 Labour dashboard summary: $data');

      if (data != null && mounted) {
        setState(() {
          _labourName = data['name']?.toString();
          _labourPhone = data['phone']?.toString();
          _dailyRate = (data['dailyRate'] is num)
              ? (data['dailyRate'] as num).toDouble()
              : null;
          _isActive = data['isActive'] as bool?;
          _hireDate = data['hireDate']?.toString();
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading labour dashboard summary: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSummary = false);
      }
    }
  }

  Future<void> _loadTodayStatus() async {
    if (labourId == null) return;
    setState(() => _isLoadingTodayStatus = true);

    try {
      final data = await ApiService.getLabourTodayStatus(labourId!);
      debugPrint('📅 Today status: $data');

      if (data != null && mounted) {
        setState(() {
          _todayCheckedIn = data['todayCheckedIn'] as bool?;
          _todayCheckedOut = data['todayCheckedOut'] as bool?;
          _hoursWorked = data['hoursWorked']?.toString();
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading today status: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingTodayStatus = false);
      }
    }
  }

  Future<void> _updateLocation() async {
    try {
      final loc = await LocationService.getCurrentLocation(); // "lat,lng"
      if (!mounted) return;
      setState(() {
        _location = loc;
      });
    } catch (e) {
      debugPrint('Location error: $e');
      if (!mounted) return;
      setState(() {
        _location = "Location unavailable";
      });
    }
  }

  // --------------------------------------------------------------------------
  // PHOTO HELPER (WEB vs MOBILE)
  // --------------------------------------------------------------------------
  Future<String> _getAttendancePhoto({required bool isCheckIn}) async {
    // 1) Web: don't use real camera, just mock filename
    if (_isWeb) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      return isCheckIn ? 'web_checkin_$ts.jpg' : 'web_checkout_$ts.jpg';
    }

    // 2) Mobile: use real camera with fallback
    try {
      final photoPath = await _cameraService.capturePhoto();
      debugPrint('📸 Attendance photo captured: $photoPath');
      return photoPath;
    } catch (e) {
      debugPrint('📸 Camera failed: $e');
      final ts = DateTime.now().millisecondsSinceEpoch;
      return isCheckIn
          ? 'mobile_checkin_fallback_$ts.jpg'
          : 'mobile_checkout_fallback_$ts.jpg';
    }
  }

  // --------------------------------------------------------------------------
  // ✅ CHECK-IN
  // --------------------------------------------------------------------------
  Future<void> _checkIn() async {
    if (labourId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing labourId – cannot check in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCheckingIn = true);

    try {
      // 1) Get GPS as "lat,lng"
      final locString = await LocationService.getCurrentLocation();
      debugPrint('📍 Location string (IN): $locString');

      double latitude = 0;
      double longitude = 0;
      final parts = locString.split(',');
      if (parts.length == 2) {
        latitude = double.tryParse(parts[0].trim()) ?? 0;
        longitude = double.tryParse(parts[1].trim()) ?? 0;
      }

      if (mounted) {
        setState(() {
          _location = locString;
        });
      }

      // 2) Get photo path (web = fake, mobile = real/fallback)
      final photoPath = await _getAttendancePhoto(isCheckIn: true);

      // 3) Call API
      final result = await ApiService.checkIn(
        labourId!,
        photoPath,
        latitude,
        longitude,
      );

      debugPrint('✅ CHECKIN RESULT: $result');

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _status =
          "✅ Check-in successful at ${TimeOfDay.now().format(context)}";
          _isCheckingIn = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Check-in successful"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        _loadTodayStatus(); // refresh
      } else {
        setState(() {
          _status = "❌ Check-in failed (no response)";
          _isCheckingIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in failed – server error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Check-in error: $e');
      if (!mounted) return;
      setState(() {
        _isCheckingIn = false;
        _status = "❌ Check-in failed";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-in failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // ✅ CHECK-OUT
  // --------------------------------------------------------------------------
  Future<void> _checkOut() async {
    if (labourId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing labourId – cannot check out'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCheckingOut = true);

    try {
      // 1) Get GPS as "lat,lng"
      final locString = await LocationService.getCurrentLocation();
      debugPrint('📍 Location string (OUT): $locString');

      double latitude = 0;
      double longitude = 0;
      final parts = locString.split(',');
      if (parts.length == 2) {
        latitude = double.tryParse(parts[0].trim()) ?? 0;
        longitude = double.tryParse(parts[1].trim()) ?? 0;
      }

      if (mounted) {
        setState(() {
          _location = locString;
        });
      }

      // 2) Get photo path (web = fake, mobile = real/fallback)
      final photoPath = await _getAttendancePhoto(isCheckIn: false);

      // 3) Call API
      final result = await ApiService.checkOut(
        labourId!,
        photoPath,
        latitude,
        longitude,
      );

      debugPrint('✅ CHECKOUT RESULT: $result');

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _status =
          "✅ Check-out successful at ${TimeOfDay.now().format(context)}";
          _isCheckingOut = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Check-out successful"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // refresh today's status
        _loadTodayStatus();
      } else {
        setState(() {
          _status = "❌ Check-out failed (no response)";
          _isCheckingOut = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out failed – server error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Check-out error: $e');
      if (!mounted) return;
      setState(() {
        _isCheckingOut = false;
        _status = "❌ Check-out failed";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-out failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // UI HELPERS
  // --------------------------------------------------------------------------
  Widget _buildHeaderCard() {
    final displayName = _labourName ??
        (labourId != null
            ? "Labour #$labourId"
            : (userId != null ? "User #$userId" : "Labour"));
    final todayStr = DateTime.now().toLocal().toString().split(' ').first;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labourPhone ?? 'Phone not set',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (role != null)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Today: $todayStr",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 14,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            title: "Daily Rate",
            value: _isLoadingSummary
                ? "..."
                : (_dailyRate != null
                ? "₹${_dailyRate!.toStringAsFixed(0)}"
                : "N/A"),
            icon: Icons.currency_rupee,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoChip(
            title: "Status",
            value: _isLoadingSummary
                ? "..."
                : (_isActive == null
                ? "Unknown"
                : (_isActive! ? "Active" : "Inactive")),
            icon: _isActive == true ? Icons.check_circle : Icons.pause_circle,
            iconColor: _isActive == true ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildHireDateCard() {
    return _InfoCard(
      title: "Joined On",
      subtitle: _isLoadingSummary ? "Loading..." : (_hireDate ?? "Not available"),
      leadingIcon: Icons.badge,
    );
  }

  Widget _buildTodayStatusCard() {
    String checkInText =
    _todayCheckedIn == true ? "Checked In" : "Not Checked In";
    String checkOutText =
    _todayCheckedOut == true ? "Checked Out" : "Not Checked Out";

    Color checkInColor =
    _todayCheckedIn == true ? Colors.green.shade600 : Colors.grey.shade500;
    Color checkOutColor = _todayCheckedOut == true
        ? Colors.red.shade600
        : Colors.grey.shade500;

    return _InfoCard(
      title: "Today's Attendance",
      isLoading: _isLoadingTodayStatus,
      subtitle: _hoursWorked != null ? "Hours: $_hoursWorked" : "No data",
      leadingIcon: Icons.today,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.login, size: 16, color: checkInColor),
              const SizedBox(width: 4),
              Text(
                checkInText,
                style: TextStyle(fontSize: 12, color: checkInColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 16, color: checkOutColor),
              const SizedBox(width: 4),
              Text(
                checkOutText,
                style: TextStyle(fontSize: 12, color: checkOutColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Labour Dashboard'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _updateLocation();
              _loadDashboardSummary();
              _loadTodayStatus();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Debug info'),
                  content: Text(
                    'userId: $userId\n'
                        'labourId: $labourId\n'
                        'contractorId: $contractorId\n'
                        'role: $role\n'
                        'location: $_location\n'
                        'status: $_status',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildSummaryRow(),
              const SizedBox(height: 12),
              _buildHireDateCard(),
              const SizedBox(height: 12),
              _buildTodayStatusCard(),
              const SizedBox(height: 16),

              // LOCATION CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BIG CHECK-IN / CHECK-OUT BUTTONS
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 120,
                      child: ElevatedButton(
                        onPressed:
                        _isCheckingIn || labourId == null ? null : _checkIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 6,
                          shadowColor: Colors.green.shade300,
                        ),
                        child: _isCheckingIn
                            ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 10),
                            Text(
                              'Checking in...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                            : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 38, color: Colors.white),
                            SizedBox(height: 6),
                            Text(
                              'CHECK IN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Camera + GPS',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 120,
                      child: ElevatedButton(
                        onPressed: _isCheckingOut || labourId == null
                            ? null
                            : _checkOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 6,
                          shadowColor: Colors.red.shade300,
                        ),
                        child: _isCheckingOut
                            ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 10),
                            Text(
                              'Checking out...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                            : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 38, color: Colors.white),
                            SizedBox(height: 6),
                            Text(
                              'CHECK OUT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Camera + GPS',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // BOTTOM BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/attendance_history',
                        arguments: {
                          'labourId': labourId,
                        },
                      ),
                      icon: const Icon(Icons.history),
                      label: const Text('Attendance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openLeaveRequestScreen, // <-- updated
                      icon: const Icon(Icons.request_page),
                      label: const Text('Leave'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // STATUS TEXT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// SMALL REUSABLE WIDGETS
// --------------------------------------------------------------------------
class _InfoChip extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const _InfoChip({
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor ?? Colors.green.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final Widget? trailing;
  final bool isLoading;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    this.trailing,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              leadingIcon,
              color: Colors.green.shade700,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isLoading
                ? const LinearProgressIndicator(minHeight: 4)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424242),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
