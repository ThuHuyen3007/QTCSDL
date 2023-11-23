use Bank
--1. Trae về tên chi nhánh ngân hàng nếu biết mã của nó
 --trước khi viết: xác định 
-- input: mã chi nhánh
-- output: tên chi nhánh
-- process:
/* khi không chắc chắn về độ dài của dl -> dùng vảchar thay vì char */
create proc spGetBrName @Br_id varchar(10), @br_name nvarchar(100) out
as
begin
  set @br_name =(select br_Name from Branch where br_id =@br_id)

end

-- dùng thử tục
declare @a varchar(10), @b nvarchar(100)
set @a = 'VB001'
exec spGetBrName @a,@b out 
print @b

--2. Trả về tên, địa chỉ và số điện thoại của khách hàng nếu biết mã khách.
create proc spCusInfor @Cust_id varchar(10)
as 
begin
select Cust_name, Cust_ad, Cust_phone from customer where Cust_id = @Cust_id 
end
select * from customer
exec spCusInfor '000001'

--3. in ra danh sách khách hàng của một chi nhánh cụ thể nếu biết mã chi nhánh đó 
create proc spCustList @BR_id varchar(10)
as
begin 
   select Cust_name from customer 
   where Br_id = @BR_id
end 

exec spCustList 'VT011' 
select * from customer

/* 4.4.	Kiểm tra một khách hàng nào đó đã tồn tại trong hệ thống CSDL của ngân hàng chưa nếu biết:
 họ tên, số điện thoại của họ. Đã tồn tại trả về 1, ngược lại trả về 0 */
 create proc spCheck @C_name nvarchar(50), @C_phone varchar(11)
as 
begin 
declare @check int  
 set @check = (select count(*) from customer where Cust_name = @C_name and Cust_phone = @C_phone)  
 if @check >0
 print '1'
 else 
 print '0'
end 
--
exec spCheck 'Lê Quang Phong' ,'01219688656'
exec spCheck 'Lê Quang Phong' ,'01219688650'
select * from customer

--5. Cập nhật số tiền trong tài khoản nếu biết số tài khoản và số tiền gửi mới
-- nếu cập nhất thành công trả về 1, nếu không cập nhật thành công trar về 0 
create proc spUpdateAcc @ac_no varchar(10), @new_balance numeric(12,0), @kq int out 
as
begin
   update account
   set ac_balance = @new_balance where ac_no = @ac_no 
  if @@rowcount > 0 
  set @kq = 1
  else 
  set @kq = 0
end
--kq tra ve 1
declare @a varchar(10), @b nvarchar(100),@c int 
set @a = '1000000001'
set @b = 20000
exec spUpdateAcc @a,@b, @c out
print @c
--kq tra ve 0
declare @a varchar(10), @b nvarchar(100),@c int 
set @a = '2000000001'
set @b = 20000
exec spUpdateAcc @a,@b, @c out
print @c

--6.Cập nhật địa chỉ của khách hàng nếu biết mã số của họ. Thành công trả về 1, thất bại trả về 0
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
exec spGetADD '000003',N'Nam Thượng,Thạch Đài, Thạch Hà, Hà Tĩnh',@kq output
print @kq

/*create proc spUpdateAd @Cust_id varchar(10), @r tinyint 
as 
begin
  update customer
  set Cust_ad = ''  where Cust_ad = @Cust_id
  if @@rowcount > 0 
  set @r = 1
  else 
  set @r = 0
end
-- khác 
--input: mã khách hàng,địa chỉ mới
--output: Thành công trả về 1, thất bại trả về 0
--proc:
go*/ 


--7.Trả về số tiền có trong tài khoản nếu biết mã tài khoản.
alter proc spAcBalance @Ac_no varchar(10)
as
begin
select ac_balance from account where Ac_no = @Ac_no
end 

exec spAcBalance '1000000001'
select* from account

-- 8.Trả về số lượng khách hàng, tổng tiền trong các tài khoản nếu biết mã chi nhánh
alter proc spCS @Br_id varchar(10)
as 
begin 
   select count (distinct Customer.cust_id) as SoLuongKhach, sum(ac_balance) as TongTien
   from customer join account on customer.Cust_id = account.cust_id
   where Br_id = @Br_id
   group by Br_id
end 

exec spCS 'VT011'
/*9.Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. 
Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am  3am*/
alter proc spCheckT @T_id varchar(10)
as
begin
declare @NgayGD date, @gioGD time, @t_type int
select @NgayGD = t_date, @gioGD = t_time, @t_type = t_type from transactions where t_id =@t_id
if  @t_type = 1 and (datepart(day, @NgayGD) = 1 or not (datepart(hh, @gioGD)> 18   and datepart(hh, @gioGD) < 7 ) 
or (datepart(hh, @gioGD) between 11 and 13.5))
   print 'Giao dich '+@T_id+' bat thuong'
else if @t_type = 0 and datepart(hh, @gioGD) between 1 and 3 
   print 'Giao dich '+@T_id+' bat thuong'
else print 'Giao dich '+@T_id+' binh thuong'
end

exec spCheckT '0000000202'
exec spCheckT '0000000201'

-- k tính ngày chủ nhật
alter proc spCheckT @T_id varchar(10)
as
begin
declare @gioGD time 
select @gioGD = t_time from transactions where t_id =@t_id
if datepart(hh, @gioGD) between 1 and 3
 print 'Giao dich '+@T_id+' bat thuong'
 else print 'Giao dich '+@T_id+' binh thuong'
end


/*10.Tr về mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau: MAX(mã giao dịch đang có) + 1.
 Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch */
alter proc spNewT_id 
as
begin
declare @new_id varchar(10) 
set @new_id= (select max(convert(int,T_id)) from transactions) +1 
select replicate('0', 10 - len(@new_id))+ @new_id
end 

exec spNewT_id


/*11.Thêm một bản ghi vào bảng TRANSACTIONS nếu biết các thông tin ngày giao dịch, 
thời gian giao dịch, số tài khoản, loại giao dịch, số tiền giao dịch. Công việc cần làm bao gồm:
a.Kiểm tra ngày và thời gian giao dịch có hợp lệ không. Nếu không, ngừng xử lý
b.Kiểm tra số tài khoản có tồn tại trong bảng ACCOUNT không? Nếu không, ngừng xử lý
c.Kiểm tra loại giao dịch có phù hợp không? Nếu không, ngừng xử lý
d.Kiểm tra số tiền có hợp lệ không (lớn hơn 0)? Nếu không, ngừng xử lý
e.Tính mã giao dịch mới
f.Thêm mới bản ghi vào bảng TRANSACTIONS
g.Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch tùy theo loại giao dịch */

 
alter proc spCau11_291 @t_date date, 
                        @t_time time,
						@ac_no varchar(10),
						@t_type int,
						@t_amount money, 
						@kq int out
as
begin
-- a. Kiểm tra ngày và thời gian giao dịch có hợp lệ không.
   if @t_date > getdate()
      set @kq = 0
	  else 
	  set @kq = 1




--b. Kiểm tra số tài khoản có tồn tại trong bảng ACCOUNT không? Nếu không, ngừng xử lý
   if not exists(select * from account where ac_no = @ac_no)
      set @kq = 0
   	  else 
	  set @kq = 1
--c. Kiểm tra loại giao dịch có phù hợp không 
   if @t_type != 0 and @t_type != 1
      set @kq = 0
   	  else 
	  set @kq = 1
-- d.Kiểm tra số tiền có hợp lệ không (lớn hơn 0)? Nếu không, ngừng xử lý
   if @t_amount <= 0
      set @kq = 0
   	  else 
	  set @kq = 1
-- e.Tính mã giao dịch mới:
if @kq =1
   begin
   declare @id varchar(10),@new_tid varchar(10)  
   set @id= (select max(convert(int,T_id)) from transactions) +1 
   set @new_tid =(select replicate('0', 10 - len(@id))+ @id)
   return
   end 

--f.Thêm mới bản ghi vào bảng TRANSACTIONS
if @kq =1
begin
   insert into transactions values(@new_tid, @t_type,@t_amount, @t_date, @t_time, @ac_no) 
end

--e. Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch tùy theo loại giao dịch */
if @kq =1
begin
  if @t_type = 0
  begin
  update account
  set ac_balance = ac_balance - @t_amount where Ac_no = @ac_no
  end
  else if @t_type =1 
  begin
  update account
  set ac_balance = ac_balance + @t_amount where Ac_no = @ac_no 
  end
end

end 



go 

declare @a date, @b time,@c varchar(10),@d tinyint, @e money, @f int  
set @a = '2022-12-27'
set @b = '07:45:00.0000000'
set @c = '1000000002'
set @d = 1
set @e = 2000000000000

exec spCau11_291 @a, @b,@c,@d,@e,@f out
print @f

select * from account 

select * from transactions


/*12.Thêm mới một tài khoản nếu biết: mã khách hàng, loại tài khoản, số tiền trong tài khoản. Bao gồm những công việc sau:
a.Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa? Nếu chưa, ngừng xử lý
b.Kiểm tra loại tài khoản có hợp lệ không? Nếu không, ngừng xử lý
c.Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý.
d.Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1
e.Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có.*/
