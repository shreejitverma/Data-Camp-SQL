-- Herein, you
-- 'll learn how to use important SQL Server aggregate functions such as SUM, COUNT, MIN, MAX, and AVG. Following that, you'll learn how to manipulate text fields. To round out the chapter, you'll power up your queries using GROUP BY and HAVING, which will enable you to perform more meaningful aggregations.
-- Summing
-- Summing and counting are key ways of aggregating data, regardless of whether you are using a database, manipulating a spreadsheet, or using a programming language such as Python or R. Let's see how to do it in T-SQL using the grid table from Chapter 1.

-- You'll start by obtaining overall sums, focusing specifically on the 'MRO' region.

-- Sum the demand_loss_mw column
SELECT
    SUM(demand_loss_mw) AS MRO_demand_loss
FROM
    grid
WHERE
  -- demand_loss_mw should not contain NULL values
  demand_loss_mw IS NOT NULL
    -- and nerc_region should be 'MRO';
    AND nerc_region = 'MRO';

-- Counting
-- Having explored the 'MRO' region, let's now explore the 'RFC' region in more detail while learning how to use the COUNT aggregate function.

-- Obtain a count of 'grid_id'
SELECT
    COUNT('grid_id') AS grid_total
FROM
    grid;

--     MIN, MAX
-- and AVG
-- Along
-- with summing and counting, you'll frequently need to find the minimum, maximum, and average of column values. Thankfully, T-SQL has functions you can use to make the task easier!

-- Find the minimum number of affected customers
SELECT
    MIN(affected_customers) AS min_affected_customers
FROM
    grid
-- Only retrieve rows where demand_loss_mw has a value
WHERE
  demand_loss_mw IS NOT NULL;


--   LEN'gth of a string
-- Knowing the length of a string is key to being able to manipulate it further using other functions, so what better way to start the lesson?

-- Calculate the length of the description column
SELECT
    LEN (description) AS description_length
FROM
    grid;


--     Left and right
-- We can retrieve portions of a string from either the start of the string, using LEFT, or working back from the end of the string, using RIGHT.

-- Select the first 25 characters from the left of the description column
SELECT
    LEFT(description, 25) AS first_25_left
FROM
    grid;

-- Stuck in the middle with you
-- You might be fortunate, and find that the interesting parts of your strings are at either end. However, chances are, you'll want to retrieve characters from somewhere around the middle. Let's see how to use RIGHT, LEN, CHARINDEX AND SUBSTRING to extract the interior portion of a text string. The description column can contain multiple reasons for power outages in each row. We want to extract any additional causes of outage whenever Weather appears in the description column.

-- Complete the query to find `Weather` within the description column
SELECT
    description,
    CHARINDEX('Weather', description)
FROM
    grid
WHERE description LIKE '%Weather%';

-- GROUP BY
-- In an earlier exercise, you wrote a separate WHERE query to determine the amount of demand lost for a specific region. We wouldn't want to have to write individual queries for every region. Fortunately,you don't have to write individual queries for every region.
-- With GROUP BY, you can obtain a sum of all the unique values for your chosen column, all at once.

-- You'll return to the grid table here and calculate the total lost demand for all regions.
-- Select the region column
SELECT
    nerc_region,
    -- Sum the demand_loss_mw column
    SUM(demand_loss_mw) AS demand_loss
FROM
    grid
-- Exclude NULL values of demand_loss
WHERE 
  demand_loss_mw IS NOT NULL
-- Group the results by nerc_region
GROUP BY
  nerc_region
-- Order the results in descending order of demand_loss
ORDER BY 
  demand_loss DESC;

--   Having
-- WHERE is used to filter rows before any grouping occurs. Once you have performed a grouping operation, you may want to further restrict the number of rows returned. This is a job for HAVING. In this exercise, you will modify an existing query to use HAVING, so that only those results with a sum of over 10000 are returned.

SELECT
    nerc_region,
    SUM (demand_loss_mw) AS demand_loss
FROM
    grid
-- Remove the WHERE clause
WHERE demand_loss_mw  IS NOT NULL
GROUP BY 
  nerc_region
-- Enter a new HAVING clause so that the sum of demand_loss_mw is greater than 10000
HAVING 
  SUM(demand_loss_mw) > 10000
ORDER BY 
  demand_loss DESC;

--   Grouping together
-- In this final exercise, you will combine GROUP BY
-- with aggregate functions such as MIN that you've seen earlier in this chapter.

-- To conclude this chapter, we'll
-- return to the eurovision table from the first chapter.

-- Retrieve the minimum and maximum place values
SELECT
    MIN(place) AS min_place,
    MAX(place) AS max_place,
    -- Retrieve the minimum and maximum points values
    MIN(points) AS min_points,
    MAX(points) AS max_points
FROM
    eurovision;


    