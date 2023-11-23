--18. Trả về số tiền có trong tài khoản nếu biết mã tài khoản
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
--2. Trả về tên, địa chỉ và số điện thoại của khách hàng nếu biết mã khách hàng.
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

/*1. Kiểm tra thông tin khách hàng đã tồn tại trong hệ thống hay chưa nếu biết họ tên và số điện thoại.
 Tồn tại trả về 1, không tồn tại trả về 0*/
/*2. Tính mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau:
 MAX(mã giao dịch đang có) + 1. Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch*/
/*3.Tính mã tài khoản mới. (định nghĩa tương tự như câu trên)*/
/* 4.Trả về tên chi nhánh ngân hàng nếu biết mã của nó.*/
/*5.Trả về tên của khách hàng nếu biết mã khách.*/
/*6.Trả về số tiền có trong tài khoản nếu biết mã tài khoản.*/
/*7.Trả về số lượng khách hàng nếu biết mã chi nhánh.*/
/*8.Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch.
 Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am  3am*/
