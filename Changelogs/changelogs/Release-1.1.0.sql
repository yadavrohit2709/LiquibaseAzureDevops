--liquibase formatted sql
--changeset dan:20210104-create-testdml-table labels:jira-123,release1.1.0
CREATE TABLE T_testdml(
  contact_name VARCHAR(50),
  testdml_rep VARCHAR(50),
  notes VARCHAR (355)
);
--rollback DROP TABLE T_testdml;

--changeset dan:20210105-create-anothertable-table labels:jira-123,release1.1.0
CREATE TABLE T_anothertable(
  contact_name VARCHAR(50),
  testdml_rep VARCHAR(50),
  notes VARCHAR (355)
);
--rollback DROP TABLE T_anothertable;

--changeset dan:20210105-create-randoobject-table labels:jira-130,release1.1.0
CREATE TABLE T_randoobject(
  contact_name VARCHAR(50),
  testdml_rep VARCHAR(50),
  notes VARCHAR (355)
);
--rollback DROP TABLE T_randoobject;

--changeset dan:20210105-create-anotherone-table labels:jira-130,release1.1.0
CREATE TABLE T_anotherone(
  contact_name VARCHAR(50),
  testdml_rep VARCHAR(50),
  notes VARCHAR (355)
);
--rollback DROP TABLE T_anotherone;

--changeset chuck:20210105-insert-a-row3 labels:jira-123,release1.1.0
INSERT INTO T_testdml (contact_name,testdml_rep,notes)
VALUES ('John Smith3','Jane Doe','Notes go here');

--rollback DELETE FROM T_testdml WHERE contact_name = 'John Smith3';

--changeset dan:20210322-create-a-procedure labels:jira-143,release1.1.0
CREATE PROCEDURE [dbo].[DemoCustOrderHist] @CustomerID nchar(5)
AS
SELECT ProductName, Total=SUM(Quantity)
FROM Products P, [Order Details] OD, Orders O, Customers C
WHERE C.CustomerID = @CustomerID
AND C.CustomerID = O.CustomerID AND O.OrderID = OD.OrderID AND OD.ProductID = P.ProductID
GROUP BY ProductName
--rollback DROP PROCEDURE [dbo].[DemoCustOrderHist];

--changeset dan:20210322-create-a-view labels:jira-143,release1.1.0
create view [dbo].[Demo_Current_Product_List] AS
SELECT Product_List.ProductID, Product_List.ProductName
FROM Products AS Product_List
WHERE (((Product_List.Discontinued)=0));

--rollback DROP VIEW [dbo].[Demo_Current_Product_List];
