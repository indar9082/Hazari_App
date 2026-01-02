// lib/services/camera_service.dart
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraController? _controller;
  Future<void>? _initializing;

  /// Initialize the camera (can be called from initState)
  Future<void> initialize() async {
    if (_initializing != null) {
      return _initializing!;
    }
    _initializing = _initInternal();
    return _initializing!;
  }

  Future<void> _initInternal() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception("No cameras available");
    }

    _controller = CameraController(
      cameras.first, // safer than cameras[1]
      ResolutionPreset.medium,
    );

    await _controller!.initialize();
  }

  /// Capture a photo and return its local file path.
  /// Throws on failure (caller can handle and use fallback).
  Future<String> capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await initialize();
    }

    try {
      return await _takePicture();
    } on CameraException catch (e) {
      print('CameraService CameraException: $e');
      rethrow;
    } catch (e) {
      print('CameraService ERROR: $e');
      rethrow;
    }
  }

  Future<String> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception("Camera is not initialized");
    }

    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile picture = await _controller!.takePicture();
    await picture.saveTo(filePath);

    return filePath;
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _initializing = null;
  }
}
