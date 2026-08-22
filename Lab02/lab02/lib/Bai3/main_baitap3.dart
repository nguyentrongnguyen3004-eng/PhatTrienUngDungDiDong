import 'dart:io';
import 'QuanLyHoaDon.dart';

void main() {
  QuanLyHoaDon quanLy = QuanLyHoaDon();
  int chon;

  do {
    print('');
    print('==========================================');
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
          'Tổng thành tiền: ${quanLy.tinhTongThanhTien().toStringAsFixed(0)} VNĐ',
        );
        break;

      case 4:
        print(
          'Tổng tiền trợ giá: ${quanLy.tinhTongTroGia().toStringAsFixed(0)} VNĐ',
        );
        break;

      case 5:
        quanLy.khachHangMuaNhieuNhat();
        break;

      case 6:
        print(
          'Tổng chiết khấu khách hàng công ty: '
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
        print('Lựa chọn không hợp lệ. Vui lòng chọn lại.');
    }
  } while (chon != 0);
}