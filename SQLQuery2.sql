set transaction isolation level read committed
select * from transactions where t_id = '0000000201'





--repeatable read
update transactions set t_amount = 200 where t_id ='0000000208'
select * from transactions where t_id ='0000000208'
select * from bank




--