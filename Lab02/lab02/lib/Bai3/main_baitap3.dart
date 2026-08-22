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
      throw ArgumentError('Tên khách hàng không được để trống');
    }

    _tenKH = value.trim();
  }

  int get soLuong => _soLuong;

  set soLuong(int value) {
    if (value <= 0) {
      throw ArgumentError('Số lượng phải lớn hơn 0');
    }

    _soLuong = value;
  }

  double get giaBan => _giaBan;

  set giaBan(double value) {
    if (value <= 0) {
      throw ArgumentError('Giá bán phải lớn hơn 0');
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
    return tinhTienHang() - tinhChietKhau() + tinhVAT();
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
        soLuong = int.parse(stdin.readLineSync() ?? '');
        break;
      } catch (e) {
        print('Lỗi: Số lượng phải là số nguyên > 0');
      }
    }

    while (true) {
      try {
        stdout.write('Nhập giá bán: ');
        giaBan = double.parse(stdin.readLineSync() ?? '');
        break;
      } catch (e) {
        print('Lỗi: Giá bán phải là số > 0');
      }
    }
  }

  void nhap();

  void xuat() {
    print('Mã khách hàng : $_maKH');
    print('Tên khách hàng: $_tenKH');
    print('Số lượng      : $_soLuong');
    print('Giá bán       : ${dinhDangTien(_giaBan)}');
    print('Tiền hàng     : ${dinhDangTien(tinhTienHang())}');
    print('VAT           : ${dinhDangTien(tinhVAT())}');
    print('Chiết khấu    : ${dinhDangTien(tinhChietKhau())}');
    print('Trợ giá       : ${dinhDangTien(tinhTroGia())}');
    print('Thành tiền    : ${dinhDangTien(tinhThanhTien())}');
  }

  String dinhDangTien(double value) {
    return '${value.toStringAsFixed(0)} VNĐ';
  }
}

// ==========================================================
// KHÁCH HÀNG CÁ NHÂN
// ==========================================================

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

// ==========================================================
// ĐẠI LÝ CẤP 1
// ==========================================================

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

// ==========================================================
// KHÁCH HÀNG CÔNG TY
// ==========================================================

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

// ==========================================================
// CLASS QUẢN LÝ HÓA ĐƠN
// ==========================================================

class QuanLyHoaDon {
  List<HoaDon> danhSach = [];

  void nhapDanhSach() {
    int n;

    while (true) {
      try {
        stdout.write('Nhập số lượng hóa đơn: ');
        n = int.parse(stdin.readLineSync() ?? '');

        if (n <= 0) {
          print('Số lượng hóa đơn phải > 0');
          continue;
        }

        break;
      } catch (e) {
        print('Vui lòng nhập số nguyên.');
      }
    }

    for (int i = 0; i < n; i++) {
      print('\n==============================');
      print('NHẬP HÓA ĐƠN THỨ ${i + 1}');
      print('1. Khách hàng cá nhân');
      print('2. Đại lý cấp 1');
      print('3. Khách hàng công ty');

      int loai;

      while (true) {
        try {
          stdout.write('Chọn loại khách hàng: ');
          loai = int.parse(stdin.readLineSync() ?? '');

          if (loai < 1 || loai > 3) {
            print('Chỉ được chọn từ 1 đến 3.');
            continue;
          }

          break;
        } catch (e) {
          print('Lựa chọn không hợp lệ.');
        }
      }

      HoaDon hoaDon;

      if (loai == 1) {
        hoaDon = HoaDonCaNhan();
      } else if (loai == 2) {
        hoaDon = DaiLyCap1();
      } else {
        hoaDon = HoaDonCongTy();
      }

      hoaDon.nhap();
      danhSach.add(hoaDon);
    }
  }

  void xuatDanhSach() {
    if (danhSach.isEmpty) {
      print('Danh sách hóa đơn đang rỗng.');
      return;
    }

    print('\n=========== DANH SÁCH HÓA ĐƠN ===========');

    for (HoaDon hoaDon in danhSach) {
      hoaDon.xuat();
      print('-------------------------------------------');
    }
  }

  double tinhTongThanhTien() {
    return danhSach.fold(
      0,
      (tong, hoaDon) => tong + hoaDon.tinhThanhTien(),
    );
  }

  double tinhTongTroGia() {
    return danhSach.fold(
      0,
      (tong, hoaDon) => tong + hoaDon.tinhTroGia(),
    );
  }

  void khachHangMuaNhieuNhat() {
    if (danhSach.isEmpty) {
      print('Danh sách hóa đơn đang rỗng.');
      return;
    }

    int maxSoLuong = danhSach
        .map((hoaDon) => hoaDon.soLuong)
        .reduce((a, b) => a > b ? a : b);

    List<HoaDon> ketQua = danhSach
        .where((hoaDon) => hoaDon.soLuong == maxSoLuong)
        .toList();

    print('\n===== KHÁCH HÀNG MUA NHIỀU NHẤT =====');

    for (HoaDon hoaDon in ketQua) {
      hoaDon.xuat();
      print('--------------------------------------');
    }
  }

  double tongChietKhauKhachHangCongTy() {
    return danhSach
        .whereType<HoaDonCongTy>()
        .fold(
          0,
          (tong, hoaDon) => tong + hoaDon.tinhChietKhau(),
        );
  }

  void sapXep() {
    danhSach.sort((a, b) {
      int soSanhSoLuong = a.soLuong.compareTo(b.soLuong);

      if (soSanhSoLuong != 0) {
        return soSanhSoLuong;
      }

      return b.tinhThanhTien().compareTo(a.tinhThanhTien());
    });

    print('Đã sắp xếp danh sách.');
  }

  void timTheoMaKhachHang(String ma) {
    List<HoaDon> ketQua = danhSach
        .where(
          (hoaDon) =>
              hoaDon.maKH.toUpperCase() == ma.toUpperCase(),
        )
        .toList();

    if (ketQua.isEmpty) {
      print('Khách hàng lạ');
      return;
    }

    print('\n===== CÁC HÓA ĐƠN CỦA KHÁCH HÀNG $ma =====');

    for (HoaDon hoaDon in ketQua) {
      hoaDon.xuat();
      print('------------------------------------------');
    }
  }
}

// ==========================================================
// MAIN
// ==========================================================

void main() {
  QuanLyHoaDon quanLy = QuanLyHoaDon();

  int chon;

  do {
    print('\n==========================================');
    print('       QUẢN LÝ HÓA ĐƠN MÁY LẠNH');
    print('==========================================');
    print('1. Nhập danh sách hóa đơn');
    print('2. Xuất danh sách hóa đơn');
    print('3. Tính tổng thành tiền');
    print('4. Tính tổng tiền trợ giá');
    print('5. Khách hàng mua số lượng nhiều nhất');
    print('6. Tổng chiết khấu khách hàng công ty');
    print('7. Sắp xếp danh sách hóa đơn');
    print('8. Tìm hóa đơn theo mã khách hàng');
    print('0. Thoát');
    print('==========================================');

    try {
      stdout.write('Chọn chức năng: ');
      chon = int.parse(stdin.readLineSync() ?? '');
    } catch (e) {
      chon = -1;
    }

    switch (chon) {
      case 1:
        quanLy.nhapDanhSach();
        break;

      case 2:
        quanLy.xuatDanhSach();
        break;

      case 3:
        print(
          'Tổng thành tiền: '
          '${quanLy.tinhTongThanhTien().toStringAsFixed(0)} VNĐ',
        );
        break;

      case 4:
        print(
          'Tổng tiền trợ giá: '
          '${quanLy.tinhTongTroGia().toStringAsFixed(0)} VNĐ',
        );
        break;

      case 5:
        quanLy.khachHangMuaNhieuNhat();
        break;

      case 6:
        print(
          'Tổng chiết khấu dành cho khách hàng công ty: '
          '${quanLy.tongChietKhauKhachHangCongTy().toStringAsFixed(0)} VNĐ',
        );
        break;

      case 7:
        quanLy.sapXep();
        quanLy.xuatDanhSach();
        break;

      case 8:
        stdout.write('Nhập mã khách hàng cần tìm: ');
        String ma = stdin.readLineSync() ?? '';

        quanLy.timTheoMaKhachHang(ma);
        break;

      case 0:
        print('Kết thúc chương trình.');
        break;

      default:
        print('Lựa chọn không hợp lệ.');
    }
  } while (chon != 0);
}