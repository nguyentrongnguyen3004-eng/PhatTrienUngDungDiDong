import 'phong.dart';
class PhongA extends Phong {
  int soNguoiThan;

  PhongA(String ma, int nguoi, int dien, int nuoc, this.soNguoiThan) : super(ma, nguoi, dien, nuoc);

  @override
  double tinhTien() {
    return 1400.0 + (2 * soDien) + (8 * soNuoc) + (50 * soNguoiThan);
  }
}