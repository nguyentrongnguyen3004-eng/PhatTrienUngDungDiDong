import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../models/upload_item.dart';
import '../services/storage_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final StorageService _storageService = StorageService.instance;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các item mẫu như trong PDF để thấy ngay giao diện chuẩn
    if (_storageService.items.isEmpty) {
      _storageService.seedSampleData();
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        final size = file.lengthSync() ?? (await file.length()) ?? bytes.length;
        await _storageService.startUpload(
          fileName: file.name,
          bytes: bytes,
          filePath: file.path,
          totalBytes: size,
          onUpdate: () {
            if (mounted) setState(() {});
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chọn file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _storageService.items;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.blueAccent, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Upload',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              child: Text(
                _isEditing ? 'Done' : 'Edit',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: items.isEmpty ? _buildEmptyView() : _buildUploadListView(items),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _pickAndUploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388AF6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Choose File',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Màn hình 1 (Trạng thái rỗng / chưa chọn file) theo mẫu hình bên trái (Trang 10)
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Graphic minh họa Cloud + File layers
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Layer cards background
                  Positioned(
                    top: 25,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        width: 75,
                        height: 95,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade200,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 45,
                    child: Transform.rotate(
                      angle: 0.25,
                      child: Container(
                        width: 75,
                        height: 95,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade200,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    child: Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade200,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Đám mây màu xanh nhạt
                  Positioned(
                    bottom: 25,
                    child: Container(
                      width: 170,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.lightBlue.shade100, Colors.blue.shade100],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFF388AF6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có file nào đang upload',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn "Choose File" bên dưới để tải lên Firebase Storage',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _storageService.seedSampleData();
                setState(() {});
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Hiện danh sách mẫu trong Slide'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF388AF6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Màn hình 2 (Danh sách file đang và đã upload) theo mẫu hình bên phải (Trang 10)
  Widget _buildUploadListView(List<UploadItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildUploadCard(item);
      },
    );
  }

  Widget _buildUploadCard(UploadItem item) {
    final ext = item.fileExtension;
    Color badgeColor;
    if (ext == 'AEP' || ext == 'AE') {
      badgeColor = const Color(0xFF9B51E0); // Tím
    } else if (ext == 'PSD' || ext == 'PS') {
      badgeColor = const Color(0xFF2F80ED); // Xanh dương
    } else if (ext == 'AI') {
      badgeColor = const Color(0xFFF2994A); // Cam
    } else {
      badgeColor = Colors.teal;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Badge loại file (AE, PS, AI, ...)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    ext.length > 3 ? ext.substring(0, 3) : ext,
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Tên file và dung lượng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.formattedSize}  •  ${(item.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),

              // Action buttons theo yêu cầu Trang 10 (pause, resume, stop/cancel, checkmark)
              _buildControlAction(item),

              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () {
                    _storageService.removeItem(item, () {
                      if (mounted) setState(() {});
                    });
                  },
                ),
            ],
          ),

          // Thanh tiến trình (%)
          if (item.status != UploadStatus.completed &&
              item.status != UploadStatus.canceled) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 5,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  item.status == UploadStatus.paused
                      ? Colors.amber
                      : const Color(0xFF388AF6),
                ),
              ),
            ),
          ],

          if (item.downloadUrl != null && !_isEditing) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.downloadUrl!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã copy Download URL vào Clipboard!')),
                );
              },
              child: Text(
                'Copy Download URL',
                style: TextStyle(fontSize: 11, color: Colors.blue.shade700, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlAction(UploadItem item) {
    switch (item.status) {
      case UploadStatus.completed:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Color(0xFF2E7D32),
            size: 20,
          ),
        );

      case UploadStatus.uploading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút Pause
            IconButton(
              icon: const Icon(Icons.pause_circle_filled, color: Color(0xFF388AF6), size: 28),
              onPressed: () {
                _storageService.pauseUpload(item, () {
                  if (mounted) setState(() {});
                });
              },
            ),
            // Nút Cancel / Stop
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 22),
              onPressed: () {
                _storageService.cancelUpload(item, () {
                  if (mounted) setState(() {});
                });
              },
            ),
          ],
        );

      case UploadStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút Play / Resume
            IconButton(
              icon: const Icon(Icons.play_circle_fill, color: Colors.amber, size: 28),
              onPressed: () {
                _storageService.resumeUpload(item, () {
                  if (mounted) setState(() {});
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 22),
              onPressed: () {
                _storageService.cancelUpload(item, () {
                  if (mounted) setState(() {});
                });
              },
            ),
          ],
        );

      case UploadStatus.canceled:
        return Text(
          'Đã hủy',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        );

      case UploadStatus.error:
        return const Icon(Icons.error, color: Colors.red, size: 22);
    }
  }
}
