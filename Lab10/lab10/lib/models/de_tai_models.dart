class LoaiDeTai {
  final String maLoai;
  final String tenLoai;
  final String tenDayDu;
  final String moTa;
  final int soTinChi;
  final int thoiGianTuan;
  final int soLuongDeTai;

  LoaiDeTai({
    required this.maLoai,
    required this.tenLoai,
    required this.tenDayDu,
    required this.moTa,
    required this.soTinChi,
    required this.thoiGianTuan,
    this.soLuongDeTai = 0,
  });

  factory LoaiDeTai.fromJson(Map<String, dynamic> json) {
    return LoaiDeTai(
      maLoai: (json['maLoai'] ?? json['MaLoai'] ?? '').toString(),
      tenLoai: (json['tenLoai'] ?? json['TenLoai'] ?? '').toString(),
      tenDayDu: (json['tenDayDu'] ?? json['TenDayDu'] ?? '').toString(),
      moTa: (json['moTa'] ?? json['MoTa'] ?? '').toString(),
      soTinChi: int.tryParse((json['soTinChi'] ?? json['SoTinChi'] ?? 3).toString()) ?? 3,
      thoiGianTuan: int.tryParse((json['thoiGianTuan'] ?? json['ThoiGianTuan'] ?? 15).toString()) ?? 15,
      soLuongDeTai: int.tryParse((json['soLuongDeTai'] ?? json['SoLuongDeTai'] ?? 0).toString()) ?? 0,
    );
  }
}

class ChuyenNganh {
  final String maCN;
  final String tenCN;
  final String moTa;
  final String maThongBao;
  final String truongBoMon;
  final String iconName;
  final int soLuongDeTai;

  ChuyenNganh({
    required this.maCN,
    required this.tenCN,
    required this.moTa,
    required this.maThongBao,
    this.truongBoMon = '',
    this.iconName = 'school',
    this.soLuongDeTai = 0,
  });

  factory ChuyenNganh.fromJson(Map<String, dynamic> json) {
    return ChuyenNganh(
      maCN: (json['maCN'] ?? json['MaCN'] ?? '').toString(),
      tenCN: (json['tenCN'] ?? json['TenCN'] ?? '').toString(),
      moTa: (json['moTa'] ?? json['MoTa'] ?? '').toString(),
      maThongBao: (json['maThongBao'] ?? json['MaThongBao'] ?? '').toString(),
      truongBoMon: (json['truongBoMon'] ?? json['TruongBoMon'] ?? '').toString(),
      iconName: (json['iconName'] ?? json['IconName'] ?? 'school').toString(),
      soLuongDeTai: int.tryParse((json['soLuongDeTai'] ?? json['SoLuongDeTai'] ?? 0).toString()) ?? 0,
    );
  }
}

class DeTai {
  final String maDeTai;
  final String tenDeTai;
  final String tenGiangVien;
  final String noiDung;
  final String yeuCau;
  final int soLuongSV;
  final String hocKy;
  final String trangThai;
  final String maLoai;
  final String tenLoai;
  final String maCN;
  final String tenCN;

  DeTai({
    required this.maDeTai,
    required this.tenDeTai,
    required this.tenGiangVien,
    required this.noiDung,
    this.yeuCau = '',
    this.soLuongSV = 2,
    this.hocKy = 'HK2 (2025-2026)',
    this.trangThai = 'Đang mở đăng ký',
    required this.maLoai,
    this.tenLoai = '',
    required this.maCN,
    this.tenCN = '',
  });

  factory DeTai.fromJson(Map<String, dynamic> json) {
    return DeTai(
      maDeTai: (json['maDeTai'] ?? json['MaDeTai'] ?? '').toString(),
      tenDeTai: (json['tenDeTai'] ?? json['TenDeTai'] ?? '').toString(),
      tenGiangVien: (json['tenGiangVien'] ?? json['TenGiangVien'] ?? '').toString(),
      noiDung: (json['noiDung'] ?? json['NoiDung'] ?? '').toString(),
      yeuCau: (json['yeuCau'] ?? json['YeuCau'] ?? '').toString(),
      soLuongSV: int.tryParse((json['soLuongSV'] ?? json['SoLuongSV'] ?? 2).toString()) ?? 2,
      hocKy: (json['hocKy'] ?? json['HocKy'] ?? 'HK2 (2025-2026)').toString(),
      trangThai: (json['trangThai'] ?? json['TrangThai'] ?? 'Đang mở đăng ký').toString(),
      maLoai: (json['maLoai'] ?? json['MaLoai'] ?? '').toString(),
      tenLoai: (json['tenLoai'] ?? json['TenLoai'] ?? '').toString(),
      maCN: (json['maCN'] ?? json['MaCN'] ?? '').toString(),
      tenCN: (json['tenCN'] ?? json['TenCN'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maDeTai': maDeTai,
      'tenDeTai': tenDeTai,
      'tenGiangVien': tenGiangVien,
      'noiDung': noiDung,
      'yeuCau': yeuCau,
      'soLuongSV': soLuongSV,
      'hocKy': hocKy,
      'trangThai': trangThai,
      'maLoai': maLoai,
      'maCN': maCN,
    };
  }
}
