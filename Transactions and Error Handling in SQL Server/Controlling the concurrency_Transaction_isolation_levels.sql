-- Controlling the concurrency: Transaction isolation levels!!
-- This chapter defines what concurrency is and how it can affect transactions. You will learn exciting concepts like dirty reads, repeatable reads, and phantom reads. To avoid or allow this reads, you will explore, one by one, the different transaction isolation levels.


-- Using the READ UNCOMMITTED isolation level
-- A new client visits your bank to open an account. You insert her data into your system, causing a script like this one to start running:

-- BEGIN TRAN

--   INSERT INTO customers (first_name, last_name, email, phone)
--   VALUES ('Ann', 'Ros', 'aros@mail.com', '555555555')

--   DECLARE @cust_id INT = scope_identity()

--   INSERT INTO accounts (account_number, customer_id, current_balance)
--   VALUES ('55555555555010121212', @cust_id, 150)

-- COMMIT TRAN


-- Set the appropriate isolation level
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- Select first_name, last_name, email and phone
	SELECT
    	first_name, 
        last_name, 
        email,
        phone
    FROM customers;



--     Prevent dirty reads
-- You have to analyze how many accounts have more than $50,000.

-- As the number of accounts is an important result, you don't want to read data modified by other transactions that haven't committed or rolled back yet. In doing this, you prevent dirty reads. However, you don't need to consider having non-repeatable or phantom reads.

-- Prepare the script.


-- Set the appropriate isolation level
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

-- Count the accounts
SELECT COUNT(*) AS number_of_accounts
FROM accounts
WHERE current_balance >= 50000;



-- Preventing non-repeatable reads
-- You are in charge of analyzing data about your bank customers.

-- You prepare a script that first selects the data of every customer. After that, your script needs to process some mathematical operations based on the result. (We won't focus on these operations for this exercise.) After that, you want to select the same data again, ensuring nothing has changed.

-- As this is critical, you think it is better if nobody can change anything in the customers table until you finish your analysis. In doing this, you prevent non-repeatable reads.


-- Set the appropriate isolation level
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

-- Begin a transaction
BEGIN TRAN

SELECT * FROM customers;

-- some mathematical operations, don't care about them...

SELECT * FROM customers;

-- Commit the transaction
COMMIT TRAN



-- Prevent phantom reads in a table
-- Today you have to analyze the data of every customer of your bank. As this information is very important, you think about locking the complete customers table, so that nobody will be able to change anything in this table. In doing this, you prevent phantom reads.

-- You prepare a script to select that information, and with the result of this selection, you need to process some mathematical operations. (We won't focus on these operations for this exercise.) After that, you want to select the same data again, ensuring nothing has changed.


-- Set the appropriate isolation level
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

-- Begin a transaction
BEGIN TRAN

SELECT * FROM customers;

-- After some mathematical operations, we selected information from the customers table.
SELECT * FROM customers;

-- Commit the transaction
COMMIT TRAN


-- Prevent phantom reads just in some rows
-- You need to analyze some data about your bank customers with the customer_id between 1 and 10. You only want to lock the rows of the customers table with the customer_id between 1 and 10. In doing this, you guarantee nobody will be able to change these rows, and you allow other transactions to work with the rest of the table.

-- You need to select the customers and execute some mathematical operations again. (We won't focus either on these operations for this exercise.) After that, you want to select the customers with the customer_id between 1 and 10 again, ensuring nothing has changed.

-- How can you prepare the script?


-- Set the appropriate isolation level
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

-- Begin a transaction
BEGIN TRAN

-- Select customer_id between 1 and 10
SELECT * 
FROM customers
WHERE customer_id BETWEEN 1 AND 10;

-- After completing some mathematical operation, select customer_id between 1 and 10
SELECT * 
FROM customers
WHERE customer_id BETWEEN 1 AND 10;

-- Commit the transaction
COMMIT TRAN



-- Avoid being blocked
-- You are trying to select every movement of account 1 from the transactions table. When selecting that information, you are blocked by another transaction, and the result doesn't output. Your database is configured under the READ COMMITTED isolation level.

-- Can you change your select query to get the information right now without changing the isolation level? In doing this you can read the uncommitted data from the transactions table.


SELECT *
	-- Avoid being blocked
	FROM transactions WITH (NOLOCK)
WHERE account_id = 1


