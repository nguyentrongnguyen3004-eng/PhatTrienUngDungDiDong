import 'dart:io';
import 'HoaDon.dart';

class DaiLyCap1 extends HoaDon {
  int _thoiGianHopTac = 0;

  DaiLyCap1() : super();

  DaiLyCap1.full(
    String maKH,
    String tenKH,
    int soLuong,
    double giaBan,
    int thoiGianHopTac,
  ) : super.full(maKH, tenKH, soLuong, giaBan) {
    this.thoiGianHopTac = thoiGianHopTac;
  }

  int get thoiGianHopTac => _thoiGianHopTac;

  set thoiGianHopTac(int value) {
    if (value < 0) {
      throw ArgumentError('Thời gian hợp tác không được âm');
    }

    _thoiGianHopTac = value;
  }

  double tinhTyLeChietKhau() {
    double tyLe = 0.30;

    if (_thoiGianHopTac > 5) {
      tyLe += (_thoiGianHopTac - 5) * 0.01;
    }

    if (tyLe > 0.35) {
      tyLe = 0.35;
    }

    return tyLe;
  }

  @override
  double tinhChietKhau() {
    return soLuong * giaBan * tinhTyLeChietKhau();
  }

  @override
  void nhap() {
    print('\n--- NHẬP ĐẠI LÝ CẤP 1 ---');

    nhapThongTinChung();

    while (true) {
      try {
        stdout.write('Nhập thời gian hợp tác (năm): ');
        thoiGianHopTac = int.parse(stdin.readLineSync() ?? '');
        break;
      } catch (e) {
        print('Lỗi: Thời gian hợp tác phải >= 0');
      }
    }
  }

  @override
  void xuat() {
    print('\n===== ĐẠI LÝ CẤP 1 =====');

    super.xuat();

    print('Thời gian hợp tác: $_thoiGianHopTac năm');
    print(
      'Tỷ lệ chiết khấu: ${(tinhTyLeChietKhau() * 100).toStringAsFixed(0)}%',
    );
  }
}