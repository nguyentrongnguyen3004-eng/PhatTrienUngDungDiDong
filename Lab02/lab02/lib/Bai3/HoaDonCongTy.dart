import 'dart:io';
import 'HoaDon.dart';

class HoaDonCongTy extends HoaDon {
  int _soNhanVien = 0;

  HoaDonCongTy() : super();

  HoaDonCongTy.full(
    String maKH,
    String tenKH,
    int soLuong,
    double giaBan,
    int soNhanVien,
  ) : super.full(maKH, tenKH, soLuong, giaBan) {
    this.soNhanVien = soNhanVien;
  }

  int get soNhanVien => _soNhanVien;

  set soNhanVien(int value) {
    if (value <= 0) {
      throw ArgumentError('Số nhân viên phải lớn hơn 0');
    }

    _soNhanVien = value;
  }

  double tinhTyLeChietKhau() {
    if (_soNhanVien > 5000) {
      return 0.07;
    }

    if (_soNhanVien > 1000) {
      return 0.05;
    }

    return 0;
  }

  @override
  double tinhChietKhau() {
    return soLuong * giaBan * tinhTyLeChietKhau();
  }

  @override
  double tinhTroGia() {
    return soLuong * 120000;
  }

  @override
  void nhap() {
    print('\n--- NHẬP KHÁCH HÀNG CÔNG TY ---');

    nhapThongTinChung();

    while (true) {
      try {
        stdout.write('Nhập số lượng nhân viên: ');
        soNhanVien = int.parse(stdin.readLineSync() ?? '');
        break;
      } catch (e) {
        print('Lỗi: Số lượng nhân viên phải > 0');
      }
    }
  }

  @override
  void xuat() {
    print('\n===== KHÁCH HÀNG CÔNG TY =====');

    super.xuat();

    print('Số nhân viên  : $_soNhanVien');
    print(
      'Tỷ lệ chiết khấu: ${(tinhTyLeChietKhau() * 100).toStringAsFixed(0)}%',
    );
  }
}