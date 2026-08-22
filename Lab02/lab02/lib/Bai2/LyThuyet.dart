import 'MonHoc.dart';

class LyThuyet extends MonHoc {
  double tieuLuan;
  double cuoiKy;

  LyThuyet(String ma, String ten, int tc, this.tieuLuan, this.cuoiKy) : super(ma, ten, tc);

  @override
  double tinhDTB() => tieuLuan * 0.3 + cuoiKy * 0.7;
}
 