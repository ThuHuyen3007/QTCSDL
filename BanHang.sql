create database BanHang
go
use Banhang
go
create table LoaiHang
(
	MaLoai int,
	TenLoai nvarchar(100),
	primary key(MaLoai)
)
go
create table Hang
(
	MaHang int,
	TenHang nvarchar(100),
	GiaNhap numeric (12,0),
	GiaBan numeric (12,0),
	DonViTinh nvarchar(50),
	SoLuongTon int,
	KhuyenMai float, --tính theo % giá bán
	MaLoai int,
	primary key(MaHang),
	foreign key (MaLoai) references LoaiHang
)
go
create table Khach
(
	SoDT varchar(15),
	HoTen nvarchar(100),
	LoaiKhach char(1),  --0: khach thuong, 1: khach quen
	primary key(SoDT)
)
go
create table DonBan
(
	MaDonBan int,
	SoDT varchar(15),
	Ngay date,
	ThoiGian time,
	TongTien numeric(12,0),
	primary key(MaDonBan),
	foreign key (SoDT) references Khach
)
go
create table DonBanChiTiet
(
	MaDonBan int,
	MaHang int,
	SoLuong int,
	ThanhTien numeric(12,0),
	foreign key (MaHang) references Hang,
	foreign key (MaDonBan) references DonBan
)
go
create table CongNo --công nợ
(
	MaCN int,
	SoDT varchar(15),
	SoTien numeric(12,0),
	TrangThai char(1), --0: chưa trả, 1: đã trả
	primary key(MaCN),
	foreign key (SoDT) references Khach
)
go
insert into LoaiHang values(1,N'Thực phẩm khô')
insert into LoaiHang values(2,N'Đồ uống')
insert into LoaiHang values(3,N'Đồ dùng gia đình')
insert into LoaiHang values(4,N'Đồ dùng học tập')
go
insert into Hang values(1, N'Mì Hảo Hảo chua cay', 3500,4000,'gói',100,0,1)
insert into Hang values(2, N'Miến Phú Hương vị sườn heo', 8500,10000,'gói',150,0,1)
insert into Hang values(3, N'Gia vị lẩu thái', 15000,17000,'hộp',89,0.05,1)
insert into Hang values(4, N'Bánh tráng Quảng Nam', 6000,8000,'gói',50,0,1)

insert into Hang values(5, N'Sữa Vinamilk ít đường 180ml', 6500,7000,'hộp',300,0,2)
insert into Hang values(6, N'Stink', 6100,9000,'chai',300,0,2)
insert into Hang values(7, N'Nước tinh khiết 350ml', 1500,4000,'chai',100,0,2)

insert into Hang values(8, N'Bút bi Thiên Long ngòi nhỏ', 4500,5000,'chiếc',300,0,4)
insert into Hang values(9, N'Bảng nhóm', 12000,15000,'chiếc',50,0,4)
go
insert into Khach values ('0981234561',N'chị Hòa', 0)
insert into Khach values ('0971987122',N'chị Ninh', 1)
insert into Khach values ('0905112324',N'anh Tín', 0)
insert into Khach values ('0961198042',N'chị Lan', 1)
go
insert into DonBan values(1, '0971987122', '2022-09-10', '10:00', 40000)
insert into DonBan values(2, '0905112324', '2022-08-19', '13:00', 50000)
go
insert into DonBanChiTiet values(1, 1, 10, 40000)
insert into DonBanChiTiet values(2, 8, 5, 40000)
insert into DonBanChiTiet values(2, 5, 2, 10000)
go
insert into CongNo values (1, '0905112324', 100000, 0)
insert into CongNo values (2, '0981234561', 20000, 1)
insert into CongNo values (3, '0961198042', 900000, 1)
insert into CongNo values (4, '0961198042', 80000, 0)
insert into CongNo values (5, '0971987122', 120000, 0)

