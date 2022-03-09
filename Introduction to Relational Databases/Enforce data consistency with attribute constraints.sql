-- Conforming with data types
-- For demonstration purposes, I created a fictional database table that only holds three records. The columns have the data types date, integer, and text, respectively.

-- CREATE TABLE transactions (
--  transaction_date date, 
--  amount integer,
--  fee text
-- );
-- Have a look at the contents of the transactions table.

-- The transaction_date accepts date values. According to the PostgreSQL documentation, it accepts values in the form of YYYY-MM-DD, DD/MM/YY, and so forth.

-- Both columns amount and fee appear to be numeric, however, the latter is modeled as text – which you will account for in the next exercise.

-- Let's add a record to the table
INSERT INTO transactions
    (transaction_date, amount, fee)
VALUES
    ('2018-09-24', 5454, '30');

-- Doublecheck the contents
SELECT *
FROM transactions;

-- Type CASTs
-- In the video, you saw that type casts are a possible solution for data type issues.
-- If you know that a certain column stores numbers as text, you can cast the column to a numeric form, i.e. to integer.

-- SELECT CAST(some_column AS integer)
-- FROM table;
-- Now, the some_column column is temporarily represented as integer instead of text, meaning that you can perform numeric calculations on the column.

    -- Calculate the net amount as amount + fee
SELECT transaction_date, amount+ CAST(fee AS integer) AS net_amount
FROM transactions;

-- Change types
-- with
-- ALTER COLUMN
-- The syntax for changing the data type of a column is straightforward. The following code changes the data type of the column_name column in table_name to varchar
-- (10):

-- ALTER TABLE table_name
-- ALTER COLUMN column_name
-- TYPE
-- varchar
-- (10)
-- Now it's time to start adding constraints to your database.
-- Select the university_shortname column
SELECT DISTINCT(university_shortname)
FROM professors;

-- Convert types USING
-- a function
-- If you don't want to reserve too much space for a certain varchar column, you can truncate the values before converting its type.

-- For this, you can use the following syntax:

-- ALTER TABLE table_name
-- ALTER COLUMN column_name
-- TYPE varchar(x)
-- USING SUBSTRING(column_name FROM 1 FOR x)
-- You should read it like this: Because you want to reserve only x characters for column_name, you have to retain a SUBSTRING of every value, i.e. the first x characters of it, and throw away the rest. This way, the values will fit the varchar(x) requirement.

-- Convert the values in firstname to a max. of 16 characters
ALTER TABLE professors 
ALTER COLUMN firstname 
TYPE varchar(16)
USING SUBSTRING(firstname FROM 1 FOR 16)

-- Disallow NULL
-- values
-- with
-- SET
-- NOT NULL
-- The professors table is almost ready now. However, it still allows for NULLs to be entered. Although some information might be missing about some professors, there's certainly columns that always need to be specified.

-- Disallow NULL values in firstname
ALTER TABLE professors 
ALTER COLUMN firstname
SET
NOT NULL;

-- Make your columns
-- UNIQUE
-- with
-- ADD CONSTRAINT
-- As seen in the video, you
-- add the UNIQUE keyword after the column_name that should be unique. This, of course, only works for new
-- tables:

-- CREATE TABLE table_name
-- (
--     column_name UNIQUE
-- );
-- If you want to
-- add a unique constraint to an existing table, you do it like
-- that:

-- ALTER TABLE table_name
-- ADD CONSTRAINT some_name UNIQUE(column_name);
-- Note that this is different from the
-- ALTER COLUMN syntax for the not-null constraint. Also, you have to give the constraint a name some_name.

-- Make universities.university_shortname unique
ALTER TABLE universities
ADD CONSTRAINT university_shortname_unq UNIQUE(university_shortname);

-- Get to know
-- SELECT COUNT
-- DISTINCT
-- Your database doesn't have any defined keys so far, and you don't know which columns or combinations of columns are suited as keys.

-- There's a simple way of finding out whether a certain column (or a combination) contains only unique values – and thus identifies the records in the table.

-- You already know the SELECT DISTINCT query from the first chapter. Now you just have to wrap everything within the COUNT() function and PostgreSQL will return the number of unique rows for the given columns:

-- SELECT COUNT(DISTINCT(column_a, column_b, ...))
-- FROM table;

-- Count the number of rows in universities
SELECT COUNT(*)
FROM universities;

