--liquibase formatted sql

--changeset Administrator:1593700833755-1 labels:jira-100
CREATE TABLE CustomerDemographics (CustomerTypeID nchar(10) NOT NULL, CustomerDesc nvarchar(MAX));

--changeset Administrator:1593700833755-2 labels:jira-100
CREATE TABLE [Order Details] (OrderID int NOT NULL, ProductID int NOT NULL, UnitPrice money CONSTRAINT DF_Order_Details_UnitPrice DEFAULT 0 NOT NULL, Quantity smallint CONSTRAINT DF_Order_Details_Quantity DEFAULT 1 NOT NULL, Discount float(24) CONSTRAINT DF_Order_Details_Discount DEFAULT 0 NOT NULL, CONSTRAINT PK_Order_Details PRIMARY KEY (OrderID, ProductID));

--changeset Administrator:1593700833755-3 labels:jira-100
CREATE TABLE Customers (CustomerID nchar(5) NOT NULL, CompanyName nvarchar(40) NOT NULL, ContactName nvarchar(30), ContactTitle nvarchar(30), Address nvarchar(60), City nvarchar(15), Region nvarchar(15), PostalCode nvarchar(10), Country nvarchar(15), Phone nvarchar(24), Fax nvarchar(24), CONSTRAINT PK_Customers PRIMARY KEY (CustomerID));

--changeset Administrator:1593700833755-4 labels:jira-100
CREATE TABLE Products (ProductID int IDENTITY (1, 1) NOT NULL, ProductName nvarchar(40) NOT NULL, SupplierID int, CategoryID int, QuantityPerUnit nvarchar(20), UnitPrice money CONSTRAINT DF_Products_UnitPrice DEFAULT 0, UnitsInStock smallint CONSTRAINT DF_Products_UnitsInStock DEFAULT 0, UnitsOnOrder smallint CONSTRAINT DF_Products_UnitsOnOrder DEFAULT 0, ReorderLevel smallint CONSTRAINT DF_Products_ReorderLevel DEFAULT 0, Discontinued bit CONSTRAINT DF_Products_Discontinued DEFAULT 'false' NOT NULL, CONSTRAINT PK_Products PRIMARY KEY (ProductID));

--changeset Administrator:1593700833755-5 labels:jira-100
CREATE TABLE Employees (EmployeeID int IDENTITY (1, 1) NOT NULL, LastName nvarchar(20) NOT NULL, FirstName nvarchar(10) NOT NULL, Title nvarchar(30), TitleOfCourtesy nvarchar(25), BirthDate datetime, HireDate datetime, Address nvarchar(60), City nvarchar(15), Region nvarchar(15), PostalCode nvarchar(10), Country nvarchar(15), HomePhone nvarchar(24), Extension nvarchar(4), Photo image, Notes nvarchar(MAX), ReportsTo int, PhotoPath nvarchar(255), CONSTRAINT PK_Employees PRIMARY KEY (EmployeeID));

--changeset Administrator:1593700833755-6 labels:jira-100
CREATE TABLE Territories (TerritoryID nvarchar(20) NOT NULL, TerritoryDescription nchar(50) NOT NULL, RegionID int NOT NULL);

--changeset Administrator:1593700833755-7 labels:jira-100
CREATE TABLE Categories (CategoryID int IDENTITY (1, 1) NOT NULL, CategoryName nvarchar(15) NOT NULL, Description nvarchar(MAX), Picture image, CONSTRAINT PK_Categories PRIMARY KEY (CategoryID));

--changeset Administrator:1593700833755-8 labels:jira-100
CREATE TABLE CustomerCustomerDemo (CustomerID nchar(5) NOT NULL, CustomerTypeID nchar(10) NOT NULL);

--changeset Administrator:1593700833755-9 labels:jira-100
CREATE TABLE Suppliers (SupplierID int IDENTITY (1, 1) NOT NULL, CompanyName nvarchar(40) NOT NULL, ContactName nvarchar(30), ContactTitle nvarchar(30), Address nvarchar(60), City nvarchar(15), Region nvarchar(15), PostalCode nvarchar(10), Country nvarchar(15), Phone nvarchar(24), Fax nvarchar(24), HomePage nvarchar(MAX), CONSTRAINT PK_Suppliers PRIMARY KEY (SupplierID));

--changeset Administrator:1593700833755-10 labels:jira-100
CREATE TABLE Shippers (ShipperID int IDENTITY (1, 1) NOT NULL, CompanyName nvarchar(40) NOT NULL, Phone nvarchar(24), CONSTRAINT PK_Shippers PRIMARY KEY (ShipperID));

--changeset Administrator:1593700833755-11 labels:jira-100
CREATE TABLE Orders (OrderID int IDENTITY (1, 1) NOT NULL, CustomerID nchar(5), EmployeeID int, OrderDate datetime, RequiredDate datetime, ShippedDate datetime, ShipVia int, Freight money CONSTRAINT DF_Orders_Freight DEFAULT 0, ShipName nvarchar(40), ShipAddress nvarchar(60), ShipCity nvarchar(15), ShipRegion nvarchar(15), ShipPostalCode nvarchar(10), ShipCountry nvarchar(15), CONSTRAINT PK_Orders PRIMARY KEY (OrderID));

--changeset Administrator:1593700833755-12 labels:jira-100
CREATE TABLE EmployeeTerritories (EmployeeID int NOT NULL, TerritoryID nvarchar(20) NOT NULL);

--changeset Administrator:1593700833755-13 labels:jira-100
ALTER TABLE CustomerDemographics ADD CONSTRAINT PK_CustomerDemographics PRIMARY KEY NONCLUSTERED (CustomerTypeID);

--changeset Administrator:1593700833755-14 labels:jira-100
ALTER TABLE [Order Details] ADD CONSTRAINT CK_Discount CHECK (([Discount]>=(0) AND [Discount]<=(1)));

--changeset Administrator:1593700833755-15 labels:jira-100
ALTER TABLE [Order Details] ADD CONSTRAINT CK_Quantity CHECK (([Quantity]>(0)));

--changeset Administrator:1593700833755-16 labels:jira-100
ALTER TABLE [Order Details] ADD CONSTRAINT CK_UnitPrice CHECK (([UnitPrice]>=(0)));

--changeset Administrator:1593700833755-17 labels:jira-100
if object_id('CustOrderHist', 'p') is null exec ('create procedure CustOrderHist as select 1 a');
ALTER PROCEDURE [dbo].[CustOrderHist] @CustomerID nchar(5)
AS
SELECT ProductName, Total=SUM(Quantity)
FROM Products P, [Order Details] OD, Orders O, Customers C
WHERE C.CustomerID = @CustomerID
AND C.CustomerID = O.CustomerID AND O.OrderID = OD.OrderID AND OD.ProductID = P.ProductID
GROUP BY ProductName;

--changeset Administrator:1593700833755-18 labels:jira-100
if object_id('CustOrdersDetail', 'p') is null exec ('create procedure CustOrdersDetail as select 1 a');
ALTER PROCEDURE [dbo].[CustOrdersDetail] @OrderID int
AS
SELECT ProductName,
    UnitPrice=ROUND(Od.UnitPrice, 2),
    Quantity,
    Discount=CONVERT(int, Discount * 100), 
    ExtendedPrice=ROUND(CONVERT(money, Quantity * (1 - Discount) * Od.UnitPrice), 2)
FROM Products P, [Order Details] Od
WHERE Od.ProductID = P.ProductID and Od.OrderID = @OrderID;

--changeset Administrator:1593700833755-19 labels:jira-100
CREATE VIEW Invoices AS SELECT Orders.ShipName, Orders.ShipAddress, Orders.ShipCity, Orders.ShipRegion, Orders.ShipPostalCode, 
	Orders.ShipCountry, Orders.CustomerID, Customers.CompanyName AS CustomerName, Customers.Address, Customers.City, 
	Customers.Region, Customers.PostalCode, Customers.Country, 
	(FirstName + ' ' + LastName) AS Salesperson, 
	Orders.OrderID, Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Shippers.CompanyName As ShipperName, 
	"Order Details".ProductID, Products.ProductName, "Order Details".UnitPrice, "Order Details".Quantity, 
	"Order Details".Discount, 
	(CONVERT(money,("Order Details".UnitPrice*Quantity*(1-Discount)/100))*100) AS ExtendedPrice, Orders.Freight
FROM 	Shippers INNER JOIN 
		(Products INNER JOIN 
			(
				(Employees INNER JOIN 
					(Customers INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID) 
				ON Employees.EmployeeID = Orders.EmployeeID) 
			INNER JOIN "Order Details" ON Orders.OrderID = "Order Details".OrderID) 
		ON Products.ProductID = "Order Details".ProductID) 
	ON Shippers.ShipperID = Orders.ShipVia;

--changeset Administrator:1593700833755-20 labels:jira-100
create view [dbo].[Order Details Extended] AS
SELECT "Order Details".OrderID, "Order Details".ProductID, Products.ProductName, 
	"Order Details".UnitPrice, "Order Details".Quantity, "Order Details".Discount, 
	(CONVERT(money,("Order Details".UnitPrice*Quantity*(1-Discount)/100))*100) AS ExtendedPrice
FROM Products INNER JOIN "Order Details" ON Products.ProductID = "Order Details".ProductID
--ORDER BY "Order Details".OrderID;

--changeset Administrator:1593700833755-21 labels:jira-100
create view [dbo].[Order Subtotals] AS
SELECT "Order Details".OrderID, Sum(CONVERT(money,("Order Details".UnitPrice*Quantity*(1-Discount)/100))*100) AS Subtotal
FROM "Order Details"
GROUP BY "Order Details".OrderID;

--changeset Administrator:1593700833755-22 labels:jira-100
CREATE NONCLUSTERED INDEX OrdersOrder_Details ON [Order Details](OrderID);

--changeset Administrator:1593700833755-23 labels:jira-100
create view [dbo].[Product Sales for 1997] AS
SELECT Categories.CategoryName, Products.ProductName, 
Sum(CONVERT(money,("Order Details".UnitPrice*Quantity*(1-Discount)/100))*100) AS ProductSales
FROM (Categories INNER JOIN Products ON Categories.CategoryID = Products.CategoryID) 
	INNER JOIN (Orders 
		INNER JOIN "Order Details" ON Orders.OrderID = "Order Details".OrderID) 
	ON Products.ProductID = "Order Details".ProductID
WHERE (((Orders.ShippedDate) Between '19970101' And '19971231'))
GROUP BY Categories.CategoryName, Products.ProductName;

--changeset Administrator:1593700833755-24 labels:jira-100
CREATE NONCLUSTERED INDEX ProductsOrder_Details ON [Order Details](ProductID);

--changeset Administrator:1593700833755-25 labels:jira-100
if object_id('SalesByCategory', 'p') is null exec ('create procedure SalesByCategory as select 1 a');
ALTER PROCEDURE [dbo].[SalesByCategory]
    @CategoryName nvarchar(15), @OrdYear nvarchar(4) = '1998'
AS
IF @OrdYear != '1996' AND @OrdYear != '1997' AND @OrdYear != '1998' 
BEGIN
	SELECT @OrdYear = '1998'
END

SELECT ProductName,
	TotalPurchase=ROUND(SUM(CONVERT(decimal(14,2), OD.Quantity * (1-OD.Discount) * OD.UnitPrice)), 0)
FROM [Order Details] OD, Orders O, Products P, Categories C
WHERE OD.OrderID = O.OrderID 
	AND OD.ProductID = P.ProductID 
	AND P.CategoryID = C.CategoryID
	AND C.CategoryName = @CategoryName
	AND SUBSTRING(CONVERT(nvarchar(22), O.OrderDate, 111), 1, 4) = @OrdYear
GROUP BY ProductName
ORDER BY ProductName;

--changeset Administrator:1593700833755-26 labels:jira-100
CREATE NONCLUSTERED INDEX City ON Customers(City);

--changeset Administrator:1593700833755-27 labels:jira-100
CREATE NONCLUSTERED INDEX CompanyName ON Customers(CompanyName);

--changeset Administrator:1593700833755-28 labels:jira-100
CREATE NONCLUSTERED INDEX CompanyName ON Suppliers(CompanyName);

--changeset Administrator:1593700833755-29 labels:jira-100
create view [dbo].[Customer and Suppliers by City] AS
SELECT City, CompanyName, ContactName, 'Customers' AS Relationship 
FROM Customers
UNION SELECT City, CompanyName, ContactName, 'Suppliers'
FROM Suppliers
--ORDER BY City, CompanyName;

--changeset Administrator:1593700833755-30 labels:jira-100
create view [dbo].[Orders Qry] AS
SELECT Orders.OrderID, Orders.CustomerID, Orders.EmployeeID, Orders.OrderDate, Orders.RequiredDate, 
	Orders.ShippedDate, Orders.ShipVia, Orders.Freight, Orders.ShipName, Orders.ShipAddress, Orders.ShipCity, 
	Orders.ShipRegion, Orders.ShipPostalCode, Orders.ShipCountry, 
	Customers.CompanyName, Customers.Address, Customers.City, Customers.Region, Customers.PostalCode, Customers.Country
FROM Customers INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

--changeset Administrator:1593700833755-31 labels:jira-100
CREATE NONCLUSTERED INDEX PostalCode ON Customers(PostalCode);

--changeset Administrator:1593700833755-32 labels:jira-100
CREATE NONCLUSTERED INDEX PostalCode ON Employees(PostalCode);

--changeset Administrator:1593700833755-33 labels:jira-100
CREATE NONCLUSTERED INDEX PostalCode ON Suppliers(PostalCode);

--changeset Administrator:1593700833755-34 labels:jira-100
create view [dbo].[Quarterly Orders] AS
SELECT DISTINCT Customers.CustomerID, Customers.CompanyName, Customers.City, Customers.Country
FROM Customers RIGHT JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.OrderDate BETWEEN '19970101' And '19971231';

--changeset Administrator:1593700833755-35 labels:jira-100
CREATE TABLE Region (RegionID int NOT NULL, RegionDescription nchar(50) NOT NULL);

--changeset Administrator:1593700833755-36 labels:jira-100
CREATE NONCLUSTERED INDEX Region ON Customers(Region);

--changeset Administrator:1593700833755-37 labels:jira-100
create view [dbo].[Sales Totals by Amount] AS
SELECT "Order Subtotals".Subtotal AS SaleAmount, Orders.OrderID, Customers.CompanyName, Orders.ShippedDate
FROM 	Customers INNER JOIN 
		(Orders INNER JOIN "Order Subtotals" ON Orders.OrderID = "Order Subtotals".OrderID) 
	ON Customers.CustomerID = Orders.CustomerID
WHERE ("Order Subtotals".Subtotal >2500) AND (Orders.ShippedDate BETWEEN '19970101' And '19971231');

--changeset Administrator:1593700833755-38 labels:jira-100
create view [dbo].[Alphabetical list of products] AS
SELECT Products.*, Categories.CategoryName
FROM Categories INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE (((Products.Discontinued)=0));

--changeset Administrator:1593700833755-39 labels:jira-100
CREATE NONCLUSTERED INDEX CategoryID ON Products(CategoryID);

--changeset Administrator:1593700833755-40 labels:jira-100
ALTER TABLE Products ADD CONSTRAINT CK_Products_UnitPrice CHECK (([UnitPrice]>=(0)));

--changeset Administrator:1593700833755-41 labels:jira-100
ALTER TABLE Products ADD CONSTRAINT CK_ReorderLevel CHECK (([ReorderLevel]>=(0)));

--changeset Administrator:1593700833755-42 labels:jira-100
ALTER TABLE Products ADD CONSTRAINT CK_UnitsInStock CHECK (([UnitsInStock]>=(0)));

--changeset Administrator:1593700833755-43 labels:jira-100
ALTER TABLE Products ADD CONSTRAINT CK_UnitsOnOrder CHECK (([UnitsOnOrder]>=(0)));

--changeset Administrator:1593700833755-44 labels:jira-100
create view [dbo].[Current Product List] AS
SELECT Product_List.ProductID, Product_List.ProductName
FROM Products AS Product_List
WHERE (((Product_List.Discontinued)=0))
--ORDER BY Product_List.ProductName;

--changeset Administrator:1593700833755-45 labels:jira-100
CREATE NONCLUSTERED INDEX ProductName ON Products(ProductName);

--changeset Administrator:1593700833755-46 labels:jira-100
create view [dbo].[Products Above Average Price] AS
SELECT Products.ProductName, Products.UnitPrice
FROM Products
WHERE Products.UnitPrice>(SELECT AVG(UnitPrice) From Products)
--ORDER BY Products.UnitPrice DESC;

--changeset Administrator:1593700833755-47 labels:jira-100
create view [dbo].[Products by Category] AS
SELECT Categories.CategoryName, Products.ProductName, Products.QuantityPerUnit, Products.UnitsInStock, Products.Discontinued
FROM Categories INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE Products.Discontinued <> 1
--ORDER BY Categories.CategoryName, Products.ProductName;

--changeset Administrator:1593700833755-48 labels:jira-100
create view [dbo].[Sales by Category] AS
SELECT Categories.CategoryID, Categories.CategoryName, Products.ProductName, 
	Sum("Order Details Extended".ExtendedPrice) AS ProductSales
FROM 	Categories INNER JOIN 
		(Products INNER JOIN 
			(Orders INNER JOIN "Order Details Extended" ON Orders.OrderID = "Order Details Extended".OrderID) 
		ON Products.ProductID = "Order Details Extended".ProductID) 
	ON Categories.CategoryID = Products.CategoryID
WHERE Orders.OrderDate BETWEEN '19970101' And '19971231'
GROUP BY Categories.CategoryID, Categories.CategoryName, Products.ProductName
--ORDER BY Products.ProductName;

--changeset Administrator:1593700833755-49 labels:jira-100
CREATE NONCLUSTERED INDEX SupplierID ON Products(SupplierID);

--changeset Administrator:1593700833755-50 labels:jira-100
if object_id('[Ten Most Expensive Products]', 'p') is null exec ('create procedure [Ten Most Expensive Products] as select 1 a');
ALTER procedure [dbo].[Ten Most Expensive Products] AS
SET ROWCOUNT 10
SELECT Products.ProductName AS TenMostExpensiveProducts, Products.UnitPrice
FROM Products
ORDER BY Products.UnitPrice DESC;

--changeset Administrator:1593700833755-51 labels:jira-100
ALTER TABLE Employees ADD CONSTRAINT CK_Birthdate CHECK (([BirthDate]<getdate()));

--changeset Administrator:1593700833755-52 labels:jira-100
if object_id('[Employee Sales by Country]', 'p') is null exec ('create procedure [Employee Sales by Country] as select 1 a');
ALTER procedure [dbo].[Employee Sales by Country] 
@Beginning_Date DateTime, @Ending_Date DateTime AS
SELECT Employees.Country, Employees.LastName, Employees.FirstName, Orders.ShippedDate, Orders.OrderID, "Order Subtotals".Subtotal AS SaleAmount
FROM Employees INNER JOIN 
	(Orders INNER JOIN "Order Subtotals" ON Orders.OrderID = "Order Subtotals".OrderID) 
	ON Employees.EmployeeID = Orders.EmployeeID
WHERE Orders.ShippedDate Between @Beginning_Date And @Ending_Date;

--changeset Administrator:1593700833755-53 labels:jira-100
CREATE NONCLUSTERED INDEX LastName ON Employees(LastName);

--changeset Administrator:1593700833755-54 labels:jira-100
ALTER TABLE Territories ADD CONSTRAINT PK_Territories PRIMARY KEY NONCLUSTERED (TerritoryID);

--changeset Administrator:1593700833755-55 labels:jira-100
CREATE NONCLUSTERED INDEX CategoryName ON Categories(CategoryName);

--changeset Administrator:1593700833755-56 labels:jira-100
ALTER TABLE CustomerCustomerDemo ADD CONSTRAINT FK_CustomerCustomerDemo FOREIGN KEY (CustomerTypeID) REFERENCES CustomerDemographics (CustomerTypeID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-57 labels:jira-100
ALTER TABLE CustomerCustomerDemo ADD CONSTRAINT FK_CustomerCustomerDemo_Customers FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-58 labels:jira-100
ALTER TABLE CustomerCustomerDemo ADD CONSTRAINT PK_CustomerCustomerDemo PRIMARY KEY NONCLUSTERED (CustomerID, CustomerTypeID);

--changeset Administrator:1593700833755-59 labels:jira-100
CREATE NONCLUSTERED INDEX CustomersOrders ON Orders(CustomerID);

--changeset Administrator:1593700833755-60 labels:jira-100
if object_id('CustOrdersOrders', 'p') is null exec ('create procedure CustOrdersOrders as select 1 a');
ALTER PROCEDURE [dbo].[CustOrdersOrders] @CustomerID nchar(5)
AS
SELECT OrderID, 
	OrderDate,
	RequiredDate,
	ShippedDate
FROM Orders
WHERE CustomerID = @CustomerID
ORDER BY OrderID;

--changeset Administrator:1593700833755-61 labels:jira-100
CREATE NONCLUSTERED INDEX EmployeesOrders ON Orders(EmployeeID);

--changeset Administrator:1593700833755-62 labels:jira-100
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-63 labels:jira-100
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-64 labels:jira-100
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_Shippers FOREIGN KEY (ShipVia) REFERENCES Shippers (ShipperID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-65 labels:jira-100
CREATE NONCLUSTERED INDEX OrderDate ON Orders(OrderDate);

--changeset Administrator:1593700833755-66 labels:jira-100
if object_id('[Sales by Year]', 'p') is null exec ('create procedure [Sales by Year] as select 1 a');
ALTER procedure [dbo].[Sales by Year] 
	@Beginning_Date DateTime, @Ending_Date DateTime AS
SELECT Orders.ShippedDate, Orders.OrderID, "Order Subtotals".Subtotal, DATENAME(yy,ShippedDate) AS Year
FROM Orders INNER JOIN "Order Subtotals" ON Orders.OrderID = "Order Subtotals".OrderID
WHERE Orders.ShippedDate Between @Beginning_Date And @Ending_Date;

--changeset Administrator:1593700833755-67 labels:jira-100
CREATE NONCLUSTERED INDEX ShippedDate ON Orders(ShippedDate);

--changeset Administrator:1593700833755-68 labels:jira-100
CREATE NONCLUSTERED INDEX ShippersOrders ON Orders(ShipVia);

--changeset Administrator:1593700833755-69 labels:jira-100
CREATE NONCLUSTERED INDEX ShipPostalCode ON Orders(ShipPostalCode);

--changeset Administrator:1593700833755-70 labels:jira-100
create view [dbo].[Summary of Sales by Quarter] AS
SELECT Orders.ShippedDate, Orders.OrderID, "Order Subtotals".Subtotal
FROM Orders INNER JOIN "Order Subtotals" ON Orders.OrderID = "Order Subtotals".OrderID
WHERE Orders.ShippedDate IS NOT NULL
--ORDER BY Orders.ShippedDate;

--changeset Administrator:1593700833755-71 labels:jira-100
create view [dbo].[Summary of Sales by Year] AS
SELECT Orders.ShippedDate, Orders.OrderID, "Order Subtotals".Subtotal
FROM Orders INNER JOIN "Order Subtotals" ON Orders.OrderID = "Order Subtotals".OrderID
WHERE Orders.ShippedDate IS NOT NULL
--ORDER BY Orders.ShippedDate;

--changeset Administrator:1593700833755-72 labels:jira-100
ALTER TABLE EmployeeTerritories ADD CONSTRAINT FK_EmployeeTerritories_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-73 labels:jira-100
ALTER TABLE EmployeeTerritories ADD CONSTRAINT FK_EmployeeTerritories_Territories FOREIGN KEY (TerritoryID) REFERENCES Territories (TerritoryID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-74 labels:jira-100
ALTER TABLE EmployeeTerritories ADD CONSTRAINT PK_EmployeeTerritories PRIMARY KEY NONCLUSTERED (EmployeeID, TerritoryID);

--changeset Administrator:1593700833755-75 labels:jira-100
ALTER TABLE [Order Details] ADD CONSTRAINT FK_Order_Details_Orders FOREIGN KEY (OrderID) REFERENCES Orders (OrderID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-76 labels:jira-100
ALTER TABLE [Order Details] ADD CONSTRAINT FK_Order_Details_Products FOREIGN KEY (ProductID) REFERENCES Products (ProductID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-77 labels:jira-100
create view [dbo].[Category Sales for 1997] AS
SELECT "Product Sales for 1997".CategoryName, Sum("Product Sales for 1997".ProductSales) AS CategorySales
FROM "Product Sales for 1997"
GROUP BY "Product Sales for 1997".CategoryName;

--changeset Administrator:1593700833755-78 labels:jira-100
ALTER TABLE Region ADD CONSTRAINT PK_Region PRIMARY KEY NONCLUSTERED (RegionID);

--changeset Administrator:1593700833755-79 labels:jira-100
ALTER TABLE Products ADD CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-80 labels:jira-100
ALTER TABLE Products ADD CONSTRAINT FK_Products_Suppliers FOREIGN KEY (SupplierID) REFERENCES Suppliers (SupplierID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-81 labels:jira-100
ALTER TABLE Employees ADD CONSTRAINT FK_Employees_Employees FOREIGN KEY (ReportsTo) REFERENCES Employees (EmployeeID) ON UPDATE NO ACTION ON DELETE NO ACTION;

--changeset Administrator:1593700833755-82 labels:jira-100
ALTER TABLE Territories ADD CONSTRAINT FK_Territories_Region FOREIGN KEY (RegionID) REFERENCES Region (RegionID) ON UPDATE NO ACTION ON DELETE NO ACTION;

