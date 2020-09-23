USE master
GO

DROP DATABASE IF EXISTS jhonr1_IN705Assignment1
GO

CREATE DATABASE jhonr1_IN705Assignment1
GO

USE jhonr1_IN705Assignment1
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
	ContactFax				NVARCHAR(24) DEFAULT(NULL),
	ContactMobilePhone		NVARCHAR(24) DEFAULT(NULL),
	ContactEmail			NVARCHAR(50) DEFAULT(NULL),
	ContactWWW				NVARCHAR(50) DEFAULT(NULL),
	ContactPostalAddress	NVARCHAR(60) NOT NULL
)


CREATE TABLE Supplier
(
	SupplierID	INT NOT NULL PRIMARY KEY,
	SupplierGST NVARCHAR(24) NOT NULL,
	CONSTRAINT FK_Supplier_Contact FOREIGN KEY (SupplierID)
		REFERENCES Contact(ContactID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
)

CREATE TABLE Customer
(
	CustomerID	INT NOT NULL PRIMARY KEY,
	CONSTRAINT FK_Customer_Contact FOREIGN KEY (CustomerID)
		REFERENCES Contact(ContactID)
		ON UPDATE CASCADE
		ON DELETE CASCADE
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
	QuoteCompiler			NVARCHAR(50) NOT NULL,
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
	Quantity		DECIMAL(14,4) NOT NULL,
	TradePrice		DECIMAL(14,4) CHECK(TradePrice >= 0) NOT NULL,
	ListPrice		DECIMAL(14,4) CHECK(ListPrice >= 0) NOT NULL,
	TimeToFit		DECIMAL(14,2) DEFAULT(0) CHECK(TimeToFit >= 0) NOT NULL,
	CONSTRAINT PK_QuoteComponent PRIMARY KEY (ComponentID, QuoteID),
	CONSTRAINT FK_QuoteComponent_Quote FOREIGN KEY (QuoteID)
		REFERENCES Quote(QuoteID)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CONSTRAINT FK_QuoteComponent_Component FOREIGN KEY(ComponentID)
		REFERENCES Component(ComponentID)
		ON UPDATE NO ACTION
		ON DELETE NO ACTION
)

CREATE TABLE AssemblySubcomponent
(
	AssemblyID		INT NOT NULL IDENTITY,
	SubcomponentID	INT NOT NULL,
	Quantity		DECIMAL(14,4) NOT NULL,
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
	INSERT Component
		(
			componentName,
			componentDescription,
			CategoryID,
			SupplierID
		)
	VALUES
		(
			@componentName,
			@componentDescription,
			dbo.getCategoryID('Assembly'),
			dbo.getAssemblySupplierID()
		)
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

-- Stored procedure createCustomer() returns 'ContactID' as 'CustomerID'
GO
CREATE OR ALTER PROCEDURE createCustomer(
	@Name nvarchar(24), 
	@Phone nvarchar(24),
	@PostalAddress nvarchar(60), 
	@Email nvarchar(50) = NULL, 
	@WWW nvarchar(50) = NULL, 
	@Fax nvarchar(24) = NULL,
	@MobilePhone nvarchar(24) = NULL
	)
AS
BEGIN
	DECLARE @CustomerID INT
	INSERT Contact (ContactName, ContactPhone, ContactPostalAddress, ContactEmail, ContactWWW, ContactFax, ContactMobilePhone)
	VALUES (@Name, @Phone, @PostalAddress, @Email, @WWW, @Fax, @MobilePhone)

	SET @CustomerID = @@IDENTITY
	INSERT Customer (CustomerID)
	VALUES (@CustomerID)
	RETURN @CustomerID

END
GO

--Stored procedure createQuote() returns 'QuoteID'
CREATE OR ALTER PROCEDURE createQuote(
	@QuoteDescription NVARCHAR(200),
	@QuoteDate DATETIME = NULL,
	@QuotePrice DECIMAL(14,4) = DEFAULT,
	@QuoteCompiler NVARCHAR(200), 
	@CustomerID INT
	)
AS
BEGIN
	IF @QuoteDate IS NULL set @QuoteDate = GETDATE() --catch the NULL parameter value and replace it
	INSERT Quote (QuoteDescription, QuoteDate, QuotePrice, QuoteCompiler, CustomerID)
	VALUES (@QuoteDescription, @QuoteDate, @QuotePrice, @QuoteCompiler, @CustomerID)

	RETURN @@IDENTITY
END
GO

/*
DECLARE @value INT
EXEC @value = createQuote 'QuoteDes', NULL, 2, 'compiler', @@IDENTITY
print(@@IDENTITY)
*/


--Stored procedure addQuoteComponent insert quoteComponent.
CREATE OR ALTER PROCEDURE addQuoteComponent(
	@QuoteID INT,
	@ComponentID INT,
	@Quantity DECIMAL(14,4)
	)
AS
BEGIN
	DECLARE @TradePrice DECIMAL(14,4), @ListPrice DECIMAL(14,4), @TimeToFit DECIMAL(14,2)

	SET @TradePrice = (SELECT TradePrice FROM Component
	WHERE ComponentID = @ComponentID)

	SET @ListPrice = (SELECT ListPrice FROM Component
	WHERE ComponentID = @ComponentID)

	SET @TimeToFit = (SELECT TimeToFit FROM Component
	WHERE ComponentID = @ComponentID)

	INSERT QuoteComponent (QuoteID, ComponentID, Quantity, TradePrice, ListPrice, TimeToFit)
	VALUES (@QuoteID, @ComponentID, @Quantity, @TradePrice, @ListPrice, @TimeToFit)
END
GO

--Create 1st customer
DECLARE @CustID INT
EXEC @CustID = createCustomer 'Bimble & Hat', '444 5555', '123 Digit Street, Dunedin', 'guy.little@bh.biz.nz'

--Create Quotes for the 1st customer
EXEC createQuote 
@QuoteDescription = 'Craypot frame', 
@QuoteDate = DEFAULT, 
@QuotePrice = 2.5, 
@QuoteCompiler = 'Bimble & Hat', 
@CustomerID = @CustID

EXEC createQuote 
@QuoteDescription = 'Craypot stand',
@QuoteCompiler = 'Bimble & Hat', 
@CustomerID = @CustID

-- Insert datas to QuoteComponent table for 1st customer, 1st Quote
EXEC addQuoteComponent 1, 30935, 3
EXEC addQuoteComponent 1, 30912, 8
EXEC addQuoteComponent 1, 30901, 24
EXEC addQuoteComponent 1, 30904, 24
EXEC addQuoteComponent 1, 30933, 0.2

-- Insert datas to QuoteComponent table for 1st customer, 2nd Quote
EXEC addQuoteComponent 2, 30914, 2
EXEC addQuoteComponent 2, 30903, 4
EXEC addQuoteComponent 2, 30906, 4
EXEC addQuoteComponent 2, 30933, 0.1

--Create 2nd customer
DECLARE @CustID2 INT
EXEC @CustID2 = createCustomer 'Hyperfont Modulator (International) Ltd.', '(4) 213 4359', '3 Lambton Quay, Wellington', 'sue@nz.hfm.com'

--Create Quotes for the 2nd customer
EXEC createQuote 
@QuoteDescription = 'Phasing restitution fulcrum',
@QuoteCompiler = 'Hyperfont Modulator (International) Ltd.', 
@CustomerID = @CustID2

-- Insert datas to QuoteComponent table for 1st customer, 1st Quote
EXEC addQuoteComponent 3, 30936, 3
EXEC addQuoteComponent 3, 30934, 1
EXEC addQuoteComponent 3, 30932, 1

-- Create procedure updateAssemblyPrices
GO
CREATE OR ALTER PROCEDURE updateAssemblyPrices
AS
BEGIN
	UPDATE Component
	SET 
		TradePrice = ac.TradePrice,
		ListPrice = ac.ListPrice
	FROM 
		(
		SELECT a.AssemblyID, SUM(c.TradePrice) AS TradePrice, SUM(c.ListPrice) AS ListPrice FROM Component c 
		JOIN AssemblySubcomponent a ON c.ComponentID = a.SubcomponentID
		GROUP BY a.AssemblyID
		) AS ac
	WHERE ComponentID = ac.AssemblyID
END

-- Update Assembly component prices
GO
EXEC updateAssemblyPrices

--Trigger on Supplier delete
GO
CREATE OR ALTER TRIGGER trigSupplierDelete ON Supplier
INSTEAD OF DELETE
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @SupplierID INT, @SupplierName NVARCHAR(50), @NumberOfComp INT
	SELECT @SupplierID = deleted.SupplierID FROM deleted

	SELECT @SupplierName = ct.ContactName,  @NumberOfComp = COUNT(*) FROM Component c
	JOIN Supplier s ON c.SupplierID = s.SupplierID
	JOIN Contact ct ON s.SupplierID = ct.ContactID
	WHERE c.SupplierID = @SupplierID
	GROUP BY c.SupplierID, ct.ContactName

	IF (@NumberOfComp > 0)
		PRINT('You cannot delete this supplier. ' + @SupplierName + ' has ' + CAST(@NumberOfComp AS NVARCHAR(5)) + ' related components.')
	ELSE
		DELETE Supplier WHERE SupplierID = @SupplierID
END
GO

---------------------------

/*
select * from Category
select * from QuoteComponent
select * from Quote
select * from Component
select * from AssemblySubcomponent
select * from Contact
select * from Supplier
select * from Customer
delete Supplier where SupplierID = 3
update Supplier set SupplierID = 444 where SupplierID = 4
delete Component where ComponentID = 30901
delete AssemblySubcomponent where AssemblyID = '30924'
SET IDENTITY_INSERT Component ON
update Component set ComponentID = 30912222 where ComponentID = 30912
SET IDENTITY_INSERT Component ON
update Category set CategoryID = 11 where CategoryID = 1
select * from Customer
insert Supplier values(5,'SupplierRuban')
*/
/*
ALTER TABLE AssemblySubcomponent 
DROP 
	CONSTRAINT FK_Subcomponent_Component, FK_Assembly_Component

GO

ALTER TABLE AssemblySubcomponent
ADD 
	CONSTRAINT FK_Subcomponent_Component FOREIGN KEY(SubcomponentID)
	REFERENCES Component(ComponentID)
	ON UPDATE CASCADE
	ON DELETE NO ACTION,
	CONSTRAINT FK_Assembly_Component FOREIGN KEY(AssemblyID)
	REFERENCES Component(ComponentID)
	ON UPDATE CASCADE
	ON DELETE NO ACTION

GO*/

