-- Learning how
-- to count and
-- add
-- In this exercise, you will get familiar
-- with the function used for counting rows and the one that sums up values.

-- You will
-- select information
-- from the voters
-- table and will calculate the number of female and male voters and the total number of votes for these groups.

-- Remember, for applying aggregate functions on groups of data, you need to
-- use the
-- GROUP BY statement.

SELECT
    gender,
    -- Count the number of voters for each group
    COUNT(customer_id) AS voters,
    -- Calculate the total number of votes per group
    SUM(total_votes) AS total_votes
FROM voters
GROUP BY gender;

-- Accessing values from the next row
-- With the LEAD() function, you can access data from a subsequent row in the same query, without using the GROUP BY statement. This way, you can easily compare values from an ordered list.

-- This is the syntax: LEAD(numeric_expression) OVER ([PARTITION BY column] ORDER BY column)

-- In this exercise, you will get familiar with comparing values from the current row with values from the following row.

-- You will select information about the voters from France and arrange the results by total votes, in ascending order. The purpose is to analyze how the number of votes from each voter compares to the number of votes recorded for the next person in the list.

SELECT
    first_name,
    last_name,
    total_votes AS votes,
    -- Select the number of votes of the next voter
    ___(___)
OVER (___ total_votes) AS votes_next_voter,
    -- Calculate the difference between the number of votes
	LEAD
(___) ___
(ORDER BY ___) - total_votes AS votes_diff
FROM voters
WHERE country = 'France'
ORDER BY total_votes;

-- Accessing
-- values from the previous row
-- By using the LAG
-- () function in a query, you can access rows previous to the current one.

-- This is the
-- syntax:
-- LAG
-- (numeric_expression) OVER
-- ([PARTITION BY column] ORDER BY column)

-- In this exercise, you will
-- use this
-- function in your query. You will analyze the ratings of the chocolate bars produced by a company called "Fruition".

-- This company produces chocolate
-- with cocoa coming from different areas of the world.

-- You want to check
-- if there is a correlation between the percentage of cocoa and the score received, for the bars coming from the same location. For this, you will compare the cocoa percentage of each bar
-- with the percentage of the bar that received the previous rating. Then, you will calculate the difference between these values and interpret the results.

SELECT
    broad_bean_origin AS bean_origin,
    rating,
    cocoa_percent,
    -- Retrieve the cocoa % of the bar with the previous rating
    LAG(cocoa_percent) 
		OVER(PARTITION BY broad_bean_origin ORDER BY rating) AS percent_lower_rating
FROM ratings
WHERE company = 'Fruition'
ORDER BY broad_bean_origin, rating ASC;

-- Getting the first
-- and last value
-- The analytical functions that
-- return the
-- first or last value from an ordered list prove to be very helpful in queries. In this exercise, you will get familiar
-- with them. The syntax
-- is:

-- FIRST_VALUE
-- (numeric_expression) OVER
-- ([PARTITION BY column] ORDER BY column ROW_or_RANGE frame)

-- LAST_VALUE
-- (numeric_expression) OVER
-- ([PARTITION BY column] ORDER BY column ROW_or_RANGE frame)

-- You will write a query to retrieve all the voters from Spain and the USA. Then, you will
-- add in your query some commands for retrieving the birth date of the youngest and the oldest voter from each country. You want to see these values on each row, to be able to compare them
-- with the birth date of each voter.

SELECT
    first_name + ' ' + last_name AS name,
    country,
    birthdate,
    -- Retrieve the birthdate of the oldest voter per country
    FIRST_VALUE(birthdate) 
	OVER (PARTITION BY country ORDER BY birthdate) AS oldest_voter,
    -- Retrieve the birthdate of the youngest voter per country
    LAST_VALUE(birthdate) 
		OVER (PARTITION BY country ORDER BY birthdate ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
				) AS youngest_voter
FROM voters
WHERE country IN ('Spain', 'USA');

-- Extracting the sign
-- and the absolute value
-- In some situations, you may need to
-- use mathematical
-- functions in your database development. After complex calculations, you may need to check the sign of an expression or its absolute value. The functions provided by SQL Server for these tasks
-- are:

-- ABS
-- (expression)
-- SIGN
-- (expression)
-- In this exercise, you will work
-- with the following
-- variables:

-- DECLARE @number1 DECIMAL(18,2) = -5.4;
-- DECLARE @number2 DECIMAL(18,2) = 7.89;
-- DECLARE @number3 DECIMAL(18,2) = 13.2;
-- DECLARE @number4 DECIMAL(18,2) = 0.003;
-- The @result variable stores the result of the following
-- calculation:
-- @number1 * @number2 - @number3 - @number4.

-- You will calculate the absolute value and the sign of this expression.

DECLARE @number1 DECIMAL(18,2) = -5.4;
DECLARE @number2 DECIMAL(18,2) = 7.89;
DECLARE @number3 DECIMAL(18,2) = 13.2;
DECLARE @number4 DECIMAL(18,2) = 0.003;

DECLARE @result DECIMAL(18,2) = @number1 * @number2 - @number3 - @number4;
SELECT
    @result AS result,
    -- Show the absolute value of the result
    ABS(@result) AS abs_result;

--     Rounding numbers
-- Sometimes
-- in your database development, you may need to round the results of a calculation. There are three functions you can
-- use for
-- this:

-- CEILING
-- (expression): rounds-up to the nearest integer value
-- FLOOR
-- (expression): rounds-down to the nearest integer value
-- ROUND
-- (expression, length): rounds the expression to the specified length.
-- In this exercise, you will get familiar
-- with the rounding functions, by applying them on a query based on the ratings table.

SELECT
    rating,
    -- Round-up the rating to an integer value
    CEILING(rating) AS round_up
FROM ratings;

-- Working with exponential functions
-- The exponential functions are useful when you need to perform calculations in the database. For databases storing real estate information, for example, you may need to calculate areas. In this case, these functions may come in handy:

-- POWER(number, power): raises the number to the specified power
-- SQUARE(number): raises the number to the power of 2
-- Or, if you need to calculate the distance between two cities, whose coordinates are known, you could use this function:

-- SQRT(number): calculates the square root of a positive number.
-- In this exercise, you will play with the exponential functions and analyze the values they return.

DECLARE @number DECIMAL(4, 2) = 4.5;
DECLARE @power INT = 4;

SELECT
    @number AS number,
    @power AS power,
    -- Raise the @number to the @power
    POWER(@number, @power) AS number_to_power,
    -- Calculate the square of the @number
    SQUARE(@number) num_squared,
    -- Calculate the square root of the @number
    SQRT(@number) num_square_root;

--     Manipulating numeric data
-- In this exercise, you are going to use some common SQL Server functions to manipulate numeric data.

-- You are going to use the ratings table, which stores information about each company that has been rated, their different cocoa beans and the rating per bean.

-- You are going to find out information like the highest, lowest, average score received by each company (using functions like MAX(), MIN(), AVG()). Then, you will use some rounding functions to present this data with fewer decimals (ROUND(), CEILING(), FLOOR()).

SELECT
    company,
    -- Select the number of cocoa flavors for each company
    COUNT(*) AS flavors,
    -- Select the minimum, maximum and average rating
    MIN(rating) AS lowest_score,
    MAX(rating) AS highest_score,
    AVG(rating) AS avg_score
FROM ratings
GROUP BY company
ORDER BY flavors DESC;