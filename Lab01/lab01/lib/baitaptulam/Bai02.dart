import 'dart:io';

void main() {
  stdout.write("Nhập số nguyên dương > 10: ");
  int n = int.parse(stdin.readLineSync()!);

  String s = n.toString();

  print("Số chữ số: ${s.length}");

  int tong = 0;
  for (var ch in s.split('')) {
    tong += int.parse(ch);
  }
  print("Tổng các chữ số: $tong");

  bool coSoLe = false;
  for (var ch in s.split('')) {
    if (int.parse(ch) % 2 != 0) {
      coSoLe = true;
      break;
    }
  }

  print(coSoLe?"Số có chứa chữ số lẻ": "Số không chứa chữ số lẻ");
}