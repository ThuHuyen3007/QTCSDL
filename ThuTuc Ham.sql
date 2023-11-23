/*THỦ TỤC*/
-- 1 -> 12
/*HÀM*/
-- 13 -> 22
/*THỦ TỤC + HÀM*/

/*1. Trả về tên chi nhánh ngân hàng nếu biết mã của nó
input: mã chi nhánh
output: tên chi nhánh
proc*/
go
create proc spGetBrName @br_id varchar(10), @br_name nvarchar(100) output
as
begin
	set @br_name = (select BR_name from Branch where BR_id=@br_id)
end
-- Dùng
declare @a varchar(10), @b nvarchar(100)
set @a = 'VB001'
exec spGetBrName @a,@b output
print @b
/*16
input:maCN
output: tenCN
function*/
go
create function fGet4(@maCN varchar(10))
returns nvarchar(50)
as
begin
	declare @tenCN nvarchar(50)
	set @tenCN = (select BR_name from Branch where BR_id=@maCN)
	return @tenCN
end
--dùng
select * from Branch
print dbo.fGet4('VB001')

--2. Trả về tên, địa chỉ và số điện thoại của khách hàng nếu biết mã khách.
--input: Mã khách hàng
--output: Tên KH, địa chỉ, sđt
select * from customer
--proc:
go
create proc spGetCustomers @cust_id varchar(10), @name nvarchar(50) output,
						@add nvarchar(100) output, @sdt varchar(15) output
as
begin
	select @name = Cust_name, @add = Cust_ad, @sdt = Cust_phone
	from customer
	where Cust_id = @cust_id
end
-- dùng:
go
declare @id varchar(10), @name nvarchar(50),@diachi nvarchar(100), @sdt varchar(15)
exec spGetCustomers '000003',@name output,@diachi output,@sdt output
print @name
print @diachi
print @sdt
--input: maKH
--output: table ThongTin(ten,diachi,sdt)
select * from customer
--Function:
--c1
go
create function fGetCust1(@maKH varchar(15))
returns table
as
return select Cust_name as N'Tên KH',Cust_ad as N'Địa chỉ',Cust_phone as N'Số điện thoại'
		from customer
		where Cust_id = @maKH

select * from fGetCust1('000001')

--c2
go
create function fGetCust2(@maKH varchar(15))
returns @cust table (Cust_name nvarchar(50),
					Cust_ad nvarchar(100),
					Cust_phone varchar(15))
as
begin
	insert into @cust
	select Cust_name,Cust_ad,Cust_phone from customer where Cust_id = @maKH
	return
end
select * from fGetCust2('000001')

-- 3. In ra danh sách khách hàng của một chi nhánh cụ thể nếu biết mã chi nhánh đó
--input: mã chi nhánh VB001
--output: danh sách khách hàng
select * from Branch
select * from customer where Br_id = 'VB002'
--proc:
go
create proc spGetCustomer @br_id varchar(10)
as 
begin
	declare @table table
			(Cust_name nvarchar(50),
			Br_id varchar(10))
	insert into @table select Cust_name,Br_id
						from customer 
						where Br_id=@br_id
	select * from @table
end
--dùng:
go
declare @a varchar(10)
set @a = 'VB002' 
exec spGetCustomer @a

--4. Kiểm tra một khách hàng nào đó đã tồn tại trong hệ thống CSDL của ngân hàng chưa
-- nếu biết: Họ tên, số điện thoại của họ
-- Đã tồn tại trả về 1, ngược lại trả về 0
--proc
go
create proc spGetKiemTra @hoten nvarchar(50), @sdt varchar(15), @kq int output
as
begin
	if @sdt in (select Cust_phone from customer where Cust_name = @hoten)
	begin
		set @kq= 1
	end
	else
	begin
		set @kq= 0
	end
end
--Dùng
select * from customer
go
declare @name nvarchar(50), @sdt varchar(15),@kq int
exec spGetKiemTra N'Hà Công Lực','01283388103', @kq output
print @kq
 /*(13) 
 input: hoten và sdt
 output: 1 or 0
 function*/
 go
 create function fGet1 (@hoten nvarchar(50), @sdt varchar(15))
 returns int
 as
 begin
	declare @kq int
	if exists (select * from customer where (Cust_name=@hoten) and (Cust_phone=@sdt))
	begin
		set @kq=1
	end
	else 
	begin
		set @kq=0
	end
	return @kq
 end
 --dùng
 select * from customer
 print dbo.fGet1(N'Hà Công Lực','01638843209')
 print dbo.fGet1(N'Hà Công Lực','01283388103')
 
--5. Cập nhật số tiền trong tài khoản nếu biết mã số tài khoản và số tiền mới.
-- Thành công trả về 1, thất bại trả về 0
--input: mã số tk, số tiền mới
--output: 1 or 0
-- proc
go
create proc spGetAc_Balance @ac_no varchar(10), @new_balance numeric(15,0)
as
begin
	update account set ac_balance = @new_balance
	where Ac_no = @ac_no
	declare @sttk numeric(15,0)
	if @@ROWCOUNT > 0
	begin
		print 1
	end
	else
	begin
		print 0
	end
end
--dùng
go
declare @a varchar(10), @b numeric(15,0)
set @a = '1000000055' 
set @b = '88118000'
exec spGetAc_Balance @a,@b

go
declare @a varchar(10), @b numeric(15,0)
set @a = '1000000001' 
set @b = '88118000'
exec spGetAc_Balance @a,@b

select * from account

--6. Cập nhật địa chỉ của khách hàng nếu biết mã số của họ. Thành công trả về 1, thất bại trả về 0
--input: mã khách hàng,địa chỉ mới
--output: Thành công trả về 1, thất bại trả về 0
--proc:
go
create proc spGetADD @cust_id varchar(10), @add_new nvarchar(100), @kq int output
as
begin
	update customer set Cust_ad = @add_new
	where Cust_id = @cust_id
	if @@ROWCOUNT > 0
	begin
		set @kq=1
	end
	else
	begin
		set @kq=0
	end
end
--dùng:
go
declare @cust_id varchar(10), @add_new nvarchar(100),@kq int
exec spGetADD '000003',N'TRUNG THIỆN, DƯƠNG THỦY, LỆ THỦY, QUẢNG BÌNH.',@kq output
print @kq

--7. (18.) Trả về số tiền có trong tài khoản nếu biết mã tài khoản.
--input: Mã tài khoản
--output: Số tiền trong tk
--proc:
go
create proc spGetTK @ac_no varchar(15), @tien numeric(15,0) output
as
begin
	set @tien = (select ac_balance from account where Ac_no = @ac_no)
end
--dùng:
select * from account
go
declare  @ac_no varchar(15), @tien numeric(15,0)
exec spGetTK '1000000004',@tien output
print @tien

--input: maKH
--output: sotien
--function:
go
create function fGetSotien (@maKH varchar(15))
returns money
as
begin
	declare @sotien money
	select @sotien = ac_balance from account where Ac_no = @maKH
	return @sotien
end
print dbo.fGetSotien('1000000001')

select * from account

--8. Trả về số lượng khách hàng, tổng tiền trong các tài khoản nếu biết mã chi nhánh
--input: mã chi nhánh
--output: số lượng khách hàng, tổng tiền trong các tài khoản
--proc
go
create proc spGetSL @br_id varchar(10), @sl int output, @tongtien numeric(15,0) output
as
begin
	select @sl = count(distinct(customer.Cust_id)), @tongtien = sum(ac_balance) 
	from account join customer on account.cust_id=customer.Cust_id
	where Br_id=@br_id
end
--dùng
go
declare @ma varchar(10), @sl int, @tongtien numeric(15,0)
exec spGetSL 'VT009',@sl output,@tongtien output
print @sl
print @tongtien

select * from account join customer on account.cust_id=customer.Cust_id where Br_id= 'VB002'

--9. Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch.
--Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am  3am
--input: mã giao dịch
--output: Có bất thường hay không
select * from transactions
--proc:
go
create proc spGetKT @ma_gd varchar(15)
as
begin
	declare @t_type int, @t_time time(7),@t_date date
	select @t_type = t_type,@t_time=t_time, @t_date = t_date
	from transactions
	where t_id = @ma_gd
	print @t_date
	if ((@t_type = 0) and (@t_time not between '00:00:00.0000000' and '03:00:00.0000000'))
	or ((@t_type = 1) and ((@t_time between '08:00:00.0000000' and '11:30:00.0000000')
					  or (@t_time between '13:30:00.0000000' and '16:00:00.0000000'))
					  and (datename(weekday,@t_date) not in ('Sunday', 'Saturday')))
	begin
		print N'Giao dịch bình thường'
	end
	else
	begin
		print N'Giao dịch bất thường'
	end
end
--dùng:
drop proc spGetKT
go
declare @ma varchar(15)
exec spGetKT '0000000201'

go
declare @ma varchar(15)
exec spGetKT '0000000243'
select datename(weekday,t_date) from transactions where t_id='0000000243' 
select DATEPART(dw,'2016-06-26')
/*(20) Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch.
 Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am  3am
 input: maGD
 output:kt(bất thường/bình thường)
 function*/
 go
 create function fGet8(@maGD varchar(10))
 returns nvarchar(50)
 as
 begin
	declare @kt nvarchar(50),@gio time,@loai int,@ngay date
	select @loai=t_type,@gio=t_time,@ngay=t_date from transactions where t_id=@maGD
	if ((@loai = 0) and (@gio not between '00:00:00.0000000' and '03:00:00.0000000'))
	or ((@loai = 1) and ((@gio between '08:00:00.0000000' and '11:30:00.0000000')
					  or (@gio between '13:30:00.0000000' and '16:00:00.0000000'))
					  and (datename(weekday,@ngay) not in ('Sunday', 'Saturday')))
	begin
		set @kt=N'Tài khoản bình thường'
	end
	else
	begin
		set @kt=N'Tài khoản bất thường'
	end
	return @kt
 end
 --dùng
 print dbo.fGet8('0000000201')
 print dbo.fGet8('0000000243')

--10. Trả về mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau:
-- MAX(mã giao dịch đang có) + 1
--input: 
--output: mã giao dịch mới
--pro
go
create proc spGetGiaoDich @t_new varchar(15) output
as
begin
	select @t_new=(t_id+1) from transactions order by t_id ASC
	while len(@t_new)<=10
	begin
		set @t_new = '0'+cast(@t_new as varchar(15))
	end
end
--C2
go
create proc spGetGD @magd varchar(15) output
as
begin
	select @magd=(t_id+1) from transactions order by t_id ASC
	set @magd =REPLICATE ('0',10-len(@magd))+@magd
end
--dùng
select t_id from transactions order by t_id ASC
go
declare @t_new varchar(15)
exec spGetGD @t_new output
print @t_new
/*10. (14) Tính mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau:
 MAX(mã giao dịch đang có) + 1. Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch
 input: 
 output:id_new
 function*/
 go
create function fGet2 ()
returns varchar(15)
as
begin
	declare @id_new varchar(15)
	set @id_new = (select max(t_id) from transactions) + 1
	set @id_new = REPLICATE ('0',10-len(@id_new))+@id_new
	return @id_new
end
 --dùng
 select * from transactions
 print dbo.fGet2()

 /*11. Thêm một bản ghi vào bảng transactions nếu biết các thông tin ngày giao dịch, thời gian giao dịch
số tài khoản, loại giao dịch, số tiền giao dịch. Công việc cần làm bao gồm
a. Kiểm tra ngày và thời gian giao dịch có hợp lệ không? Nếu không, ngừng xử lý
b. Kiểm tra stk có tồn tại trong bảng account k? Nếu không, ngừng xử lý 
=> Return: kết thúc thủ tục ngay tại return
c. Kiểm tra loại GD có phù hợp k? Nếu không, ngừng xử lý
d. Ktra số tiền có hợp lệ không (>0)? Nếu không, ngừng xử lý
e. Tính mã GD mới
f. Thêm mới bản hi vào bảng transactions
g. Cập nhật bảng Account = cách cộng hoặc trừ số tiền vừa thực hiện GD tùy theo GD

input: ngày giao dịch, thời gian giao dịch, số tài khoản, loại giao dịch, số tiền giao dịch
output:
proc*/

go
create proc updatetransactions @ngaygd date, @tggd time, @stk varchar(15), @loaigd int, @tiengd numeric(15,0)
as
begin
	--a
	if (@ngaygd>GETDATE()) and (ISDATE(cast(@ngaygd as varchar(15)))=0)
	 and (cast(@tggd as datetime)>GETDATE()) and (ISDATE(cast(@tggd as varchar(15)))=0)
	begin
		return
	end
	--b
	declare @countb int
	set @countb = (select count(ac_no) from account where Ac_no = @stk)
	if @countb < 1
	begin
		return
	end
	--c
	if (@loaigd<>0) and (@loaigd<>1)
	begin
		return
	end
	--d
	if @tiengd<=0
	begin
		return
	end
	--e
	declare @magd varchar(15)
	select @magd=(t_id+1) from transactions order by t_id ASC
	set @magd=REPLICATE ('0',10-len(@magd))+@magd
	--f
	INSERT INTO transactions VALUES(@magd,@loaigd,@tiengd,@ngaygd,@tggd,@stk)
	--g
	if @@ROWCOUNT>0
	begin 
		IF @loaigd=0
			UPDATE ACCOUNT
			SET ac_balance=ac_balance-@tiengd
			WHERE ac_no=@stk
		ELSE 
			UPDATE ACCOUNT
			SET ac_balance=ac_balance+@tiengd
			WHERE ac_no=@stk
	end
	else
		print N'UPDATE KHÔNG THÀNH CÔNG'
end
--dùng
go
EXEC updatetransactions '2023-03-20','07:00','10000000','1','2000'

select * from transactions
/*12. Thêm mới một tài khoản nếu biết: mã khách hàng, loại tài khoản, số tiền trong tài khoản.
Bao gồm những công việc sau:
a.	Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa? Nếu chưa, ngừng xử lý
b.	Kiểm tra loại tài khoản có hợp lệ không? Nếu không, ngừng xử lý
c.	Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý.
d.	Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1
e.	Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có.
*/
go
create proc updateaccount @makh varchar(15), @loaitk int, @tientk numeric(15,0)
as
begin
	--a
	declare @counta int
	set @counta = (select count(Cust_id) from customer where Cust_id = @makh)
	if @counta < 1
	begin
		print N'Không hợp lệ'
		return
	end
	--b
	if @loaitk not in (0,1)
	begin
		print N'Không hợp lệ'
		return
	end
	--c
	if @tientk is null
	begin
		set @tientk = 50000
	end
	else if @tientk <0
	begin
		print N'Không hợp lệ'
		return
	end
	--d
	declare @matk varchar(15)
	select @matk=(ac_no+1) from account order by Ac_no ASC
--	set @matk = (select max(ac_no) from account) + 1
	--f
	INSERT INTO account VALUES(@matk,@tientk,@loaitk,@makh)
	--test
	if @@ROWCOUNT>0
	begin 
		print N'UPDATE THÀNH CÔNG'
	end
	else
	begin
		print N'UPDATE KHÔNG THÀNH CÔNG'
	end
end
--dùng
exec updateaccount '000001','0',2000000

select * from account
select (Ac_no) from account order by Ac_no ASC

/*15.Tính mã tài khoản mới. (định nghĩa tương tự như câu trên)
 input: 
 output:ac_new
 function*/
go
create function fGet3 ()
returns varchar(15)
as
begin
	declare @ac_new varchar(15)
	set @ac_new = (select max(Ac_no) from account) + 1
	set @ac_new = REPLICATE ('0',10-len(@ac_new))+@ac_new
	return @ac_new
end
 --dùng
 select * from account
 print dbo.fGet3()

 /*17.Trả về tên của khách hàng nếu biết mã khách.
input: maKH
output:tenKH
function*/
go
create function fGet5(@maKH varchar(15))
returns nvarchar(50)
as
begin
	declare @tenKH nvarchar(50)
	select @tenKH=Cust_name from customer where Cust_id=@maKH
	return @tenKH
end
--dùng
select * from customer
print dbo.fGet5('000001')

/*18.Trả về số tiền có trong tài khoản nếu biết mã tài khoản.
input: maTK
output:sotien
function*/
go
create function fGet6 (@maTK varchar(15))
returns money
as
begin
	declare @sotien money
	select @sotien=ac_balance from account where Ac_no=@maTK
	return @sotien
end
--dùng
select * from account
print dbo.fGet6('1000000001')
/*19.Trả về số lượng khách hàng nếu biết mã chi nhánh.
input:maCN
output:SL
function*/
go
create function fGet7(@maCN varchar(15))
returns int
as
begin
	declare @SL int
	select @SL=count(distinct cust_id) from customer where Br_id=@maCN
	return @SL
end
--dùng
print dbo.fGet7('VT009')
--19. Trả về số lượng khách hàng nếu biết mã chi nhánh
--input: maCN
--output: SLKH
--Function

go
create function fGetSoLuong (@maCN varchar(15))
returns int
as
begin
	declare @SLKH int
	select @SLKH = count(Cust_id) from customer where Br_id = @maCN
	return @SLKH
end

print dbo.fGetSoLuong('VT009')

select * from customer

--22.
--input: Mavung
--Output: cNewID
select * from Branch
--Function
go
create function fGetMaCNNew (@mavung varchar(10))
returns varchar(15)
as
begin
	declare @cNewID varchar(15)
	if exists (select * from Branch where left(BR_id,2) = @mavung)
	begin
		declare @maxID varchar(10)
		select @maxID = max(RIGHT(br_id,3))+1 from Branch where left(BR_id,2) = @mavung
		set @cNewID = @mavung + REPLICATE('0',3-len(@maxID))+@maxID
	end
	else
	begin
		set @cNewID = @mavung + '001'
	end
	return @cNewID
end

print dbo.fGetMaCNNew('VB')
print dbo.fGetMaCNNew('VT')
print dbo.fGetMaCNNew('VN')
print dbo.fGetMaCNNew('VC')