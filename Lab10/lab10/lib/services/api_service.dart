import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/de_tai_models.dart';

class ApiService {
  static String _customBaseUrl = '';

  /// Tự động chọn địa chỉ API phù hợp:
  /// - Android Emulator: http://10.0.2.2:5130/api
  /// - Web / Windows / iOS Simulator: http://localhost:5130/api
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) return _customBaseUrl;
    if (kIsWeb) return 'http://localhost:5130/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5130/api';
    }
    return 'http://localhost:5130/api';
  }

  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url.trim().replaceAll(RegExp(r'/$'), '');
  }

  /// Lấy danh sách loại đề tài (Đồ án, KLKS, Luận văn, Khác)
  static Future<List<LoaiDeTai>> fetchLoaiDeTai() async {
    final uri = Uri.parse('$baseUrl/LoaiDeTai');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => LoaiDeTai.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải Loại đề tài (${response.statusCode})');
    }
  }

  /// Lấy danh sách chuyên ngành thực hiện (CNPM, HTTT, MMT, ATTT...)
  static Future<List<ChuyenNganh>> fetchChuyenNganh() async {
    final uri = Uri.parse('$baseUrl/ChuyenNganh');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => ChuyenNganh.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải Chuyên ngành (${response.statusCode})');
    }
  }

  /// Lấy danh sách đề tài (hỗ trợ lọc theo mã loại, mã chuyên ngành, từ khóa)
  static Future<List<DeTai>> fetchDeTai({
    String? maLoai,
    String? maCN,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (maLoai != null && maLoai.isNotEmpty) queryParams['maLoai'] = maLoai;
    if (maCN != null && maCN.isNotEmpty) queryParams['maCN'] = maCN;
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl/DeTai').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => DeTai.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải Đề tài (${response.statusCode})');
    }
  }

  /// Thêm đề tài mới (POST)
  static Future<void> createDeTai(DeTai deTai) async {
    final uri = Uri.parse('$baseUrl/DeTai');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(deTai.toJson()),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không thể thêm đề tài: $body');
    }
  }

  /// Cập nhật đề tài (PUT)
  static Future<void> updateDeTai(DeTai deTai) async {
    final uri = Uri.parse('$baseUrl/DeTai');
    final response = await http
        .put(
          uri,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(deTai.toJson()),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không thể cập nhật đề tài: $body');
    }
  }

  /// Xóa đề tài (DELETE)
  static Future<void> deleteDeTai(String maDeTai) async {
    final uri = Uri.parse('$baseUrl/DeTai/$maDeTai');
    final response = await http.delete(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không thể xóa đề tài: $body');
    }
  }
}
