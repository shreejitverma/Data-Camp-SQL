-- Trigger Limitations and Use Cases
-- Find out known limitations of triggers, as well as common use cases for AFTER triggers (DML), INSTEAD OF triggers (DML) and DDL triggers.
-- Classification of Triggers
-- Creating a report on existing triggers
-- Taking on the responsibility of administrating the database for the Fresh Fruit Delivery company also means keeping an eye on existing triggers.

-- The best approach is to have a report that can be run regularly and outputs details of the existing triggers.

-- This will ensure you have a good overview of the triggers and give you access to some interesting information.


-- Get the column that contains the trigger name
SELECT name AS TriggerName,
	   parent_class_desc AS TriggerType,
	   create_date AS CreateDate,
	   modify_date AS LastModifiedDate,
	   is_disabled AS Disabled,
       -- Get the column that tells if it's an INSTEAD OF trigger
	   is_instead_of_trigger AS InsteadOfTrigger
FROM sys.triggers;


-- Keeping a history of row changes
-- The Fresh Fruit Delivery company needs to track changes made to the Customers table.

-- You are asked to create a new trigger that covers any statements modifying rows in the table.


-- Create a trigger to keep row history
CREATE TRIGGER CopyCustomersToHistory
ON Customers
-- Fire the trigger for new and updated rows
AFTER INSERT, UPDATE
AS
	INSERT INTO CustomersHistory (CustomerID, Customer, ContractID, ContractDate, Address, PhoneNo, Email, ChangeDate)
	SELECT CustomerID, Customer, ContractID, ContractDate, Address, PhoneNo, Email, GETDATE()
    -- Get info from the special table that keeps new rows
    FROM inserted;


--     Table auditing using triggers
-- The company has decided to keep track of changes made to all the most important tables. One of those tables is Orders.

-- Any modification made to the content of Orders should be inserted into TablesAudit.


-- Add a trigger that tracks table changes
CREATE TRIGGER OrdersAudit
ON Orders
AFTER INSERT, UPDATE, DELETE
AS
	DECLARE @Insert BIT = 0;
	DECLARE @Delete BIT = 0;
	IF EXISTS (SELECT * FROM inserted) SET @Insert = 1;
	IF EXISTS (SELECT * FROM deleted) SET @Delete = 1;
	INSERT INTO ___ (TableName, EventType, UserAccount, EventDate)
	SELECT 'Orders' AS TableName
	       ,CASE WHEN @Insert = 1 AND @Delete = 0 THEN 'INSERT'
				 WHEN @Insert = 1 AND @Delete = 1 THEN 'UPDATE'
				 WHEN @Insert = 0 AND @Delete = 1 THEN 'DELETE'
				 END AS Event
		   ,ORIGINAL_LOGIN() AS UserAccount
		   ,GETDATE() AS EventDate;




--            Preventing changes to Products
-- The Fresh Fruit Delivery company doesn't want regular users to be able to change product information or the actual stock.


-- Prevent any product changes
CREATE TRIGGER PreventProductChanges
ON Products
AFTER INSERT, UPDATE
AS
	RAISERROR ('Updates of products are not permitted. Contact the database administrator if a change is needed.', 16, 1);


--     Checking stock before placing orders
-- On multiple occasions, customers have placed orders for products when the company didn't have enough stock to fulfill the orders.

-- This issue can be easily fixed by adding a new trigger with conditional logic for its actions.

-- The trigger should fire when new rows are added to the Orders table and check if the company has sufficient stock of the specified products to fulfill those orders.

-- If there is sufficient stock, the trigger will then perform the same INSERT operation like the one that fired it—only this time, the values will be taken from the inserted special table.


-- Create a new trigger to confirm stock before ordering
CREATE TRIGGER ConfirmStock
ON Orders
INSTEAD OF INSERT
AS
	IF EXISTS (SELECT *
			   FROM Products AS p
			   INNER JOIN inserted AS i ON i.Product = p.Product
			   WHERE p.Quantity < i.Quantity)
	BEGIN
		RAISERROR ('You cannot place orders when there is no stock for the order''s product.', 16, 1);
	END
	ELSE
	BEGIN
		INSERT INTO Orders (OrderID, Customer, Product, Price, Currency, Quantity, WithDiscount, Discount, OrderDate, TotalAmount, Dispatched)
		SELECT OrderID, Customer, Product, Price, Currency, Quantity, WithDiscount, Discount, OrderDate, TotalAmount, Dispatched FROM inserted;
	END;





--     Database auditing
-- Your next task is to develop a new trigger to audit database object changes.

-- You need to create the trigger at the database level. You can use the DDL_TABLE_VIEW_EVENTS group event to fire the trigger. This group event includes any database operation involving tables, views, indexes, or statistics. By using the group event, you do not need to specify all the events individually.

-- The trigger will insert details about the firing statement (event, user, query, etc.) into the DatabaseAudit table.


-- Create a new trigger
CREATE TRIGGER DatabaseAudit
-- Attach the trigger at the database level
ON DATABASE
-- Fire the trigger for all tables/ views events
FOR DDL_TABLE_VIEW_EVENTS
AS
	INSERT INTO DatabaseAudit (EventType, DatabaseName, SchemaName, Object, ObjectType, UserAccount, Query, EventTime)
	SELECT EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(50)') AS EventType
		  ,EVENTDATA().value('(/EVENT_INSTANCE/DatabaseName)[1]', 'NVARCHAR(50)') AS DatabaseName
		  ,EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]', 'NVARCHAR(50)') AS SchemaName
		  ,EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)') AS Object
		  ,EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(50)') AS ObjectType
		  ,EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(100)') AS UserAccount
		  ,EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)') AS Query
		  ,EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]', 'DATETIME') AS EventTime;



--           Preventing server changes
-- The company is also asking you to find a method to prevent databases from being mistakenly deleted by employees.

-- After a detailed analysis, you decide to use a trigger to fulfill the request.

-- The trigger will roll back any attempts to delete databases.




-- Create a trigger to prevent database deletion
CREATE TRIGGER PreventDatabaseDelete
-- Attach the trigger at the server level
ON ALL SERVER
FOR DROP_DATABASE
AS
   PRINT 'You are not allowed to remove existing databases.';
   ROLLBACK;


   