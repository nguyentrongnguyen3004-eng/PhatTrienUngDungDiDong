import 'dart:io';
import 'HoaDon.dart';

class HoaDonCaNhan extends HoaDon {
  double _khoangCach = 0;

  HoaDonCaNhan() : super();

  HoaDonCaNhan.full(
    String maKH,
    String tenKH,
    int soLuong,
    double giaBan,
    double khoangCach,
  ) : super.full(maKH, tenKH, soLuong, giaBan) {
    this.khoangCach = khoangCach;
  }

  double get khoangCach => _khoangCach;

  set khoangCach(double value) {
    if (value < 0) {
      throw ArgumentError('Khoảng cách không được âm');
    }

    _khoangCach = value;
  }

  @override
  double tinhChietKhau() {
    double chietKhau = 0;

    if (soLuong >= 3) {
      chietKhau += soLuong * giaBan * 0.05;
    }

    if (_khoangCach < 10) {
      chietKhau += soLuong * 50000;
    }

    return chietKhau;
  }

  @override
  double tinhTroGia() {
    double troGia = soLuong * giaBan * 0.02;

    if (soLuong > 2) {
      troGia += 100000;
    }

    return troGia;
  }

  @override
  void nhap() {
    print('\n--- NHẬP KHÁCH HÀNG CÁ NHÂN ---');

    nhapThongTinChung();

    while (true) {
      try {
        stdout.write('Nhập khoảng cách giao hàng (km): ');
        khoangCach = double.parse(stdin.readLineSync() ?? '');
        break;
      } catch (e) {
        print('Lỗi: Khoảng cách phải >= 0');
      }
    }
  }

  @override
  void xuat() {
    print('\n===== KHÁCH HÀNG CÁ NHÂN =====');

    super.xuat();

    print('Khoảng cách   : $_khoangCach km');
  }
}