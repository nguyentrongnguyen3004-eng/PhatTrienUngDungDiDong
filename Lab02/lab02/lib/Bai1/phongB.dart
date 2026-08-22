import 'phong.dart';

class PhongB extends Phong {
  int giatUi;
  int soMay;

  PhongB(String ma, int nguoi, int dien, int nuoc, this.giatUi, this.soMay) : super(ma, nguoi, dien, nuoc);

  @override
  double tinhTien() {
    return 2000 + 2 * soDien + 8 * soNuoc + giatUi * 5 + soMay * 100;
  }
}
