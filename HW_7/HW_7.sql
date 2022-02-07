/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "08 - ������� �� XML � JSON �����".

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
���������� � �������� 1, 2:
* ���� � ��������� � ���� ����� ��������, �� ����� ������� ������ SELECT c ����������� � ���� XML. 
* ���� � ��� � ������� ������������ �������/������ � XML, �� ������ ����� ���� XML � ���� �������.
* ���� � ���� XML ��� ����� ������, �� ������ ����� ����� �������� ������ � ������������� �� � ������� (��������, � https://data.gov.ru).
* ������ ��������/������� � ���� https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. � ������ �������� ���� ���� StockItems.xml.
��� ������ �� ������� Warehouse.StockItems.
������������� ��� ������ � ������� ������� � ������, ������������ Warehouse.StockItems.
����: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

����������� - ���� �� ������� � insert, update, merge, �� ��������� ��� ������ � ������� Warehouse.StockItems.
������������ ������ � ������� ��������, ������������� �������� (������������ ������ �� ���� StockItemName). 
*/

DECLARE @xmlDocument  xml

SET @xmlDocument = (
SELECT * FROM OPENROWSET (
			  BULK 'C:\Users\user\Documents\GitHub\otus-mssql-korshunova\HW_7\StockItems.xml',  SINGLE_CLOB
			  ) as data )

SELECT  
  t.item.value('(@Name)[1]', 'varchar(100)') as [StockItemName],
  t.item.value('(SupplierID)[1]', 'int') as [SupplierID],
  t.item.value('(Package/UnitPackageID)[1]', 'int') as [UnitPackageID],
  t.item.value('(Package/OuterPackageID)[1]', 'int') as [OuterPackageID],
  t.item.value('(Package/QuantityPerOuter)[1]', 'int') as [QuantityPerOuter],
  t.item.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18,3)') as [TypicalWeightPerUnit],
  t.item.value('(LeadTimeDays)[1]', 'int') as [LeadTimeDays],
  t.item.value('(IsChillerStock)[1]', 'bit') as [IsChillerStock],
  t.item.value('(TaxRate)[1]', 'decimal(18,3)') as [TaxRate],
  t.item.value('(UnitPrice)[1]', 'decimal(18,2)') as [UnitPrice]

FROM @xmlDocument.nodes('/StockItems/Item') as t(item)



/*
2. ��������� ������ �� ������� StockItems � ����� �� xml-����, ��� StockItems.xml
*/

SELECT 
StockItemName as '@Name',
SupplierID as 'SupplierID', 
UnitPackageID as 'Package/UnitPackageID', 
OuterPackageID as 'Package/OuterPackageID', 
QuantityPerOuter as 'Package/QuantityPerOuter', 
TypicalWeightPerUnit as 'Package/TypicalWeightPerUnit',  
LeadTimeDays as 'LeadTimeDays', 
IsChillerStock as 'IsChillerStock', 
TaxRate as 'TaxRate', 
UnitPrice as 'UnitPrice'
FROM Warehouse.StockItems
FOR XML PATH('Item'), ROOT ('StockItems');



/*
3. � ������� Warehouse.StockItems � ������� CustomFields ���� ������ � JSON.
�������� SELECT ��� ������:
- StockItemID
- StockItemName
- CountryOfManufacture (�� CustomFields)
- FirstTag (�� ���� CustomFields, ������ �������� �� ������� Tags)
*/

SELECT StockItemID, StockItemName, CustomFields,
JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
FROM Warehouse.StockItems



/*
4. ����� � StockItems ������, ��� ���� ��� "Vintage".
�������: 
- StockItemID
- StockItemName
- (�����������) ��� ���� (�� CustomFields) ����� ������� � ����� ����

���� ������ � ���� CustomFields, � �� � Tags.
������ �������� ����� ������� ������ � JSON.
��� ������ ������������ ���������, ������������ LIKE ���������.

������ ���� � ����� ����:
... where ... = 'Vintage'

��� ������� �� �����:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


-- �� �������:  (�����������) ��� ���� (�� CustomFields) ����� ������� � ����� ����
SELECT StockItemID, StockItemName, CustomFields
FROM Warehouse.StockItems
WHERE JSON_VALUE(CustomFields, '$.Tags[0]') = 'Vintage'
