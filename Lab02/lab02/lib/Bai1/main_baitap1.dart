import 'phong.dart';
import 'phongA.dart';
import 'readfile.dart';

void main() async {
  List<Phong> ds = await readFilePhong('lib/Bai1/phongthue.txt');

  print('================================================');
  print("=== TẤT CẢ PHÒNG THUÊ CÓ TRONG DANH SÁCH ===");
  ds.forEach((p) => p.showInfo());

  print('\n================================================');
  print("=== DANH SÁCH CÁC PHÒNG CÓ SỐ NGƯỜI THUÊ > 2 ===");
  ds.where((p) => p.soNguoi > 2).forEach((p) => p.showInfo());

  print('\n================================================');
  double tong = ds.fold(0, (s, p) => s + p.tinhTien());
  print("TỔNG TIỀN PHÒNG THU ĐƯỢC: $tong");

  print('\n================================================');
  ds.sort((a, b) => b.soDien.compareTo(a.soDien));
  print("=== DANH SÁCH CÁC PHÒNG THUÊ GIẢM DẦN THEO SỐ ĐIỆN ===");
  ds.forEach((p) => p.showInfo());

  print('\n================================================');
  print("=== DANH SÁCH CÁC PHÒNG LOẠI A ===");
  ds.where((p) => p is PhongA).forEach((p) => p.showInfo());
}

