/*TRIGGER*/

/*khi insert dữ liệu vào bảng transactions,
 hãy đảm bảo rằng ngày giao dịch không phải là ngày trong quá khứ
 loại trigger: for
 sự kiện kích hoạt: insert
 bảng nào: transactions*/

go
alter trigger tCheckTDate
on transactions
for insert
as
begin
	--muốn lấy dữ liệu đang xử lý -> inserted
	declare @date date
	select @date = t_date from inserted
	if @date< cast(getdate() as date)
	begin
		print 'Invaid data'
		rollback
	end
end

insert into transactions values('99999',0,1000,'2023-03-28','00:00:00','1000000001')
select * from transactions

/*khi xóa dữ liệu trong bảng transactions, hãy chuyển loại giao dịch thành 9
loại trigger: instead of
sự kiện kích hoạt: delete
bảng nào: transactions
lấy dữ liệu đang xử lý: deleted*/

go
create trigger tDeleteT
on transactions
instead of delete
as
begin
	declare @maGD varchar(15)
	select @maGD = t_id from deleted
	update transactions set t_type=9 where t_id=@maGD
	print N'Deleted!!!'
end

delete from transactions where t_id='99999'

select * from transactions

/*1/5. Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
a.	Kiểm tra trạng thái tài khoản của giao dịch hiện hành. 
Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ 
và hủy thao tác đã thực hiện. Ngược lại:  
i.	Nếu là giao dịch gửi: số dư = số dư + tiền gửi. 
ii.	Nếu là giao dịch rút: số dư = số dư – tiền rút.
 Nếu số dư sau khi thực hiện giao dịch < 50.000 thì đưa ra thông báo ‘không đủ tiền’ 
 và hủy thao tác đã thực hiện.*/
 /*loại trigger: for
sự kiện kích hoạt: insert
bảng nào: transactions
lấy dữ liệu đang xử lý: inserted*/
ALTER TABLE transactions
ENABLE TRIGGER ALL
go
create trigger tGet1
on transactions
for insert
as
begin
	declare @ac_no varchar(15), @t_amount money,@t_type int
	select @ac_no=ac_no,@t_amount=t_amount,@t_type=t_type from inserted
	if (select ac_type from account where Ac_no = @ac_no)=9
	begin
		print N'tài khoản đã bị xóa'
		rollback
	end
	else
	begin
		if @t_type=1
		begin
			update account set ac_balance=ac_balance+@t_amount where Ac_no=@ac_no
		end
		else 
		begin
			if (select ac_balance from account where Ac_no = @ac_no)<50000
			begin
				print N'không đủ tiền'
				rollback
			end
			else
			begin
			update account set ac_balance=ac_balance-@t_amount where Ac_no=@ac_no
			end
		end
	end
end
insert into transactions values('9998',1,1000,'2023-03-28','00:00:00','1000000055')
select * from transactions
select * from account

/*2/7. Sau khi xóa dữ liệu trong transactions hãy tính lại số dư trong bảng account:
a. Nếu là giao dịch rút. Số dư = số dư cũ + t_amount
b. Nếu là giao dịch gửi. Số dư = số dư cũ - t_amount
loại trigger: after/for
sự kiện kích hoạt: delete
bảng: transactions*/
go
create trigger tGet2
on transactions
for delete
as
begin
	declare @maTK varchar(15),@tien money,@loai int
	select @maTK = ac_no, @tien = t_amount, @loai=t_type from deleted
	update account set ac_balance=ac_balance+@tien where (Ac_no=@maTK) and (@loai=0)
	update account set ac_balance=ac_balance-@tien where (Ac_no=@maTK) and (@loai=1)
	print N'Đã update'
end

select * from account
select * from transactions
delete from transactions where t_id='0000000407'

/*3/8. Khi cập nhật hoặc sửa dữ liệu tên khách hàng,
 hãy đảm bảo tên khách không nhỏ hơn 5 kí tự.*/
/*loại trigger: for
sự kiện kích hoạt: update
bảng nào: customer
lấy dữ liệu đang xử lý: inserted*/
ALTER TABLE customer
ENABLE TRIGGER ALL
go
create trigger tGet3
on customer
for update
as
begin
	declare @ten nvarchar(50)
	select @ten=Cust_name from inserted
	if len(@ten)<5
	begin
		print 'Error'
		rollback
	end
end
update customer set Cust_name=N'Hà Công Lực' where Cust_id='000001'
update customer set Cust_name=N'Nam' where Cust_id='000001'
select * from customer

 /*4. Khi xóa dữ liệu trong bảng account, hãy thực hiện thao tác 
 cập nhật trạng thái tài khoản là 9 (không dùng nữa) thay vì xóa.*/
 /*loại trigger: instead of
sự kiện kích hoạt: delete
bảng nào: account
lấy dữ liệu đang xử lý: deleted*/
ALTER TABLE account
ENABLE TRIGGER ALL
go
create trigger tGet4
on account
instead of delete
as
begin
	declare @maTK varchar(15)
	select @maTK = Ac_no from deleted
	update account set ac_type=9 where Ac_no=@maTK
	print N'Deleted!!!'
end
delete from account where Ac_no='1000000055'
select * from account

 /*6. Khi sửa dữ liệu trong bảng transactions hãy tính lại số dư:
Số dư = số dư cũ + (số dữ mới – số dư cũ)*/
/*loại trigger: for
sự kiện kích hoạt: update
bảng nào: transactions
lấy dữ liệu đang xử lý: inserted,deleted*/

ALTER TABLE transactions
ENABLE TRIGGER ALL
go
create trigger tGet6
on transactions
for update
as
begin
	declare @ac_no varchar(15),@old_amount money, @new_amount money
	select @ac_no=ac_no,@old_amount=t_amount from deleted
	select @new_amount=t_amount from inserted where ac_no=@ac_no
	update account set ac_balance=ac_balance+(@new_amount-@old_amount)
	where Ac_no=@ac_no
end

update transactions set t_amount=2000 where t_id='9999'
select * from transactions
select * from account
/*9/12. Khi tác động đến bảng account (thêm, sửa, xóa), hãy kiểm tra loại tài khoản.
 Nếu ac_type = 9 (đã bị xóa) thì đưa ra thông báo ‘tài khoản đã bị xóa’ 
 và hủy các thao tác vừa thực hiện.*/
/*loại trigger: for
sự kiện kích hoạt: insert, update,delete
bảng nào: account
lấy dữ liệu đang xử lý: inserted,deleted*/
ALTER TABLE account
ENABLE TRIGGER ALL
go
create trigger tGet9
on account
for insert, update,delete
as
begin
	if (select ac_type from inserted)=9 or (select ac_type from deleted)=9
	begin
		print N'tài khoản đã bị xóa'
		rollback
	end
end

update account set ac_balance=4000 where Ac_no='1000000055'
delete from account where Ac_no='1000000055'
insert into transactions values ('0000000409', '0', 200000, '2013-03-23', '03:00', '1000000055')
/*10/13. Khi thêm mới dữ liệu vào bảng customer, 
kiểm tra nếu họ tên và số điện thoại đã tồn tại trong bảng thì đưa ra 
thông báo 'đã tồn tại khách hàng' và hủy toàn bộ thao tác.
loại trigger: after/for
sự kiện kích hoạt: insert
bảng: customer*/
go
--disable trigger all
alter trigger tGet11
on customer
for insert
as
begin
	--muốn lấy dữ liệu đang xử lý -> inserted
	declare @hoten nvarchar(50),@sdt varchar(15)
	select @hoten=Cust_name,@sdt=Cust_phone from inserted
	if exists(select * from customer where (Cust_name=@hoten) and (Cust_phone=@sdt))
	begin
		print N'đã tồn tại khách hàng'
		rollback
	end
end

insert into customer values('999999',N'Hà Công Lực','01283388103','','VT009')
select * from customer

/*11/14. Khi thêm mới dữ liệu vào bảng account hãy kiểm tra mã khách hàng.
Nếu mã khách hàng chưa tồn tại trong bảng customer thì đưa ra thông báo 
'khách hàng chưa tồn tại, hãy tạo mới khách hàng trước' và hủy toàn bộ thao tác.*/
go
create trigger tGet15
on account
for insert
as
begin
	--muốn lấy dữ liệu đang xử lý -> inserted
	declare @maKH varchar(15)
	select @maKH = cust_id from inserted
	if not exists(select * from customer where (Cust_id=@maKH))
	begin
		print N'khách hàng chưa tồn tại, hãy tạo mới khách hàng trước'
		rollback
	end
end

insert into account values('1000000059',20000,1,'000050')
select * from account
