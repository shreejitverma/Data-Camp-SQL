-- Raising, throwing and customizing your errors!!
-- In this chapter, you will deepen your knowledge of handling errors. You will learn how to raise errors using RAISERROR and THROW. Additionally, you will discover how to customize errors.


-- CATCHING the RAISERROR
-- You need to select a product from the products table using a given product_id.

-- If the select statement doesn't find any product, you want to raise an error using the RAISERROR statement. You also need to catch possible errors in the execution.

-- For this exercise, the value of @product_id is 5.


-- Set @product_id to 5
DECLARE @product_id INT = 5;

IF NOT EXISTS (SELECT * FROM products WHERE product_id = @product_id)
	-- Invoke RAISERROR with parameters
	RAISERROR('No product with id %d.', 11, 1, @product_id);
ELSE 
	SELECT * FROM products WHERE product_id = @product_id;



--     THROW without parameters
-- You want to prepare a stored procedure to insert new products in the database. In that stored procedure, you want to insert the possible errors in a table called errors, and after that, re-throw the original error.

-- How do you prepare the stored procedure?


CREATE PROCEDURE insert_product
  @product_name VARCHAR(50),
  @stock INT,
  @price DECIMAL

AS

BEGIN TRY
	INSERT INTO products (product_name, stock, price)
		VALUES (@product_name, @stock, @price);
END TRY
-- Set up the CATCH block
BEGIN CATCH
	-- Insert the error and end the statement with a semicolon
    INSERT INTO errors VALUES ('Error inserting a product');
    -- Re-throw the error
	THROW; 
END CATCH




-- Executing a stored procedure that throws an error
-- You need to insert a new product using the stored procedure you created in the previous exercise:

-- CREATE PROCEDURE insert_product
--   @product_name VARCHAR(50),
--   @stock INT,
--   @price DECIMAL

-- AS

-- BEGIN TRY
--     INSERT INTO products (product_name, stock, price)
--         VALUES (@product_name, @stock, @price);
-- END TRY
-- BEGIN CATCH    
--     INSERT INTO errors VALUES ('Error inserting a product');  
--     THROW;  
-- END CATCH
-- You want to register that you received 3 Super bike bikes with a price of $499.99. You need to catch the possible errors generated in the execution of the stored procedure, showing the original error message.

-- How do you prepare the script?


BEGIN TRY
	-- Execute the stored procedure
	EXEC insert_product
    	-- Set the values for the parameters
    	@product_name = 'Super bike',
        @stock = 3,
        @price = 499.99;
END TRY
-- Set up the CATCH block
BEGIN CATCH
	-- Select the error message
	SELECT ERROR_MESSAGE();
END CATCH


-- THROW with parameters
-- You need to prepare a script to select all the information of a member from the staff table using a given staff_id.

-- If the select statement doesn't find any member, you want to throw an error using the THROW statement. You need to warn there is no staff member with such id.


-- Set @staff_id to 4
DECLARE @staff_id INT = 4;

IF NOT EXISTS (SELECT * FROM staff WHERE staff_id = @staff_id)
   	-- Invoke the THROW statement with parameters
	THROW 50001, 'No staff number with such id', 1;
ELSE
   	SELECT * FROM staff WHERE staff_id = @staff_id


--        Concatenating the message
-- You need to prepare a script to select all the information about the members from the staff table using a given first_name.

-- If the select statement doesn't find any member, you want to throw an error using the THROW statement. You need to warn there is no staff member with such a name.


-- Set @first_name to 'Pedro'
DECLARE @first_name NVARCHAR(20) = 'Pedro';
-- Concat the message
DECLARE @my_message NVARCHAR(500) =
	FORMATMESSAGE('There is no staff member with ', @first_name, ' as the first name.');

IF NOT EXISTS (SELECT * FROM staff WHERE first_name = @first_name)
	-- Throw the error
	THROW 50000, @my_message, 1;


--     FORMATMESSAGE with message string
-- Every time you sell a bike in your store, you need to check if there is enough stock. You prepare a script to check it and throw an error if there is not enough stock.

-- Today, you sold 10 'Trek CrossRip+ - 2018' bikes, so you need to check if you can sell them.


DECLARE @product_name AS NVARCHAR(50) = 'Trek CrossRip+ - 2018';
DECLARE @number_of_sold_bikes AS INT = 10;
DECLARE @current_stock INT;
-- Select the current stock
SELECT ___ = stock FROM products WHERE product_name = @product_name;
DECLARE @my_message NVARCHAR(500) =
	-- Customize the message
	FORMATMESSAGE('There are not enough %s bikes. You only have %d in stock.', @product_name, @current_stock);

IF (@current_stock - @number_of_sold_bikes < 0)
	-- Throw the error
	THROW 50000, @my_message, 1;



--     FORMATMESSAGE with message number
-- Like in the previous exercise, you need to check if there is enough stock when you sell a product.

-- This time you want to add your custom error message to the sys.messages catalog, by executing the sp_addmessage stored procedure.


-- Pass the variables to the stored procedure
EXEC sp_addmessage @msgnum = 50002, @severity = 16, @msgtext = 'There are not enough %s bikes. You only have %d in stock.', @lang = N'us_english';

DECLARE @product_name AS NVARCHAR(50) = 'Trek CrossRip+ - 2018';
DECLARE @number_of_sold_bikes AS INT = 10;
DECLARE @current_stock INT;
SELECT @current_stock = stock FROM products WHERE product_name = @product_name;
DECLARE @my_message NVARCHAR(500) =
	-- Prepare the error message
	FORMATMESSAGE(50002, @product_name, @current_stock);

IF (@current_stock - @number_of_sold_bikes < 0)
	-- Throw the error
	THROW 50000, @my_message, 1;


    