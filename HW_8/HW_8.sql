/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "10 - ��������� ��������� ������".

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
1. ����������� � ���� ���� ������� ��������� insert � ������� Customers ��� Suppliers 
*/
INSERT INTO [Purchasing].[Suppliers]
           ([SupplierID]
           ,[SupplierName]
           ,[SupplierCategoryID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[SupplierReference]
           ,[BankAccountName]
           ,[BankAccountBranch]
           ,[BankAccountCode]
           ,[BankAccountNumber]
           ,[BankInternationalCode]
           ,[PaymentDays]
           ,[InternalComments]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy])
SELECT TOP (5) [SupplierID] + 10000 AS SupplierID
      ,CONCAT('Test_', [SupplierName]) AS SupplierName
      ,[SupplierCategoryID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[SupplierReference]
      ,[BankAccountName]
      ,[BankAccountBranch]
      ,[BankAccountCode]
      ,[BankAccountNumber]
      ,[BankInternationalCode]
      ,[PaymentDays]
      ,[InternalComments]
      ,'(999) 555-0100' [PhoneNumber]
      ,[FaxNumber]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
  FROM [WideWorldImporters].[Purchasing].[Suppliers]

/*
2. ������� ���� ������ �� Customers, ������� ���� ���� ���������
*/

DELETE FROM [WideWorldImporters].[Purchasing].[Suppliers]
WHERE SupplierID = 10001

/*
3. �������� ���� ������, �� ����������� ����� UPDATE
*/

UPDATE [WideWorldImporters].[Purchasing].[Suppliers]
SET PhoneNumber  = '(777) 920-0212' WHERE SupplierID = 10002

/*
4. �������� MERGE, ������� ������� ������ � �������, ���� �� ��� ���, � ������� ���� ��� ��� ����
*/
MERGE [WideWorldImporters].[Purchasing].[Suppliers] as target_t
USING [WideWorldImporters].[Purchasing].[Suppliers] as source_t
ON (target_t.SupplierID = source_t.SupplierID)
WHEN MATCHED THEN 
	UPDATE SET SupplierName = source_t.SupplierName, PhoneNumber  = source_t.PhoneNumber
WHEN NOT MATCHED THEN 
	INSERT (SupplierName, PhoneNumber)
	VALUES (source_t.SupplierName, source_t.PhoneNumber)

	OUTPUT deleted.*, $action, inserted.*;

/*
5. �������� ������, ������� �������� ������ ����� bcp out � ��������� ����� bulk insert

*/

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "C:\Users\user\Desktop\���� MSSQL\InvoiceLines1.txt" -T -w -t, -S KorshunovaA\SQL2017' 

/*
���������: 
SQLState = S1000, NativeError = 0
Error = [Microsoft][ODBC Driver 13 for SQL Server] �� ������� ������� ���� ������ BCP �� �������.
NULL

����������, ��� ���������?
*/