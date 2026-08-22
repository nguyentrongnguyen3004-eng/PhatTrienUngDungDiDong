import 'MonHoc.dart';

class ThucHanh extends MonHoc {
  double d1, d2, d3;

  ThucHanh(String ma, String ten, int tc, this.d1, this.d2, this.d3) : super(ma, ten, tc);

  @override
  double tinhDTB() => (d1 + d2 + d3) / 3;
}
