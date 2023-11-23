--in ra các số chẵn nhỏ hơn hoặc bằng 100
/*declare @count int
set @count =1
while @count <=100
begin
	if @count %2=0
	begin
		print @count
		set @count = @count+1
		continue
	end
	else
		begin
			set @count = @count+1
	end
end*/

declare @count int
set @count =1
while @count <=100
begin
	if @count %2 <> 0
	begin
		set @count = @count+1
		continue
	end
	else
	begin
		print @count
		set @count = @count+1
	end
end
/*1. Viết đoạn code thực hiện việc chuyển đổi đầu số điện thoại di động theo quy định của bộ
 Thông tin và truyền thông cho một khách hàng bất kì, ví dụ với: Dương Ngọc Long*/

declare @sdt varchar(15)
select @sdt=Cust_phone 
from customer 
where Cust_name like N'Hà Công Lực'
if LEFT(@sdt,4) in ('0120','0121','0122','0126','0128')
	begin
		set @sdt = '07' + RIGHT(@sdt,8)
	end
else if LEFT(@sdt,4) in ('0123', '0124', '0125', '0127', '0129')
	begin
		set @sdt = '08' + RIGHT(@sdt,8)
	end
else if LEFT(@sdt,4) in ('0162', '0163', '0164', '0165', '0166', '0167', '0168', '0169')
	begin
		set @sdt = '03' + RIGHT(@sdt,8)
	end
else if LEFT(@sdt,4) in ('0186', '0188')
	begin
		set @sdt = '05' + RIGHT(@sdt,8)
	end
else if LEFT(@sdt,4) in ('0199')
	begin
		set @sdt = '05' + RIGHT(@sdt,8)
	end
print @sdt

 /*2. Trong vòng 10 năm trở lại đây Nguyễn Lê Minh Quân có thực hiện giao dịch nào không? 
 Nếu có, hãy trừ 50.000 phí duy trì tài khoản.*/

declare @count2 int,@amount2 numeric(15, 0),@ac char(10)
select @ac = account.Ac_no, @count2 = count(t_id)
from transactions join account on transactions.ac_no=account.Ac_no
				join customer on customer.cust_id=account.cust_id
where (DATEDIFF(YY,t_date,GETDATE())<=10) and (Cust_name like N'Nguyễn Lê Minh Quân')
group by account.Ac_no
print 'So lan giao dich: ' +cast( @count2 as varchar(5))
if @count2>0
	begin
		update account set ac_balance=ac_balance-50000
		where Ac_no = @ac
		set @amount2 =(select ac_balance 
						from account 
						where Ac_no=@ac)
	end
print 'So dư tai khoan: ' +cast( @amount2 as varchar(15))

/*Hà Công Lực*/

declare @bang2 table 
(ac char(10),
ac_blance numeric(15,0),
counts int)
insert into @bang2 select account.Ac_no,ac_balance,count(t_id)
					from transactions join account on transactions.ac_no=account.Ac_no
										join customer on customer.cust_id=account.cust_id
					where (DATEDIFF(YY,t_date,GETDATE())<=10) and (Cust_name like N'Hà Công Lực')
					group by account.Ac_no,ac_balance
update account set ac_balance=ac_balance+50000
		where Ac_no in (select ac from @bang2 where counts>0)
select account.Ac_no,ac_balance,count(t_id)
					from transactions join account on transactions.ac_no=account.Ac_no
										join customer on customer.cust_id=account.cust_id
					where (DATEDIFF(YY,t_date,GETDATE())<=10) and (Cust_name like N'Hà Công Lực')
					group by account.Ac_no,ac_balance

/*3. Trần Quang Khải thực hiện giao dịch gần đây nhất vào thứ mấy?
 (thứ hai, thứ ba, thứ tư,…, chủ nhật) và vào mùa nào (mùa xuân, mùa hạ, mùa thu, mùa đông)?*/
declare @thu varchar(10), @mua varchar(10)
select @thu = DATEPART(dw,t_date),@mua = DATEPART(qq,t_date)
from transactions join account on transactions.ac_no = account.Ac_no
				join customer on account.cust_id = customer.Cust_id
where Cust_name = N'Trần Quang Khải' 
order by t_date ASC
if @thu = 1 print N'Chủ nhật'
else if @thu=2 print N'Thứ 2'
else if @thu=3 print N'Thứ 3'
else if @thu=4 print N'Thứ 4'
else if @thu=5 print N'Thứ 5'
else if @thu=6 print N'Thứ 6'
else if @thu=7 print N'Thứ 7'
if @mua=1 print N'Mùa xuân'
else if @mua=2 print N'Mùa hạ'
else if @mua=3 print N'Mùa thu'
else if @mua=4 print N'Mùa đông'

/*4. Đưa ra nhận xét về nhà mạng mà Lê Anh Huy đang sử dụng?
 (Viettel, Mobi phone, Vinaphone, Vietnamobile, khác)*/

declare @sdt4 varchar(15)
select @sdt4=Cust_phone 
from customer 
where Cust_name like N'Lê Anh Huy'
print @sdt4
if LEFT(@sdt4,4) in ('0120','0121','0122','0126','0128')
	or LEFT(@sdt4,3) in ('089','090','093','070','079','077','076','078')
	begin
		print N'Lê Anh Huy đang dùng nhà mạng Mobiphone'
	end
else if LEFT(@sdt4,4) in ('0123','0124','0125','0127','0129')
	or LEFT(@sdt4,3) in ('091','094','088','083','084','085','081','082')
	begin
		print N'Lê Anh Huy đang dùng nhà mạng Vinaphone'
	end
else if LEFT(@sdt4,4) in ('0162','0163','0164','0165','0166','0167','0168','0169')
	or LEFT(@sdt4,3) in ('086','096','097','032','033','034','035','036','037','038','039')
	begin
		print N'Lê Anh Huy đang dùng nhà mạng Viettel'
	end
else if LEFT(@sdt4,4) in ('0186','0188')
	or LEFT(@sdt4,3) in ('092','056','058')
	begin
		print N'Lê Anh Huy đang dùng nhà mạng Vietnamobile'
	end
else 
	begin
		print N'Lê Anh Huy đang dùng nhà mạng khác'
	end

/*5. Số điện thoại của Trần Quang Khải là số tiến, số lùi hay số lộn xộn. 
 Định nghĩa: trừ 3 số đầu tiên, các số còn lại tăng dần gọi là số tiến,
  ví dụ: 098356789 là số tiến*/

declare @sdt1 varchar(15), @kt varchar(10) = ''
select @sdt1 = SUBSTRING(Cust_phone, 4, len(Cust_phone) - 3)
from customer where Cust_name = N'Trần Quang Khải'
print @sdt1
while LEN(@sdt1) > 1
begin
	if SUBSTRING(@sdt1,1,1) > SUBSTRING(@sdt1,2,1)
		set @kt = @kt + '>'
	else if SUBSTRING(@sdt1,1,1) < SUBSTRING(@sdt1,2,1)
		set @kt = @kt + '<'
	else 
	    set @kt = @kt + '='
	set @sdt1 = SUBSTRING(@sdt1,2,LEN(@sdt1)-1)
end 

if @kt not like ('%>%')
	print N'Số Tiến'
else if @kt not like ('%<%')
	print N'Số Lùi'
else 
	print N'Số Lộn Xộn'

/*6.Hà Công Lực thực hiện giao dịch gần đây nhất vào buổi nào
(sáng, trưa, chiều, tối, đêm)?*/

declare @gio varchar(10)
select @gio = DATEPART(HH,t_time)
from transactions join account on transactions.ac_no = account.Ac_no
				join customer on account.cust_id = customer.Cust_id
where Cust_name = N'Hà Công Lực' 
order by t_date ASC
print @gio
if @gio between 1 and 10 
	begin 
	print N'Sáng' 
	end
else if @gio between 11 and 13 
	begin 
	print N'Trưa' 
	end
else if @gio between 13 and 18 
	begin 
	print N'Chiều' 
	end
else if @gio between 19 and 21 
	begin 
	print N'Tối' 
	end
else  
	begin
	print N'Đêm'
	end

/*7. Chi nhánh ngân hàng mà Trương Duy Tường đang sử dụng thuộc miền nào?
 Gợi ý: nếu mã chi nhánh là VN  miền nam, VT  miền trung, VB  miền bắc,
 còn lại: bị sai mã.*/

declare @ma7 varchar(10)
select @ma7 = LEFT(Br_id,2)
from customer
where (Cust_name = N'Trương Duy Tường') 
print @ma7
if @ma7 = 'VN'
	begin 
	print N'Chi nhánh ngân hàng mà Trương Duy Tường đang sử dụng thuộc miền Nam' 
	end
else if @ma7 = 'VT'
	begin 
	print N'Chi nhánh ngân hàng mà Trương Duy Tường đang sử dụng thuộc miền Trung' 
	end
else if @ma7 = 'VB'
	begin 
	print N'Chi nhánh ngân hàng mà Trương Duy Tường đang sử dụng thuộc miền Bắc' 
	end
else  
	begin
	print N'Error!!!'
	end

/*8. Căn cứ vào số điện thoại của Trần Phước Đạt, hãy nhận định anh này dùng 
dịch vụ di động của hãng nào: Viettel, Mobi phone, Vina phone, hãng khác.*/

declare @sdt8 varchar(15)
select @sdt8=Cust_phone 
from customer 
where Cust_name like N'Trần Phước Đạt'
print @sdt8
if LEFT(@sdt8,4) in ('0120','0121','0122','0126','0128')
	or LEFT(@sdt8,3) in ('089','090','093','070','079','077','076','078')
	begin
		print N'Trần Phước Đạt đang dùng dịch vụ di động của hãng Mobiphone'
	end
else if LEFT(@sdt8,4) in ('0123','0124','0125','0127','0129')
	or LEFT(@sdt8,3) in ('091','094','088','083','084','085','081','082')
	begin
		print N'Trần Phước Đạt đang dùng dịch vụ di động của hãng Vinaphone'
	end
else if LEFT(@sdt8,4) in ('0162','0163','0164','0165','0166','0167','0168','0169')
	or LEFT(@sdt8,3) in ('086','096','097','032','033','034','035','036','037','038','039')
	begin
		print N'Trần Phước Đạt đang dùng dịch vụ di động của hãng Viettel'
	end
else 
	begin
		print N'Trần Phước Đạt đang dùng dịch vụ di động của hãng khách'
	end

/*9.Hãy nhận định Lê Anh Huy ở vùng nông thôn hay thành thị.
 Gợi ý: nông thôn thì địa chỉ thường có chứa 
 chữ “thôn” hoặc “xóm” hoặc “đội” hoặc “xã” hoặc “huyện”*/

declare @vung varchar(20)
select @vung = count(Cust_name) from customer
where ((Cust_ad like N'%thôn%') 
	or (Cust_ad like N'%xã%' and (Cust_ad not like N'%thị xã%') ) 
	or (Cust_ad like N'%xóm%')
	or (Cust_ad like N'%đội%')
	or (Cust_ad like N'%huyện%'))
	and Cust_name = N'Lê Anh Huy'
if @vung = 0 
	print N'Thành thị'
else print N'Nông thôn'

/*10. Hãy kiểm tra tài khoản của Trần Văn Thiện Thanh, nếu tiền trong tài khoản
 của anh ta nhỏ hơn không hoặc bằng không nhưng 6 tháng gần đây không có giao dịch
 thì hãy đóng tài khoản bằng cách cập nhật ac_type = ‘K’*/

declare @tien10 numeric(15, 0), @tg10 int,@loai10 varchar(5),@ac10 char(10)
select @ac10=account.Ac_no, @tien10 = ac_balance,@tg10 = DATEDIFF(mm,t_date,getdate())
from transactions join account on transactions.ac_no = account.Ac_no
				join customer on account.cust_id = customer.Cust_id
where Cust_name = N'Trần Văn Thiện Thanh'
order by t_date
print N'Số tiền trong tài khoản: '+ cast(@tien10 as varchar(15))
print N'Số tháng kể từ lần giao dịch cuối cùng đến nay: '+cast(@tg10 as varchar(5))
if (@tien10<=0) and (@tg10>6)
	begin
	update account set ac_type='K'
	where Ac_no = @ac10
	set @loai10 =( select ac_type 
					from account
					where Ac_no=@ac10)
	print N'Đã cập nhật'
	end
/*11. Mã số giao dịch gần đây nhất của Huỳnh Tấn Dũng là số chẵn hay số lẻ?*/
declare @ma11 char(10)
select @ma11 = t_id
from transactions join account on transactions.ac_no = account.Ac_no
				join customer on account.cust_id = customer.Cust_id
where Cust_name = N'Huỳnh Tấn Dũng' 
order by t_date ASC
if @ma11 % 2 =0
	print N'Mã số giao dịch gần đây nhất là số chẵn'
else print N'Mã số giao dịch gần đây nhất là số lẻ'

/*12. Có bao nhiêu giao dịch diễn ra trong tháng 9/2016 với tổng tiền mỗi loại là bao nhiêu 
(bao nhiêu tiền rút, bao nhiêu tiền gửi)*/

declare @count12 int, @tienrut numeric(15,0), @tiengui numeric(15,0)
select @count12 = count(t_id)
from transactions
where (MONTH(t_date)=9) and (YEAR(t_date)=2016)
select @tienrut = sum(t_amount)
from transactions
where (MONTH(t_date)=9) and (YEAR(t_date)=2016) and (t_type=0)
if @tienrut is null
	begin
	set @tienrut=0
	end
select @tiengui = sum(t_amount)
from transactions
where (MONTH(t_date)=9) and (YEAR(t_date)=2016) and (t_type=1)
if @tiengui is null
	begin
	set @tiengui=0
	end
print N'Số lượng giao dịch diễn ra trong tháng 9/2016: '+cast(@count12 as varchar(5))
print N'Tổng số tiền gửi: ' + cast(@tiengui as varchar(15))
print N'Tổng số tiền rút: ' + cast(@tienrut as varchar(15))

/*13. Ở Hà Nội ngân hàng Vietcombank có bao nhiêu chi nhánh và có bao nhiêu khách hàng?
 Trả lời theo mẫu: “Ở Hà Nội, Vietcombank có … chi nhánh và có …khách hàng”*/

declare @snh int, @skh int
select @snh = count(Br_id) 
from Branch 
where BR_name like N'%Hà Nội%'
select @skh = count(Cust_id) 
from customer join Branch on customer.Br_id=Branch.BR_id
where BR_name like N'%Hà Nội%'
print N'Ở Hà Nội, Vietcombank có '+ cast(@snh as nvarchar(3))
    + N' chi nhánh và có ' + cast(@skh as varchar(3)) + N' khách hàng'

/*14. Tài khoản có nhiều tiền nhất là của ai,số tiền hiện có trong tài khoản đó là bao nhiêu?
 Tài khoản này thuộc chi nhánh nào?*/

declare @ai nvarchar(50), @tien14 numeric(15,0), @cn nvarchar(50)
select @ai = Cust_name,@tien14 = ac_balance, @cn = BR_name
from account join customer on account.cust_id=customer.Cust_id
			join Branch on customer.Br_id=Branch.BR_id
order by ac_balance
print N'Tài khoản có nhiều tiền nhất là của '+ @ai
print N'số tiền hiện có trong tài khoản đó là '+cast(@tien14 as varchar(15))
print N'Tài khoản này thuộc chi nhánh có tên ' + @cn

/*15. Có bao nhiêu khách hàng ở Đà Nẵng?*/

declare @kh15 int
select @kh15 = count(cust_id)
from customer
where UPPER(Cust_ad) like N'%ĐÀ NẴNG%'
print @kh15

/*16. Có bao nhiêu khách hàng ở Quảng Nam nhưng mở tài khoản Sài Gòn*/

declare @kh16 int
select @kh16 = count(cust_id)
from customer join Branch on customer.Br_id=Branch.BR_id
where (UPPER(Cust_ad) like N'%QUẢNG NAM%') and (UPPER(Br_name) like N'%SÀI GÒN%')
print @kh16

/*17.Ai là người thực hiện giao dịch có mã số 0000000387, thuộc chi nhánh nào?
 Giao dịch này thuộc loại nào?*/

declare @ai17 nvarchar(50), @loai int, @cn17 nvarchar(50)
select @ai17 = Cust_name,@loai = t_type, @cn17 = BR_name
from transactions join account on transactions.ac_no=account.Ac_no 
			join customer on account.cust_id=customer.Cust_id
			join Branch on customer.Br_id=Branch.BR_id
where t_id = '0000000387'
print N'Tài khoản có nhiều tiền nhất là của '+ @ai17
if @loai = 0
	begin
	print N'Giao dịch này thuộc loại là rút tiền'
	end
else
	begin
	print N'Giao dịch này thuộc loại là gửi tiền'
	end
print N'Tài khoản này thuộc chi nhánh có tên ' + @cn17

/*18. Hiển thị danh sách khách hàng gồm: họ và tên, số điện thoại, số lượng tài khoản đang có và nhận xét.
 Nếu < 1 tài khoản  “Bất thường”, còn lại “Bình thường”*/

declare @bang18 table 
(hoten nvarchar(50),
sdt varchar(15),
soluongtk int,
nhanxet nvarchar(20))
insert into @bang18 select Cust_name,Cust_phone,count(ac_no),N'Bình thường'
					from account join customer on account.cust_id=customer.Cust_id
					group by Cust_name,Cust_phone
update @bang18 set nhanxet = N'Bất thường' where soluongtk<1
select hoten as N'Họ và tên', sdt as N'Số điện thoại',
		soluongtk as N'Số lượng tài khoản đang có', nhanxet as N'Nhận xét' 
from @bang18

/*19.Viết đoạn code nhận xét tiền trong tài khoản của ông Hà Công Lực.
 <100.000: ít, < 5.000.000  trung bình, còn lại: nhiều*/

declare @tien19 numeric(15,0)
select @tien19 = sum(ac_balance)
from account join customer on account.cust_id=customer.Cust_id
where Cust_name = N'Hà Công Lực'
if @tien19<100000
	begin
	print N'Số tiền trong tài khoản của ông Hà Công Lực còn ít'
	end
else if @tien19<5000000
	begin
	print N'Số tiền trong tài khoản của ông Hà Công Lực còn trung bình'
	end
else
	begin
	print N'Số tiền trong tài khoản của ông Hà Công Lực còn nhiều'
	end

/*20.Hiển thị danh sách các giao dịch của chi nhánh Huế với các thông tin:
 mã giao dịch, thời gian giao dịch, số tiền giao dịch, loại giao dịch (rút/gửi), số tài khoản. Ví dụ:
Mã giao dịch		Thời gian GD	Số tiền GD	Loại GD		Số tài khoản
00133455		2017-11-30 09:00	3000000		Rút			04847374948			*/

declare @bang20 table 
(mgd varchar(15),
tggd date,
stgg numeric(15,0),
lgd nvarchar(10),
stk varchar(15))
insert into @bang20 select t_id,t_date,t_amount,t_type,transactions.ac_no
					from transactions join account on transactions.ac_no=account.Ac_no
									join customer on account.cust_id=customer.Cust_id
									join Branch on customer.Br_id=Branch.BR_id
					where BR_name like N'%Huế%'
update @bang20 set lgd = N'Rút' where lgd=0
update @bang20 set lgd = N'Gửi' where lgd='1'
select mgd N'Mã giao dịch', tggd N'Thời gian GD',
	stgg N'Số tiền GD',lgd N'Loại GD', stk N'Số tài khoản'
from @bang20

/*21. Kiểm tra xem khách hàng Nguyễn Đức Duy có ở Quảng Nam hay không?*/

declare @dc nvarchar(100)
select @dc = UPPER(cust_ad)
from customer
where Cust_name = N'Nguyễn Đức Duy'
if @dc like N'%QUẢNG NAM%'
	begin
	print N'Khách hàng Nguyễn Đức Duy ở Quảng Nam'
	end
else
	begin
	print N'Khách hàng Nguyễn Đức Duy không ở Quảng Nam'
	end
/*22.Điều tra số tiền trong tài khoản ông Lê Quang Phong có hợp lệ hay không?
 (Hợp lệ: tổng tiền gửi – tổng tiền rút = số tiền hiện có trong tài khoản). 
 Nếu hợp lệ, đưa ra thông báo “Hợp lệ”, ngược lại hãy cập nhật lại tài khoản sao cho số tiền trong tài khoản
  khớp với tổng số tiền đã giao dịch (ac_balance = sum(tổng tiền gửi) – sum(tổng tiền rút)*/

declare @tien22 numeric(15,0), @tienrut22 numeric(15,0), @tiengui22 numeric(15,0),@ac22 char(10)
select @tien22 = ac_balance,@ac22 = account.Ac_no
from account join customer on account.cust_id=customer.cust_id
where Cust_name = N'Lê Quang Phong'
select @tienrut22 = sum(t_amount)
from transactions right outer join account on transactions.ac_no=account.Ac_no
				right outer join customer on account.cust_id=customer.cust_id
where (Cust_name = N'Lê Quang Phong') and (t_type=0)
if @tienrut22 is null
	begin
	set @tienrut22=0
	end
select @tiengui22 = sum(t_amount)
from transactions right outer join account on transactions.ac_no=account.Ac_no
				right outer join customer on account.cust_id=customer.cust_id
where (Cust_name = N'Lê Quang Phong') and (t_type=1)
if @tiengui22 is null
	begin
	set @tiengui22=0
	end
print N'Số tiền hiện có trong tài khoản: '+cast(@tien22 as varchar(15))
print N'Tổng số tiền gửi: ' + cast(@tiengui22 as varchar(15))
print N'Tổng số tiền rút: ' + cast(@tienrut22 as varchar(15))
if (@tiengui22-@tienrut22)=@tien22
	begin
	print N'Hợp lệ'
	end
else
	begin
	update account set ac_balance = @tiengui22-@tienrut22
	where Ac_no = @ac22
	set @tien22 = (select ac_balance from account where Ac_no=@ac22)
	print N'Cập nhật lại tài khoản: ac_balance = ' +cast(@tien22 as varchar(15))
	end

/*23. Chi nhánh Đà Nẵng có giao dịch gửi tiền nào diễn ra vào ngày chủ nhật hay không?
 Nếu có, hãy hiển thị số lần giao dịch, nếu không, hãy đưa ra thông báo “không có”*/

declare @count23 int
select @count23 = count(t_id)
from transactions join account on transactions.ac_no=account.Ac_no
				join customer on account.cust_id=customer.Cust_id
				join Branch on customer.Br_id=Branch.BR_id
where (DATEPART(dw,t_date)=7) and (BR_name like N'%Đà Nẵng%') and (t_type=1)
if @count23 = 0
	begin
	print N'Không có'
	end
else
	begin
	print @count23
	end

/*24. Kiểm tra xem khu vực miền bắc có nhiều phòng giao dịch hơn khu vực miền trung ko? 
Miền bắc có mã bắt đầu bằng VB, miền trung có mã bắt đầu bằng VT*/

declare @mb int, @mt int
select @mb = count(br_id)
from Branch
where BR_id like 'VB%'
select @mt = count(br_id)
from Branch
where BR_id like 'VT%'
print N'khu vực miền bắc: ' + cast(@mb as varchar(5))
print N'khu vực miền trung: ' + cast(@mt as varchar(5))
if @mb>@mt
	begin
	print N'Miền bắc có nhiều phòng giao dịch hơn'
	end
else if @mb<@mt
	begin
	print N'Miền Trung có nhiều phòng giao dịch hơn'
	end
else
	begin
	print N'hai miền có số phòng giao dịch bằng nhau'
	end
/*VÒNG LẶP*/

/*1. In ra dãy số lẻ từ 1 – n, với n là giá trị tự chọn*/

declare @n1 int,@i1 int
set @n1=15
set @i1=1
while @i1<=@n1
	begin
	print @i1
	set @i1=@i1+2
	end

/*2. In ra dãy số chẵn từ 0 – n, với n là giá trị tự chọn*/

declare @n2 int,@i2 int
set @n2=18
set @i2=0
while @i2<=@n2
	begin
	print @i2
	set @i2=@i2+2
	end

/*3. In ra 100 số đầu tiền trong dãy số Fibonaci*/

declare @f numeric(30,0),@f1 numeric(30,0),@f2 numeric(30,0), @i3 int
set @f1=1
set @f2=1
set @i3=1
while @i3<=100
	begin
		if (@i3=1) or (@i3=2)
		begin 
			set @f=1
		end
		else
		begin
			set @f=@f1+@f2
			set @f1=@f2
			set @f2=@f
		end
		print @f
		set @i3=@i3+1
	end

/*4. In ra tam giác sao: 1 tam giác vuông, 1 tam tam giác cân như ví dụ dưới đây:*/

declare @star varchar(15)
set @star = '*'
while len(@star)<=5
	begin
		print @star
		set @star = @star + '*'
	end

declare @n int
set @n =1
while (@n<=4)
begin
  print replicate (' ',9 - 2*@n-1) + replicate('* ',2*@n-1)
  set @n=@n+1
end
/*5. In bảng cửu chương*/

declare @i4 int, @j4 int
set @i4=1
while @i4<=9
	begin
		print N'Bảng cửu chương '+cast(@i4 as varchar(5))
		set @j4=1
		while @j4<=10
		begin
		print cast(@i4 as varchar(5)) + ' x '+ cast(@j4 as varchar(5))+ ' = ' +cast(@j4*@i4 as varchar(5))
		set @j4=@j4+1
		end
		set @i4=@i4+1
	end

/*6. Viết đoạn code đọc số. Ví dụ: 1.234.567  
Một triệu hai trăm ba mươi tư ngàn năm trăm sáu mươi bảy đồng. (Giả sử số lớn nhất là hàng trăm tỉ)*/

declare @i int, @j int, @x int,@y int = 1, @doc nvarchar(100) = N' đồng.', @a varchar(15) ='4581365476'
set @j=len(@a)%3
set @i = case when @j=0 then len(@a)/3
			else len(@a)/3+1
		end 
while @y<@i
	begin
	set @x=1
	while @x<=3
		begin
		if substring(@a,len(@a),1)=0 set @doc=N' không'+@doc
		else if substring(@a,len(@a),1)=1 set @doc=N' một'+@doc
		else if substring(@a,len(@a),1)=2 set @doc=N' hai'+@doc
		else if substring(@a,len(@a),1)=3 set @doc=N' ba'+@doc
		else if substring(@a,len(@a),1)=4 set @doc=N' bốn'+@doc
		else if substring(@a,len(@a),1)=5 set @doc=N' năm'+@doc
		else if substring(@a,len(@a),1)=6 set @doc=N' sáu'+@doc
		else if substring(@a,len(@a),1)=7 set @doc=N' bảy'+@doc
		else if substring(@a,len(@a),1)=8 set @doc=N' tám'+@doc
		else set @doc=N' chín'+@doc
		set @x=@x+1
		if @x=2 set @doc=N' mươi'+@doc
		else if @x=3 set @doc=N' trăm'+@doc
		set @a=left(@a,len(@a)-1)
		end
	set @y=@y+1
	if @y=2 set @doc=N' ngàn'+@doc
	else if @y=3 set @doc=N' triệu'+@doc
	else if @y=4 set @doc=N' tỷ'+@doc
	end
set @x=1
while @x<=@j
	begin
	if substring(@a,len(@a),1)=0 set @doc=N' không'+@doc
	else if substring(@a,len(@a),1)=1 set @doc=N' một'+@doc
	else if substring(@a,len(@a),1)=2 set @doc=N' hai'+@doc
	else if substring(@a,len(@a),1)=3 set @doc=N' ba'+@doc
	else if substring(@a,len(@a),1)=4 set @doc=N' bốn'+@doc
	else if substring(@a,len(@a),1)=5 set @doc=N' năm'+@doc
	else if substring(@a,len(@a),1)=6 set @doc=N' sáu'+@doc
	else if substring(@a,len(@a),1)=7 set @doc=N' bảy'+@doc
	else if substring(@a,len(@a),1)=8 set @doc=N' tám'+@doc
	else set @doc=N' chín'+@doc
	set @x=@x+1
	if (@x=2) and (@x<>@j+1) set @doc=N' mươi'+@doc
	else if (@x=3) and (@x<>@j+1)set @doc=N' trăm'+@doc
	set @a=left(@a,len(@a)-1)
	end
set @doc=Right(@doc,len(@doc)-1)
print @doc

/*7. Kiểm tra số điện thoại của Lê Quang Phong là số tiến hay số lùi. 
Gợi ý:
	Với những số điện thoại có 10 số, thì trừ 3 số đầu tiên, 
	nếu số sau lớn hơn hoặc bằng số trước thì là số tiến, ngược lại là số lùi. 
	Ví dụ: 0981.244.789 (tiến), 0912.776.541 (lùi), 0912.563.897 (lộn xộn)
	Với những số điện thoại có 11 số thì trừ 4 số đầu tiên. */
declare @sdt7 varchar(15), @kt7 varchar(10) = ''
select @sdt7 = RIGHT(Cust_phone,7)
from customer where Cust_name = N'Lê Quang Phong'
print @sdt7
while LEN(@sdt7) > 1
begin
	if SUBSTRING(@sdt7,1,1) > SUBSTRING(@sdt7,2,1)
		set @kt7 = @kt7 + '>'
	else if SUBSTRING(@sdt7,1,1) < SUBSTRING(@sdt7,2,1)
		set @kt7 = @kt7 + '<'
	else 
	    set @kt7 = @kt7 + ''
	set @sdt7 = RIGHT(@sdt7,len(@sdt7)-1)
end 
if @kt7 not like ('%>%')
	print N'Số Tiến'
else if @kt7 not like ('%<%')
	print N'Số Lùi'
else 
	print N'Số Lộn Xộn'