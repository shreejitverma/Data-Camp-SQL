-- Trigger Optimization and Management
-- Learn to delete and modify triggers. Acquaint yourself with the way trigger management is done. Learn how to investigate problematic triggers in practice.
-- Classification of Triggers

-- Removing unwanted triggers
-- After some time, the Fresh Fruit Delivery company notices that some of the triggers they requested are no longer needed. Their workflow has changed and not all of the triggers are used now.

-- It's a good practice to have your database clean and up-to-date. Unused objects should always be removed after proper confirmation from the involved parties.

-- The company calls to ask you to help them remove the unused triggers.


-- Remove the trigger
DROP TRIGGER PreventNewDiscounts;


-- Modifying a trigger's definition
-- A member of the Sales team has noticed that one of the triggers attached to the Discounts table is showing a message with the word "allowed" missing.


-- Fix the typo in the trigger message
ALTER TRIGGER PreventDiscountsDelete
ON Discounts
INSTEAD OF DELETE
AS
	PRINT 'You are not allowed to remove data from the Discounts table.';



--     Disabling a trigger
-- Fresh Fruit Delivery needs to make some changes to a couple of rows in the Orders table.

-- Earlier they asked for a trigger to prevent unwanted changes to the Orders table, but now that trigger is stopping them from making the necessary modifications.

-- You are asked to help them with the situation by temporarily stopping that trigger from firing.


-- Pause the trigger execution
DISABLE TRIGGER PreventOrdersUpdate
ON Orders;



-- Re-enabling a disabled trigger
-- You helped the company update the Orders table by disabling the PreventOrdersUpdate trigger. Now they want the trigger to be active again to ensure no unwanted modifications are made to the table.



-- Resume the trigger execution
ENABLE TRIGGER PreventOrdersUpdate
ON Orders;



-- Managing existing triggers
-- Fresh Fruit Delivery has asked you to act as the main administrator of their database.

-- A best practice when taking over an existing database is to get familiar with all the existing objects.

-- You'd like to start by looking at the existing triggers.


-- Get the disabled triggers
SELECT name,
	   object_id,
	   parent_class_desc
FROM sys.triggers
WHERE is_disabled = 1;



-- Keeping track of trigger executions
-- One important factor when monitoring triggers is to have a history of their execution. This allows you to associate the timings between trigger runs and any issues that occur in the database.

-- If the times match, it's possible that the problems were caused by the trigger.

-- SQL Server provides information about the execution of any triggers that are currently stored in memory in the sys.dm_exec_trigger_stats view. But once a trigger is removed from the memory, any information about it is removed from the view as well, so you lose the trigger execution history.

-- To overcome this limitation, you decide to make use of the TriggerAudit table to store information about any attempts to modify rows in the Orders table, because people have reported the table is often unresponsive.


-- Modify the trigger to add new functionality
ALTER TRIGGER PreventOrdersUpdate
ON Orders
-- Prevent any row changes
INSTEAD OF UPDATE
AS
	-- Keep history of trigger executions
	INSERT INTO TriggerAudit (TriggerName, ExecutionDate)
	SELECT 'PreventOrdersUpdate', 
           GETDATE();

	RAISERROR ('Updates on "Orders" table are not permitted.
                Place a new order to add new products.', 16, 1);



--                 Identifying problematic triggers
-- You've identified an issue when placing new orders in the company's sales system.

-- The issue is related to a trigger run, but you don't have many details on the triggers themselves. Unfortunately, the database objects (including triggers) are not documented.

-- You need to identify the trigger that's causing the problem to proceed with the investigation. To be sure, you need to gather some important details about the triggers.

-- The only information you have when starting the investigation is that the table related to the issues is Orders.


-- Get the table ID
SELECT object_id AS TableID
FROM sys.objects
WHERE name = 'Orders';


