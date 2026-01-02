// lib/models/attendance.dart
class Attendance {
  final int id;
  final int userId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String? checkInPhotoPath;
  final String? checkOutPhotoPath;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String status;

  Attendance({
    required this.id,
    required this.userId,
    required this.checkInTime,
    this.checkOutTime,
    this.checkInPhotoPath,
    this.checkOutPhotoPath,
    this.checkInLocation,
    this.checkOutLocation,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      checkInTime: DateTime.parse(json['checkInTime']),
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime']) : null,
      checkInPhotoPath: json['checkInPhotoPath'],
      checkOutPhotoPath: json['checkOutPhotoPath'],
      checkInLocation: json['checkInLocation'],
      checkOutLocation: json['checkOutLocation'],
      status: json['status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'checkInPhotoPath': checkInPhotoPath,
      'checkOutPhotoPath': checkOutPhotoPath,
      'checkInLocation': checkInLocation,
      'checkOutLocation': checkOutLocation,
    };
  }

  String get duration {
    if (checkOutTime == null) return 'Pending';
    final hours = checkOutTime!.difference(checkInTime).inHours;
    final minutes = checkOutTime!.difference(checkInTime).inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
