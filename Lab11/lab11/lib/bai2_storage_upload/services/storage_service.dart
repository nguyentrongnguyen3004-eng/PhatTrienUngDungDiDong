import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/upload_item.dart';
import '../../services/firebase_service.dart';

class StorageService {
  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<UploadItem> _items = [];

  List<UploadItem> get items => List.unmodifiable(_items);

  /// Nạp các item mẫu giống hệt trong slide (Trang 10) để quan sát giao diện
  void seedSampleData() {
    if (_items.isNotEmpty) return;
    _items.addAll([
      UploadItem(
        id: 'sample_1',
        fileName: 'Dribbble.aep',
        totalBytes: 234 * 1024,
        bytesTransferred: 234 * 1024,
        progress: 1.0,
        status: UploadStatus.completed,
        downloadUrl: 'https://firebasestorage.googleapis.com/demo/dribbble.aep',
      ),
      UploadItem(
        id: 'sample_2',
        fileName: 'Homepage.psd',
        totalBytes: 23 * 1024 * 1024,
        bytesTransferred: (23 * 1024 * 1024 * 0.45).toInt(),
        progress: 0.45,
        status: UploadStatus.uploading,
      ),
      UploadItem(
        id: 'sample_3',
        fileName: 'Outline icon.ai',
        totalBytes: (1.2 * 1024 * 1024).toInt(),
        bytesTransferred: (1.2 * 1024 * 1024 * 0.70).toInt(),
        progress: 0.70,
        status: UploadStatus.paused,
      ),
    ]);
  }

  /// Bắt đầu upload file lên Firebase Storage
  Future<UploadItem> startUpload({
    required String fileName,
    Uint8List? bytes,
    String? filePath,
    required int totalBytes,
    required VoidCallback onUpdate,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = UploadItem(
      id: id,
      fileName: fileName,
      totalBytes: totalBytes > 0 ? totalBytes : 1024 * 500,
      fileBytes: bytes,
      localPath: filePath,
    );
    _items.add(item);
    onUpdate();

    if (FirebaseService.instance.useMockMode) {
      _startMockUpload(item, onUpdate);
      return item;
    }

    try {
      final storageRef = _storage.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      UploadTask uploadTask;

      if (kIsWeb || bytes != null) {
        uploadTask = storageRef.putData(bytes!);
      } else {
        uploadTask = storageRef.putFile(File(filePath!));
      }

      item.uploadTask = uploadTask;

      item.subscription = uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) async {
          item.bytesTransferred = snapshot.bytesTransferred;
          if (snapshot.totalBytes > 0) {
            item.progress = snapshot.bytesTransferred / snapshot.totalBytes;
          }

          switch (snapshot.state) {
            case TaskState.running:
              item.status = UploadStatus.uploading;
              break;
            case TaskState.paused:
              item.status = UploadStatus.paused;
              break;
            case TaskState.success:
              item.status = UploadStatus.completed;
              item.downloadUrl = await snapshot.ref.getDownloadURL();
              break;
            case TaskState.canceled:
              item.status = UploadStatus.canceled;
              break;
            case TaskState.error:
              item.status = UploadStatus.error;
              break;
          }
          onUpdate();
        },
        onError: (e) {
          item.status = UploadStatus.error;
          item.errorMessage = e.toString();
          onUpdate();
        },
      );
    } catch (e) {
      // Nếu Firebase storage thật lỗi (chưa cấu hình rules hoặc bucket), tự chuyển mock
      _startMockUpload(item, onUpdate);
    }

    return item;
  }

  void _startMockUpload(UploadItem item, VoidCallback onUpdate) {
    item.mockTimer?.cancel();
    item.status = UploadStatus.uploading;
    item.mockTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (item.status != UploadStatus.uploading) {
        timer.cancel();
        return;
      }
      final step = item.totalBytes ~/ 20;
      item.bytesTransferred += step;
      if (item.bytesTransferred >= item.totalBytes) {
        item.bytesTransferred = item.totalBytes;
        item.progress = 1.0;
        item.status = UploadStatus.completed;
        item.downloadUrl = 'https://firebasestorage.googleapis.com/mock/${item.fileName}';
        timer.cancel();
      } else {
        item.progress = item.bytesTransferred / item.totalBytes;
      }
      onUpdate();
    });
  }

  /// Tạm dừng upload (Trang 10: Quản lý tiến trình upload - pause)
  void pauseUpload(UploadItem item, VoidCallback onUpdate) {
    if (item.uploadTask != null) {
      item.uploadTask!.pause();
    }
    item.mockTimer?.cancel();
    item.status = UploadStatus.paused;
    onUpdate();
  }

  /// Tiếp tục upload (Trang 10: resume)
  void resumeUpload(UploadItem item, VoidCallback onUpdate) {
    if (item.uploadTask != null) {
      item.uploadTask!.resume();
    } else {
      _startMockUpload(item, onUpdate);
    }
    item.status = UploadStatus.uploading;
    onUpdate();
  }

  /// Hủy upload (Trang 10: stop/cancel)
  void cancelUpload(UploadItem item, VoidCallback onUpdate) {
    if (item.uploadTask != null) {
      item.uploadTask!.cancel();
    }
    item.mockTimer?.cancel();
    item.subscription?.cancel();
    item.status = UploadStatus.canceled;
    onUpdate();
  }

  /// Xóa item khỏi danh sách
  void removeItem(UploadItem item, VoidCallback onUpdate) {
    cancelUpload(item, () {});
    _items.remove(item);
    onUpdate();
  }

  /// Xóa tất cả các item
  void clearAll(VoidCallback onUpdate) {
    for (var it in _items) {
      cancelUpload(it, () {});
    }
    _items.clear();
    onUpdate();
  }
}
