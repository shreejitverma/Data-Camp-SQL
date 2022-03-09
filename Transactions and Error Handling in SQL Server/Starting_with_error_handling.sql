
-- Starting with error handling!!
-- To begin the course, you will learn how to handle errors using the TRY...CATCH construct that provides T-SQL. You will study the anatomy of errors, and you will learn how to use some functions that can give you information about errors.

-- Your first error-handling script
-- You realized your products table doesn't have any constraint to check the data stored in its stock column. It makes sense that stock is always greater than or equal to 0. For some reason, there is a mistake in the following row. The stock is -1!

-- | product_id | product_name | stock | price |
-- |------------|--------------|-------|-------|
-- | 6          | Trek Neko+   | -1    | 2799  |
-- You want to prepare a script adding a constraint to the products table, so that only stocks greater than or equal to 0 are allowed.

-- If you add this constraint that only allows stocks greater than or equal to 0, the execution will fail because there is one row where the stock equals -1.

-- How can you prepare the script?


-- Set up the TRY block
BEGIN TRY
	-- Add the constraint
	ALTER TABLE products
		ADD CONSTRAINT CHK_Stock CHECK (stock >= 0);
END TRY
-- Set up the CATCH block
BEGIN CATCH
	SELECT 'An error occurred!';
END CATCH


-- Nesting TRY...CATCH constructs
-- You want to register a new buyer in your buyers table. This new buyer is Peter Thomson. His e-mail is peterthomson@mail.com and his phone number is 555000100.

-- In your database, there is also a table called errors, in which each error is stored.

-- You prepare a script that controls possible errors in the insertion of this person's data. It also inserts those errors into the errors table.

-- How do you prepare the script?




    
-- Set up the first TRY block
BEGIN TRY
	INSERT INTO buyers (first_name, last_name, email, phone)
		VALUES ('Peter', 'Thompson', 'peterthomson@mail.com', '555000100');
END TRY
-- Set up the first CATCH block
BEGIN CATCH
	SELECT 'An error occurred inserting the buyer! You are in the first CATCH block';
    -- Set up the nested TRY block
    BEGIN TRY
    	INSERT INTO errors 
        	VALUES ('Error inserting a buyer');
        SELECT 'Error inserted correctly!';
	END TRY
    -- Set up the nested CATCH block
    BEGIN CATCH
    	SELECT 'An error occurred inserting the error! You are in the nested CATCH block';
    END CATCH
END CATCH


-- Correcting compilation errors
-- Today, your colleague Bernard has to leave work early. He was preparing a script to insert a new product into the products table, but he couldn't finish it. He asks you for help and gives you the script to finish it.

-- He wants to insert the 'Sun Bicycles ElectroLite - 2017', with a stock of 10 units and a price of $1559.99. He also wants to insert possible errors in a table called errors. In fact, if you try to insert this bicycle, you will get an error because there is already another product with the same name.

-- When you execute the script, you realize there are several compilation errors.

-- Can you correct Bernard's script? The final output must be: An error occurred inserting the product!


BEGIN TRY
	INSERT INTO products (product_name, stock, price)
		VALUES ('Sun Bicycles ElectroLite - 2017', 10, 1559.99);
END TRY
BEGIN CATCH
	SELECT 'An error occurred inserting the product!';
    BEGIN TRY
    	INSERT INTO errors
        	VALUES ('Error inserting a product');
    END TRY    
    BEGIN CATCH
    	SELECT 'An error occurred inserting the error!';
    END CATCH    
END CATCH



-- Using error functions
-- For every month, you want to know the total amount of money you earned in your bike store. Instead of reviewing every order line, you thought it would be better to prepare a script that computes it and displays the results.

-- While writing the script, you made a mistake. As you can see, the operation 'Total: ' + SUM(price * quantity) AS total is missing a cast conversion, causing an error.

-- How can we catch this error? Show the error number, severity, state, line, and message.


-- Set up the TRY block
BEGIN TRY 	
	SELECT 'Total: ' + SUM(price * quantity) AS total
	FROM orders  
END TRY
-- Set up the CATCH block
BEGIN CATCH 
	-- Show error information.
	SELECT  ERROR_NUMBER() AS number,  
        	ERROR_SEVERITY() AS severity_level,  
        	ERROR_STATE() AS state,
        	ERROR_LINE() AS line,  
        	ERROR_MESSAGE() AS message; 	
END CATCH


-- Using error functions in a nested TRY...CATCH
-- You received some new electric bikes in your store, so you need to update the stock.

-- You want to register that you received 2 Trek Powerfly 5 - 2018 bikes with a price of $3499.99 each, and 3 New Power K- 2018 bikes at $1999.99 each.

-- You try to insert the products in the database because you think they are new models. However, you forgot you already have the first one in stock. Luckily, the products table has a constraint requiring every product name to be unique.

-- You prepare a script controlling possible errors in the insertions. You also want to insert possible errors in a table called errors, and, if something fails when inserting the error, show the error number and error message.


BEGIN TRY
    INSERT INTO products (product_name, stock, price) 
    VALUES	('Trek Powerfly 5 - 2018', 2, 3499.99),   		
    		('New Power K- 2018', 3, 1999.99)		
END TRY
-- Set up the outer CATCH block
BEGIN CATCH
	SELECT 'An error occurred inserting the product!';
    -- Set up the inner TRY block
    BEGIN TRY
    	-- Insert the error
    	INSERT INTO errors
        	VALUES ('Error inserting a product');
    END TRY    
    -- Set up the inner CATCH block
    BEGIN CATCH
    	-- Show number and message error
    	SELECT 
        	ERROR_LINE() AS line,	   
			ERROR_MESSAGE() AS message; 
    END CATCH   
END CATCH


