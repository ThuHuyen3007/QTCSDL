use Bank

go
/*1. Tạo một thủ tục thực hiện xóa bản ghi trong bảng TRANSACTIONS với các công việc như sau:
• Kiểm tra mã giao dịch đã tồn tại hay chưa. Nếu chưa tồn tại, kết thúc xử lý 
• Nếu loại giao dịch là gửi tiền. Thực hiện xóa bản ghi trong bảng TRANSACTIONS 
đồng thời cập nhật bảng ACCOUNT với sự thay đổi của cột AC_BALANCE như sau:
 AC_BALANCE= AC_BALANCE - t_amount của giáo tác vừa xóa.
• Nếu là giao dịch rút tiền. Thực hiện xóa bản ghi trong bảng TRANSACTIONS 
đồng thời cập nhật bảng ACCOUNT với sự thay đổi của cột AC_BALANCE như SAU:
AC_BALANCE=AC_BALANCE+t_amount của giáo tác vừa xóa
Trong quá trình thực hiện, nếu bị lỗi ở 1 bước bất kì thi toàn bộ dữ liệu quay trở lại trạng thái ban đầu.*/
--input: 
--output:
create proc Cau1 @maGD varchar(15), @kq int out
as
begin
	declare @loaiGD int, @tienGD money, @maTK varchar(15)
	--a
	if not exists(select * from transactions where t_id=@maGD)
	begin
		set @kq = 0
		return
	end
	select @loaiGD = t_type, @tienGD=t_amount, @maTK=ac_no from transactions where t_id=@maGD
	--b
	if @loaiGD = 1
	begin 
		begin transaction
		delete from transactions where t_id=@maGD
		if @@ROWCOUNT<=0
		begin
			set @kq = 0
			return
		end		
		update account set ac_balance = ac_balance - @tienGD where Ac_no=@maTK
		if @@ROWCOUNT<=0
		begin
			set @kq = 0
			rollback transaction
			return		
		end
		else
		begin
			set @kq = 1
			commit transaction
			return
		end
	end 
	--c
	else if @loaiGD = 0
	begin
		begin transaction
		delete from transactions where t_id=@maGD
		if @@ROWCOUNT<=0
		begin
			set @kq = 0
			return
		end
		update account set ac_balance = ac_balance + @tienGD where Ac_no=@maTK
		if @@ROWCOUNT<=0
		begin
			set @kq = 0
			rollback transaction		
			return
		end
		else
		begin
			set @kq = 1
			commit transaction
			return
			
		end
	end
end

select * from account

declare @ret int
exec Cau1 '9999', @ret out
print @ret

/*
Thực hiện xóa KH nếu biết mã của KH. Công việc cần làm gồm:
- Kiểm tra tồn tại của KH dựa vào mã đã input. Nếu không tồn tại thì kết thúc
- Xóa tất cả những giao dịch của KH này trong bảng transactions
- Xóa tất cả nhưng tài khoản của KH này trong bảng account
- Xóa dl của KH với mã đã cho trong bảng customer
Hãy đảm bảo rằng dl chỉ được ghi nhận vào bảng các bảng nếu tất cả công việc nêu trên 
thực hiện thành công và không cho phép bất kỳ giao tác nào đọc dl đang chịu sự
tác động của các giao tác đã nêu.
*/
go
create proc xoaKH @maKH varchar(15), @kq int out
as
begin
	if not exists (select * from customer where Cust_id = @maKH)
	begin
		set @kq = 0
		return
	end
	begin transaction 
	delete from transactions 
	where t_id in (select t_id from transactions join account on transactions.ac_no=account.Ac_no
									where cust_id =@maKH)
	if @@ROWCOUNT<=0
	begin
		set @kq = 0
		return
	end
	delete from account where cust_id = @maKH
	if @@ROWCOUNT<=0
	begin
		set @kq = 0
		rollback transaction
		return
	end
	delete from customer where Cust_id = @maKH
	if @@ROWCOUNT<=0
	begin
		set @kq = 0
		rollback transaction
		return
	end
	else
	begin
		set @kq = 1
		commit transaction 
		return
	end
end

declare @kqua int
exec xoaKH '000001', @kqua out
print @kqua
select * from customer where Cust_id = '000001'
