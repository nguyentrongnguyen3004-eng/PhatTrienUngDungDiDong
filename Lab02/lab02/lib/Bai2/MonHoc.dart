abstract class MonHoc {
  String maMH;
  String tenMH;
  int soTC;

  MonHoc(this.maMH, this.tenMH, this.soTC);

  double tinhDTB();

  double he4() {
    double d = tinhDTB();

    if (d >= 8.5) return 4.0;
    if (d >= 7.0) return 3.0;
    if (d >= 5.5) return 2.0;
    if (d >= 4.0) return 1.0;

    return 0.0;
  }

  String diemChu() {
    double h4 = he4();

    if (h4 == 4) return 'A';
    if (h4 == 3) return 'B';
    if (h4 == 2) return 'C';
    if (h4 == 1) return 'D';

    return 'F';
  }

  @override
  String toString() {
    return "$maMH | "
        "$tenMH | "
        "TC: $soTC | "
        "DTB: ${tinhDTB().toStringAsFixed(2)} | "
        "Hệ 4: ${he4()} | "
        "Điểm chữ: ${diemChu()}";
  }
}