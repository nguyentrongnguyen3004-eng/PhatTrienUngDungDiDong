abstract class Phong {
  String maPhong;
  int soNguoi;
  int soDien;
  int soNuoc;

  Phong(this.maPhong, this.soNguoi, this.soDien, this.soNuoc);

  double tinhTien();

  void showInfo() {
    print("Mã: $maPhong | Người: $soNguoi | Điện: $soDien | Nước: $soNuoc | Tiền: ${tinhTien()}");
  }
}
