-- Query performance tuning !!
-- Students are introduced to how STATISTICS TIME, STATISTICS IO, indexes, and executions plans can be used in SQL Server to help analyze and tune query performance.


-- STATISTICS TIME in queries
-- A friend is writing a training course on how the command STATISTICS TIME can be used to tune query performance and asks for your help to complete a presentation. He requires two queries that return NBA team details where the host city had a 2017 population of more than two million.

-- NBA team details can be queried from the NBA Season 2017-2018 database and city populations can be queried by adding in tables from the Earthquakes database.

-- Each query uses a different filter on the Teams table.

-- Query 1

-- Filters the Teams table using IN and three sub-queries
-- Query 2

-- Filters the Teams table using EXISTS


SET STATISTICS TIME ON -- Turn the time command on


-- STATISTICS IO: Example 1
-- Your sales company has just taken on a new regional manager for Western Europe. He has asked you to provide him daily updates on orders shipped to some key Western Europe capital cities. As this data is time sensitive, you want a robust query that is tuned to return the results as quickly as possible.

-- You initially decide on a query that uses two sub-queries: one in the SELECT statement to get the count of orders and one using a filter condition with an IN operator.

-- You will turn on the STATISTICS IO command to review the page read statistics.

SET STATISTICS IO ON -- Turn the IO command on


-- STATISTICS IO: Example 2
-- In the previous exercise, you were asked you to provide a new regional manager daily updates on orders shipped to Western Europe capital cities. You initially created a query that contained two sub-queries. You decide to do a rewrite and use an INNER JOIN.

-- The STATISTICS IO command is turned on. You will need to turn it off after completing the query.


-- Example 2
SELECT c.CustomerID,
       c.CompanyName,
       COUNT(o.CustomerID)
FROM Customers AS c
INNER JOIN Orders AS o -- Join operator
    ON c.CustomerID = o.CustomerID
WHERE o.ShipCity IN -- Shipping destination column
     ('Berlin','Bern','Bruxelles','Helsinki',
	 'Lisboa','Madrid','Paris','London')
GROUP BY c.CustomerID,
         c.CompanyName;



--          Clustered index
-- Clustered indexes can be added to tables to speed up search operations in queries. You have two copies of the Cities table from the Earthquakes database: one copy has a clustered index on the CountryCode column. The other is not indexed.

-- You have a query on each table with a different filter condition:

-- Query 1

-- Returns all rows where the country is either Russia or China.
-- Query 2

-- Returns all rows where the country is either Jamaica or New Zealand.


-- Query 1
SELECT *
FROM Cities
WHERE CountryCode = 'RU' -- Country code
		OR CountryCode = 'CN' -- Country code



--         Sort operator in execution plans
-- Execution plans can tell us if and where a query used an internal sorting operation. Internal sorting is often required when using an operator in a query that checks for and removes duplicate rows.

-- You are given an execution plan of a query that returns all cities listed in the Earthquakes database. The query appends queries from the Nations and Cities tables. Use the following execution plan to determine if the appending operator used is UNION or UNION ALL


SELECT CityName AS NearCityName,
	   CountryCode
FROM Cities

UNION -- Append queries

SELECT Capital AS NearCityName,
       Code2 AS CountryCode
FROM Nations;


