begin transaction
update transactions set t_amount = 100
where t_id = '0000000201'
waitfor delay '00:00:10' --Chờ 10 giây
rollback

select * from transactions where t_id = '0000000201'
--repeatable read
set transaction isolation level repeatable read
begin transaction
select * from transactions where t_id ='0000000208'
waitfor delay '00:00:15'
select * from transactions where t_id ='0000000208'
commit
--serializable
set transaction isolation level serializable
begin tran
select * from bank 
waitfor delay '00:00:10'
select * from bank
commit
--Snapshot
ALTER DATABASE TestDB
SET ALLOW_SNAPSHOT_ISOLATION O