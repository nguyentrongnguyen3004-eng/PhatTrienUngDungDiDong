import 'dart:io';

void main() {
  stdout.write("Nhập chuỗi: ");
  String s = stdin.readLineSync()!;

  print("Chuỗi vừa nhập: $s");

  String nguyenAm = "aeiouAEIOUáàảãạăắằẳẵặâấầẩẫậ"
  "éèẻẽẹêếềểễệ"
  "íìỉĩị"
  "óòỏõọôốồổỗộơớờởỡợ"
  "úùủũụưứừửữự"
  "ýỳỷỹỵ";

  int demNguyenAm = 0;
  for (int i = 0; i < s.length; i++) {
    if (nguyenAm.contains(s[i])) {
      demNguyenAm++;
    }
  }
  print("Số ký tự nguyên âm: $demNguyenAm");

  List<String> tu = s.trim().split(RegExp(r'\s+'));
  print("Số từ trong chuỗi: ${tu.length}");

  String chuanHoa = s.replaceAll(" ", "").toLowerCase();
  String daoNguoc = chuanHoa.split('').reversed.join();

  if (chuanHoa == daoNguoc) {
    print("Chuỗi là chuỗi đối xứng");
  } 
  else {
    print("Chuỗi không phải là chuỗi đối xứng");
  }

  String chuoiDaoTu = tu.reversed.join(" ");
  print("Chuỗi sau khi đảo từ: $chuoiDaoTu");
}