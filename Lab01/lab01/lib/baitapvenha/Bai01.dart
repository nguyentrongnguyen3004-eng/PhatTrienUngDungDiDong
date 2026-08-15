import 'dart:io';
import 'dart:math';

void main() {
  Random rd = Random();

  List<int> ds = List.generate(10, (_) => rd.nextInt(96) + 5);

  print("Danh sách: $ds");

  List<int> soLe = ds.where((x) => x % 2 != 0).toList();

  if (soLe.isEmpty) {
    print("Danh sách không có số lẻ");
  } 
  else {
    double tb =
    soLe.reduce((a, b) => a + b) / soLe.length;
    print("Trung bình cộng các số lẻ: $tb");
  }

  bool doiXung = true;
  for (int i = 0; i < ds.length ~/ 2; i++) {
    if (ds[i] != ds[ds.length - i - 1]) {
      doiXung = false;
      break;
    }
  }
  print(doiXung ? "Danh sách đối xứng" : "Danh sách không đối xứng");
  
  bool tangDan = true;
  for (int i = 0; i < ds.length - 1; i++) {
    if (ds[i] > ds[i + 1]) {
      tangDan = false;
      break;
    }
  }

  print(tangDan ? "Danh sách tăng dần" : "Danh sách không tăng dần");
  int max = ds.reduce((a, b) => a > b ? a : b);
  print("Phần tử lớn nhất: $max");

  List<int> soChan = ds.where((x) => x % 2 == 0).toList();
  if (soChan.isEmpty) {
    print("Danh sách không có số chẵn");
  } 
  else {
    int maxChan = soChan.reduce((a, b) => a > b ? a : b);
    print("Số chẵn lớn nhất: $maxChan");
  }

  stdout.write("Nhập giá trị cần tìm: ");
  int x = int.parse(stdin.readLineSync()!);

  if (!ds.contains(x)) {
    print("Không tìm thấy $x trong danh sách");
  } 
  else {
    ds.removeWhere((e) => e == x);
    print("Đã xóa các phần tử bằng $x");
    print("Danh sách sau khi xóa: $ds");
  }
}