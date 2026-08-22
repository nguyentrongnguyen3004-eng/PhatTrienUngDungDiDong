import 'dart:io';

import 'HoaDon.dart';
import 'HoaDonCaNhan.dart';
import 'DaiLyCap1.dart';
import 'HoaDonCongTy.dart';

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
      print('\n================================');
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

    print('\n========== DANH SÁCH HÓA ĐƠN ==========');

    for (HoaDon hoaDon in danhSach) {
      hoaDon.xuat();
      print('----------------------------------------');
    }
  }

  double tinhTongThanhTien() {
    return danhSach.fold(
      0.0,
      (tong, hoaDon) => tong + hoaDon.tinhThanhTien(),
    );
  }

  double tinhTongTroGia() {
    return danhSach.fold(
      0.0,
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
      print('----------------------------------------');
    }
  }

  double tongChietKhauKhachHangCongTy() {
    return danhSach
        .whereType<HoaDonCongTy>()
        .fold(
          0.0,
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
              hoaDon.maKH.toUpperCase() == ma.trim().toUpperCase(),
        )
        .toList();

    if (ketQua.isEmpty) {
      print('Khách hàng lạ');
      return;
    }

    print(
      '\n===== CÁC HÓA ĐƠN CỦA KHÁCH HÀNG ${ma.toUpperCase()} =====',
    );

    for (HoaDon hoaDon in ketQua) {
      hoaDon.xuat();
      print('----------------------------------------');
    }
  }
}