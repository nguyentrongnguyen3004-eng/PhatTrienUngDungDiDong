-- =============================================================================
-- BÀI 10 - CHƯƠNG 6: XÂY DỰNG VÀ SỬ DỤNG API
-- BÀI TẬP 02: CƠ SỞ DỮ LIỆU QUẢN LÝ CÁC LOẠI ĐỒ ÁN & CHUYÊN NGÀNH (SQL SERVER)
-- =============================================================================

USE master;
GO

IF DB_ID('Lab10_QuanLyDeTaiDB') IS NOT NULL
BEGIN
    ALTER DATABASE Lab10_QuanLyDeTaiDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Lab10_QuanLyDeTaiDB;
END
GO

CREATE DATABASE Lab10_QuanLyDeTaiDB;
GO

USE Lab10_QuanLyDeTaiDB;
GO

-- =============================================================================
-- 1. BẢNG LOẠI ĐỀ TÀI (Đồ án, KLKS, Luận văn, Khác)
-- =============================================================================
CREATE TABLE tblLoaiDeTai (
    MaLoai VARCHAR(15) PRIMARY KEY,
    TenLoai NVARCHAR(50) NOT NULL,
    TenDayDu NVARCHAR(150) NOT NULL,
    MoTa NVARCHAR(300) NULL,
    SoTinChi INT DEFAULT 3,
    ThoiGianTuan INT DEFAULT 15
);
GO

-- =============================================================================
-- 2. BẢNG CHUYÊN NGÀNH THỰC HIỆN (CNPM, HTTT, MMT, ATTT...)
-- =============================================================================
CREATE TABLE tblChuyenNganh (
    MaCN VARCHAR(15) PRIMARY KEY,
    TenCN NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(300) NOT NULL,
    MaThongBao VARCHAR(20) NOT NULL,
    TruongBoMon NVARCHAR(100) NULL,
    IconName VARCHAR(50) DEFAULT 'school'
);
GO

-- =============================================================================
-- 3. BẢNG ĐỀ TÀI ĐỒ ÁN CHI TIẾT (Liên kết Loại đề tài & Chuyên ngành)
-- =============================================================================
CREATE TABLE tblDeTai (
    MaDeTai VARCHAR(15) PRIMARY KEY,
    TenDeTai NVARCHAR(250) NOT NULL,
    TenGiangVien NVARCHAR(100) NOT NULL,
    NoiDung NVARCHAR(500) NOT NULL,
    YeuCau NVARCHAR(400) NULL,
    SoLuongSV INT DEFAULT 2,
    HocKy NVARCHAR(30) DEFAULT N'HK2 (2025-2026)',
    TrangThai NVARCHAR(50) DEFAULT N'Đang mở đăng ký',
    MaLoai VARCHAR(15) NOT NULL,
    MaCN VARCHAR(15) NOT NULL,
    CONSTRAINT FK_DeTai_LoaiDeTai FOREIGN KEY (MaLoai) REFERENCES tblLoaiDeTai(MaLoai) ON DELETE CASCADE,
    CONSTRAINT FK_DeTai_ChuyenNganh FOREIGN KEY (MaCN) REFERENCES tblChuyenNganh(MaCN) ON DELETE CASCADE
);
GO

-- =============================================================================
-- DỮ LIỆU MẪU: BẢNG LOẠI ĐỀ TÀI (tblLoaiDeTai)
-- =============================================================================
INSERT INTO tblLoaiDeTai (MaLoai, TenLoai, TenDayDu, MoTa, SoTinChi, ThoiGianTuan) VALUES
('DA',   N'Đồ án',    N'Đồ án chuyên ngành CNTT',          N'Đồ án thực hành xây dựng ứng dụng hoặc hệ thống phần mềm theo chuyên ngành.', 2, 12),
('KLKS', N'KLKS',     N'Khóa luận tốt nghiệp Kỹ sư',       N'Khóa luận dành cho sinh viên hệ Kỹ sư giải quyết bài toán kỹ thuật chuyên sâu.', 4, 15),
('LV',   N'Luận văn', N'Luận văn tốt nghiệp Cử nhân/ThS',  N'Công trình nghiên cứu lý thuyết và thực nghiệm chuyên sâu có tính học thuật cao.', 4, 16),
('KHAC', N'Khác',     N'Đề tài Nghiên cứu khoa học SV',    N'Đề tài NCKH cấp Khoa/Trường, dự án khởi nghiệp hoặc cuộc thi học thuật.', 3, 20);
GO

-- =============================================================================
-- DỮ LIỆU MẪU: BẢNG CHUYÊN NGÀNH (tblChuyenNganh)
-- =============================================================================
INSERT INTO tblChuyenNganh (MaCN, TenCN, MoTa, MaThongBao, TruongBoMon, IconName) VALUES
('CNPM', N'Công nghệ phần mềm', N'Phát triển các ứng dụng giải quyết các vấn đề thực tế',       'CNPM', N'ThS. Vũ Văn Vinh',      'code'),
('HTTT', N'Hệ thống thông tin', N'Phát triển các kỹ thuật xử lý thông tin trong tổ chức',      'HTTT', N'ThS. Nguyễn Văn Lễ',    'storage'),
('MMT',  N'Mạng máy tính',      N'Xử lý các vấn đề liên quan đến mạng máy tính',               'MMT',  N'TS. Vũ Đức Thịnh',      'lan'),
('ATTT', N'An toàn thông tin',  N'Thiết kế và đảm bảo an toàn cho hệ thống máy tính',          'BMTT', N'TS. Lê Hoàng Nam',      'security'),
('KHMT', N'Khoa học dữ liệu & AI', N'Nghiên cứu Trí tuệ nhân tạo, Học máy và Khai phá dữ liệu', 'KHMT', N'PGS.TS. Trần Minh Quân', 'psychology');
GO

-- =============================================================================
-- DỮ LIỆU MẪU PHONG PHÚ: BẢNG ĐỀ TÀI (tblDeTai) - 20 ĐỀ TÀI
-- =============================================================================
INSERT INTO tblDeTai (MaDeTai, TenDeTai, TenGiangVien, NoiDung, YeuCau, SoLuongSV, HocKy, TrangThai, MaLoai, MaCN) VALUES
-- Chuyên ngành Công nghệ phần mềm (CNPM)
('DT01', N'Khai thác tập hữu ích cao trên CSDL giao dịch', 
 N'ThS. Vũ Văn Vinh', 
 N'Khai phá tập HUI, tìm hiểu và vận dụng các kỹ thuật tỉa hiệu quả để giảm bớt không gian tìm kiếm.', 
 N'Nắm vững cấu trúc dữ liệu, giải thuật và ngôn ngữ C#/Python.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'DA', 'CNPM'),

('DT02', N'Xây dựng ứng dụng di động đăng ký đồ án & khóa luận bằng Flutter và .NET Core API', 
 N'ThS. Vũ Văn Vinh', 
 N'Phát triển hệ thống kết nối Flutter Mobile App với ASP.NET Core Web API và SQL Server hỗ trợ sinh viên đăng ký đề tài trực tuyến.', 
 N'Thành thạo Flutter, RESTful API, Entity Framework Core và SQL Server.', 3, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'DA', 'CNPM'),

('DT03', N'Xây dựng hệ thống thương mại điện tử đa nền tảng tích hợp gợi ý sản phẩm thông minh', 
 N'ThS. Trần Thị Mai', 
 N'Thiết kế kiến trúc Microservices cho sàn TMĐT trên Web và Mobile, tích hợp bộ lọc cộng tác gợi ý sản phẩm theo hành vi người dùng.', 
 N'Biết Flutter/React, ASP.NET Core Web API, Docker và SQL Server.', 3, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'KLKS', 'CNPM'),

('DT04', N'Nghiên cứu kiến trúc Clean Architecture và áp dụng xây dựng hệ thống quản lý bệnh viện thông minh', 
 N'TS. Nguyễn Hoàng Việt', 
 N'Áp dụng Domain-Driven Design (DDD) và Clean Architecture trên nền tảng .NET 8 kết hợp ứng dụng đặt lịch khám trên di động.', 
 N'Hiểu rõ mẫu thiết kế phần mềm, SOLID, Unit Test và CI/CD.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'LV', 'CNPM'),

('DT05', N'Ứng dụng AI hỗ trợ sinh viên tự động phân nhóm và quản lý tiến độ dự án học tập (ProGroup AI)', 
 N'ThS. Vũ Văn Vinh', 
 N'Tích hợp mô hình ngôn ngữ lớn (LLM) để phân tích kỹ năng sinh viên, gợi ý ghép nhóm tối ưu và theo dõi Kanban thời gian thực.', 
 N'Có kiến thức về Flutter, Firebase/SignalR, REST API và Gemini API.', 3, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'KHAC', 'CNPM'),

-- Chuyên ngành Hệ thống thông tin (HTTT)
('DT06', N'Xây dựng hệ thống thông tin hỗ trợ việc giảng dạy và quản lý học vụ tại HUIT', 
 N'ThS. Nguyễn Văn Lễ', 
 N'Phân tích thiết kế hệ thống quản lý lịch giảng, điểm danh QR Code, chấm điểm quá trình và thống kê báo cáo cho giảng viên.', 
 N'Nắm vững phân tích thiết kế HTTT (UML), SQL Server và lập trình Web/Mobile.', 3, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'DA', 'HTTT'),

('DT07', N'Xây dựng hệ thống ERP quản lý chuỗi cung ứng và kho vận thông minh cho doanh nghiệp vừa và nhỏ', 
 N'ThS. Nguyễn Văn Lễ', 
 N'Phát triển các phân hệ Quản lý mua hàng, Quản lý tồn kho thời gian thực bằng mã vạch và dự báo nhu cầu nhập hàng.', 
 N'Hiểu quy trình nghiệp vụ ERP, cơ sở dữ liệu quan hệ và báo cáo BI.', 3, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'KLKS', 'HTTT'),

('DT08', N'Tích hợp kho dữ liệu (Data Warehouse) và phân tích OLAP trong quản trị doanh thu bán lẻ', 
 N'TS. Phạm Thị Thu Hương', 
 N'Thiết kế lược đồ hình sao (Star Schema), xây dựng tiến trình ETL với SSIS và trực quan hóa dữ liệu đa chiều trên Power BI.', 
 N'Thành thạo SQL Server, SSIS, SSAS và Power BI.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'LV', 'HTTT'),

('DT09', N'Hệ thống thông tin địa lý (GIS) tra cứu quy hoạch và điểm thu gom rác thải xanh tại TP.HCM', 
 N'ThS. Đỗ Quốc Bảo', 
 N'Ứng dụng bản đồ số tích hợp dữ liệu không gian giúp người dân tra cứu điểm phân loại rác và tối ưu lộ trình xe thu gom.', 
 N'Biết sử dụng Google Maps SDK, Flutter và hệ quản trị CSDL không gian.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'KHAC', 'HTTT'),

-- Chuyên ngành Mạng máy tính (MMT)
('DT10', N'Khai thác K tập hữu ích cao nhất (topKHUI) trong phân tích lưu lượng mạng', 
 N'TS. Vũ Đức Thịnh', 
 N'Khai phá topKHUI kết hợp với việc tăng ngưỡng sớm để có được minUtil lớn nhất, từ đó áp dụng các chiến lược tỉa và tăng ngưỡng.', 
 N'Hiểu biết về khai phá dữ liệu và phân tích gói tin mạng.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'DA', 'MMT'),

('DT11', N'Thiết kế và triển khai hệ thống giám sát hạ tầng mạng doanh nghiệp tự động với Zabbix và Grafana', 
 N'TS. Vũ Đức Thịnh', 
 N'Xây dựng hệ thống thu thập số liệu SNMP, cảnh báo sự cố tức thời qua Telegram/Mobile App khi băng thông hoặc thiết bị vượt ngưỡng.', 
 N'Kiến thức quản trị mạng Linux, giao thức SNMP, Docker và định tuyến.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'KLKS', 'MMT'),

('DT12', N'Nghiên cứu giải pháp cân bằng tải và tối ưu hóa định tuyến trên mạng khả trình SDN (Software-Defined Networking)', 
 N'TS. Vũ Đức Thịnh', 
 N'Mô phỏng mạng SDN trên Mininet với Ryu Controller, xây dựng thuật toán định tuyến động giảm độ trễ và nghẽn mạch.', 
 N'Nắm vững kiến trúc mạng SDN, OpenFlow, Python và Linux.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'LV', 'MMT'),

('DT13', N'Xây dựng hệ thống nhà thông minh IoT giám sát môi trường và điều khiển thiết bị qua giao thức MQTT', 
 N'ThS. Lê Quang Huy', 
 N'Kết nối vi điều khiển ESP32 với cảm biến nhiệt độ, độ ẩm, khí gas truyền dữ liệu qua MQTT Broker lên ứng dụng Flutter.', 
 N'Biết lập trình nhúng ESP32/Arduino, giao thức MQTT và Flutter.', 3, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'KHAC', 'MMT'),

-- Chuyên ngành An toàn thông tin (ATTT)
('DT14', N'Phát hiện tấn công và ngăn ngừa phát tán mã độc trong hệ thống mạng nội bộ', 
 N'TS. Lê Hoàng Nam', 
 N'Nghiên cứu cơ chế hoạt động của IDS/IPS (Suricata/Snort), xây dựng bộ luật phát hiện sớm các hành vi quét cổng và phát tán mã độc.', 
 N'Kiến thức về an ninh mạng, phân tích gói tin Wireshark và hệ điều hành Linux.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'DA', 'ATTT'),

('DT15', N'Xây dựng hệ thống xác thực đa nhân tố (MFA) và quản lý định danh tập trung chuẩn OAuth2 / OpenID Connect', 
 N'TS. Lê Hoàng Nam', 
 N'Triển khai cổng xác thực tập trung SSO bảo vệ các dịch vụ Web API bằng JWT, chữ ký số RSA và xác thực sinh trắc học trên di động.', 
 N'Hiểu sâu về mật mã học, JWT, OAuth2, ASP.NET Core Identity và Bảo mật ứng dụng.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'KLKS', 'ATTT'),

('DT16', N'Ứng dụng Học sâu (Deep Learning) trong phát hiện tấn công DDoS và bất thường lưu lượng mạng', 
 N'TS. Lê Hoàng Nam', 
 N'Huấn luyện mô hình LSTM/CNN trên bộ dữ liệu CIC-IDS2017 để phân loại lưu lượng bình thường và các cuộc tấn công DDoS theo thời gian thực.', 
 N'Biết Python, TensorFlow/PyTorch và kiến thức bảo mật mạng.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'LV', 'ATTT'),

('DT17', N'Nghiên cứu kỹ thuật kiểm thử xâm nhập (Pentest) và đánh giá lỗ hổng bảo mật ứng dụng Web/API theo OWASP Top 10', 
 N'ThS. Phan Thanh Tùng', 
 N'Thực hiện rà quét, khai thác thử nghiệm các lỗ hổng SQL Injection, XSS, Broken Access Control và xây dựng giải pháp vá lỗi.', 
 N'Sử dụng thành thạo Burp Suite, OWASP ZAP, Kali Linux và hiểu rõ bảo mật Web.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'KHAC', 'ATTT'),

-- Chuyên ngành Khoa học dữ liệu & AI (KHMT)
('DT18', N'Xây dựng hệ thống nhận diện biển số xe và quản lý bãi đỗ xe thông minh bằng YOLOv8', 
 N'PGS.TS. Trần Minh Quân', 
 N'Ứng dụng thị giác máy tính (Computer Vision) phát hiện và đọc ký tự biển số xe Việt Nam theo thời gian thực kết hợp thanh toán tự động.', 
 N'Thành thạo Python, OpenCV, YOLO và lập trình giao diện.', 3, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'DA', 'KHMT'),

('DT19', N'Xây dựng trợ lý ảo hỏi đáp quy chế học vụ thông minh dựa trên kiến trúc RAG (Retrieval-Augmented Generation)', 
 N'PGS.TS. Trần Minh Quân', 
 N'Số hóa sổ tay sinh viên, lưu trữ Vector Database và kết hợp mô hình ngôn ngữ lớn để trả lời chính xác câu hỏi học vụ.', 
 N'Nắm vững NLP, Vector DB, LangChain/Python và xây dựng REST API.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'KLKS', 'KHMT'),

('DT20', N'Nghiên cứu mô hình Transformer trong phân tích cảm xúc bình luận tiếng Việt trên mạng xã hội', 
 N'PGS.TS. Trần Minh Quân', 
 N'Tinh chỉnh (Fine-tuning) mô hình PhoBERT để phân loại sắc thái bình luận và đánh giá phản hồi khách hàng tự động.', 
 N'Kiến thức tốt về Xử lý ngôn ngữ tự nhiên (NLP), Deep Learning và Python.', 2, N'HK2 (2025-2026)', N'Đang mở đăng ký', 'LV', 'KHMT');
GO

-- Kiểm tra dữ liệu đã tạo
SELECT * FROM tblLoaiDeTai;
SELECT * FROM tblChuyenNganh;
SELECT COUNT(*) AS TongSoDeTai FROM tblDeTai;
GO
