/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, GROUP BY, HAVING".

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
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/

SELECT StockItemID, StockItemName
FROM Warehouse.StockItems
WHERE StockItemName like '%urgent%' or StockItemName like 'Animal%'

/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/

SELECT ps.SupplierID, ps.SupplierName from Purchasing.Suppliers ps
LEFT JOIN Purchasing.PurchaseOrders pp on pp.SupplierID = ps.SupplierID
WHERE pp.PurchaseOrderID is null
/*
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.

���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).

�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT so.OrderID, CONVERT(NVARCHAR, OrderDate, 104) OrderDate, DATENAME(month, OrderDate) OrderMonth, 
DATEPART(quarter, OrderDate) OrderQuarter, 
(case 
when MONTH(OrderDate) between 1 and 4 then 1 
when MONTH(OrderDate) between 5 and 8 then 2
when MONTH(OrderDate) between 9 and 12 then 3
else 0 end) OrderThirdOfTheYear, sc.CustomerName
FROM Sales.Orders so 
JOIN Sales.OrderLines sol on sol.OrderID = so.OrderID
JOIN Sales.Customers sc on sc.CustomerID = so.CustomerID
WHERE (sol.UnitPrice > 100 or sol.Quantity > 20) and so.PickingCompletedWhen is not NULL
ORDER BY OrderQuarter, OrderThirdOfTheYear, OrderDate
-- �����������
OFFSET 1000 ROWS 
FETCH NEXT 100 ROWS ONLY;


/*
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT DeliveryMethodName, ExpectedDeliveryDate, SupplierName, ap.FullName
FROM Purchasing.Suppliers ps
JOIN Purchasing.PurchaseOrders po ON po.SupplierID = ps.SupplierID
JOIN Application.DeliveryMethods dm ON dm.DeliveryMethodID = po.DeliveryMethodID
JOIN Application.People ap ON ap.PersonID = po.ContactPersonID
WHERE po.ExpectedDeliveryDate between convert(date, '2013-01-01') and convert(date, '2013-02-01')
and (dm.DeliveryMethodName = 'Air Freight' or  dm.DeliveryMethodName = 'Refrigerated Air Freight')
and IsOrderFinalized = 1

/*
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/

SELECT TOP(10) so.OrderID, so.OrderDate, sc.CustomerName, ap.FullName from Sales.Orders so
JOIN Sales.Customers sc on sc.CustomerID = so.CustomerID
JOIN Application.People ap on ap.PersonID = SalespersonPersonID
ORDER BY OrderDate desc


/*
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems.
*/

SELECT sc.CustomerID, sc.CustomerName, sc.PhoneNumber FROM Sales.Invoices si
JOIN Sales.Customers sc ON sc.CustomerID = si.CustomerID
JOIN Sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
JOIN Warehouse.StockItems wsi on wsi.StockItemID = sil.StockItemID
WHERE StockItemName = 'Chocolate frogs 250g'
ORDER BY CustomerID

/*
7. ��������� ������� ���� ������, ����� ����� ������� �� �������
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

SELECT si.InvoiceDate, 
YEAR(si.InvoiceDate) OrderYear, 
MONTH(si.InvoiceDate) OrderMonth, 
AVG(sil.UnitPrice) over (partition by MONTH(si.InvoiceDate)) AvgPriceInMonth,
SUM(sil.Quantity * sil.UnitPrice) over (partition by MONTH(si.InvoiceDate)) SumPriceInMonth
FROM Sales.Invoices si
JOIN Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
WHERE si.ConfirmedDeliveryTime is not null

 
/*
8. ���������� ��� ������, ��� ����� ����� ������ ��������� 10 000

�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

SELECT YEAR(si.InvoiceDate) InvoiceYear, MONTH(si.InvoiceDate) InvoiceMonth,
SUM(sil.Quantity * sil.UnitPrice) SumPrice
FROM Sales.Invoices si
JOIN Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
WHERE si.ConfirmedDeliveryTime is not null 
GROUP BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate)
HAVING SUM(sil.Quantity * sil.UnitPrice) > 10000
ORDER BY InvoiceYear, InvoiceMonth


/*
9. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.

�������:
* ��� �������
* ����� �������
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

SELECT distinct InvoiceYear, InvoiceMonth, StockItemName, FirstDate, SumInvoice, SumQuantity FROM (
SELECT si.InvoiceDate,
YEAR(si.InvoiceDate) InvoiceYear,
MONTH(si.InvoiceDate) InvoiceMonth, wsi.StockItemName,
FIRST_VALUE(si.InvoiceDate) OVER (ORDER BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate), wsi.StockItemName) FirstDate,
SUM(sil.Quantity * sil.UnitPrice) OVER (PARTITION BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate), wsi.StockItemName) SumInvoice,
SUM(sil.Quantity) OVER (PARTITION BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate), wsi.StockItemName) SumQuantity
FROM Sales.Invoices si
JOIN Sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
JOIN Warehouse.StockItems wsi on wsi.StockItemID = sil.StockItemID
WHERE ConfirmedDeliveryTime is not null) a
WHERE SumQuantity < 50
ORDER BY  InvoiceYear, InvoiceMonth, StockItemName
