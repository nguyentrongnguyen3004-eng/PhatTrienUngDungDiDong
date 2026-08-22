import 'MonHoc.dart';

class DoAn extends MonHoc {
  double gvhd, gvpb;

  DoAn(String ma, String ten, int tc, this.gvhd, this.gvpb) : super(ma, ten, tc);

  @override
  double tinhDTB() => (gvhd + gvpb) / 2;
}
