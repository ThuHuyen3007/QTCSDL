/*Câu 1. Viết module trả về mã hàng mới, biết rằng: mã hàng = MAX(mã hàng) + 1*/
/*Function
input:
output: MHNEW*/
select * from Hang
go
create function cau1()
returns int
as
begin
	declare @MHNEW int
	select @MHNEW = (max(MaHang)+1) from Hang
	return @MHNEW
end
--Thử
print dbo.cau1()
/*Câu 2. Viết module thực hiện việc thêm dữ liệu cho bảng DonBanChiTiet với 
tham số đầu vào là: mã đơn bán, mã hàng, số lượng. Công việc gồm:
a. Kiểm tra sự tồn tại của mã đơn bán. Nếu mã đơn bán không tồn tại trong bảng DonBan 
thì thông báo lỗi và kết thúc
b. Kiểm tra sự tồn tại của mã hàng. Nếu mã hàng không tồn tại trong bảng Hang thì thông báo lỗi và kết thúc
c. Kiểm tra số lượng hàng. Nếu nhỏ hơn hoặc bằng 0 thì thông báo lỗi và kết thúc
d. Tính ThanhTien = số lượng * giá bán của trong bảng HANG của mã hàng tương ứng
e. Thêm mới bản ghi vào bảng DonBanChiTiet với các giá trị đã có và đưa ra thông báo kết quả của việc thêm mới.*/
/*Procedure
input: MDB, MH,SL
output:*/
go
create proc cau2 @MDB int, @MH int, @SL int
as
begin
	declare @GB money, @TT money
	--a.
	if not exists (select * from DonBan where MaDonBan = @MDB)
	begin
		print 'ERROR!'
		return
	end
	--b
	if not exists (select * from Hang where MaHang = @MH)
	begin
		print 'ERROR!'
		return
	end
	--c
	if @SL<=0
	begin
		print 'ERROR!'
		return
	end
	--d
	select @GB = GiaBan from Hang where MaHang=@MH
	set @TT = @SL * @GB
	--e
	insert into DonBanChiTiet values(@MDB,@MH,@SL,@TT)
	if @@ROWCOUNT>0
	begin
		print N'Thêm bản ghi thành công!'
	end
	else
	begin
		print N'Thêm bản ghi thất bại!'
	end
end

select * from DonBanChiTiet
select * from Hang
select * from DonBan
--Thử
exec cau2 3,4,5
exec cau2 2,10,5
exec cau2 2,10,0
exec cau2 2,6,4
/*Câu 3. Khi người dùng xóa dữ liệu ở bảng CongNo, hãy thực hiện cập nhật dữ liệu đó với TrangThai = 5.*/
/*loại trigger: instead of
sự kiện kích hoạt: delete
bảng: CongNo
lấy dữ liệu đang xử lý: deleted*/
select * from CongNo
go
create trigger cau3
on CongNo
instead of delete
as
begin
	declare @MaCN int
	select @MaCN = MaCN from deleted
	update CongNo set TrangThai=5 where MaCN=@MaCN
	if @@ROWCOUNT>0
		print N'Deleted!!!'
end

delete from CongNo where MaCN=5
select * from CongNo