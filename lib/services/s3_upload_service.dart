import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mygate_coepd/services/api_service.dart';

/// S3UploadService
///
/// Upload flow:
///  Flutter → POST /api/upload/file (multipart) → PHP backend → S3
///
/// The PHP backend handles the AWS signing and uploads to S3.
/// This is the most reliable approach — no presigned URL signature issues.
class S3UploadService {
  static final S3UploadService _instance = S3UploadService._internal();
  factory S3UploadService() => _instance;
  S3UploadService._internal();

  final ApiService _api = ApiService();

  // ── Folder constants ──────────────────────────────────────────────────────
  static const String folderProfiles  = 'profiles';
  static const String folderVehicles  = 'vehicles';
  static const String folderPets      = 'pets';
  static const String folderVisitors  = 'visitors';
  static const String folderFamily    = 'family';
  static const String folderCommunity = 'community';

  /// Upload [file] to S3 via the backend and return the permanent public URL.
  /// Throws a descriptive [Exception] on any failure.
  Future<String> uploadImage(File file, {String folder = folderProfiles}) async {
    final fileName = file.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      'folder': folder,
    });

    final Response resp;
    try {
      resp = await _api.dio.post(
        '/api/upload/file',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception('Upload failed: $msg');
    }

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      final msg = resp.data?['message'] ?? 'Upload failed (HTTP ${resp.statusCode})';
      throw Exception(msg);
    }

    if (resp.data?['status'] != true) {
      final msg = resp.data?['message'] ?? 'Upload failed';
      throw Exception(msg);
    }

    final url = resp.data['data']?['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('No URL returned from upload');
    }

    return url;
  }
}
