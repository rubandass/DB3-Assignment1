USE master
GO

DROP DATABASE IF EXISTS jhonr1_IN705Assignment1
GO

CREATE DATABASE jhonr1_IN705Assignment1
GO

USE jhonr1_IN705Assignment1;
GO

CREATE TABLE Category 
(
	CategoryID		INT NOT NULL PRIMARY KEY IDENTITY, 
	CategoryName	NVARCHAR(50) NOT NULL
)

CREATE TABLE Contact
(
	ContactID				INT NOT NULL PRIMARY KEY IDENTITY,
	ContactName				NVARCHAR(50) NOT NULL,
	ContactPhone			NVARCHAR(24) NOT NULL,
	ContactFax				NVARCHAR(24) DEFAULT(''),
	ContactMobilePhone		NVARCHAR(24) DEFAULT(''),
	ContactEmail			NVARCHAR(50) DEFAULT(''),
	ContactWWW				NVARCHAR(50) DEFAULT(''),
	ContactPostalAddress	NVARCHAR(60) NOT NULL
)


CREATE TABLE Supplier
(
	SupplierID	INT NOT NULL PRIMARY KEY,
	SupplierGST NVARCHAR(24) NOT NULL,
	CONSTRAINT FK_Supplier_Contact FOREIGN KEY(SupplierID)
		REFERENCES Contact(ContactID)
		ON UPDATE CASCADE
		ON DELETE CASCADE
)

CREATE TABLE Customer
(
	CustomerID	INT NOT NULL PRIMARY KEY IDENTITY
)

CREATE TABLE Component
(
	ComponentID				INT NOT NULL PRIMARY KEY IDENTITY,
	ComponentName			NVARCHAR(24) NOT NULL,
	ComponentDescription	NVARCHAR(200) NOT NULL,
	TradePrice				DECIMAL(14,4) DEFAULT(0) CHECK(TradePrice >= 0) NOT NULL,
	ListPrice				DECIMAL(14,4) DEFAULT(0) CHECK(ListPrice >= 0) NOT NULL,
	TimeToFit				DECIMAL(14,2) DEFAULT(0) CHECK(TimeToFit >= 0) NOT NULL,
	CategoryID				INT NOT NULL,
	SupplierID				INT NOT NULL,
	CONSTRAINT FK_Component_Category FOREIGN KEY(CategoryID)
		REFERENCES Category(CategoryID)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CONSTRAINT FK_Component_Supplier FOREIGN KEY(SupplierID)
		REFERENCES Supplier(SupplierID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)

CREATE TABLE Quote
(
	QuoteID					INT NOT NULL PRIMARY KEY IDENTITY,
	QuoteDescription		NVARCHAR(200) NOT NULL,
	QuoteDate				DATETIME NOT NULL,
	QuotePrice				DECIMAL(14,4) DEFAULT(0) CHECK(QuotePrice >= 0),
	QuoteCompiler			NVARCHAR(200) NOT NULL,
	CustomerID				INT NOT NULL,
	CONSTRAINT FK_Quote_Customer FOREIGN KEY(CustomerID)
		REFERENCES Customer(CustomerID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)

CREATE TABLE QuoteComponent
(
	ComponentID		INT NOT NULL,
	QuoteID			INT NOT NULL,
	Quantity		INT NOT NULL,
	TradePrice		DECIMAL(14,4) CHECK(TradePrice >= 0) NOT NULL,
	ListPrice		DECIMAL(14,4) CHECK(ListPrice >= 0) NOT NULL,
	TimeToFit		DECIMAL(14,2) DEFAULT(0) CHECK(TimeToFit >= 0) NOT NULL,
	CONSTRAINT PK_QuoteComponent PRIMARY KEY (ComponentID, QuoteID),
	CONSTRAINT FK_QuoteComponent_Component FOREIGN KEY(ComponentID)
		REFERENCES Component(ComponentID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	CONSTRAINT FK_QuoteComponent_Quote FOREIGN KEY(QuoteID)
		REFERENCES Quote(QuoteID)
		ON UPDATE CASCADE
		ON DELETE CASCADE
)

CREATE TABLE AssemblySubcomponent
(
	AssemblyID		INT NOT NULL IDENTITY,
	SubcomponentID	INT NOT NULL,
	Quantity		DECIMAL(14,4) NOT NULL,
	CONSTRAINT PK_AssemblySubcomponent PRIMARY KEY (AssemblyID, SubcomponentID),
	CONSTRAINT FK_Subcomponent_Component FOREIGN KEY(SubcomponentID)
		REFERENCES Component(ComponentID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	CONSTRAINT FK_Assembly_Component FOREIGN KEY(AssemblyID)
		REFERENCES Component(ComponentID)
		ON UPDATE NO ACTION
		ON DELETE NO ACTION
)

GO

-- function getCategoryID() returns CategoryID
CREATE OR ALTER FUNCTION getCategoryID(@categoryName NVARCHAR(20))
RETURNS INT
AS
BEGIN
	RETURN	(
				SELECT CategoryID FROM Category
				WHERE CategoryName = @categoryName
			)
END
GO

--function getAssemblySupplierID() returns ContactID as AssemblySupplierID
CREATE OR ALTER FUNCTION getAssemblySupplierID()
RETURNS INT
AS
BEGIN
	RETURN	(
				SELECT ContactID FROM Contact
				WHERE ContactName LIKE 'BIT Manufacturing%'
			)
END
GO

--stored procedure createAssembly
CREATE OR ALTER PROCEDURE createAssembly
		(	@componentName nvarchar(24), 
			@componentDescription nvarchar(200)
		)
AS
BEGIN
	SET IDENTITY_INSERT Component ON
	INSERT Component
		(
			ComponentID,
			componentName,
			componentDescription,
			CategoryID,
			SupplierID
		)
	VALUES
		(
			@@IDENTITY + 1,
			@componentName,
			@componentDescription,
			dbo.getCategoryID('Assembly'),
			dbo.getAssemblySupplierID()
		)
	SET IDENTITY_INSERT Component OFF
END
GO

--stored procedure addSubComponent
CREATE OR ALTER PROCEDURE addSubComponent
		(	@assemblyName nvarchar(24), 
			@subComponentName nvarchar(24),
			@quantity decimal(14,4)
		)
AS
BEGIN
	SET IDENTITY_INSERT AssemblySubcomponent ON

	INSERT AssemblySubcomponent
		(
			AssemblyID,
			SubcomponentID,
			Quantity
		)
	VALUES
		(
			(SELECT ComponentID FROM Component
			WHERE ComponentName = @assemblyName),
			(SELECT ComponentID FROM Component
			WHERE ComponentName = @subComponentName),
			@quantity
		)
	SET IDENTITY_INSERT AssemblySubcomponent OFF
END
GO

--create categories
insert Category (CategoryName) values ('Black Steel')
insert Category (CategoryName) values ('Assembly')
insert Category (CategoryName) values ('Fixings')
insert Category (CategoryName) values ('Paint')
insert Category (CategoryName) values ('Labour')

--create contacts
BEGIN
insert Contact (ContactName, ContactPostalAddress, ContactWWW, ContactEmail, ContactPhone, ContactFax)
values ('ABC Ltd.', '17 George Street, Dunedin', 'www.abc.co.nz', 'info@abc.co.nz', '	471 2345', null)

DECLARE @ABC INT
SET @ABC = @@IDENTITY

insert Supplier (SupplierID, SupplierGST)
values (@@IDENTITY, 'SupplierABC123')

insert Contact (ContactName, ContactPostalAddress, ContactWWW, ContactEmail, ContactPhone, ContactFax)
values ('XYZ Ltd.', '23 Princes Street, Dunedin', null, 'xyz@paradise.net.nz', '4798765', '4798760')

DECLARE @XYZ INT
SET @XYZ = @@IDENTITY

insert Supplier (SupplierID, SupplierGST)
values (@@IDENTITY, 'SupplierXYZ123')

insert Contact (ContactName, ContactPostalAddress, ContactWWW, ContactEmail, ContactPhone, ContactFax)
values ('CDBD Pty Ltd.',	'Lot 27, Kangaroo Estate, Bondi, NSW, Australia 2026', '	www.cdbd.com.au', 'support@cdbd.com.au', '+61 (2) 9130 1234', null)

DECLARE @CDBD INT
SET @CDBD = @@IDENTITY

insert Supplier (SupplierID, SupplierGST)
values (@@IDENTITY, 'SupplierCDBD123')

insert Contact (ContactName, ContactPostalAddress, ContactWWW, ContactEmail, ContactPhone, ContactFax)
values ('BIT Manufacturing Ltd.', 'Forth Street, Dunedin', 'bitmanf.tekotago.ac.nz', 'bitmanf@tekotago.ac.nz', '0800 SMARTMOVE', null)

DECLARE @BITManf INT
SET @BITManf = @@IDENTITY

insert Supplier (SupplierID, SupplierGST)
values (@@IDENTITY, 'SupplierBIT123')

END

-- create components
SET IDENTITY_INSERT Component ON

insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30901, 'BMS10', '10mm M6 ms bolt', @ABC, 0.20, 0.17, 0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30902, 'BMS12', '12mm M6 ms bolt', @ABC, 0.25, 0.2125,	0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30903, 'BMS15', '15mm M6 ms bolt', @ABC, 0.32, 0.2720, 0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30904, 'NMS10', '10mm M6 ms nut', @ABC, 0.05, 0.04, 0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30905, 'NMS12', '12mm M6 ms nut', @ABC, 0.052, 0.0416, 0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30906, 'NMS15', '15mm M6 ms nut', @ABC, 0.052, 0.0416, 0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30911, 'BMS.3.12', '3mm x 12mm flat ms bar', @XYZ, 1.20, 1.15, 	0.75, dbo.getCategoryID('Black Steel'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30912, 'BMS.5.15', '5mm x 15mm flat ms bar', @XYZ, 2.50, 2.45, 	0.75, dbo.getCategoryID('Black Steel'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30913, 'BMS.10.25', '10mm x 25mm flat ms bar', @XYZ, 8.33, 8.27, 0.75, dbo.getCategoryID('Black Steel'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30914, 'BMS.15.40', '15mm x 40mm flat ms bar', @XYZ, 20.00, 19.85, 0.75, dbo.getCategoryID('Black Steel'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30931, '27', 'Anti-rust paint, silver', @CDBD, 74.58, 63.85, 0, dbo.getCategoryID('Paint'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30932, '43', 'Anti-rust paint, red', @CDBD, 74.58, 63.85, 0, dbo.getCategoryID('Paint'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30933, '154', 'Anti-rust paint, blue', @CDBD, 74.58, 63.85, 0, dbo.getCategoryID('Paint'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30921, 'ARTLAB', 'Artisan labour', @BITManf, 42.00, 42.00, 0	, dbo.getCategoryID('Labour'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30922, 'DESLAB', 'Designer labour', @BITManf, 54.00, 54.00, 0, dbo.getCategoryID('Labour'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30923, 'APPLAB', 'Apprentice labour', @BITManf, 23.50, 23.50, 0, dbo.getCategoryID('Labour'))

SET IDENTITY_INSERT Component OFF

--create assemblies
exec createAssembly  'SmallCorner.15', '15mm small corner'
exec dbo.addSubComponent 'SmallCorner.15', 'BMS.5.15', 0.120
exec dbo.addSubComponent 'SmallCorner.15', 'APPLAB', 0.33333
exec dbo.addSubComponent 'SmallCorner.15', '43', 0.0833333

exec dbo.createAssembly 'SquareStrap.1000.15', '1000mm x 15mm square strap'
exec dbo.addSubComponent 'SquareStrap.1000.15', 'BMS.5.15', 4
exec dbo.addSubComponent 'SquareStrap.1000.15', 'SmallCorner.15', 4
exec dbo.addSubComponent 'SquareStrap.1000.15', 'APPLAB', 25
exec dbo.addSubComponent 'SquareStrap.1000.15', 'ARTLAB', 10
exec dbo.addSubComponent 'SquareStrap.1000.15', '43', 0.185
exec dbo.addSubComponent 'SquareStrap.1000.15', 'BMS10', 8

exec dbo.createAssembly 'CornerBrace.15', '15mm corner brace'
exec dbo.addSubComponent 'CornerBrace.15', 'BMS.5.15', 0.090
exec dbo.addSubComponent 'CornerBrace.15', 'BMS10', 2
