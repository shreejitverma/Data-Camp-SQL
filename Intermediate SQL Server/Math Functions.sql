-- One
-- of the first steps in data analysis is examining data through aggregations. This chapter explores how to
-- create aggregations in SQL Server, a common first step in data exploration. You will also clean missing data and categorize data into bins
-- with CASE statements.

-- Calculating the total
-- In this chapter, you will
-- use the
-- shipments data. The Shipments table has several columns such
-- as:

-- MixDesc:
-- the concrete type
-- Quantity:
-- the amount of concrete shipped
-- In this exercise, your objective is to calculate the total quantity for each type of concrete used.

-- Write a query that returns an aggregation 
___ MixDesc, ___
FROM Shipments
-- Group by the relevant column
___

-- Counting the number of rows
-- In this exercise, you will calculate the number of orders for each concrete type. Since each row represents one order, all you need to is count the number of rows for each type of MixDesc.

-- Count the number of rows by MixDesc
SELECT MixDesc, ___
FROM Shipments
GROUP BY ___

-- Counting the number
-- of days between dates
-- In this exercise, you will calculate the difference between the order date and ship date.

-- Return the difference in OrderDate and ShipDate
SELECT OrderDate, ShipDate,
    ___(___, OrderDate, ShipDate) AS Duration
FROM Shipments


-- Rounding numbers
-- Sometimes, you only
-- care about the whole dollar amount and want to ignore the decimal values of the cost. In this exercise, you will round the cost to the nearest dollar.

-- Round Cost to the nearest dollar
SELECT Cost,
    ROUND(Cost, 0) AS RoundedCost
FROM Shipments

-- Exercise
-- Truncating
-- numbers
-- Since rounding can sometimes be misleading, i.e., $16.8 becomes $17
-- while $16.4 remains $16, you may want to
-- truncate the values after the decimal instead of rounding them. When you
-- truncate the numbers, both $16.8 and $16.4 remain $16. In this exercise, you will do just that,
-- truncate the Cost column to a whole number.

-- Truncate cost to whole number
SELECT Cost,
    ROUND(Cost, 0, 1) AS TruncateCost
FROM Shipments

-- Calculating the absolute
-- value
-- The Shipments table contains some bad data. There was a problem
-- with the scales, and the weights show up as negative numbers. In this exercise, you will write a query to convert all negative weights to positive weights.

-- Return the absolute value of DeliveryWeight
SELECT DeliveryWeight,
    ABS(DeliveryWeight) AS AbsoluteValue
FROM Shipments

-- Calculating squares
-- and square roots
-- It's time for you to practice calculating squares and square roots of columns.

-- Return the square and square root of WeightValue
SELECT WeightValue,
    SQUARE(WeightValue) AS WeightSquare,
    SQRT(WeightValue) AS WeightSqrt
FROM Shipments