-- Introduction to Triggers
-- An introduction to the basic concepts of SQL Server triggers. Create your first trigger using T-SQL code. Learn how triggers are used and what alternatives exist.
-- Classification of Triggers

-- Creating your first trigger
-- You have been hired by the company Fresh Fruit Delivery to help secure their database and ensure data integrity. The company sells fresh fruit to other online shops, and they use several tables to keep track of stock and placed orders.

-- One of their tables (Discounts) specifies the discount amount that shops receive when placing large orders. A deletion of several hundred rows happened at some point in the past when one of their employees removed some orders by mistake. They need a new trigger on the Discounts table to prevent DELETE statements related to the table, and this is where you can help.


-- Create a new trigger that fires when deleting data
CREATE TRIGGER PreventDiscountsDelete
ON Discounts
-- The trigger should fire instead of DELETE
INSTEAD OF DELETE
AS
	PRINT 'You are not allowed to delete data from the Discounts table.';


--     Practicing creating triggers
-- The Fresh Fruit Delivery company needs help creating a new trigger called OrdersUpdatedRows on the Orders table.

-- This trigger will be responsible for filling in a historical table (OrdersUpdate) where information about the updated rows is kept.

-- A historical table is often used in practice to store information that has been altered in the original table. In this example, changes to orders will be saved into OrdersUpdate to be used by the company for auditing purposes.


-- Set up a new trigger
CREATE TRIGGER OrdersUpdatedRows
ON Orders
-- The trigger should fire after UPDATE statements
AFTER UPDATE
-- Add the AS keyword before the trigger body
AS
	-- Insert details about the changes to a dedicated table
	INSERT INTO OrdersUpdate(OrderID, OrderDate, ModifyDate)
	SELECT OrderID, OrderDate, GETDATE()
	FROM inserted;


--     Creating a trigger to keep track of data changes
-- The Fresh Fruit Delivery company needs to keep track of any new items added to the Products table. You can do this by using a trigger.

-- The new trigger will store the name, price, and first introduced date for new items into a ProductsHistory table.


-- Create a new trigger
CREATE TRIGGER ProductsNewItems
ON Products
AFTER INSERT
AS
	-- Add details to the history table
	INSERT INTO ProductsHistory(Product, Price, Currency, FirstAdded)
	SELECT Product, Price, Currency, GETDATE()
	FROM inserted;


--     Triggers vs. stored procedures
-- One important task when you take ownership of an existing database is to familiarize yourself with the objects that comprise the database.

-- This task includes getting to know existing procedures, functions, and triggers.

-- You find the following objects in the Fresh Fruit Delivery database:

-- The company uses a regular stored procedure, MonthlyOrders, for reporting purposes. The stored procedure sums up order amounts for each product every month.

-- The trigger CustomerDiscountHistory is used to keep a history of the changes that occur in the Discounts table. The trigger is fired when updates are made to the Discounts table, and it stores the old and new values from the Discount column into the table DiscountsHistory.


-- Run an update for some of the discounts
UPDATE Discounts
SET Discount = Discount + 1
WHERE Discount <= 5;

-- Verify the trigger ran successfully
SELECT * FROM DiscountsHistory;



-- Triggers vs. computed columns
-- While continuing your analysis of the database, you find two other interesting objects:

-- The table SalesWithPrice has a column that calculates the TotalAmount as Quantity * Price. This is done using a computed column which uses columns from the same table for the calculation.

-- The trigger SalesCalculateTotalAmount was created on the SalesWithoutPrice table. The Price column is not part of the SalesWithoutPrice table, so a computed column cannot be used for the TotalAmount. The trigger overcomes this limitation by using the Price column from the Products table.


-- Add the following rows to the table
INSERT INTO SalesWithPrice (Customer, Product, Price, Currency, Quantity)
VALUES ('Fruit Mag', 'Pomelo', 1.12, 'USD', 200),
	   ('VitaFruit', 'Avocado', 2.67, 'USD', 400),
	   ('Tasty Fruits', 'Blackcurrant', 2.32, 'USD', 1100),
	   ('Health Mag', 'Kiwi', 1.42, 'USD', 100),
	   ('eShop', 'Plum', 1.1, 'USD', 500);

-- Verify the results after adding the new rows
SELECT * FROM SalesWithPrice;



