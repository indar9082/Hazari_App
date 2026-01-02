// lib/services/api_service.dart
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class ApiService {
  // Use http://10.0.2.2:8080/api for Android emulator if needed
  static const String baseUrl = 'http://localhost:8080/api';

  static String? _token; // Store login token globally for authenticated calls

  // ---- Token helpers (optional) ----
  static void setToken(String? token) => _token = token;
  static String? getToken() => _token;

  // --------------------------------------------------------------------------
  // LOGIN → Stores token and returns decoded body map (if any)
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username.trim(),
          'password': password,
        }),
      );

      debugPrint("🔐 LOGIN RESPONSE: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          _token = data['token']?.toString();
          return data;
        } else {
          return {'result': data};
        }
      }
    } catch (e, st) {
      debugPrint('❌ Login API Error: $e\n$st');
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // REGISTER
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> register(
      String username, String password, String phone, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'phone': phone,
          'role': role,
        }),
      );

      debugPrint("📝 REGISTER RESPONSE: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return decoded is Map<String, dynamic> ? decoded : {'result': decoded};
      }
    } catch (e, st) {
      debugPrint('❌ Register API Error: $e\n$st');
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // GET USER PROFILE (example returning User model)
  // --------------------------------------------------------------------------
  static Future<User?> getUserProfile(int userId) async {
    try {
      debugPrint('GET $baseUrl/user/$userId');

      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      debugPrint("👤 PROFILE RESPONSE: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return User.fromJson(decoded);
        }
      } else {
        debugPrint('❌ Profile failed: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('❌ Profile API Error: $e\n$st');
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // CHECK-IN
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> checkIn(
      int labourId, String photoPath, double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/labour/checkin'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'labourId': labourId,
          'photoPath': photoPath,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      debugPrint("CHECKIN => ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = _safeDecode(response.body);
        return decoded;
      } else {
        debugPrint('❌ Check-in HTTP error: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint("❌ Check-in Error: $e\n$st");
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // CHECK-OUT
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> checkOut(
      int labourId, String photoPath, double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/labour/checkout/$labourId'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'photoPath': photoPath,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      debugPrint("CHECKOUT => ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = _safeDecode(response.body);
        return decoded;
      } else {
        debugPrint('❌ Check-out HTTP error: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint("❌ Check-out Error: $e\n$st");
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // LEAVE: create request
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> postLeaveRequest(Map<String, dynamic> payload) async {
    try {
      final url = Uri.parse('$baseUrl/labour/leaves');
      debugPrint('POST LEAVE URL: $url');
      debugPrint('POST LEAVE payload: $payload');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: json.encode(payload),
      );

      debugPrint('POST LEAVE RESP: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _safeDecode(response.body);
      } else {
        debugPrint('postLeaveRequest failed: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('Error posting leave request: $e\n$st');
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // GET LABOUR PROFILE (single robust method - tries common endpoints)
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> getLabourProfile(int labourId) async {
    try {
      final candidates = [
        '$baseUrl/labour/profile/$labourId',
        '$baseUrl/labour/$labourId',
        '$baseUrl/labour/by-id/$labourId',
        '$baseUrl/labour/profile?labourId=$labourId',
      ];

      for (final u in candidates) {
        final uri = Uri.parse(u);
        debugPrint('GET LABOUR PROFILE: trying $uri');

        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (_token != null) 'Authorization': 'Bearer $_token',
          },
        );

        debugPrint('GET LABOUR PROFILE => ${response.statusCode} | ${response.body}');

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) return decoded;
          if (decoded is List && decoded.isNotEmpty && decoded[0] is Map<String, dynamic>) {
            return Map<String, dynamic>.from(decoded[0]);
          }
          return {'result': decoded};
        }
      }
    } catch (e, st) {
      debugPrint('Error in getLabourProfile: $e\n$st');
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // ADD LABOUR
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> addLabour({
    required String name,
    required String phone,
    required String aadhaarNumber,
    required double dailyRate,
    required int contractorId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/labour/add');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (_token != null) headers['Authorization'] = 'Bearer $_token';

      final body = json.encode({
        'name': name,
        'phone': phone,
        'aadhaarNumber': aadhaarNumber,
        'dailyRate': dailyRate,
        'contractorId': contractorId,
      });

      final response = await http.post(url, headers: headers, body: body);
      debugPrint('📨 ADD LABOUR RESP: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _safeDecode(response.body);
      }
    } catch (e, st) {
      debugPrint('❌ Add Labour Error: $e\n$st');
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // GET LABOURS FOR CONTRACTOR
  // --------------------------------------------------------------------------
  static Future<List<dynamic>> getLaboursForContractor(int contractorId) async {
    try {
      final url = Uri.parse('$baseUrl/labour/by-contractor/$contractorId');
      final headers = <String, String>{};
      if (_token != null) headers['Authorization'] = 'Bearer $_token';

      final response = await http.get(url, headers: headers);
      debugPrint('📨 GET LABOURS RESP: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List<dynamic>) return decoded;
      }
    } catch (e, st) {
      debugPrint('❌ Get Labours Error: $e\n$st');
    }
    return [];
  }

  // --------------------------------------------------------------------------
  // FORGOT PASSWORD
  // --------------------------------------------------------------------------
  static Future<String?> forgotPassword({
    required String username,
    required String phone,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/forgot-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'phone': phone,
          'newPassword': newPassword,
        }),
      );

      debugPrint('FORGOT PASSWORD => ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data['message']?.toString() ?? 'Password reset successful';
        } catch (_) {
          return response.body;
        }
      } else {
        return 'Error: ${response.body}';
      }
    } catch (e, st) {
      debugPrint('FORGOT PASSWORD ERROR: $e\n$st');
      return 'Error: $e';
    }
  }

  // --------------------------------------------------------------------------
  // Labour dashboard summary & today-status
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> getLabourDashboardSummary(int labourId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/labour/dashboard/$labourId'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) return _safeDecode(response.body);
    } catch (e, st) {
      debugPrint('❌ Error in getLabourDashboardSummary: $e\n$st');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getLabourTodayStatus(int labourId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/labour/today-status/$labourId'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) return _safeDecode(response.body);
    } catch (e, st) {
      debugPrint('❌ Error in getLabourTodayStatus: $e\n$st');
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // CONTRACTOR TODAY ATTENDANCE
  // --------------------------------------------------------------------------
  static Future<dynamic> getContractorTodayAttendance(int contractorId) async {
    try {
      final url = Uri.parse('$baseUrl/contractor/$contractorId/today-attendance');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      debugPrint('TODAY ATTENDANCE (CONTRACTOR) => ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e, st) {
      debugPrint('Error fetching contractor today attendance: $e\n$st');
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // Approve / Reject leave (contractor)
  // --------------------------------------------------------------------------
  static Future<bool> approveLeave(int leaveId) async {
    try {
      final url = Uri.parse('$baseUrl/contractor/leaves/$leaveId/approve');
      debugPrint('APPROVE LEAVE => $url');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      debugPrint('APPROVE LEAVE RESP: ${response.statusCode} | ${response.body}');
      return response.statusCode == 200;
    } catch (e, st) {
      debugPrint('Error approveLeave: $e\n$st');
      return false;
    }
  }

  static Future<bool> rejectLeave(int leaveId, {String? reason}) async {
    try {
      final uri = Uri.parse('$baseUrl/contractor/leaves/$leaveId/reject${reason != null ? "?reason=${Uri.encodeComponent(reason)}" : ""}');
      debugPrint('REJECT LEAVE => $uri');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      debugPrint('REJECT LEAVE RESP: ${response.statusCode} | ${response.body}');
      return response.statusCode == 200;
    } catch (e, st) {
      debugPrint('Error rejectLeave: $e\n$st');
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // Utility: decode JSON safely into Map<String, dynamic>
  // --------------------------------------------------------------------------
  static Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'result': decoded};
    } catch (_) {
      return {'result': body};
    }
  }

  // --------------------------------------------------------------------------
  // Clear stored token (logout)
  // --------------------------------------------------------------------------
  static void clearToken() {
    _token = null;
  }
}
