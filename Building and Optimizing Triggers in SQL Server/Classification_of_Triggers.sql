-- Classification of Triggers
-- Learn about the different types of SQL Server triggers: AFTER triggers (DML), INSTEAD OF triggers (DML), DDL triggers, and logon triggers.
-- Create the trigger
-- Tracking retired products
-- As shown in the example from the video, Fresh Fruit Delivery needs to keep track of any retired products in a dedicated history table (RetiredProducts).

-- You are asked to create a new trigger that fires when rows are removed from the Products table.

-- The information about the removed rows will be saved into the RetiredProducts table.

-- Create the trigger
CREATE TRIGGER TrackRetiredProducts
ON Products
AFTER DELETE
AS
	INSERT INTO RetiredProducts (Product, Measure)
	SELECT Product, Measure
	FROM deleted;


--     The TrackRetiredProducts trigger in action
-- Once you've created a trigger, it's always a good idea to see if it performs as expected.

-- The company's request for the trigger created earlier was based on a real need: they want to retire several products from their offering. This means you can check the trigger in action.

-- Remove the products that will be retired
DELETE FROM Products
WHERE Product IN ('Cloudberry', 'Guava', 'Nance', 'Yuzu');

-- Verify the output of the history table
SELECT * FROM RetiredProducts;


-- Practicing with AFTER triggers
-- Fresh Fruit Delivery company is happy with your services, and they've decided to keep working with you.

-- You have been given the task to create new triggers on some tables, with the following requirements:

-- Keep track of canceled orders (rows deleted from the Orders table). Their details will be kept in the table CanceledOrders upon removal.

-- Keep track of discount changes in the table Discounts. Both the old and the new values will be copied to the DiscountsHistory table.

-- Send an email to the Sales team via the SendEmailtoSales stored procedure when a new order is placed.


-- Create a new trigger for canceled orders
CREATE TRIGGER KeepCanceledOrders
ON Orders
AFTER INSERT
AS 
	INSERT INTO CanceledOrders
	SELECT * FROM deleted;


--     Preventing changes to orders
-- Fresh Fruit Delivery needs to prevent changes from being made to the Orders table.

-- Any attempt to do so should not be permitted and an error should be shown instead.


-- Create the trigger
CREATE TRIGGER PreventOrdersUpdate
ON Orders
INSTEAD OF UPDATE
AS
	RAISERROR ('Updates on "Orders" table are not permitted.
                Place a new order to add new products.', 16, 1);



--                 Creating the PreventNewDiscounts trigger
-- The company doesn't want regular users to add discounts. Only the Sales Manager should be able to do that.

-- To prevent such changes, you need to create a new trigger called PreventNewDiscounts.

-- The trigger should be attached to the Discounts table and prevent new rows from being added to the table.


-- Create a new trigger
___ ___ ___
ON ___
___ ___ ___
AS
	RAISERROR ('You are not allowed to add discounts for existing customers.
                Contact the Sales Manager for more details.', 16, 1);



--                 Tracking table changes
-- You need to create a new trigger at the database level that logs modifications to the table TablesChangeLog.

-- The trigger should fire when tables are created, modified, or deleted.


-- Create the trigger to log table info
CREATE TRIGGER TrackTableChanges
ON DATABASE
FOR CREATE_TABLE,
	ALTER_TABLE,
	DROP_TABLE
AS
	INSERT INTO TablesChangeLog (EventData, ChangedBy)
    VALUES (EVENTDATA(), USER);



--     Preventing table deletion
-- Fresh Fruit Delivery wants to prevent its regular employees from deleting tables from the database.


-- Add a trigger to disable the removal of tables
CREATE TRIGGER PrevenTableDeletion
ON DATABASE
FOR DROP_TABLE
AS
	RAISERROR ('You are not allowed to remove tables from this database.', 16, 1);
    -- Revert the statement that removes the table
    ROLLBACK;



--     Enhancing database security
-- Recently, several inconsistencies have been discovered on the Fresh Fruit Delivery company's database server.

-- The IT Security team does not have an auditing process to find out when users are connecting to the database and track breaking changes back to the responsible user.

-- You are asked to help the Security team by implementing a new trigger based on their requirements.

-- Due to the complexity of this request, you should build the INSERT statement in the first step and use it to create the trigger in the second step.


-- Save user details in the audit table
INSERT INTO ServerLogonLog (LoginName, LoginDate, SessionID, SourceIPAddress)
SELECT ORIGINAL_LOGIN(), GETDATE(), @@SPID, client_net_address
-- The user details can be found in SYS.DM_EXEC_CONNECTIONS
FROM SYS.DM_EXEC_CONNECTIONS WHERE session_id = @@SPID;



