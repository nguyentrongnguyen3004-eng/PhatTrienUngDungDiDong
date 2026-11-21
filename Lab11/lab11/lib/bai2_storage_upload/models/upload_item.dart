import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

enum UploadStatus { uploading, paused, completed, canceled, error }

class UploadItem {
  final String id;
  final String fileName;
  final int totalBytes;
  int bytesTransferred;
  double progress; // 0.0 to 1.0
  UploadStatus status;
  String? downloadUrl;
  String? errorMessage;
  
  // Tham chiếu Firebase UploadTask thật (nếu có)
  UploadTask? uploadTask;
  StreamSubscription<TaskSnapshot>? subscription;
  
  // Dữ liệu giả lập timer (dành cho Demo Mock Mode)
  Timer? mockTimer;
  final Uint8List? fileBytes;
  final String? localPath;

  UploadItem({
    required this.id,
    required this.fileName,
    required this.totalBytes,
    this.bytesTransferred = 0,
    this.progress = 0.0,
    this.status = UploadStatus.uploading,
    this.downloadUrl,
    this.errorMessage,
    this.uploadTask,
    this.fileBytes,
    this.localPath,
  });

  String get formattedSize {
    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : 'FILE';
  }
}
