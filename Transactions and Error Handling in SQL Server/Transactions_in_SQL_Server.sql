-- Transactions in SQL Server!!
-- In this chapter, you will be introduced to the concept of transactions. You will discover how to commit and rollback them. You will finish by learning how to return the number of transactions and their state.


-- Correcting a transaction
-- Today you have been given a script which is not correct. It was written by a colleague of yours who didn't know how to finish it. Your colleague tried to transfer $100 from account 1 to account 5, and register those movements into the transactions table.

-- You immediately realize there are several errors. SQL Server doesn't recognize the transaction statements it uses.

-- Can you correct the script?


BEGIN TRY  
	BEGIN TRAN;
		UPDATE accounts SET current_balance = current_balance - 100 WHERE account_id = 1;
		INSERT INTO transactions VALUES (1, -100, GETDATE());
        
		UPDATE accounts SET current_balance = current_balance + 100 WHERE account_id = 5;
		INSERT INTO transactions VALUES (5, 100, GETDATE());
	COMMIT TRAN;
END TRY
BEGIN CATCH  
	ROLLBACK TRAN;
END CATCH


-- Rolling back a transaction if there is an error
-- On your first day of work, you were given the task of setting up transactions that record when money is transferred in your bank.

-- You want to prepare a simple script where $100 transfers from account_id = 1 and goes to account_id = 5. After that, it registers those movements into the transactions table. You think you have written everything correctly, but as a cautious worker, you prefer to check everything!

-- As a matter of fact, you did make a mistake. Instead of inserting a new transaction for account 5, you did it for account 500, which doesn't exist.

-- To prevent future errors, the script you create should rollback every change if an error occurs. If everything goes correctly, the transaction should be committed.



BEGIN TRY  
	-- Begin the transaction
	BEGIN TRAN;
		UPDATE accounts SET current_balance = current_balance - 100 WHERE account_id = 1;
		INSERT INTO transactions VALUES (1, -100, GETDATE());
        
		UPDATE accounts SET current_balance = current_balance + 100 WHERE account_id = 5;
        -- Correct it
		INSERT INTO transactions VALUES (500, 100, GETDATE());
    -- Commit the transaction
	COMMIT TRAN;    
END TRY
BEGIN CATCH  
	SELECT 'Rolling back the transaction';
    -- Rollback the transaction
	ROLLBACK TRAN;
END CATCH



-- Choosing when to commit or rollback a transaction
-- The bank where you work has decided to give $100 to those accounts with less than $5,000. However, the bank director only wants to give that money if there aren't more than 200 accounts with less than $5,000.

-- You prepare a script to give those $100, and of the multiple ways of doing it, you decide to open a transaction and then update every account with a balance of less than $5,000. After that, you check the number of the rows affected by the update, using the @@ROWCOUNT function. If this number is bigger than 200, you rollback the transaction. Otherwise, you commit it.

-- How do you prepare the script?


-- Begin the transaction
BEGIN TRAN; 
	UPDATE accounts set current_balance = current_balance + 100
		WHERE current_balance < 5000;
	-- Check number of affected rows
	IF @@ROWCOUNT > 200 
		BEGIN 
        	-- Rollback the transaction
			ROLLBACK TRAN; 
			SELECT 'More accounts than expected. Rolling back'; 
		END
	ELSE
		BEGIN 
        	-- Commit the transaction
			COMMIT TRAN; 
			SELECT 'Updates commited'; 
		END



--             Checking @@TRANCOUNT in a TRY...CATCH construct
-- The owner of account 10 has won a raffle and will be awarded $200. You prepare a simple script to add those $200 to the current_balance of account 10. You think you have written everything correctly, but you prefer to check your code.

-- In fact, you made a silly mistake when adding the money: SET current_balance = 'current_balance' + 200. You wrote 'current_balance' as a string, which generates an error.

-- The script you create should rollback every change if an error occurs, checking if there is an open transaction. If everything goes correctly, the transaction should be committed, also checking if there is an open transaction.


BEGIN TRY
	-- Begin the transaction
	BEGIN TRAN;
    	-- Correct the mistake
		UPDATE accounts SET current_balance = current_balance + 200
			WHERE account_id = 10;
    	-- Check if there is a transaction
		IF @@TRANCOUNT > 0     
    		-- Commit the transaction
			COMMIT TRAN;
     
	SELECT * FROM accounts
    	WHERE account_id = 10;      
END TRY
BEGIN CATCH  
    SELECT 'Rolling back the transaction'; 
    -- Check if there is a transaction
    IF @@TRANCOUNT > 0   	
    	-- Rollback the transaction
        ROLLBACK TRAN;
END CATCH



-- Using savepoints
-- Your colleague Anita needs help. She prepared a script that uses savepoints, but it doesn't work. The script marks the first savepoint, savepoint1 and then inserts the data of a customer. Then, the script marks another savepoint, savepoint2, and inserts the data of another customer again. After that, both savepoints are rolled back. Finally, the script marks another savepoint, savepoint3, and inserts the data of another customer.

-- Anita tells you that her script doesn't work because it has some errors, but she doesn't know how to correct them. Can you help her?


BEGIN TRAN;
	-- Mark savepoint1
	SAVE TRAN savepoint1;
	INSERT INTO customers VALUES ('Mark', 'Davis', 'markdavis@mail.com', '555909090');

	-- Mark savepoint2
    SAVE TRAN savepoint2;
	INSERT INTO customers VALUES ('Zack', 'Roberts', 'zackroberts@mail.com', '555919191');

	-- Rollback savepoint2
	ROLLBACK TRAN savepoint2;
    -- Rollback savepoint1
	ROLLBACK TRAN savepoint1;

	-- Mark savepoint3
	SAVE TRAN savepoint3;
	INSERT INTO customers VALUES ('Jeremy', 'Johnsson', 'jeremyjohnsson@mail.com', '555929292');
-- Commit the transaction
COMMIT TRAN;



-- XACT_ABORT and THROW
-- The wealthiest customers of the bank where you work have decided to donate the 0.01% of their current_balance to a non-profit organization. You are in charge of preparing the script to update the customer's accounts, but you have to do it only for those accounts with a current_balance with more than $5,000,000. The director of the bank tells you that if there aren't at least 10 wealthy customers, you shouldn't do this operation, because she wants to interview more customers.

-- You prepare a script, and of the multiple ways of doing it, you decide to use XACT_ABORT in combination with THROW. This way, if the number of affected rows is less than or equal to 10, you can throw an error so that the transaction is rolled back.


-- Use the appropriate setting
SET XACT_ABORT OFF;
-- Begin the transaction
BEGIN TRAN; 
	UPDATE accounts set current_balance = current_balance - current_balance * 0.01 / 100
		WHERE current_balance > 5000000;
	IF @@ROWCOUNT <= 10	
    	-- Throw the error
		THROW 55000, 'Not enough wealthy customers!', 1;
	ELSE		
    	-- Commit the transaction
		COMMIT TRAN; 



--         Doomed transactions
-- You want to insert the data of two new customers into the customer table. You prepare a script controlling that if an error occurs, the transaction rollbacks and you get the message of the error. You want to control it using XACT_ABORT in combination with XACT_STATE.




-- Use the appropriate setting
SET XACT_ABORT OFF;
BEGIN TRY
	BEGIN TRAN;
		INSERT INTO customers VALUES ('Mark', 'Davis', 'markdavis@mail.com', '555909090');
		INSERT INTO customers VALUES ('Dylan', 'Smith', 'dylansmith@mail.com', '555888999');
	COMMIT TRAN;
END TRY
BEGIN CATCH
	-- Check if there is an open transaction
	IF XACT_STATE() <> 0
    	-- Rollback the transaction
		ROLLBACK TRAN;
    -- Select the message of the error
    SELECT ERROR_MESSAGE() AS Error_message;
END CATCH



