USE master
GO
create DATABASE EmployeeDB
GO
USE EmployeeDB
GO

IF EXISTS (SELECT * FROM sys.databases WHERE Name='EmployeeDB')
DROP DATABASE EmployeeDB
GO

--Create table
CREATE TABLE Department
(
    Department_ID int PRIMARY KEY,
    Department_name VARCHAR(50) NOT NULL,
    Department_description VARCHAR(100) NOT NULL
)

CREATE TABLE Employee
(
    Employee_code CHAR(6) PRIMARY KEY,
    First_name VARCHAR(30) NOT NULL,
    Last_name VARCHAR(30) NOT NULL,
    Birthday DATE NOT NULL,
    Gender BIT DEFAULT(1),
    Employee_address VARCHAR(100),
    Department_Id int foreign key references [Department](Department_Id),
    Salary money
)

INSERT into Department VALUES
(1, N'Nhân viên bán hàng', N'Gioi thieu san phẩm và dich vu'),
(2, N'Thu ngan', N'Quan ly giao dich khach hang'),
(3, N'Tư vấn khách hàng', N'Tu van va cham soc khach hang')

SELECT * FROM Department
GO

INSERT into Employee VALUES
('EMP001', 'Tran Vu', 'Minh Ngoc', '1999-09-04', 1, 'Hà Noi', 1, 100.000),
('EMP002', 'Nguyen', 'Van A', '1999-05-03', 3, 'Ha Noi', 2, 200.000),
('EMP003', 'Tim', 'Brandon', '1998-06-07', 1, 'Ha Noi', 1, 100.000)

SELECT * FROM Employee
GO

--2: Increase the salary for all employees by 10%

update Employee
set Salary = Salary + Salary*0.1

SELECT * FROM Department
GO

SELECT * FROM Employee
GO

--3: Using ALTER TABLE statement to add constraint on Employee table to ensure that salary always greater than 0

ALTER TABLE [dbo].[Employee] ADD CONSTRAINT SalaryCheck CHECK (Salary > 0)
GO

SELECT * FROM Employee
GO

--test
INSERT into Employee VALUES
('EMP004', 'Nguyen', 'Long', '1999-05-03', 1, 'Hà Noi', 1, 000.000)

INSERT into Employee VALUES
('EMP005', 'Tony', 'Bao', '1998-06-07', 1, 'Ha Noi', 2, 100.000)

--4: Create a trigger named tg_chkBirthday 
--to ensure value of birthday column on Employee table always greater than 23
CREATE TRIGGER tg_chkBirthday
ON Employee
after update, insert as
begin
    declare @DateofBirth date;
	select @DateofBirth  = inserted.Birthday from inserted;

	if(Day(@DateofBirth) <= 23 ) 
	begin
	    print 'Day of birthday must be greater than 23!';
		rollback transaction;
	end
end

--test
INSERT into Employee VALUES
('EMP006', 'Charlie', 'Dung', '1996-02-03', 1, 'Ha Noi', 2, 200.000)

--5: Create an unique, none-clustered index named IX_DepartmentName
-- on DepartName column on Department table
CREATE UNIQUE NONCLUSTERED INDEX IX_DepartmentName
ON Department(Department_name)

--6 Create a view to display employee’s code, 
--full name and department name of all employee’s
create view View_Employee
as
select e.Employee_code,
       e.First_name + ' ' + e.Last_name as FullName,
	   d.Department_name
from Employee as e
inner join Department as d on d.Department_Id = e.Department_Id

select * from View_Employee

--7: Create a stored procedure named sp_getAllEmp that accepts Department ID 
--as given input parameter and displays all employees in that Department
create procedure sp_getAllEmp (@id int)
as
begin
    if(@id  in (select Department_ID from Department))
	begin
	   select e.Employee_code,
	          e.First_name + ' ' + e.Last_name as FullName,
              e.Birthday,
			  e.Gender,
              e.Employee_address,
			  e.Salary
	   from Department as d
	   inner join Employee as e on e.Department_Id = d.Department_ID
	   where d.Department_ID = @id
	end
	else
	begin
	   print 'Dont find depart Id!';
	   rollback transaction;
	end
end

--test
exec sp_getAllEmp @id=1

--8: Create a stored procedure named sp_delDept
--that accepts employee Id as given input parameter to delete an employee
create procedure sp_delDept(@empCode char(6))
as 
begin
   if (select count (*) from Employee where Employee.Employee_code = @empCode) > 0
   begin
      delete from Employee
      where Employee_code = @empCode
      print 'Delete employee complete!'
   end
   else
   begin
      print 'Dont find employee!';
      rollback transaction;
   end
end

--test
exec sp_delDept @empCode = 'EMP003'

