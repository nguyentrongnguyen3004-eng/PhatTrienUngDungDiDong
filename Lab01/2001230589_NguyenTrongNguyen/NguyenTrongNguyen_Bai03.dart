import 'dart:io';

bool laSoNguyenTo(int n) {
  if (n < 2) return false;
  for (int i = 2; i <= n ~/ 2; i++) {
    if (n % i == 0) return false;
  }
  return true;
}

void baitap3() {
  stdout.write("Nhập số lượng phần tử: ");
  int n = int.parse(stdin.readLineSync()!);

  List<int> ds = [];

  for (int i = 0; i < n; i++) {
    stdout.write("Nhập phần tử thứ ${i + 1}: ");
    ds.add(int.parse(stdin.readLineSync()!));
  }

  print("Danh sách: $ds");

  int tong = ds.reduce((a, b) => a + b);
  print("Tổng các phần tử: $tong");

  print("Các số nguyên tố:");
  for (var x in ds) {
    if (laSoNguyenTo(x)) {
      print(x);
    }
  }

  stdout.write("Nhập giá trị cần kiểm tra: ");
  int k = int.parse(stdin.readLineSync()!);

  if (ds.contains(k)) {
    print("Giá trị $k có trong danh sách tại vị trí:");
    for (int i = 0; i < ds.length; i++) {
      if (ds[i] == k) {
        print(i);
      }
    }
  } else {
    ds.insert(0, k);
    print("Không tìm thấy. Đã thêm $k vào đầu danh sách.");
    print("Danh sách mới: $ds");
  }
}