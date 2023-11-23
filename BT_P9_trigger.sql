use bank
go

/* 1. Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
a. Kiểm tra trạng thái tài khoản của giao dịch hiện hành. Nếu trạng thái tài khoản ac_type = 9 
thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện. Ngược lại:  
i. Nếu là giao dịch gửi: số dư = số dư + tiền gửi. 
ii. Nếu là giao dịch rút: số dư = số dư – tiền rút. 
Nếu số dư sau khi thực hiện giao dịch < 50.000 thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện. */
-- loại trigger: for
-- sự kiện kích hoạt: insert
-- bảng: transactions
create trigger tcau1
on transactions
for insert
as
begin
	declare @ac_type int, @t_type int, @ac_balance money, @t_amount money
	select @ac_type = ac_type, @t_type = t_type, @ac_balance = ac_balance, @t_amount = t_amount from inserted join account on inserted.ac_no = account.Ac_no
	if @ac_type = 9
	begin
		print N'Tài khoản đã bị xóa'
		rollback
	end
	else
	begin
		if @t_type = 1
		begin
			update account
			set ac_balance = @ac_balance + @t_amount
			where Ac_no = (select ac_no from inserted)
		end
		else if @t_type = 0
		begin
			if (@ac_balance - @t_amount) < 50000 
			begin
				print N'Không đủ tiền'
				rollback
			end
			else
			begin
				update account
				set ac_balance = @ac_balance - @t_amount
				where Ac_no = (select ac_no from inserted)
			end
		end
	end
end

insert into transactions values('120111', 1, 200000, '2022-04-03', '11:00:00', '1000000001')

drop trigger tcau1
go

/* 2. Sau khi xóa dữ liệu trong transactions hãy tính lại số dư:
a. Nếu là giao dịch rút
Số dư = số dư cũ + t_amount
b. Nếu là giao dịch gửi
Số dư = số dư cũ – t_amount */
-- loại trigger: instead of
-- sự kiện kích hoạt: delete
-- bảng: transactions
create trigger tcau2
on transactions
for delete
as
begin
	declare @t_type int, @ac_balance money, @t_amount money
	select @t_type = t_type, @ac_balance = ac_balance, @t_amount = t_amount from deleted join account on deleted.ac_no = account.Ac_no
	if @t_type = 0
	begin
		update account
		set ac_balance = @ac_balance + @t_amount
		where Ac_no = (select ac_no from deleted)
	end
	else if @t_type = 1
	begin
		update account
		set ac_balance = @ac_balance - @t_amount
		where Ac_no = (select ac_no from deleted)
	end
end

delete from transactions where t_id = '199999'

drop trigger tcau2
go

-- 3. Khi cập nhật hoặc sửa dữ liệu tên khách hàng, hãy đảm bảo tên khách không nhỏ hơn 5 kí tự. 
-- loại trigger: for
-- sự kiện kích hoạt: update
-- bảng: customer
create trigger tcau3
on customer
for update
as
begin
	declare @Cust_name nvarchar(50)
	set @Cust_name = (select Cust_name from inserted)
	if len(@Cust_name) < 5
	begin 
		print N'Tên không hợp lệ'
		rollback
	end
end

update customer
set Cust_name = N'Nguyễn Quang Lợi'
where Cust_id = '000003'

drop trigger tcau3
go

-- 4. Khi xóa dữ liệu trong bảng account, hãy thực hiện thao tác cập nhật trạng thái tài khoản là 9 (không dùng nữa) thay vì xóa.
-- loại trigger: instead of
-- sự kiện kích hoạt: delete
-- bảng: account
create trigger tcau4
on account
instead of delete
as
begin
	update account
	set ac_type = 9
	where Ac_no = (select Ac_no from deleted)
end

delete from account where Ac_no = '1000000054'

drop trigger tcau4
go

/* 5. Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
a. Kiểm tra trạng thái tài khoản của giao dịch hiện hành. 
Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện. Ngược lại:  
i. Nếu là giao dịch gửi: số dư = số dư + tiền gửi. 
ii. Nếu là giao dịch rút: số dư = số dư – tiền rút. 
Nếu số dư sau khi thực hiện giao dịch < 50.000 thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện. */

'Giống câu 1'

/* 6. Khi sửa dữ liệu trong bảng transactions hãy tính lại số dư:
Số dư = số dư cũ + (số dữ mới – số dư cũ) */
-- loại trigger: for
-- sự kiện kích hoạt: update
-- bảng: transactions
create trigger tcau6
on transactions
for update
as
begin
	declare @old_ac_balance money, @old_t_type int, @new_t_type int, @old_t_amount money, @new_t_amount money
	select @old_t_type = t_type, @old_t_amount = t_amount, @old_ac_balance = ac_balance from deleted join account on deleted.ac_no = account.Ac_no
	select @new_t_type = t_type, @new_t_amount = t_amount from inserted join account on inserted.ac_no = account.Ac_no
	if @old_t_type = 1
	begin
		set @old_ac_balance = @old_ac_balance - @old_t_amount
	end
	else if @old_t_type = 0
	begin
		set @old_ac_balance = @old_ac_balance + @old_t_amount
	end

	if @new_t_type = 1
	begin 
		update account
		set ac_balance = @old_ac_balance + @new_t_amount
		where Ac_no = (select ac_no from inserted)
	end
	else if @new_t_type = 0
	begin 
		update account
		set ac_balance = @old_ac_balance - @new_t_amount
		where Ac_no = (select ac_no from inserted)
	end
end

update transactions
--set t_type = 0
set t_amount = 1000
where t_id = '199999'

drop trigger tcau6
go

/* 7. Sau khi xóa dữ liệu trong transactions hãy tính lại số dư:
a. Nếu là giao dịch rút
Số dư = số dư cũ + t_amount
b. Nếu là giao dịch gửi
Số dư = số dư cũ – t_amount */

'Giống câu 2'

-- 8. Khi cập nhật hoặc sửa dữ liệu tên khách hàng, hãy đảm bảo tên khách không nhỏ hơn 5 kí tự. 

'Giống câu 3'

/* 9. Khi tác động đến bảng account (thêm, sửa, xóa), hãy kiểm tra loại tài khoản. 
Nếu ac_type = 9 (đã bị xóa) thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy các thao tác vừa thực hiện. */
-- loại trigger: for
-- sự kiện kích hoạt: insert, delete, update
-- bảng: account
create trigger tcau9
on account
for insert, delete, update
as
begin
	declare @d_ac_type int, @i_ac_type int 
	set @d_ac_type = (select ac_type from deleted)
	set @i_ac_type = (select ac_type from inserted)
	-- insert
	if (@i_ac_type = 9) and (@d_ac_type is null)
	begin
		print N'Tài khoản đã bị xóa'
		rollback
	end
	-- delete
	if (@i_ac_type is null) and (@d_ac_type = 9)
	begin
		print N'Tài khoản đã bị xóa'
		rollback
	end
	-- update
	if (@i_ac_type is not null) and (@d_ac_type = 9)
	begin
		print N'Tài khoản đã bị xóa'
		rollback
	end
end

insert into account values('12345', 2500000, 1, '000001')

delete from account where Ac_no = '12345'

update account
set ac_balance = 30000000
where Ac_no = '1000000053'

drop trigger tcau9
go

/* 10.	Khi thêm mới dữ liệu vào bảng customer, kiểm tra nếu họ tên và số điện thoại đã tồn tại trong bảng 
thì đưa ra thông báo ‘đã tồn tại khách hàng’ và hủy toàn bộ thao tác. */
-- loại trigger: for
-- sự kiện kích hoạt: insert
-- bảng: customer
create trigger tcau10
on customer
for insert
as
begin
	declare @Cust_name nvarchar(50), @Cust_phone varchar(11)
	select @Cust_name = Cust_name, @Cust_phone = Cust_phone from inserted
	if (select count(*) from customer where Cust_name = @Cust_name and Cust_phone = @Cust_phone) > 1
	begin
		print N'Đã tồn tại khách hàng'
		rollback
	end
end

insert into customer values('1110', N'Hà Công Lực', '01283388103', 'NGUYỄN TIẾN DUẨN - THÔN 3 - XÃ DHÊYANG - EAHLEO - ĐĂKLĂK', 'VT009')

insert into customer values('12200', N'Đinh Công Toàn', '0738920134', 'Duy Vinh - Duy Xuyên - Quang Nam', 'VB001')

drop trigger tcau10
go

/* 11.	Khi thêm mới dữ liệu vào bảng account, hãy kiển tra mã khách hàng. 
Nếu mã khách hàng chưa tồn tại trong bảng customer thì đưa ra thông báo 
‘khách hàng chưa tồn tại, hãy tạo mới khách hàng trước’ và hủy toàn bộ thao tác. */
-- loại trigger: for
-- sự kiện kích hoạt: insert
-- bảng: account
create trigger tcau11
on account
for insert
as
begin
	declare @Cust_id varchar(6)
	Select @Cust_id = cust_id from inserted
	if (select count(*) from customer where Cust_id = @Cust_id) <= 0
	begin
		print N'Khách hàng chưa tồn tại, hãy tạo mới khách hàng trước'
		rollback
	end
end

insert into account values('11000', 100000, 1, '000001')

drop trigger tcau11
go

/* 12.	Khi tác động đến bảng account (thêm, sửa, xóa), hãy kiểm tra loại tài khoản. 
Nếu ac_type = 9 (đã bị xóa) thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy các thao tác vừa thực hiện. */

'Giống câu 9'

/* 13.	Khi thêm mới dữ liệu vào bảng customer, kiểm tra nếu họ tên và số điện thoại đã tồn tại trong bảng 
thì đưa ra thông báo ‘đã tồn tại khách hàng’ và hủy toàn bộ thao tác. */

'Giống câu 10'

/* 14.	Khi thêm mới dữ liệu vào bảng account, hãy kiểm tra mã khách hàng. 
Nếu mã khách hàng chưa tồn tại trong bảng customer 
thì đưa ra thông báo ‘khách hàng chưa tồn tại, hãy tạo mới khách hàng trước’ và hủy toàn bộ thao tác. */

'Giống câu 11'


