/* ============================================================
   1. TẠO DATABASE
   ============================================================ */

CREATE DATABASE ProjectRegistrationDB;
GO

USE ProjectRegistrationDB;
GO


/* ============================================================
   2. BẢNG VAI TRÒ
   ============================================================ */

CREATE TABLE VaiTros
(
    VaiTroId INT IDENTITY(1,1) PRIMARY KEY,

    MaVaiTro VARCHAR(50) NOT NULL UNIQUE,

    TenVaiTro NVARCHAR(100) NOT NULL,

    MoTa NVARCHAR(255) NULL
);
GO


INSERT INTO VaiTros
(
    MaVaiTro,
    TenVaiTro,
    MoTa
)
VALUES
(
    'ADMIN',
    N'Quản trị viên',
    N'Quản lý hệ thống, tài khoản và phân quyền'
),
(
    'SINHVIEN',
    N'Sinh viên',
    N'Tham gia đăng ký nhóm và đề tài đồ án'
),
(
    'GIANGVIEN',
    N'Giảng viên',
    N'Quản lý lớp học phần và đồ án'
),
(
    'GIAOVUKHOA',
    N'Giáo vụ Khoa',
    N'Quản lý dữ liệu thuộc Khoa'
),
(
    'PHONGDAOTAO',
    N'Phòng Đào tạo',
    N'Quản lý dữ liệu học kỳ và học phần'
);
GO


/* ============================================================
   3. BẢNG KHOA
   ============================================================ */

CREATE TABLE Khoas
(
    KhoaId INT IDENTITY(1,1) PRIMARY KEY,

    MaKhoa VARCHAR(20) NOT NULL UNIQUE,

    TenKhoa NVARCHAR(200) NOT NULL,

    TrangThai BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO


/* ============================================================
   4. BẢNG NGƯỜI DÙNG
   ============================================================ */

CREATE TABLE NguoiDungs
(
    NguoiDungId INT IDENTITY(1,1) PRIMARY KEY,

    TenDangNhap VARCHAR(100) NOT NULL UNIQUE,

    MatKhauHash NVARCHAR(500) NOT NULL,

    Email VARCHAR(150) NOT NULL UNIQUE,

    HoTen NVARCHAR(200) NOT NULL,

    SoDienThoai VARCHAR(20) NULL,

    AvatarUrl NVARCHAR(500) NULL,

    VaiTroId INT NOT NULL,

    TrangThai BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    UpdatedAt DATETIME NULL,

    CONSTRAINT FK_NguoiDungs_VaiTros
        FOREIGN KEY (VaiTroId)
        REFERENCES VaiTros(VaiTroId)
);
GO


/* ============================================================
   5. BẢNG HỌC KỲ
   ============================================================ */

CREATE TABLE HocKys
(
    HocKyId INT IDENTITY(1,1) PRIMARY KEY,

    TenHocKy NVARCHAR(100) NOT NULL,

    NamHoc VARCHAR(20) NOT NULL,

    NgayBatDau DATE NOT NULL,

    NgayKetThuc DATE NOT NULL,

    TrangThai BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_HocKys_Ngay
        CHECK (NgayKetThuc > NgayBatDau)
);
GO


/* ============================================================
   6. BẢNG SINH VIÊN
   ============================================================ */

CREATE TABLE SinhViens
(
    SinhVienId INT IDENTITY(1,1) PRIMARY KEY,

    NguoiDungId INT NOT NULL UNIQUE,

    MSSV VARCHAR(30) NOT NULL UNIQUE,

    KhoaId INT NOT NULL,

    NgaySinh DATE NULL,

    GioiTinh NVARCHAR(10) NULL,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_SinhViens_NguoiDungs
        FOREIGN KEY (NguoiDungId)
        REFERENCES NguoiDungs(NguoiDungId),

    CONSTRAINT FK_SinhViens_Khoas
        FOREIGN KEY (KhoaId)
        REFERENCES Khoas(KhoaId)
);
GO


/* ============================================================
   7. BẢNG GIẢNG VIÊN
   ============================================================ */

CREATE TABLE GiangViens
(
    GiangVienId INT IDENTITY(1,1) PRIMARY KEY,

    NguoiDungId INT NOT NULL UNIQUE,

    MaGiangVien VARCHAR(30) NOT NULL UNIQUE,

    KhoaId INT NOT NULL,

    HocVi NVARCHAR(100) NULL,

    ChuyenMon NVARCHAR(200) NULL,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_GiangViens_NguoiDungs
        FOREIGN KEY (NguoiDungId)
        REFERENCES NguoiDungs(NguoiDungId),

    CONSTRAINT FK_GiangViens_Khoas
        FOREIGN KEY (KhoaId)
        REFERENCES Khoas(KhoaId)
);
GO


/* ============================================================
   8. BẢNG HỌC PHẦN
   ============================================================ */

CREATE TABLE HocPhans
(
    HocPhanId INT IDENTITY(1,1) PRIMARY KEY,

    MaHocPhan VARCHAR(30) NOT NULL UNIQUE,

    TenHocPhan NVARCHAR(300) NOT NULL,

    SoTinChi INT NOT NULL,

    KhoaId INT NULL,

    MoTa NVARCHAR(1000) NULL,

    TrangThai BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_HocPhans_SoTinChi
        CHECK (SoTinChi > 0),

    CONSTRAINT FK_HocPhans_Khoas
        FOREIGN KEY (KhoaId)
        REFERENCES Khoas(KhoaId)
);
GO


/* ============================================================
   9. BẢNG LỚP HỌC PHẦN
   ============================================================ */

CREATE TABLE LopHocPhans
(
    LopHocPhanId INT IDENTITY(1,1) PRIMARY KEY,

    MaLopHocPhan VARCHAR(50) NOT NULL,

    TenLopHocPhan NVARCHAR(300) NULL,

    HocPhanId INT NOT NULL,

    HocKyId INT NOT NULL,

    KhoaId INT NOT NULL,

    SoLuongToiDa INT NULL,

    TrangThai BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_LopHocPhans_MaLop_HocKy
        UNIQUE (MaLopHocPhan, HocKyId),

    CONSTRAINT CK_LopHocPhans_SoLuong
        CHECK (
            SoLuongToiDa IS NULL
            OR SoLuongToiDa > 0
        ),

    CONSTRAINT FK_LopHocPhans_HocPhans
        FOREIGN KEY (HocPhanId)
        REFERENCES HocPhans(HocPhanId),

    CONSTRAINT FK_LopHocPhans_HocKys
        FOREIGN KEY (HocKyId)
        REFERENCES HocKys(HocKyId),

    CONSTRAINT FK_LopHocPhans_Khoas
        FOREIGN KEY (KhoaId)
        REFERENCES Khoas(KhoaId)
);
GO


/* ============================================================
   10. BẢNG PHÂN CÔNG GIẢNG VIÊN
   ============================================================ */

CREATE TABLE PhanCongGiangViens
(
    PhanCongId INT IDENTITY(1,1) PRIMARY KEY,

    LopHocPhanId INT NOT NULL,

    GiangVienId INT NOT NULL,

    VaiTro NVARCHAR(100)
        NOT NULL
        DEFAULT N'Giảng viên phụ trách',

    NgayPhanCong DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    TrangThai BIT
        NOT NULL
        DEFAULT 1,

    CONSTRAINT UQ_PhanCongGiangVien
        UNIQUE (LopHocPhanId, GiangVienId),

    CONSTRAINT FK_PhanCongGiangViens_LopHocPhans
        FOREIGN KEY (LopHocPhanId)
        REFERENCES LopHocPhans(LopHocPhanId),

    CONSTRAINT FK_PhanCongGiangViens_GiangViens
        FOREIGN KEY (GiangVienId)
        REFERENCES GiangViens(GiangVienId)
);
GO


/* ============================================================
   11. BẢNG SINH VIÊN - LỚP HỌC PHẦN
   ============================================================ */

CREATE TABLE SinhVienLopHocPhans
(
    SinhVienLopHocPhanId INT IDENTITY(1,1) PRIMARY KEY,

    SinhVienId INT NOT NULL,

    LopHocPhanId INT NOT NULL,

    NgayThamGia DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    TrangThai BIT
        NOT NULL
        DEFAULT 1,

    CONSTRAINT UQ_SinhVien_LopHocPhan
        UNIQUE (SinhVienId, LopHocPhanId),

    CONSTRAINT FK_SinhVienLopHocPhans_SinhViens
        FOREIGN KEY (SinhVienId)
        REFERENCES SinhViens(SinhVienId),

    CONSTRAINT FK_SinhVienLopHocPhans_LopHocPhans
        FOREIGN KEY (LopHocPhanId)
        REFERENCES LopHocPhans(LopHocPhanId)
);
GO


/* ============================================================
   12. BẢNG ĐỢT ĐĂNG KÝ ĐỒ ÁN
   ============================================================ */

CREATE TABLE DotDangKyDoAns
(
    DotDangKyId INT IDENTITY(1,1) PRIMARY KEY,

    LopHocPhanId INT NOT NULL,

    TenDot NVARCHAR(200) NOT NULL,

    NgayBatDau DATETIME NOT NULL,

    NgayKetThuc DATETIME NOT NULL,

    MinMembers INT NOT NULL,

    MaxMembers INT NOT NULL,

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Chưa mở',

    CreatedAt DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    CONSTRAINT CK_DotDangKyDoAns_Ngay
        CHECK (NgayKetThuc > NgayBatDau),

    CONSTRAINT CK_DotDangKyDoAns_ThanhVien
        CHECK
        (
            MinMembers > 0
            AND MaxMembers >= MinMembers
        ),

    CONSTRAINT FK_DotDangKyDoAns_LopHocPhans
        FOREIGN KEY (LopHocPhanId)
        REFERENCES LopHocPhans(LopHocPhanId)
);
GO


/* ============================================================
   13. BẢNG NHÓM ĐỒ ÁN
   ============================================================ */

CREATE TABLE NhomDoAns
(
    NhomId INT IDENTITY(1,1) PRIMARY KEY,

    DotDangKyId INT NOT NULL,

    TenNhom NVARCHAR(200) NOT NULL,

    TruongNhomId INT NOT NULL,

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Đang hoạt động',

    CreatedAt DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    UpdatedAt DATETIME NULL,

    CONSTRAINT FK_NhomDoAns_DotDangKy
        FOREIGN KEY (DotDangKyId)
        REFERENCES DotDangKyDoAns(DotDangKyId),

    CONSTRAINT FK_NhomDoAns_TruongNhom
        FOREIGN KEY (TruongNhomId)
        REFERENCES SinhViens(SinhVienId)
);
GO


/* ============================================================
   14. BẢNG THÀNH VIÊN NHÓM
   ============================================================ */

CREATE TABLE ThanhVienNhoms
(
    ThanhVienNhomId INT IDENTITY(1,1) PRIMARY KEY,

    NhomId INT NOT NULL,

    SinhVienId INT NOT NULL,

    VaiTro NVARCHAR(50)
        NOT NULL
        DEFAULT N'Thành viên',

    NgayThamGia DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Đã tham gia',

    CONSTRAINT UQ_ThanhVienNhom
        UNIQUE (NhomId, SinhVienId),

    CONSTRAINT FK_ThanhVienNhoms_NhomDoAns
        FOREIGN KEY (NhomId)
        REFERENCES NhomDoAns(NhomId),

    CONSTRAINT FK_ThanhVienNhoms_SinhViens
        FOREIGN KEY (SinhVienId)
        REFERENCES SinhViens(SinhVienId)
);
GO


/* ============================================================
   15. BẢNG ĐỀ TÀI ĐỒ ÁN
   ============================================================ */

CREATE TABLE DeTaiDoAns
(
    DeTaiId INT IDENTITY(1,1) PRIMARY KEY,

    DotDangKyId INT NOT NULL,

    TenDeTai NVARCHAR(500) NOT NULL,

    MoTa NVARCHAR(MAX) NULL,

    NguonDeTai NVARCHAR(50) NOT NULL,

    GiangVienId INT NULL,

    SinhVienDeXuatId INT NULL,

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Chưa sử dụng',

    TrangThaiDuyet NVARCHAR(50)
        NOT NULL
        DEFAULT N'Đã duyệt',

    CreatedAt DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    UpdatedAt DATETIME NULL,

    CONSTRAINT CK_DeTaiDoAns_Nguon
        CHECK
        (
            NguonDeTai IN
            (
                N'Giảng viên',
                N'Sinh viên đề xuất',
                N'AI hỗ trợ'
            )
        ),

    CONSTRAINT FK_DeTaiDoAns_DotDangKy
        FOREIGN KEY (DotDangKyId)
        REFERENCES DotDangKyDoAns(DotDangKyId),

    CONSTRAINT FK_DeTaiDoAns_GiangViens
        FOREIGN KEY (GiangVienId)
        REFERENCES GiangViens(GiangVienId),

    CONSTRAINT FK_DeTaiDoAns_SinhViens
        FOREIGN KEY (SinhVienDeXuatId)
        REFERENCES SinhViens(SinhVienId)
);
GO


/* ============================================================
   16. BẢNG ĐĂNG KÝ ĐỀ TÀI
   ============================================================ */

CREATE TABLE DangKyDeTais
(
    DangKyDeTaiId INT IDENTITY(1,1) PRIMARY KEY,

    NhomId INT NOT NULL,

    DeTaiId INT NOT NULL,

    NgayDangKy DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Chờ duyệt',

    GhiChu NVARCHAR(1000) NULL,

    NgayDuyet DATETIME NULL,

    GiangVienDuyetId INT NULL,

    CONSTRAINT UQ_DangKyDeTai
        UNIQUE (NhomId, DeTaiId),

    CONSTRAINT FK_DangKyDeTais_NhomDoAns
        FOREIGN KEY (NhomId)
        REFERENCES NhomDoAns(NhomId),

    CONSTRAINT FK_DangKyDeTais_DeTaiDoAns
        FOREIGN KEY (DeTaiId)
        REFERENCES DeTaiDoAns(DeTaiId),

    CONSTRAINT FK_DangKyDeTais_GiangViens
        FOREIGN KEY (GiangVienDuyetId)
        REFERENCES GiangViens(GiangVienId)
);
GO


/* ============================================================
   17. BẢNG TIN NHẮN NHÓM
   ============================================================ */

CREATE TABLE TinNhans
(
    TinNhanId INT IDENTITY(1,1) PRIMARY KEY,

    NhomId INT NOT NULL,

    NguoiGuiId INT NOT NULL,

    NoiDung NVARCHAR(MAX) NOT NULL,

    SentAt DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    IsDeleted BIT
        NOT NULL
        DEFAULT 0,

    CONSTRAINT FK_TinNhans_NhomDoAns
        FOREIGN KEY (NhomId)
        REFERENCES NhomDoAns(NhomId),

    CONSTRAINT FK_TinNhans_NguoiDungs
        FOREIGN KEY (NguoiGuiId)
        REFERENCES NguoiDungs(NguoiDungId)
);
GO


/* ============================================================
   18. BẢNG OTP QUÊN MẬT KHẨU
   ============================================================ */

CREATE TABLE PasswordResetOtps
(
    OtpId INT IDENTITY(1,1) PRIMARY KEY,

    NguoiDungId INT NOT NULL,

    OtpCodeHash NVARCHAR(500) NOT NULL,

    ExpiredAt DATETIME NOT NULL,

    IsUsed BIT
        NOT NULL
        DEFAULT 0,

    CreatedAt DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    CONSTRAINT FK_PasswordResetOtps_NguoiDungs
        FOREIGN KEY (NguoiDungId)
        REFERENCES NguoiDungs(NguoiDungId)
);
GO


/* ============================================================
   19. BẢNG LỊCH SỬ AI
   ============================================================ */

CREATE TABLE AIRequests
(
    AIRequestId INT IDENTITY(1,1) PRIMARY KEY,

    NguoiDungId INT NOT NULL,

    ChucNangAI NVARCHAR(100) NOT NULL,

    Prompt NVARCHAR(MAX) NOT NULL,

    Response NVARCHAR(MAX) NULL,

    CreatedAt DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    CONSTRAINT FK_AIRequests_NguoiDungs
        FOREIGN KEY (NguoiDungId)
        REFERENCES NguoiDungs(NguoiDungId)
);
GO


/* ============================================================
   20. BẢNG ĐỢT IMPORT DỮ LIỆU
   ============================================================ */

CREATE TABLE DotImports
(
    DotImportId INT IDENTITY(1,1) PRIMARY KEY,

    LoaiDuLieu NVARCHAR(100) NOT NULL,

    TenFile NVARCHAR(500) NOT NULL,

    NguoiImportId INT NOT NULL,

    TongSoDong INT
        NOT NULL
        DEFAULT 0,

    SoDongThanhCong INT
        NOT NULL
        DEFAULT 0,

    SoDongLoi INT
        NOT NULL
        DEFAULT 0,

    TrangThai NVARCHAR(50)
        NOT NULL
        DEFAULT N'Đang xử lý',

    CreatedAt DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    CONSTRAINT FK_DotImports_NguoiDungs
        FOREIGN KEY (NguoiImportId)
        REFERENCES NguoiDungs(NguoiDungId)
);
GO


/* ============================================================
   21. BẢNG LỖI IMPORT
   ============================================================ */

CREATE TABLE LoiImports
(
    LoiImportId INT IDENTITY(1,1) PRIMARY KEY,

    DotImportId INT NOT NULL,

    SoDong INT NOT NULL,

    TenCot NVARCHAR(200) NULL,

    NoiDungLoi NVARCHAR(1000) NOT NULL,

    CreatedAt DATETIME
        NOT NULL
        DEFAULT GETDATE(),

    CONSTRAINT FK_LoiImports_DotImports
        FOREIGN KEY (DotImportId)
        REFERENCES DotImports(DotImportId)
);
GO


/* ============================================================
   22. INDEX
   ============================================================ */

CREATE INDEX IX_SinhViens_MSSV
ON SinhViens(MSSV);
GO


CREATE INDEX IX_GiangViens_MaGiangVien
ON GiangViens(MaGiangVien);
GO


CREATE INDEX IX_LopHocPhans_HocPhanId
ON LopHocPhans(HocPhanId);
GO


CREATE INDEX IX_LopHocPhans_HocKyId
ON LopHocPhans(HocKyId);
GO


CREATE INDEX IX_SinhVienLopHocPhans_SinhVienId
ON SinhVienLopHocPhans(SinhVienId);
GO


CREATE INDEX IX_SinhVienLopHocPhans_LopHocPhanId
ON SinhVienLopHocPhans(LopHocPhanId);
GO


CREATE INDEX IX_PhanCongGiangViens_LopHocPhanId
ON PhanCongGiangViens(LopHocPhanId);
GO


CREATE INDEX IX_PhanCongGiangViens_GiangVienId
ON PhanCongGiangViens(GiangVienId);
GO


CREATE INDEX IX_DotDangKyDoAns_LopHocPhanId
ON DotDangKyDoAns(LopHocPhanId);
GO


CREATE INDEX IX_NhomDoAns_DotDangKyId
ON NhomDoAns(DotDangKyId);
GO


CREATE INDEX IX_ThanhVienNhoms_NhomId
ON ThanhVienNhoms(NhomId);
GO


CREATE INDEX IX_ThanhVienNhoms_SinhVienId
ON ThanhVienNhoms(SinhVienId);
GO


CREATE INDEX IX_DeTaiDoAns_DotDangKyId
ON DeTaiDoAns(DotDangKyId);
GO


CREATE INDEX IX_DangKyDeTais_NhomId
ON DangKyDeTais(NhomId);
GO


CREATE INDEX IX_DangKyDeTais_DeTaiId
ON DangKyDeTais(DeTaiId);
GO


CREATE INDEX IX_TinNhans_NhomId
ON TinNhans(NhomId);
GO


CREATE INDEX IX_AIRequests_NguoiDungId
ON AIRequests(NguoiDungId);
GO


/* ============================================================
   HOÀN THÀNH DATABASE
   ============================================================ */

PRINT N'Đã tạo thành công Database ProjectRegistrationDB';
GO