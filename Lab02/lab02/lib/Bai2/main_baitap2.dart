import 'dart:io';

import 'MonHoc.dart';
import 'DoAn.dart';
import 'LyThuyet.dart';
import 'ThucHanh.dart';

void main() async {
  List<MonHoc> ds = [];

  int chon;

  do {
    print('\n==========================================');
    print('        QUẢN LÝ DANH SÁCH MÔN HỌC');
    print('==========================================');
    print('1. Nhập danh sách môn học');
    print('2. Xuất danh sách môn học');
    print('3. Kiểm tra danh sách tăng dần theo tên');
    print('4. Sắp xếp tăng dần theo số tín chỉ');
    print('5. Xuất môn học có số tín chỉ cao nhất');
    print('6. Tìm môn học theo tên');
    print('7. Đọc danh sách môn học từ file');
    print('8. Tính số tín chỉ trung bình');
    print('0. Thoát');
    print('==========================================');

    stdout.write('Chọn chức năng: ');

    try {
      chon = int.parse(stdin.readLineSync() ?? '');
    } catch (e) {
      chon = -1;
    }

    switch (chon) {
      case 1:
        ds = nhapDuLieu();
        break;

      case 2:
        print('\n=== DANH SÁCH MÔN HỌC ===');
        showMonHoc(ds);
        break;

      case 3:
        if (ds.isEmpty) {
          print('Danh sách môn học rỗng.');
          break;
        }

        bool tang = kiemTraTangTheoTen(ds);

        if (tang) {
          print('Danh sách đang tăng dần theo tên môn học.');
        } else {
          print('Danh sách chưa tăng dần theo tên môn học.');
        }

        break;

      case 4:
        if (ds.isEmpty) {
          print('Danh sách môn học rỗng.');
          break;
        }

        ds.sort(
          (a, b) => a.soTC.compareTo(b.soTC),
        );

        print('Đã sắp xếp tăng dần theo số tín chỉ.');

        showMonHoc(ds);
        break;

      case 5:
        if (ds.isEmpty) {
          print('Danh sách môn học rỗng.');
          break;
        }

        int maxTC = ds
            .map((mh) => mh.soTC)
            .reduce((a, b) => a > b ? a : b);

        List<MonHoc> dsMax = ds
            .where((mh) => mh.soTC == maxTC)
            .toList();

        print('\n=== MÔN HỌC CÓ SỐ TÍN CHỈ CAO NHẤT ===');

        showMonHoc(dsMax);
        break;

      case 6:
        if (ds.isEmpty) {
          print('Danh sách môn học rỗng.');
          break;
        }

        timMonHocTheoTen(ds);
        break;

      case 7:
        ds = await readFileMonHoc('lib/Bai2/monhoc.txt');

        if (ds.isEmpty) {
          print('Không đọc được dữ liệu hoặc file rỗng.');
        } else {
          print('Đọc file thành công.');
          showMonHoc(ds);
        }

        break;

      case 8:
        if (ds.isEmpty) {
          print('Danh sách môn học rỗng.');
          break;
        }

        double tongTC = ds.fold(
          0.0,
          (tong, mh) => tong + mh.soTC,
        );

        double trungBinh = tongTC / ds.length;

        print(
          'Số tín chỉ trung bình: '
          '${trungBinh.toStringAsFixed(2)}',
        );

        break;

      case 0:
        print('Kết thúc chương trình.');
        break;

      default:
        print('Lựa chọn không hợp lệ. Vui lòng chọn lại.');
    }
  } while (chon != 0);
}

// ======================================================
// NHẬP DANH SÁCH MÔN HỌC
// ======================================================

List<MonHoc> nhapDuLieu() {
  List<MonHoc> dsMonHoc = [];

  int n;

  while (true) {
    try {
      stdout.write('Nhập số lượng môn học: ');

      n = int.parse(
        stdin.readLineSync() ?? '',
      );

      if (n <= 0) {
        print('Số lượng môn học phải lớn hơn 0.');
        continue;
      }

      break;
    } catch (e) {
      print('Vui lòng nhập số nguyên hợp lệ.');
    }
  }

  for (int i = 0; i < n; i++) {
    print('\n--- Nhập môn học thứ ${i + 1} ---');

    MonHoc? monHoc = nhapMotMonHoc();

    if (monHoc != null) {
      dsMonHoc.add(monHoc);
    } else {
      i--;
    }
  }

  return dsMonHoc;
}

// ======================================================
// NHẬP 1 MÔN HỌC
// ======================================================

MonHoc? nhapMotMonHoc({String? tenCoSan}) {
  int loai;

  try {
    stdout.write(
      'Chọn loại môn (1-Lý thuyết, 2-Thực hành, 3-Đồ án): ',
    );

    loai = int.parse(
      stdin.readLineSync() ?? '',
    );
  } catch (e) {
    print('Loại môn không hợp lệ.');
    return null;
  }

  if (loai < 1 || loai > 3) {
    print('Chỉ được chọn từ 1 đến 3.');
    return null;
  }

  stdout.write('Mã môn học: ');
  String ma = stdin.readLineSync()?.trim() ?? '';

  String ten;

  if (tenCoSan != null) {
    ten = tenCoSan;
  } else {
    stdout.write('Tên môn học: ');
    ten = stdin.readLineSync()?.trim() ?? '';
  }

  int tc;

  try {
    stdout.write('Số tín chỉ: ');

    tc = int.parse(
      stdin.readLineSync() ?? '',
    );
  } catch (e) {
    print('Số tín chỉ không hợp lệ.');
    return null;
  }

  if (tc <= 0) {
    print('Số tín chỉ phải lớn hơn 0.');
    return null;
  }

  try {
    if (loai == 1) {
      stdout.write('Điểm tiểu luận: ');

      double tieuLuan = double.parse(
        stdin.readLineSync() ?? '',
      );

      stdout.write('Điểm cuối kỳ: ');

      double cuoiKy = double.parse(
        stdin.readLineSync() ?? '',
      );

      return LyThuyet(
        ma,
        ten,
        tc,
        tieuLuan,
        cuoiKy,
      );
    }

    if (loai == 2) {
      stdout.write('Điểm KT1: ');

      double d1 = double.parse(
        stdin.readLineSync() ?? '',
      );

      stdout.write('Điểm KT2: ');

      double d2 = double.parse(
        stdin.readLineSync() ?? '',
      );

      stdout.write('Điểm KT3: ');

      double d3 = double.parse(
        stdin.readLineSync() ?? '',
      );

      return ThucHanh(
        ma,
        ten,
        tc,
        d1,
        d2,
        d3,
      );
    }

    stdout.write('Điểm GVHD: ');

    double gvhd = double.parse(
      stdin.readLineSync() ?? '',
    );

    stdout.write('Điểm GVPB: ');

    double gvpb = double.parse(
      stdin.readLineSync() ?? '',
    );

    return DoAn(
      ma,
      ten,
      tc,
      gvhd,
      gvpb,
    );
  } catch (e) {
    print('Điểm nhập vào không hợp lệ.');
    return null;
  }
}

// ======================================================
// KIỂM TRA DANH SÁCH TĂNG DẦN THEO TÊN
// ======================================================

bool kiemTraTangTheoTen(List<MonHoc> ds) {
  for (int i = 0; i < ds.length - 1; i++) {
    String ten1 = ds[i].tenMH.toLowerCase();
    String ten2 = ds[i + 1].tenMH.toLowerCase();

    if (ten1.compareTo(ten2) > 0) {
      return false;
    }
  }

  return true;
}

// ======================================================
// TÌM MÔN HỌC THEO TÊN
// ======================================================

void timMonHocTheoTen(List<MonHoc> ds) {
  stdout.write('\nNhập tên môn học cần tìm: ');

  String ten = stdin.readLineSync()?.trim() ?? '';

  List<MonHoc> ketQua = ds
      .where(
        (mh) =>
            mh.tenMH.toLowerCase() ==
            ten.toLowerCase(),
      )
      .toList();

  if (ketQua.isNotEmpty) {
    print('\nĐã tìm thấy môn học:');
    showMonHoc(ketQua);
  } else {
    print('Không tìm thấy môn "$ten".');
    print('Nhập thông tin để thêm môn học mới.');

    MonHoc? monMoi = nhapMotMonHoc(
      tenCoSan: ten,
    );

    if (monMoi != null) {
      ds.add(monMoi);

      print('Đã thêm môn học vào cuối danh sách.');
    }
  }
}

// ======================================================
// ĐỌC DANH SÁCH MÔN HỌC TỪ FILE
// ======================================================

Future<List<MonHoc>> readFileMonHoc(
  String fileName,
) async {
  List<MonHoc> ds = [];

  try {
    List<String> lines =
        await File(fileName).readAsLines();

    for (String line in lines) {
      if (line.trim().isEmpty) {
        continue;
      }

      List<String> p = line.split('#');

      if (p.length < 6) {
        continue;
      }

      String loai = p[0].trim();
      String ma = p[1].trim();
      String ten = p[2].trim();
      int tc = int.parse(p[3].trim());

      if (loai == 'LT' && p.length == 6) {
        double tieuLuan =
            double.parse(p[4].trim());

        double cuoiKy =
            double.parse(p[5].trim());

        ds.add(
          LyThuyet(
            ma,
            ten,
            tc,
            tieuLuan,
            cuoiKy,
          ),
        );
      } else if (loai == 'TH' &&
          p.length == 7) {
        double d1 =
            double.parse(p[4].trim());

        double d2 =
            double.parse(p[5].trim());

        double d3 =
            double.parse(p[6].trim());

        ds.add(
          ThucHanh(
            ma,
            ten,
            tc,
            d1,
            d2,
            d3,
          ),
        );
      } else if (loai == 'DA' &&
          p.length == 6) {
        double gvhd =
            double.parse(p[4].trim());

        double gvpb =
            double.parse(p[5].trim());

        ds.add(
          DoAn(
            ma,
            ten,
            tc,
            gvhd,
            gvpb,
          ),
        );
      }
    }
  } catch (e) {
    print('Lỗi khi đọc file môn học: $e');
  }

  return ds;
}

// ======================================================
// XUẤT DANH SÁCH
// ======================================================

void showMonHoc(List<MonHoc> ds) {
  if (ds.isEmpty) {
    print('Danh sách môn học rỗng.');
    return;
  }

  print('');

  print(
    '${'STT'.padRight(5)}'
    '${'Mã MH'.padRight(10)}'
    '${'Tên môn học'.padRight(30)}'
    '${'TC'.padRight(6)}'
    '${'Điểm TB'.padRight(12)}'
    '${'Hệ 4'.padRight(8)}'
    'Điểm chữ',
  );

  print('-' * 85);

  for (int i = 0; i < ds.length; i++) {
    MonHoc mh = ds[i];

    String ten = mh.tenMH;

    if (ten.length > 28) {
      ten = '${ten.substring(0, 25)}...';
    }

    print(
      '${(i + 1).toString().padRight(5)}'
      '${mh.maMH.padRight(10)}'
      '${ten.padRight(30)}'
      '${mh.soTC.toString().padRight(6)}'
      '${mh.tinhDTB().toStringAsFixed(2).padRight(12)}'
      '${mh.he4().toStringAsFixed(1).padRight(8)}'
      '${mh.diemChu()}',
    );
  }
}