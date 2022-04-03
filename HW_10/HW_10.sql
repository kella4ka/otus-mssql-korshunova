use WideWorldImporters;

-- �������� CLR
exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO

exec sp_configure 'clr enabled', 1;
exec sp_configure 'clr strict security', 0 
GO

-- clr strict security 
-- 1 (Enabled): ���������� Database Engine ������������ �������� PERMISSION_SET � ������� 
-- � ������ ���������������� �� ��� UNSAFE. �� ���������, ������� � SQL Server 2017.

reconfigure;
GO

-- ��� ����������� �������� ������ � EXTERNAL_ACCESS ��� UNSAFE
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; 

-- ���������� dll 
-- �������� ���� � �����!
CREATE ASSEMBLY amount_by_customer
FROM 'C:\Users\user\source\repos\HW_10\HW_10\bin\Debug\HW_10.dll'
WITH PERMISSION_SET = SAFE;  




CREATE PROCEDURE get_amount_by_customer
@customer_id int,
@customer nvarchar(100) OUTPUT,
@amount decimal(18,2) OUTPUT
AS  
EXTERNAL NAME amount_by_customer.[HW_10.AmountByCustomerProc].AmountByCustomer 

-- ���� ������ (dll) �� ����� ������ �� �����, ��� ���������� � ��

-- ��� ���������� ������������������ ������ 

-- SSMS
-- <DB> -> Programmability -> Assemblies 

-- ���������� ������������ ������ (SSMS: <DB> -> Programmability -> Assemblies)
SELECT * FROM sys.assemblies


DECLARE @customer_id int,  @customer nvarchar(100), @amount decimal(18,2) 
EXEC get_amount_by_customer 1, @customer out, @amount out
PRINT @customer PRINT @amount

-- �������� ���������
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'get_amount_by_customer')  
   drop procedure get_amount_by_customer 

-- �������� ������
IF EXISTS (SELECT name FROM sys.assemblies WHERE name = 'amount_by_customer')  
   drop assembly amount_by_customer  