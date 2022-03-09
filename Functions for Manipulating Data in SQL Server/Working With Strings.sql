-- -- Strings are one
-- -- of the most commonly used data types in databases. It's important to know what you can do with them. In this chapter, you will learn how to manipulate strings, to get the results you want.

-- Calculating the length
-- of a string
-- It is important to know how to calculate the length of the strings stored in a database. You may need to calculate the product
-- with the shortest name or the person
-- with the longest email address.

-- Calculating the length of a string also proves to be useful in data cleansing and validation tasks. For example,
-- if a business rule is that all product codes must have at least 6 characters, you can easily find the ones that are shorter.

-- In SQL Server, you can
-- use the
-- LEN
-- () function for calculating the length of a string of characters.

-- You will
-- use it
-- in this exercise to calculate the location
-- with the longest name from where cocoa beans are used
-- (column broad_bean_origin, from the ratings table).

SELECT TOP 10
    company,
    broad_bean_origin,
    -- Calculate the length of the broad_bean_origin column
    LEN(broad_bean_origin) AS length
FROM ratings
--Order the results based on the new column, descending
ORDER BY length DESC;

-- Looking
-- for a string within a string
-- If you need to check whether an expression exists within a string, you can
-- use the
-- CHARINDEX
-- () function. This function returns the position of the expression you are searching within the string.

-- The syntax
-- is:
-- CHARINDEX
-- (expression_to_find, expression_to_search [, start_location])

-- In this exercise, you are going to
-- use the
-- voters table to search for information about the voters whose names meet several conditions.

SELECT
    first_name,
    last_name,
    email
FROM voters
-- Look for the "dan" expression in the first_name
WHERE CHARINDEX('dan', first_name) > 0;

-- Looking
-- for a pattern within a string
-- If you want to search for a pattern in a string, PATINDEX
-- () is the function you are looking for. This function returns the starting position of the first occurrence of the pattern within the string.

-- The syntax
-- is:
-- PATINDEX
-- ('%pattern%', expression)

-- pattern	match
-- %	any string of zero or more characters
-- _	any single character
-- []	any single character within the range specified in brackets
-- In this exercise, you are going to
-- use the
-- voters table to look at information about the voters whose names follow a specified pattern.

SELECT
    first_name,
    last_name,
    email
FROM voters
-- Look for first names that contain "rr" in the middle
WHERE PATINDEX('%rr%', first_name) > 0;


-- Changing
-- to lowercase and uppercase
-- Most of the time, you can't make changes directly to the data from the database to make it look more user-friendly. However, when you query the data, you can control the aspect of the results, and you can make them easier to read.

-- Working with functions that manipulate string values is easy and gives great results. In this exercise, you will see how easy it is to work with the functions that transform the characters from a string to lowercase or uppercase. The purpose is to create a message mentioning the types of cocoa beans used by each company and their country of origin: The company BONNAT uses beans of type "Criollo", originating from VENEZUELA .

SELECT
    company,
    bean_type,
    broad_bean_origin,
    'The company ' +  company + ' uses beans of type "' + bean_type + '", originating from ' + broad_bean_origin + '.'
FROM ratings
WHERE
    -- The 'broad_bean_origin' should not be unknown
	LOWER(broad_bean_origin) NOT LIKE '%unknown%';


-- Using the beginning or end of a string
-- Sometimes you may need to take only certain parts of a string. If you know that those parts can be found at the beginning or the end of the string, remember that there are built-in functions that can help you with this task.

-- You will use these functions in this exercise. The purpose is to create an alias for each voter from the voters table, as a combination of the first 3 letters from the first name, the last 3 letters from the last name, and the last 2 digits from the birthday.

SELECT
    first_name,
    last_name,
    country,
    -- Select only the first 3 characters from the first name
    LEFT(first_name,3) AS part1
FROM voters;

-- Extracting a substring
-- In this exercise, you will extract parts of a string. You will work with data from the voters table.

-- There is a built-in function that can help you with this task. The parameters required by this function are:

-- the expression from which the substring is extracted;
-- the starting position of the substring
-- and its length.
-- Keep in mind that the position of the first character in a string is 1, not 0. This will help you to correctly calculate the starting position of the substring.

SELECT
    email,
    -- Extract 5 characters from email, starting at position 3
    SUBSTRING(email, 3,5) AS some_letters
FROM voters;

-- Replacing parts
-- of a string
-- Sometimes, you need to replace characters from a string
-- with something else.

-- For example,
-- if a name was inserted in a table
-- with an extra character, you may want to fix the mistake.

-- If a company was acquired and changed its name, you need to replace the old company name
-- with the new name in all documents stored in the database.

-- In this exercise, you will
-- use a
-- built-in function that replaces a part of a string
-- with something else. For using the function correctly, you need to supply the following
-- parameters:

-- the expression
-- the string to be found
-- the replacement string.

SELECT
    first_name,
    last_name,
    email,
    -- Replace "yahoo.com" with "live.com"
    REPLACE(email, 'yahoo.com', 'live.com') AS new_email
FROM voters;

-- Concatenating data
-- Assembling a string from parts is done quite often in SQL Server. You may need to put together information from different columns and send the result as a whole to different applications. In this exercise, you will get familiar with the different options for concatenating data.

-- You will create a message similar to this one: "Chocolate with beans from Belize has a cocoa percentage of 0.6400".

-- The sentence is created by concatenating two string variables with data from the columns bean_origin and cocoa_percent, from the ratings table.

-- For restricting the number of results, the query will select only values for the company called "Ambrosia" and bean_type is not unknown.


DECLARE @string1 NVARCHAR(100) = 'Chocolate with beans from';
DECLARE @string2 NVARCHAR(100) = 'has a cocoa percentage of';

SELECT
    bean_type,
    bean_origin,
    cocoa_percent,
    -- Create a message by concatenating values with "+"
    @string1 + ' ' + bean_origin + ' ' + @string2 + ' ' + CAST(cocoa_percent AS nvarchar) AS message1
FROM ratings
WHERE 
	company = 'Ambrosia'
    AND bean_type <> 'Unknown';

--     Aggregating strings
-- Usually, when we talk about concatenation, we mean putting together values from different columns. A common challenge for database developers is also to concatenate values from multiple rows. This was a task that required writing many lines of code and each developer had a personal implementation.

-- You can now achieve the same results using the STRING_AGG() function.

-- The syntax is: STRING_AGG(expression, separator) [WITHIN GROUP (ORDER BY expression)]

-- In this exercise, you will create a list with the origins of the beans for each of the following companies: 'Bar Au Chocolat', 'Chocolate Con Amor', 'East Van Roasters'.

-- Remember, for STRING_AGG() to work, you need to find a rule for grouping your data and use it in the GROUP BY clause.

SELECT
    -- Create a list with all bean origins, delimited by comma
    STRING_AGG(bean_origin, ',') AS bean_origins
FROM ratings
WHERE company IN ('Bar Au Chocolat', 'Chocolate Con Amor', 'East Van Roasters');

-- Splitting a string
-- into pieces
-- Besides concatenating multiple row values, a common task is to split a string into pieces.

-- Starting
-- with SQL Server 2016, there is a built-in function for achieving this
-- task:
-- STRING_SPLIT
-- (string, separator).

-- This function splits the string into substrings based on the separator and returns a table, each row containing a part of the original string.

-- Remember:
-- because the result of the function is a table, it cannot be used as a column in the
-- SELECT clause;
-- you can only
-- use it
-- in the FROM clause, just like a normal table.

-- In this exercise, you will get familiar
-- with this function.

DECLARE @phrase NVARCHAR(MAX) = 'In the morning I brush my teeth. In the afternoon I take a nap. In the evening I watch TV.'

SELECT value
FROM STRING_SPLIT(@phrase, '.');

-- Applying various string functions on data
-- As you may have noticed, string functions are really useful for manipulating data. SQL Server offers a lot of built-in functions for string manipulation and some of them are quite fun to use. In this exercise, you are going to apply several string functions to the data from the voters table, to show it in a more presentable manner.

-- You will get the chance to use functions like: LEN(), UPPER(), PATINDEX(), CONCAT(), REPLACE() and SUBSTRING().

-- Remember: when searching for patterns within a string, these are the most helpful:

-- pattern	match
-- %	any string of zero or more characters
-- _	any single character
-- []	any single character within the range specified in brackets

SELECT
    first_name,
    last_name,
    birthdate,
    email,
    country
FROM voters
-- Select only voters with a first name less than 5 characters
WHERE LEN(first_name) < 5
    -- Look for the desired pattern in the email address
    AND PATINDEX('j_a%_yahoo.com', email) > 0;


    