import 'dart:io';

abstract class HoaDon {
  String _maKH = '';
  String _tenKH = '';
  int _soLuong = 1;
  double _giaBan = 1;

  HoaDon() {
    _maKH = 'KH0000';
    _tenKH = 'Unknown';
    _soLuong = 1;
    _giaBan = 1;
  }

  HoaDon.full(
    String maKH,
    String tenKH,
    int soLuong,
    double giaBan,
  ) {
    this.maKH = maKH;
    this.tenKH = tenKH;
    this.soLuong = soLuong;
    this.giaBan = giaBan;
  }

  String get maKH => _maKH;

  set maKH(String value) {
    RegExp regex = RegExp(r'^KH\d{4}$');

    if (!regex.hasMatch(value)) {
      throw FormatException(
        'Mã khách hàng phải có dạng KHxxxx, ví dụ KH0002',
      );
    }

    _maKH = value;
  }

  String get tenKH => _tenKH;

  set tenKH(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError(
        'Tên khách hàng không được để trống',
      );
    }

    _tenKH = value.trim();
  }

  int get soLuong => _soLuong;

  set soLuong(int value) {
    if (value <= 0) {
      throw ArgumentError(
        'Số lượng phải lớn hơn 0',
      );
    }

    _soLuong = value;
  }

  double get giaBan => _giaBan;

  set giaBan(double value) {
    if (value <= 0) {
      throw ArgumentError(
        'Giá bán phải lớn hơn 0',
      );
    }

    _giaBan = value;
  }

  double tinhTienHang() {
    return _soLuong * _giaBan;
  }

  double tinhVAT() {
    return tinhTienHang() * 0.10;
  }

  double tinhChietKhau();

  double tinhTroGia() {
    return 0;
  }

  double tinhThanhTien() {
    return tinhTienHang() -
        tinhChietKhau() +
        tinhVAT();
  }

  void nhapThongTinChung() {
    while (true) {
      try {
        stdout.write('Nhập mã khách hàng: ');
        maKH = stdin.readLineSync() ?? '';
        break;
      } catch (e) {
        print('Lỗi: $e');
      }
    }

    while (true) {
      try {
        stdout.write('Nhập tên khách hàng: ');
        tenKH = stdin.readLineSync() ?? '';
        break;
      } catch (e) {
        print('Lỗi: $e');
      }
    }

    while (true) {
      try {
        stdout.write('Nhập số lượng: ');

        soLuong = int.parse(
          stdin.readLineSync() ?? '',
        );

        break;
      } catch (e) {
        print(
          'Lỗi: Số lượng phải là số nguyên > 0',
        );
      }
    }

    while (true) {
      try {
        stdout.write('Nhập giá bán: ');

        giaBan = double.parse(
          stdin.readLineSync() ?? '',
        );

        break;
      } catch (e) {
        print(
          'Lỗi: Giá bán phải là số > 0',
        );
      }
    }
  }

  void nhap();

  void xuat() {
    print('Mã khách hàng : $_maKH');
    print('Tên khách hàng: $_tenKH');
    print('Số lượng      : $_soLuong');
    print(
      'Giá bán       : ${dinhDangTien(_giaBan)}',
    );
    print(
      'Tiền hàng     : ${dinhDangTien(tinhTienHang())}',
    );
    print(
      'VAT           : ${dinhDangTien(tinhVAT())}',
    );
    print(
      'Chiết khấu    : ${dinhDangTien(tinhChietKhau())}',
    );
    print(
      'Trợ giá       : ${dinhDangTien(tinhTroGia())}',
    );
    print(
      'Thành tiền    : ${dinhDangTien(tinhThanhTien())}',
    );
  }

  String dinhDangTien(double value) {
    return '${value.toStringAsFixed(0)} VNĐ';
  }
}