Use DB_Books
go
--tạo key
ALTER TABLE Books
ALTER COLUMN ID int not null
ALTER TABLE Books
ADD CONSTRAINT Books_PK PRIMARY KEY (ID)
--xóa cột link
--alter table Books
--drop column link
--xử lý null
delete from Books where [Tên sách] is null
delete from Books where [Giá bán] is null
delete from Books where [Mô tả sản phẩm] is null
update Books set [Tác giả] = N'Nhiều tác giả' 
where ([Tác giả] is null) or ([Tác giả] = ',') or ([Tác giả] = '.') 
or ([Tác giả] = N'Nhiều') or ([Tác giả] = 'nhieu tac gia') or ([Tác giả] = N'Nhóm tác giả')
update Books set [Tác giả] = Left([Tác giả], len([Tác giả])-1) where Right([Tác giả], 1) = ',' 
update Books set [Thể loại] = N'Khác' where [Thể loại] is null
update Books set [Giảm giá] = '0%' where [Giảm giá] is null
update Books set [Số lượng bán] = 0 where [Số lượng bán] is null
update Books set [Điểm đánh giá] = 0 where [Điểm đánh giá] is null
update Books set [Số nhận xét] = 0 where [Số nhận xét] is null
update Books set [Giá gốc] = [Giá bán] where [Giá gốc] is null
--Định dạng
update Books set [Giá bán] = REPLACE([Giá bán],'.','')
update Books set [Giá gốc] = REPLACE([Giá gốc],'.','')
update Books set [Giá bán] = LEFT([Giá bán],len([Giá bán])-2)
update Books set [Giá gốc] = LEFT([Giá gốc],len([Giá gốc])-2)
update Books set [Số lượng bán] = RIGHT([Số lượng bán],len([Số lượng bán])-7) where len([Số lượng bán])>7
update Books set [Số nhận xét] = LEFT([Số nhận xét],len([Số nhận xét])-9) where len([Số nhận xét])>9
update Books set [Thể loại] = Right([Thể loại], (len([Thể loại])-CHARINDEX('/', [Thể loại],1)))
update Books set [Tác giả] = Left([Tác giả], len([Tác giả]))
delete from Books where ([Tác giả] = N'Nhiều tác giả') or ([Tác giả] = '`') 
or ([Tác giả] like N'%div class%') or ([Tác giả] = '.') or ([Tác giả] = '...')
ALTER TABLE Books
ALTER COLUMN [Giá bán] money
ALTER TABLE Books
ALTER COLUMN [Giá gốc] money
ALTER TABLE Books
ALTER COLUMN [Số nhận xét] int

select * from Books
