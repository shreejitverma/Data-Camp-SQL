-- -- Window Functions
-- In the final
-- chapter of this course, you will work
-- with partitions of data and window functions to calculate several summary stats and see how easy it is to
-- create running totals and compute the mode of numeric columns.

-- Window functions
-- with aggregations
-- (I)
-- To familiarize yourself
-- with the window functions, you will work
-- with the Orders table in this chapter. Recall that using OVER
-- (), you can
-- create a window for the entire table. To
-- create partitions using a specific column, you need to
-- use OVER
-- () along
-- with PARTITION BY.

SELECT OrderID, TerritoryName,
    -- Total price for each partition
    SUM(OrderPrice)
       -- Create the window and partitions
       OVER(PARTITION BY TerritoryName) AS TotalPrice
FROM Orders

-- Window functions
-- with aggregations
-- (II)
-- In the last exercise, you calculated the sum of all orders for each territory. In this exercise, you will calculate the number of orders in each territory.

SELECT OrderID, TerritoryName,
    -- Number of rows per partition
    COUNT(*)
       -- Create the window and partitions
       OVER(PARTITION BY TerritoryName) AS TotalOrders
FROM Orders

-- First value
-- in a window
-- Suppose you want to figure out the first OrderDate in each territory or the last one. How would you do that? You can
-- use the
-- window functions FIRST_VALUE
-- () and LAST_VALUE
-- (), respectively! Here are the
-- steps:

-- First,
-- create partitions for each territory
-- Then, order by OrderDate
-- Finally,
-- use the
-- FIRST_VALUE
-- () and/or LAST_VALUE
-- () functions as per your requirement

SELECT TerritoryName, OrderDate,
    -- Select the first value in each partition
    FIRST_VALUE(OrderDate) 
       -- Create the partitions and arrange the rows
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS FirstOrder
FROM Orders

-- Previous
-- and next values
-- What
-- if you want to shift the values in a column by one row up or down? You can
-- use the
-- exact same steps as in the previous exercise but
-- with two new functions, LEAD
-- (), for the next value, and LAG
-- (), for the previous value. So you follow these
-- steps:

-- First,
-- create partitions
-- Then, order by a certain column
-- Finally,
-- use the
-- LEAD
-- () and/or LAG
-- () functions as per your requirement


SELECT TerritoryName, OrderDate,
    -- Specify the previous OrderDate in the window
    LAG(OrderDate) 
       -- Over the window, partition by territory & order by order date
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS PreviousOrder,
    -- Specify the next OrderDate in the window
    LEAD(OrderDate) 
       -- Create the partitions and arrange the rows
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS NextOrder
FROM Orders

-- Creating running totals
-- You usually don't have to use ORDER BY when using aggregations, but if you want to create running totals, you should arrange your rows! In this exercise, you will create a running total of OrderPrice.

SELECT TerritoryName, OrderDate,
    -- Create a running total
    SUM(OrderPrice) 
       -- Create the partitions and arrange the rows
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS TerritoryTotal
FROM Orders

-- Assigning row numbers
-- Records in T-SQL are inherently unordered. Although in certain situations, you may want to assign row numbers for reference. In this exercise, you will do just that.
SELECT TerritoryName, OrderDate,
    -- Assign a row number
    ROW_NUMBER()
       -- Create the partitions and arrange the rows
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS OrderCount
FROM Orders

-- Calculating standard deviation
-- Calculating the standard deviation is quite common when dealing
-- with numeric columns. In this exercise, you will calculate the running standard deviation, similar to the running total you calculated in the previous lesson.

SELECT OrderDate, TerritoryName,
    -- Calculate the standard deviation
    STDEV(OrderPrice)
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS StdDevPrice
FROM Orders

Calculating
mode
(I)
Unfortunately, there is no function to calculate the mode, the most recurring value in a column. To calculate the
mode:

-- First,
-- create a CTE containing an ordered count of values using ROW_NUMBER
-- ()
-- Write a query using the CTE to pick the value
-- with the highest row number
-- In this exercise, you will write the CTE needed to calculate the mode of OrderPrice.
-- Create a CTE Called ModePrice which contains two columns
WITH
    ModePrice (OrderPrice, UnitPriceFrequency)
    AS
    (
        SELECT OrderPrice,
            ROW_NUMBER() 
	OVER(PARTITION BY OrderPrice ORDER BY OrderPrice) AS UnitPriceFrequency
        FROM Orders
    )

-- Select everything from the CTE
SELECT *
FROM ModePrice

-- Calculating mode
-- (II)
-- In the last exercise, you created a CTE which assigned row numbers to each unique value in OrderPrice. All you need to do now is to find the OrderPrice
-- with the highest row number.

-- CTE from the previous exercise
WITH
    ModePrice
(OrderPrice, UnitPriceFrequency)
    AS
(
        SELECT OrderPrice,
    ROW_NUMBER() 
    OVER (PARTITION BY OrderPrice ORDER BY OrderPrice) AS UnitPriceFrequency
FROM Orders
    )

-- Select the order price from the CTE
SELECT OrderPrice AS ModeOrderPrice
FROM ModePrice
-- Select the maximum UnitPriceFrequency from the CTE
WHERE UnitPriceFrequency IN (SELECT MAX(UnitPriceFrequency)
FROM ModePrice)

