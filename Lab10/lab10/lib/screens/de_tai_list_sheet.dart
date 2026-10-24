import 'package:flutter/material.dart';
import '../models/de_tai_models.dart';
import '../services/api_service.dart';

class DeTaiListScreen extends StatefulWidget {
  final List<LoaiDeTai> dsLoaiDeTai;
  final List<ChuyenNganh> dsChuyenNganh;
  final String? initialMaLoai;
  final String? initialMaCN;

  const DeTaiListScreen({
    super.key,
    required this.dsLoaiDeTai,
    required this.dsChuyenNganh,
    this.initialMaLoai,
    this.initialMaCN,
  });

  @override
  State<DeTaiListScreen> createState() => _DeTaiListScreenState();
}

class _DeTaiListScreenState extends State<DeTaiListScreen> {
  List<DeTai> _dsDeTai = [];
  bool _isLoading = true;
  String? _selectedMaLoai;
  String? _selectedMaCN;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMaLoai = widget.initialMaLoai;
    _selectedMaCN = widget.initialMaCN;
    _loadDeTai();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeTai() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.fetchDeTai(
        maLoai: _selectedMaLoai,
        maCN: _selectedMaCN,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _dsDeTai = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải danh sách đề tài: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Color _getLoaiColor(String maLoai) {
    switch (maLoai.toUpperCase()) {
      case 'DA':
        return const Color(0xFF5E35B1);
      case 'KLKS':
        return const Color(0xFF00897B);
      case 'LV':
        return const Color(0xFF1E88E5);
      default:
        return const Color(0xFFE65100);
    }
  }

  void _showDeTaiDetailDialog(DeTai dt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dt.maDeTai,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                dt.tenLoai.isNotEmpty ? dt.tenLoai : dt.maLoai,
                style: TextStyle(
                  fontSize: 15,
                  color: _getLoaiColor(dt.maLoai),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dt.tenDeTai,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const Divider(height: 24),
              _buildDetailRow(Icons.person, 'Giảng viên HD:', dt.tenGiangVien),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.category,
                'Chuyên ngành:',
                dt.tenCN.isNotEmpty ? '${dt.tenCN} (${dt.maCN})' : dt.maCN,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.groups,
                'Số lượng SV tối đa:',
                '${dt.soLuongSV} sinh viên',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.calendar_today, 'Học kỳ:', dt.hocKy),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.check_circle, 'Trạng thái:', dt.trangThai),
              const SizedBox(height: 12),
              const Text(
                'Nội dung thực hiện:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dt.noiDung,
                  style: const TextStyle(fontSize: 13.5, height: 1.4),
                ),
              ),
              if (dt.yeuCau.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Yêu cầu kiến thức:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dt.yeuCau,
                    style: const TextStyle(fontSize: 13.5, height: 1.4),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showAddOrEditDialog(existing: dt);
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Sửa'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey.shade700),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(DeTai dt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa đề tài'),
        content: Text(
          'Bạn có chắc chắn muốn xóa đề tài "${dt.maDeTai} - ${dt.tenDeTai}" khỏi SQL Server không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteDeTai(dt.maDeTai);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa đề tài ${dt.maDeTai} thành công!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        _loadDeTai();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _showAddOrEditDialog({DeTai? existing}) async {
    final isEdit = existing != null;
    final maCtl = TextEditingController(text: existing?.maDeTai ?? '');
    final tenCtl = TextEditingController(text: existing?.tenDeTai ?? '');
    final gvCtl = TextEditingController(
      text: existing?.tenGiangVien ?? 'ThS. Vũ Văn Vinh',
    );
    final noiDungCtl = TextEditingController(text: existing?.noiDung ?? '');
    final yeuCauCtl = TextEditingController(text: existing?.yeuCau ?? '');
    final soLuongCtl = TextEditingController(
      text: (existing?.soLuongSV ?? 2).toString(),
    );

    String selectedLoai = existing?.maLoai ??
        (_selectedMaLoai ??
            (widget.dsLoaiDeTai.isNotEmpty
                ? widget.dsLoaiDeTai.first.maLoai
                : 'DA'));
    String selectedCN = existing?.maCN ??
        (_selectedMaCN ??
            (widget.dsChuyenNganh.isNotEmpty
                ? widget.dsChuyenNganh.first.maCN
                : 'CNPM'));

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isEdit ? 'Cập nhật đề tài (${existing.maDeTai})' : 'Thêm đề tài mới vào SQL Server',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: maCtl,
                    enabled: !isEdit,
                    decoration: const InputDecoration(
                      labelText: 'Mã đề tài (VD: DT21)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedLoai,
                          decoration: const InputDecoration(
                            labelText: 'Loại đề tài',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: widget.dsLoaiDeTai
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.maLoai,
                                  child: Text(e.tenLoai),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedLoai = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCN,
                          decoration: const InputDecoration(
                            labelText: 'Chuyên ngành',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: widget.dsChuyenNganh
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.maCN,
                                  child: Text(e.maCN),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedCN = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tenCtl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Tên đề tài',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: gvCtl,
                          decoration: const InputDecoration(
                            labelText: 'Giảng viên hướng dẫn',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: soLuongCtl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Số SV',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noiDungCtl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung đề tài',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: yeuCauCtl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Yêu cầu kiến thức (tùy chọn)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.save, size: 18),
              label: Text(isEdit ? 'Lưu cập nhật' : 'Thêm vào CSDL'),
              onPressed: () async {
                if (maCtl.text.trim().isEmpty ||
                    tenCtl.text.trim().isEmpty ||
                    noiDungCtl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập Mã, Tên và Nội dung đề tài!'),
                    ),
                  );
                  return;
                }
                final model = DeTai(
                  maDeTai: maCtl.text.trim().toUpperCase(),
                  tenDeTai: tenCtl.text.trim(),
                  tenGiangVien: gvCtl.text.trim(),
                  noiDung: noiDungCtl.text.trim(),
                  yeuCau: yeuCauCtl.text.trim(),
                  soLuongSV: int.tryParse(soLuongCtl.text.trim()) ?? 2,
                  maLoai: selectedLoai,
                  maCN: selectedCN,
                );
                try {
                  if (isEdit) {
                    await ApiService.updateDeTai(model);
                  } else {
                    await ApiService.createDeTai(model);
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx, true);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi lưu dữ liệu: $e'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Đã cập nhật đề tài thành công!' : 'Đã thêm đề tài mới vào SQL Server!',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      _loadDeTai();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF9A00),
        foregroundColor: Colors.black87,
        elevation: 2,
        title: const Text(
          'Danh sách Đề tài Đồ án (SQL Server)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại từ API',
            onPressed: _loadDeTai,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,
        onPressed: () => _showAddOrEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm đề tài'),
      ),
      body: Column(
        children: [
          // Bộ lọc và Tìm kiếm
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ô tìm kiếm
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _loadDeTai(),
                        decoration: InputDecoration(
                          hintText: 'Tìm theo mã, tên đề tài, giảng viên...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _loadDeTai();
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _loadDeTai,
                      child: const Text('Lọc'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Chip lọc Loại đề tài & Chuyên ngành
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tất cả loại'),
                        selected: _selectedMaLoai == null,
                        onSelected: (_) {
                          setState(() => _selectedMaLoai = null);
                          _loadDeTai();
                        },
                      ),
                      const SizedBox(width: 6),
                      ...widget.dsLoaiDeTai.map(
                        (loai) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(loai.tenLoai),
                            selected: _selectedMaLoai == loai.maLoai,
                            onSelected: (selected) {
                              setState(() {
                                _selectedMaLoai = selected ? loai.maLoai : null;
                              });
                              _loadDeTai();
                            },
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 16),
                      FilterChip(
                        label: const Text('Tất cả CN'),
                        selected: _selectedMaCN == null,
                        onSelected: (_) {
                          setState(() => _selectedMaCN = null);
                          _loadDeTai();
                        },
                      ),
                      const SizedBox(width: 6),
                      ...widget.dsChuyenNganh.map(
                        (cn) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(cn.maCN),
                            selected: _selectedMaCN == cn.maCN,
                            onSelected: (selected) {
                              setState(() {
                                _selectedMaCN = selected ? cn.maCN : null;
                              });
                              _loadDeTai();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Thanh kết quả
          Container(
            width: double.infinity,
            color: const Color(0xFF1976D2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kết quả từ SQL Server: ${_dsDeTai.length} đề tài',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (_selectedMaLoai != null || _selectedMaCN != null)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMaLoai = null;
                        _selectedMaCN = null;
                        _searchController.clear();
                      });
                      _loadDeTai();
                    },
                    child: const Text(
                      'Xóa bộ lọc',
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Danh sách Đề tài (kiểu thẻ DeTaiItem nâng cấp)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dsDeTai.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_off_outlined,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Không tìm thấy đề tài phù hợp',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 80),
                        itemCount: _dsDeTai.length,
                        itemBuilder: (context, index) {
                          final dt = _dsDeTai[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCD9CD),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.black87,
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _showDeTaiDetailDialog(dt),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Hàng tiêu đề giống mẫu DeTaiItem trang 12-13
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 4, right: 10),
                                          child: Icon(
                                            Icons.home,
                                            color: Colors.black87,
                                            size: 26,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    dt.maDeTai,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getLoaiColor(
                                                        dt.maLoai,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      dt.tenLoai.isNotEmpty
                                                          ? dt.tenLoai
                                                          : dt.maLoai,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blueGrey.shade700,
                                                      borderRadius:
                                                          BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      dt.maCN,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                dt.tenDeTai,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 15.5,
                                                  color: Color(0xFF0D47A1),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Xóa đề tài',
                                          onPressed: () => _confirmDelete(dt),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      color: Colors.black87,
                                      thickness: 1.2,
                                      height: 16,
                                    ),
                                    Text(
                                      'Chuyên ngành (${dt.tenCN.isNotEmpty ? dt.tenCN : dt.maCN}): ${dt.noiDung}',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Số SV tối đa: ${dt.soLuongSV}',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          'Giáo viên: ${dt.tenGiangVien}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
