use Bank
select Cust_id,Cust_name,Cust_phone,Cust_ad,b_name 
from customer join (Bank join Branch on Bank.b_id=Branch.B_id) on customer.Br_id=Branch.BR_id
--1
select Cust_id,Cust_name,Cust_phone,Cust_ad from customer
where (Cust_ad like N'%Ngũ Hành Sơn%') and (Cust_ad like N'%Đà Nẵng%')
--2
select BR_id,BR_name,BR_ad from Branch
where BR_ad = ''
--3
select t_id,t_date,t_time,t_amount,t_type from transactions
where (t_amount < 50000) and (t_type = 0)
--4
select Cust_id,Cust_name,Cust_phone,Cust_ad from customer
where (Cust_name like N'%[a,u,i]__')
--5
select Cust_id,Cust_name,Cust_phone,Cust_ad from customer
where (Cust_ad like N'%thôn%') 
or (Cust_ad like N'%xã%' and (Cust_ad not like N'%thị xã%') ) 
or (Cust_ad like N'%xóm%')
--6
select  Cust_name,Cust_phone,Cust_ad, t_date
from (account join transactions on account.Ac_no=transactions.ac_no)
				join customer on customer.Cust_id=account.cust_id
where (DATEPART(qq,t_date)=1) and (DATEPART(yy,t_date)=2012) and (t_type=0)
--7
select Cust_name, t_id,t_date,t_time,t_amount,t_type 
from (account join transactions on account.Ac_no=transactions.ac_no)
 join customer on customer.Cust_id=account.cust_id 
 where datepart(hh,t_time)=(select datepart(hh,t_time) from (account join transactions on account.Ac_no=transactions.ac_no)
 join customer on customer.Cust_id=account.cust_id where (Cust_name = N'Lê Nguyễn Hoàng Văn') and (DATEPART(yy,t_date)=2016)) 
  and (Cust_name <> N'Lê Nguyễn Hoàng Văn') and (DATEPART(yy,t_date)=2016)
--8
select t_id,t_date,t_time,t_amount,t_type,BR_name
from ((account join transactions on account.Ac_no=transactions.ac_no) 
				join customer on customer.Cust_id=account.cust_id)
				join Branch on Branch.BR_id=customer.Br_id
where BR_name like N'%Huế%'
--9
select cust_name, LEFT(cust_name,LEN(cust_name) - CHARINDEX(' ',REVERSE(cust_name))) as 'ho va ten dem',
 RIGHT(cust_name,CHARINDEX(' ',REVERSE(cust_name))) as 'ten' from customer
--10
Select cust_name as N'Tên khách hàng', 
reverse(left(reverse(cust_ad),CHARINDEX(',',REVERSE(Replace(Cust_ad,'-',','))) - 1)) as N'Tỉnh/Thành Phố' from customer

select cust_ad, 
ltrim(rtrim(iif(CHARINDEX(',',REVERSE(Cust_ad))>0,
 iif(len(RIGHT(Cust_ad,CHARINDEX(',',REVERSE(cust_ad))-1))<20,
RIGHT(Cust_ad,CHARINDEX(',',REVERSE(cust_ad))-1),RIGHT(Cust_ad,CHARINDEX(' ',REVERSE(cust_ad),7)-1)),
RIGHT(Cust_ad,CHARINDEX('-',REVERSE(cust_ad))-1)))) as 'Tinh/TP' from customer
--11
select t_date,t_type,cust_name, BR_name, t_amount 
from ((account join transactions on account.Ac_no=transactions.ac_no) 
				join customer on customer.Cust_id=account.cust_id) 
				join Branch on Branch.BR_id=customer.Br_id
where (t_date='2013-09-27') and (t_type=1)
--12
select cust_name, BR_name,t_date,t_time, t_type, t_amount 
from ((account join transactions on account.Ac_no=transactions.ac_no) 
				join customer on customer.Cust_id=account.cust_id) 
				join Branch on Branch.BR_id=customer.Br_id
where Cust_name = N'Nguyễn Lê Minh Quân'
--13
select cust_name, BR_name,t_date, t_type, t_amount 
from ((account join transactions on account.Ac_no=transactions.ac_no) 
				join customer on customer.Cust_id=account.cust_id) 
				join Branch on Branch.BR_id=customer.Br_id
where BR_name like N'%Huế%' 
and (DATEPART(yy,t_date)=2014) 
and (DATEPART(mm,t_date) BETWEEN 5 and 12)
--14
select  customer.Cust_id,Cust_name,Cust_phone, count(t_id)
from (account full outer join transactions on account.Ac_no=transactions.ac_no) 
right outer join customer on customer.Cust_id=account.cust_id
where (cust_phone LIKE '03[2,3,4,5,6,7,8,9]%') or (cust_phone LIKE '016[2,3,4,5,6,7,8,9]%') 
or (cust_phone LIKE '086%') or (cust_phone LIKE '09[6,7,8]%')
group by customer.Cust_id,Cust_name,Cust_phone
having count(t_id)=0
--15
Select Cust_id, Cust_name, Cust_phone, Cust_ad, BR_name 
from customer join Branch on Branch.BR_id=customer.Br_id
Where upper(ltrim(rtrim(iif(CHARINDEX(',',REVERSE(Cust_ad))>0,
 iif(len(RIGHT(Cust_ad,CHARINDEX(',',REVERSE(cust_ad))-1))<20,
RIGHT(Cust_ad,CHARINDEX(',',REVERSE(cust_ad))-1),RIGHT(Cust_ad,CHARINDEX(' ',REVERSE(cust_ad),7)-1)),
RIGHT(Cust_ad,CHARINDEX('-',REVERSE(cust_ad))-1))))) 
not like UPPER(LTRIM(RIGHT(BR_name,len(BR_Name)-CHARINDEX(' ',BR_name))))
--16
select Cust_name,Cust_phone from customer
where len(cust_phone)=11
--17
select cust_name, BR_name,t_date, t_type, t_amount 
from ((account join transactions on account.Ac_no=transactions.ac_no) 
				join customer on customer.Cust_id=account.cust_id)
				join Branch on Branch.BR_id=customer.Br_id
where (DATEPART(yy,t_date)=2013) and (DATEPART(qq,t_date)=1)
--18
select t_id,t_date,t_type,DATEPART(dw,t_date) from transactions
where (t_type=1) and ((DATEPART(dw,t_date)=1) or (DATEPART(dw,t_date)=7))

select t_id,t_date,t_type,DATEPART(dw,t_date) from transactions
where (t_type=1) and DATEPART(dw,t_date) in (1,7)
--19
select BR_name, count(Cust_id) as 'SL'
from Branch left outer join customer on Branch.BR_id=customer.Br_id
group by BR_name
having count(Cust_id) = 0

select BR_name, Cust_id
from Branch left outer join customer on Branch.BR_id=customer.Br_id
where Cust_id is NULL
--20
select account.Ac_no, count(t_id) as 'SL'
from account left outer join transactions on account.Ac_no=transactions.ac_no
group by account.Ac_no
having count(t_id)=0

select account.Ac_no, ac_type
from account left outer join transactions on account.Ac_no=transactions.ac_no
where t_id is Null
-- Ai là người cùng chi nhánh với Trần Văn Thiện Thanh
select Cust_name,Br_id from customer
where Br_id = (select Br_id from customer where Cust_name=N'Trần Văn Thiện Thanh')

--Chi nhánh nào không khách hàng
select br_name from Branch
where BR_id not in (select br_id from customer)

--1. Thống kê số lượng giao dịch, tổng tiền giao dịch trong từng tháng của năm 2014
select datepart(month,t_date) 'Tháng',count(t_id) 'So luong',sum(t_amount) 'tong tien giao dich'
from transactions
where datepart(yy,t_date)=2014
group by datepart(month,t_date)

--2. Thống kê tổng tiền khách hàng gửi của mỗi chi nhánh, sắp xếp theo thứ tự giảm dần của tổng tiền
select BR_name, sum(t_amount) as 'tong tien gui'
from ((account join transactions on account.Ac_no=transactions.ac_no) 
				join customer on customer.Cust_id=account.cust_id) 
				join Branch on Branch.BR_id=customer.Br_id
where t_type=0
group by BR_name
order by sum(t_amount) DESC

-- 3. Những chi nhánh nào thực hiện nhiều giao dịch gửi tiền trong tháng 12/2015 hơn chi nhánh ĐN
select BR_name, t_type, DATEPART(mm,t_date) 'Thang',DATEPART(yy,t_date) 'Nam', count(t_id) as 'so luong'
from ((account join transactions on account.Ac_no=transactions.ac_no) 
				join customer on customer.Cust_id=account.cust_id) 
				join Branch on Branch.BR_id=customer.Br_id
where DATEPART(mm,t_date)=12 and DATEPART(yy,t_date)=2015 and t_type=1
group by BR_name, t_type,DATEPART(mm,t_date),DATEPART(yy,t_date)
having count(t_id)>= (select count(t_id) 
						from ((account join transactions on account.Ac_no=transactions.ac_no) 
										join customer on customer.Cust_id=account.cust_id) 
										join Branch on Branch.BR_id=customer.Br_id
						where br_name like N'%Đà Nẵng%' 
						and t_type=1 
						and DATEPART(mm,t_date)=12 
						and DATEPART(yy,t_date)=2015)

--4. Hiển thị danh sách khách hàng chưa thực hiện giao dịch nào trong năm 2017
select distinct Cust_name
from customer 
where 
(customer.Cust_id not in (select distinct cust_id 
							from transactions join account on account.Ac_no=transactions.ac_no 
							where (DATEPART(yy,t_date) = 2017))) 
	or 
	(customer.Cust_id = (select  Cust_id 
							from (account full outer join transactions on account.Ac_no=transactions.ac_no) 
							group by Cust_id
							having count(t_id)=0))

--5. Tìm giao dịch gửi tiền nhiều nhất trong mùa đông. Nếu có thể, hãy đưa ra tên của người thực hiện giao dịch và chi nhánh
select Cust_name,BR_name,t_amount,t_type,DATEPART(qq,t_date) as N'Quý'
from ((account join transactions on account.Ac_no=transactions.ac_no) 
				join customer on customer.Cust_id=account.cust_id) 
				join Branch on Branch.BR_id=customer.Br_id
where t_amount = (select max(t_amount) from transactions where datepart(qq,t_date)=4)
	and (t_type=1) and (datepart(qq,t_date)=4)

--6. Có bao nhiêu người ở Đắc Lắc sở hữu nhiều hơn một tài khoản?
with a as (select customer.Cust_id,Cust_ad,COUNT(Ac_no) as 'SL'
from account join customer on account.cust_id=customer.Cust_id
where (Cust_ad like N'%Đăk%') and (Cust_ad like N'%Lăk%') 
group by customer.Cust_id,Cust_ad
having COUNT(Ac_no)>1)
select count(cust_id) from a

/*7. Cuối mỗi năm, nhiều khách hàng có xu hướng rút tiền khỏi ngân hàng để chuyển sang ngân hàng 
khác hoặc chuyển sang hình thức tiết kiệm khác. Hãy lọc những khách hàng có xu hướng rút tiền khỏi
ngân hàng bằng cách hiển thị những người rút gần hết tiền trong tài khoản (tổng tiền rút trong
tháng 12/2017 nhiều hơn 100 triệu và số dư trong tài khoản còn lại <= 100.000)*/

select Cust_id,ac_balance,t_type,sum(t_amount)
from account join transactions on account.Ac_no=transactions.ac_no
where (t_type=0) and (ac_balance<=100000) and (YEAR(t_date)=2017) and (MONTH(t_date)=12)
group by Cust_id,ac_balance,t_type
having sum(t_amount)>100000000

/*8. Hãy liệt kê những tài khoản bất thường đó. 
Gợi ý: tài khoản bất thường là tài khoản có tổng tiền gửi – tổng tiền rút <> số tiền trong tài khoản*/

with gui as (select ac_no,sum(t_amount) as 'tiengui' 
			from transactions where t_type=1 group by ac_no), 
	rut as (select ac_no,sum(t_amount) as 'tienrut' 
			from transactions where t_type=0 group by ac_no)
select account.ac_no,iif(tiengui is null,0,tiengui)-iif(tienrut is null,0,tienrut) as 'gui-rut',ac_balance 
from account left outer join gui on gui.ac_no=account.Ac_no
			left outer join rut on gui.ac_no=rut.ac_no
where (iif(tiengui is null,0,tiengui)-iif(tienrut is null,0,tienrut) <> ac_balance)

/*9. Ngân hàng cần biết những chi nhánh nào có nhiều giao dịch rút tiền vào buổi chiều để chuẩn bị 
chuyển tiền tới. Hãy liệt kê danh sách các chi nhánh và lượng tiền rút trung bình theo ngày (chỉ xét 
những giao dịch diễn ra trong buổi chiều), sắp xếp giảm dần theo lượng tiền giao dịch. */

select Br_id,avg(t_amount) as 'Luong tien trung binh'
from customer join account on customer.Cust_id=account.cust_id
			join transactions on account.Ac_no=transactions.ac_no
where datepart(HH,t_time) between 13 and 17
group by Br_id
order by avg(t_amount) DESC

/*10. Hiển thị những giao dịch trong mùa xuân của các chi nhánh miền trung. 
Gợi ý: giả sử một năm có 4 mùa, mỗi mùa kéo dài 3 tháng; 
chi nhánh miền trung có mã chi nhánh bắt đầu bằng VT.*/

select t_id, t_date, br_id
from customer join account on customer.Cust_id=account.cust_id
			join transactions on account.Ac_no=transactions.ac_no
where (DATEPART(mm,t_date) between 1 and 3) and (Br_id like 'VT%') 

/*11. Ông Phạm Duy Khánh thuộc chi nhánh nào? Từ 01/2017 đến nay ông Khánh đã thực hiện bao nhiêu
giao dịch gửi tiền vào ngân hàng với tổng số tiền là bao nhiêu.*/

select BR_name,t_type,count(t_id) as 'so giao dich',sum(t_amount) as 'tong tien' 
from Branch join customer on Branch.BR_id=customer.Br_id
			join account on customer.Cust_id=account.cust_id
			join transactions on account.Ac_no=transactions.ac_no
where (Cust_name like N'Phạm Duy Khánh')  and (YEAR(t_date)>=2017)
group by BR_name,t_type

/*12. Hiển thị khách hàng cùng họ với khách hàng có mã số 000002*/

select Cust_id,Cust_name
from customer
where LEFT(Cust_name,CHARINDEX(' ',Cust_name)) = (select LEFT(Cust_name,CHARINDEX(' ',Cust_name))
												from customer
												where Cust_id='000002')

/*13. Hiển thị những khách hàng sống cùng tỉnh/thành phố với ông Lương Minh Hiếu*/

select Cust_name,Cust_ad from customer 
where replace(UPPER(replace(reverse(left(reverse(cust_ad),
												CHARINDEX(',',REVERSE(Replace(Cust_ad,
																			'-',','))) - 1)),'.','')),N'TỈNH ','')
 = (select reverse(left(reverse(cust_ad),CHARINDEX(',',REVERSE(Replace(Cust_ad,'-',','))) - 1))
	from customer 
	where Cust_name Like N'Lương Minh Hiếu')