/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "12 - �������� ���������, �������, ��������, �������".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
�� ���� �������� �������� �������� ��������� / ������� � ������������������ �� �������������.
*/

/*
1) �������� ������� ������������ ������� � ���������� ������ �������.
*/


CREATE FUNCTION get_customer_by_max_price ()
	RETURNS int AS
BEGIN
	DECLARE @customer_id int;
	    
	SELECT @customer_id = CustomerID FROM (
	SELECT TOP(1) si.CustomerID, max(sil.Quantity * sil.UnitPrice) SUMM
	FROM Sales.Invoices si
	JOIN Sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
	GROUP BY si.CustomerID
	ORDER BY SUMM desc, CustomerID) as source_tab
 
    RETURN @customer_id
END;

 SELECT [dbo].[get_customer_by_max_price] ()


/*
2) �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
������������ ������� :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE PROCEDURE Get_Amount_By_Customer_ID      
    @customer_id int   
AS   

    SELECT max(sil.Quantity * sil.UnitPrice) SUMM
	FROM Sales.Invoices si
	JOIN Sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
	GROUP BY si.CustomerID
	HAVING si.CustomerID = @customer_id;
GO 


EXECUTE Get_Amount_By_Customer_ID 118;

/*
3) ������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.
*/

CREATE FUNCTION Amount_By_Customer_ID (@customer_id int)
	RETURNS decimal(18,2) AS
	BEGIN
	DECLARE @sum int;

    SELECT @sum = max(sil.Quantity * sil.UnitPrice)
	FROM Sales.Invoices si
	JOIN Sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
	GROUP BY si.CustomerID
	HAVING si.CustomerID = @customer_id;

RETURN @sum
END;

CREATE PROCEDURE Get_Amount_By_Customer_ID      
    @customer_id int   
AS   

    SELECT max(sil.Quantity * sil.UnitPrice) SUMM
	FROM Sales.Invoices si
	JOIN Sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
	GROUP BY si.CustomerID
	HAVING si.CustomerID = @customer_id;
GO 


EXECUTE Get_Amount_By_Customer_ID 10;


SELECT dbo.Amount_By_Customer_ID (10);

/*
4) �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����. 
*/

CREATE FUNCTION get_max_price_by_customers (@customer_id int)
RETURNS TABLE
AS
RETURN
(
    SELECT si.CustomerID, sc.CustomerName,  max(sil.Quantity * sil.UnitPrice) SUMM
	FROM Sales.Invoices si
	JOIN Sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
	JOIN Sales.Customers sc on sc.CustomerID = si.CustomerID
	WHERE si.CustomerID = @customer_id
	GROUP BY si.CustomerID, sc.CustomerName
);
GO

select p.*
from Sales.Customers as tab
cross apply [dbo].[get_max_price_by_customers](tab.CustomerID) AS p

/*
5) �����������. �� ���� ���������� ������� ����� ������� �������� ���������� �� �� ������������ � ������. 
*/
