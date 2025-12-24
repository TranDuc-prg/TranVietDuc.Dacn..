/* =========================================================
   1. XÓA CSDL CŨ VÀ TẠO CSDL MỚI (DDL)
========================================================= */

-- Di chuyển sang master để đảm bảo có thể thao tác với database mục tiêu
USE master; 
GO

/* Nếu database đã tồn tại => ngắt kết nối và xóa để tạo mới */
IF DB_ID('QuanLyBanHang') IS NOT NULL
BEGIN
    -- Đặt database vào chế độ single-user để ngắt kết nối
    ALTER DATABASE QuanLyBanHang SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    -- Xóa database
    DROP DATABASE QuanLyBanHang;
END
GO

-- Tạo cơ sở dữ liệu mới
CREATE DATABASE QuanLyBanHang;
GO

-- Chuyển sang sử dụng database mới
USE QuanLyBanHang;
GO

/* =========================================================
   2. TẠO CẤU TRÚC BẢNG (DDL) - Đã sửa lỗi FK và thêm NOT NULL
========================================================= */

/* BẢNG HỆ THỐNG */
CREATE TABLE HeThong (
    id INT IDENTITY PRIMARY KEY,
    hienThiThongBao NVARCHAR(255) NOT NULL,
    luuDuLieu NVARCHAR(255) NOT NULL,
    thongKeBaoCao NVARCHAR(255) NOT NULL
);

/* BẢNG TÀI KHOẢN */
CREATE TABLE TaiKhoan (
    tenDangNhap VARCHAR(50) PRIMARY KEY,
    matKhau VARCHAR(255) NOT NULL
);

/* ADMIN (Sử dụng tên cột: tenDangNhap) */
CREATE TABLE Admin (
    maAdmin INT IDENTITY PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    email VARCHAR(100),
    tenDangNhap VARCHAR(50) UNIQUE NOT NULL, 
    quanLySP INT NULL,
    duyetNCC INT NULL,
    quanLyDonHang INT NULL,
    FOREIGN KEY (tenDangNhap) REFERENCES TaiKhoan(tenDangNhap)
);

/* NHÂN VIÊN (Sử dụng tên cột: tenDangNhap) */
CREATE TABLE NhanVien (
    maNV INT IDENTITY PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    email VARCHAR(100),
    soDienThoai VARCHAR(20),
    tenDangNhap VARCHAR(50) UNIQUE NOT NULL, 
    FOREIGN KEY (tenDangNhap) REFERENCES TaiKhoan(tenDangNhap)
);

/* KHÁCH HÀNG (Sử dụng tên cột: tenDangNhap) */
CREATE TABLE KhachHang (
    maKH INT IDENTITY PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    diaChi NVARCHAR(255),
    email VARCHAR(100),
    soDienThoai VARCHAR(20),
    tenDangNhap VARCHAR(50) UNIQUE NOT NULL, 
    FOREIGN KEY (tenDangNhap) REFERENCES TaiKhoan(tenDangNhap)
);

/* NHÀ CUNG CẤP */
CREATE TABLE NhaCC (
    maNCC INT IDENTITY PRIMARY KEY,
    tenNCC NVARCHAR(100) NOT NULL,
    diaChi NVARCHAR(255),
    soDienThoai VARCHAR(20),
    trangThaiDuyet NVARCHAR(100)
);

/* SẢN PHẨM */
CREATE TABLE SanPham (
    maSP INT IDENTITY PRIMARY KEY,
    tenSP NVARCHAR(100) NOT NULL,
    loaiSP NVARCHAR(100),
    giaBan FLOAT NOT NULL, 
    maNCC INT NOT NULL, 
    FOREIGN KEY (maNCC) REFERENCES NhaCC(maNCC)
);

/* CHƯƠNG TRÌNH KHUYẾN MÃI */
CREATE TABLE ChuongTrinhKhuyenMai (
    maKM INT IDENTITY PRIMARY KEY,
    tenKM NVARCHAR(100) NOT NULL,
    ngayBatDau DATE NOT NULL,
    ngayKetThuc DATE NOT NULL,
    phanTramGiamGia FLOAT NOT NULL
);

/* HÓA ĐƠN */
CREATE TABLE HoaDon (
    maHD INT IDENTITY PRIMARY KEY,
    ngayLap DATE NOT NULL,
    tongTien FLOAT NOT NULL,
    giamGia FLOAT NOT NULL,
    thanhTien FLOAT NOT NULL,
    maKH INT NOT NULL,
    maNV INT NOT NULL,
    FOREIGN KEY (maKH) REFERENCES KhachHang(maKH),
    FOREIGN KEY (maNV) REFERENCES NhanVien(maNV)
);

/* CHI TIẾT HÓA ĐƠN */
CREATE TABLE ChiTietHoaDon (
    maHD INT NOT NULL,
    maSP INT NOT NULL,
    soLuong INT NOT NULL,
    donGia FLOAT NOT NULL,
    PRIMARY KEY(maHD, maSP),
    FOREIGN KEY (maHD) REFERENCES HoaDon(maHD),
    FOREIGN KEY (maSP) REFERENCES SanPham(maSP)
);
GO

/* =========================================================
   3. THÊM DỮ LIỆU MẪU (DML) - Đã cập nhật tên cột
========================================================= */

-- 1. TaiKhoan
INSERT INTO TaiKhoan (tenDangNhap, matKhau) VALUES
('admin01', 'pass_admin'),
('nv_a', 'pass_nv'),
('kh_binh', 'pass_kh'),
('ncc_gom', 'pass_ncc');

-- 2. Admin
INSERT INTO Admin (hoTen, email, tenDangNhap) VALUES 
(N'Lý Thu Hằng', 'lyhang@email.com', 'admin01');

-- 3. NhanVien
INSERT INTO NhanVien (hoTen, email, soDienThoai, tenDangNhap) VALUES
(N'Trần Văn An', 'an@email.com', '0901234567', 'nv_a');

-- 4. KhachHang
INSERT INTO KhachHang (hoTen, diaChi, email, soDienThoai, tenDangNhap) VALUES
(N'Nguyễn Văn Bình', N'123 Trần Hưng Đạo, Q.1', 'binh@email.com', '0912345678', 'kh_binh');

-- 5. NhaCC
INSERT INTO NhaCC (tenNCC, diaChi, soDienThoai, trangThaiDuyet) VALUES
(N'Gốm Sứ Bát Tràng', N'Gia Lâm, Hà Nội', '024111222', N'Đã duyệt'),
(N'Tranh Thêu Lụa', N'Hà Đông, Hà Nội', '024333444', N'Đã duyệt');

-- 6. SanPham
INSERT INTO SanPham (tenSP, loaiSP, giaBan, maNCC) VALUES
(N'Bình gốm Họa Long', N'Gốm', 450000, 1),
(N'Bộ ấm trà Sứ Trắng', N'Sứ', 200000, 1),
(N'Tranh thêu Hoa Sen', N'Tranh', 1200000, 2);

-- 7. HoaDon
INSERT INTO HoaDon (ngayLap, tongTien, giamGia, thanhTien, maKH, maNV) VALUES
('2025-11-28', 650000, 50000, 600000, 1, 1);

-- 8. ChiTietHoaDon
INSERT INTO ChiTietHoaDon (maHD, maSP, soLuong, donGia) VALUES
(1, 1, 1, 450000), -- 1 Bình gốm
(1, 2, 1, 200000); -- 1 Bộ ấm trà

-- 9. ChuongTrinhKhuyenMai
INSERT INTO ChuongTrinhKhuyenMai (tenKM, ngayBatDau, ngayKetThuc, phanTramGiamGia) VALUES
(N'Giảm 10% cho Gốm', '2025-12-01', '2025-12-31', 0.10);
GO

/* =========================================================
   4. PHÂN QUYỀN VÀ CẤP QUYỀN (DCL) - Đã thêm logic kiểm tra ROLE
========================================================= */

-- Kiểm tra và xóa ROLE nếu đã tồn tại để tránh lỗi "already exists"
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_Admin' AND type = 'R') DROP ROLE role_Admin;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_NhanVien' AND type = 'R') DROP ROLE role_NhanVien;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_KhachHang' AND type = 'R') DROP ROLE role_KhachHang;

-- Tạo lại các ROLE
CREATE ROLE role_Admin;
CREATE ROLE role_NhanVien;
CREATE ROLE role_KhachHang;
GO

/* Cấp quyền */

-- Quyền Admin (Toàn quyền quản lý)
GRANT CONTROL ON DATABASE::QuanLyBanHang TO role_Admin;

-- Quyền Nhân viên (Quản lý sản phẩm, NCC, và đơn hàng)
GRANT SELECT, INSERT, UPDATE, DELETE ON SanPham TO role_NhanVien;
GRANT SELECT, INSERT, UPDATE, DELETE ON NhaCC TO role_NhanVien;
GRANT SELECT ON KhachHang TO role_NhanVien;
GRANT SELECT, INSERT, UPDATE, DELETE ON HoaDon TO role_NhanVien;
GRANT SELECT, INSERT, UPDATE, DELETE ON ChiTietHoaDon TO role_NhanVien;

-- Quyền Khách hàng (Xem, tạo đơn hàng, xem hóa đơn của mình)
GRANT SELECT ON SanPham TO role_KhachHang;
GRANT SELECT ON ChuongTrinhKhuyenMai TO role_KhachHang;
GRANT SELECT, INSERT ON HoaDon TO role_KhachHang; 
GRANT INSERT ON ChiTietHoaDon TO role_KhachHang;
GO

/* =========================================================
   5. LỆNH IN THÔNG TIN (SELECT FULL)
========================================================= */

-- IN NHÂN VIÊN
SELECT * FROM NhanVien;

-- IN KHÁCH HÀNG
SELECT * FROM KhachHang;

-- IN ADMIN
SELECT * FROM Admin;

-- IN NHÀ CUNG CẤP
SELECT * FROM NhaCC;

-- IN SẢN PHẨM + TÊN NHÀ CUNG CẤP
SELECT SP.maSP, SP.tenSP, SP.loaiSP, SP.giaBan, NCC.tenNCC
FROM SanPham SP
LEFT JOIN NhaCC NCC ON SP.maNCC = NCC.maNCC;

-- IN HÓA ĐƠN + KHÁCH HÀNG + NHÂN VIÊN
SELECT HD.maHD, HD.ngayLap, HD.tongTien, HD.giamGia, HD.thanhTien,
       KH.hoTen AS TenKhachHang,
       NV.hoTen AS TenNhanVien
FROM HoaDon HD
LEFT JOIN KhachHang KH ON HD.maKH = KH.maKH
LEFT JOIN NhanVien NV ON HD.maNV = NV.maNV;

-- IN CHI TIẾT HÓA ĐƠN ĐẦY ĐỦ
SELECT HD.maHD, SP.tenSP, CTHD.soLuong, CTHD.donGia, 
       (CTHD.soLuong * CTHD.donGia) AS ThanhTien
FROM ChiTietHoaDon CTHD
JOIN HoaDon HD ON CTHD.maHD = HD.maHD
JOIN SanPham SP ON CTHD.maSP = SP.maSP;

-- IN TOÀN BỘ HỆ THỐNG
SELECT * FROM HeThong;