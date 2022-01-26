/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "07 - ������������ SQL".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*

��� ������� �� ������� "��������� CROSS APPLY, PIVOT, UNPIVOT."
����� ��� ���� �������� ������������ PIVOT, ������������ ���������� �� ���� ��������.
��� ������� ��������� ��������� �� ���� CustomerName.

��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.

���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.

������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (������ �������)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


DECLARE @dml AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)


SELECT @ColumnName = 
ISNULL(@ColumnName + ',','') + QUOTENAME(CustomerName)
FROM(
	SELECT distinct CustomerName
	FROM Sales.Customers
) AS Customers
ORDER BY CustomerName

SET @dml = 
  N' SELECT StartDateOfMonth, ' +@ColumnName + ' FROM
  (
	SELECT convert(varchar, DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1), 104) StartDateOfMonth,
	CustomerName,
	COUNT(InvoiceId) as cnt
	FROM Sales.Invoices si
	JOIN Sales.Customers sc on sc.CustomerID = si.CustomerID
	GROUP BY DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate),1), CustomerName
	) AS SourceTable  
	PIVOT(SUM(cnt) FOR CustomerName IN (' +@ColumnName + ')) AS PivotTable'

EXEC sp_executesql @dml