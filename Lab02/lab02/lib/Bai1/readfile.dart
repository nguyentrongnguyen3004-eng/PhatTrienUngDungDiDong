import 'dart:io';

import 'phong.dart';
import 'phongA.dart';
import 'phongB.dart';

Future<List<Phong>> readFilePhong(String fileName) async {
  List<Phong> ds = [];

  try {
    List<String> lines = await File(fileName).readAsLines();

    for (String line in lines) {
      if (line.trim().isEmpty) {
        continue;
      }

      List<String> parts = line.split('#');

      String maPhong = parts[0].trim();

      if (maPhong.startsWith('A')) {
        if (parts.length == 5) {
          int soNguoi = int.parse(parts[1].trim());
          int soDien = int.parse(parts[2].trim());
          int soNuoc = int.parse(parts[3].trim());
          int soNguoiThan = int.parse(parts[4].trim());

          ds.add(
            PhongA(
              maPhong,
              soNguoi,
              soDien,
              soNuoc,
              soNguoiThan,
            ),
          );
        }
      } else if (maPhong.startsWith('B')) {
        if (parts.length == 6) {
          int soNguoi = int.parse(parts[1].trim());
          int soDien = int.parse(parts[2].trim());
          int soNuoc = int.parse(parts[3].trim());
          int giatUi = int.parse(parts[4].trim());
          int soMay = int.parse(parts[5].trim());

          ds.add(
            PhongB(
              maPhong,
              soNguoi,
              soDien,
              soNuoc,
              giatUi,
              soMay,
            ),
          );
        }
      }
    }
  } catch (e) {
    print("Lỗi khi đọc file: $e");
  }

  return ds;
}