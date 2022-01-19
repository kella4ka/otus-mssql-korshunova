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
WHERE po.ExpectedDeliveryDate between '2013-01-01' and  '2013-01-31'
and (dm.DeliveryMethodName = 'Air Freight' or  dm.DeliveryMethodName = 'Refrigerated Air Freight')
and IsOrderFinalized = 1
order by ExpectedDeliveryDate


/*
7. ��������� ������� ���� ������, ����� ����� ������� �� �������
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

SELECT YEAR(si.InvoiceDate) AS InvoiceYear,
MONTH(si.InvoiceDate) InvoiceMonth,
AVG(sil.UnitPrice) AvgPriceInMonth,
SUM(sil.Quantity * sil.UnitPrice) SumPriceInMonth
FROM Sales.Invoices si
JOIN Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
WHERE si.ConfirmedDeliveryTime is not null
GROUP BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate)
order by InvoiceYear, InvoiceMonth


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

SELECT YEAR(si.InvoiceDate) InvoiceYear,
MONTH(si.InvoiceDate) InvoiceMonth,
wsi.StockItemName,
MIN(si.InvoiceDate) FirstDate,
SUM(sil.Quantity * sil.UnitPrice) SumInvoice,
SUM(sil.Quantity) SumQuantity
FROM Sales.Invoices si
JOIN Sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
JOIN Warehouse.StockItems wsi on wsi.StockItemID = sil.StockItemID
WHERE ConfirmedDeliveryTime is not null
GROUP BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate), wsi.StockItemName
HAVING SUM(sil.Quantity) < 50
ORDER BY StockItemName, YEAR(si.InvoiceDate), MONTH(si.InvoiceDate)