import 'package:flutter/material.dart';
import '../models/de_tai_models.dart';
import '../services/api_service.dart';
import 'de_tai_list_sheet.dart';

class BaiTap02Screen extends StatefulWidget {
  const BaiTap02Screen({super.key});

  @override
  State<BaiTap02Screen> createState() => _BaiTap02ScreenState();
}

class _BaiTap02ScreenState extends State<BaiTap02Screen> {
  List<LoaiDeTai> _dsLoaiDeTai = [];
  List<ChuyenNganh> _dsChuyenNganh = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedMaLoai;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.fetchLoaiDeTai(),
        ApiService.fetchChuyenNganh(),
      ]);

      if (!mounted) return;
      setState(() {
        _dsLoaiDeTai = results[0] as List<LoaiDeTai>;
        _dsChuyenNganh = results[1] as List<ChuyenNganh>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _openDeTaiScreen({String? maLoai, String? maCN}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeTaiListScreen(
          dsLoaiDeTai: _dsLoaiDeTai,
          dsChuyenNganh: _dsChuyenNganh,
          initialMaLoai: maLoai,
          initialMaCN: maCN,
        ),
      ),
    ).then((_) => _fetchAllData());
  }

  void _showLoaiDeTaiDialog(LoaiDeTai loai) {
    setState(() => _selectedMaLoai = loai.maLoai);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF512DA8),
              foregroundColor: Colors.white,
              child: Text(
                loai.maLoai,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                loai.tenDayDu.isNotEmpty ? loai.tenDayDu : loai.tenLoai,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn chọn loại đề tài: ${loai.tenLoai}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF512DA8),
              ),
            ),
            const SizedBox(height: 10),
            if (loai.moTa.isNotEmpty) ...[
              Text(loai.moTa, style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 12),
            ],
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem('Số tín chỉ', '${loai.soTinChi} TC'),
                  _buildMetricItem('Thời gian', '${loai.thoiGianTuan} tuần'),
                  _buildMetricItem('Số đề tài', '${loai.soLuongDeTai} đề tài'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF512DA8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _openDeTaiScreen(maLoai: loai.maLoai);
            },
            icon: const Icon(Icons.list_alt, size: 18),
            label: Text('Xem ${loai.soLuongDeTai} đề tài'),
          ),
        ],
      ),
    );
  }

  void _showChuyenNganhDialog(ChuyenNganh cn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Thông báo',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn chọn ${cn.maThongBao.isNotEmpty ? cn.maThongBao : cn.maCN}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Chuyên ngành: ${cn.tenCN}',
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(cn.moTa, style: const TextStyle(fontSize: 13.5, height: 1.4)),
            if (cn.truongBoMon.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Trưởng bộ môn: ${cn.truongBoMon}',
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Số đề tài trong CSDL: ${cn.soLuongDeTai} đề tài',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _openDeTaiScreen(
                maLoai: _selectedMaLoai,
                maCN: cn.maCN,
              );
            },
            icon: const Icon(Icons.menu_book, size: 18),
            label: const Text('Xem danh sách đề tài'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF512DA8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  void _showConfigApiDialog() {
    final controller = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cấu hình địa chỉ Web API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '• Android Emulator: http://10.0.2.2:5130/api\n'
              '• Windows / Web / iOS: http://localhost:5130/api',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Base URL API',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              ApiService.setCustomBaseUrl(controller.text);
              Navigator.pop(ctx);
              _fetchAllData();
            },
            child: const Text('Lưu & Kết nối'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBanner(String title, {Widget? trailing}) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF039BE5), // Màu xanh dương chuẩn hình mẫu trang 20
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF9A00), // Màu cam vàng chuẩn hình mẫu
        foregroundColor: Colors.black87,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black87),
          tooltip: 'Trang chủ',
          onPressed: () {
            setState(() => _selectedMaLoai = null);
            _fetchAllData();
          },
        ),
        title: const Text(
          'ListView Demo',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _openDeTaiScreen(),
            icon: const Icon(Icons.library_books, color: Colors.black87, size: 19),
            label: const Text(
              'Đề tài',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cấu hình địa chỉ API',
            icon: const Icon(Icons.settings_ethernet, color: Colors.black87),
            onPressed: _showConfigApiDialog,
          ),
          IconButton(
            tooltip: 'Tải lại dữ liệu từ SQL Server',
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _fetchAllData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF512DA8)),
                  SizedBox(height: 14),
                  Text('Đang tải dữ liệu từ SQL Server Web API...'),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. BANNER: Chọn loại đề tài
                    _buildSectionBanner(
                      'Chọn loại đề tài',
                      trailing: _selectedMaLoai != null
                          ? InkWell(
                              onTap: () => setState(() => _selectedMaLoai = null),
                              child: const Text(
                                'Bỏ chọn',
                                style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),

                    // Hàng các nút tròn màu tím: Đồ án | KLKS | Luận văn | Khác
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _dsLoaiDeTai.map((loai) {
                          final isSelected = _selectedMaLoai == loai.maLoai;
                          return GestureDetector(
                            onTap: () => _showLoaiDeTaiDialog(loai),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF311B92)
                                    : const Color(0xFF512DA8), // Tím đậm như mẫu
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFFFFB300),
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  loai.tenLoai,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // 2. BANNER: Chọn chuyên ngành thực hiện
                    _buildSectionBanner(
                      'Chọn chuyên ngành thực hiện',
                      trailing: Text(
                        '${_dsChuyenNganh.length} chuyên ngành',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Danh sách chuyên ngành lấy từ SQL Server
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        itemCount: _dsChuyenNganh.length,
                        itemBuilder: (context, index) {
                          final cn = _dsChuyenNganh[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7D4C8), // Nền xám kem chuẩn hình mẫu
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.black87,
                                width: 1.1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              leading: const Icon(
                                Icons.home,
                                color: Colors.black87,
                                size: 26,
                              ),
                              title: Text(
                                cn.tenCN,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  cn.moTa,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward,
                                color: Colors.black87,
                                size: 22,
                              ),
                              onTap: () => _showChuyenNganhDialog(cn),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Không thể kết nối tới Web API',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang gọi tới: ${ApiService.baseUrl}\n\nChi tiết: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13.5),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _fetchAllData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
                OutlinedButton.icon(
                  onPressed: _showConfigApiDialog,
                  icon: const Icon(Icons.settings),
                  label: const Text('Đổi địa chỉ IP/Port'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
