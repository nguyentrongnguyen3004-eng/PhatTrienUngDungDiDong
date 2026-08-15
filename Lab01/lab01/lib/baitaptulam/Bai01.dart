import 'dart:io';

void main() {
  stdout.write("Nhập số lượng que kem (>0): ");
  int soLuong = int.parse(stdin.readLineSync()!);

  stdout.write("Nhập giá tiền 1 que kem: ");
  double gia = double.parse(stdin.readLineSync()!);

  double tongTien = soLuong * gia;
  double giamGia = 0;

  if (soLuong > 10) {
    giamGia = 0.10;
  } 
  else if (soLuong >= 5 && soLuong <= 10) {
    giamGia = 0.05;
  }

  double thanhToan = tongTien * (1 - giamGia);
  print("Tổng tiền ban đầu: $tongTien");
  print("Giảm giá: ${giamGia * 100}%");
  print("Số tiền phải trả: $thanhToan");
}
