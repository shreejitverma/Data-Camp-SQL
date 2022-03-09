
-- Sub-queries and presence or absence!!
-- This chapter is an introduction to sub-queries and their potential impacts on query performance. It also examines the different methods used to determine if the data in one table is present, or absent, in a related table.



-- Uncorrelated sub-query
-- A sub-query is another query within a query. The sub-query returns its results to an outer query to be processed.

-- You want a query that returns the region and countries that have experienced earthquakes centered at a depth of 400km or deeper. Your query will use the Earthquakes table in the sub-query, and Nations table in the outer query.


SELECT UNStatisticalRegion,
       CountryName 
FROM Nations
WHERE Code2 -- Country code for outer query 
         IN (SELECT Country -- Country code for sub-query
             FROM Earthquakes
             WHERE depth >= 400 ) -- Depth filter
ORDER BY UNStatisticalRegion;


-- Correlated sub-query
-- Sub-queries are used to retrieve information from another table, or query, that is separate to the main query.

-- A friend is working on a project looking at earthquake hazards around the world. She requires a table that lists all countries, their continent and the average magnitude earthquake by country. This query will need to access data from the Nations and Earthquakes tables.


SELECT UNContinentRegion,
       CountryName, 
        (SELECT AVG(magnitude) -- Add average magnitude
        FROM Earthquakes e 
         	  -- Add country code reference
        WHERE n.Code2 = e.Country) AS AverageMagnitude 
FROM Nations n
ORDER BY UNContinentRegion DESC, 
         AverageMagnitude DESC;



--          Sub-query vs INNER JOIN
-- Often the results from a correlated sub-query can be replicated using an INNER JOIN. Depending on what your requirements are, using an INNER JOIN may be more efficient because it only makes one pass through the data whereas the correlated sub-query must execute for each row in the outer query.

-- You want to find out the 2017 population of the biggest city for every country in the world. You can get this information from the Earthquakes database with the Nations table as the outer query and Cities table in the sub-query.

-- You will first create this query as a correlated sub-query then rewrite it using an INNER JOIN.


SELECT
	n.CountryName,
	 (SELECT MAX(c.Pop2017) -- Add 2017 population column
	 FROM Cities AS c 
                       -- Outer query country code column
	 WHERE c.CountryCode = n.Code2) AS BiggestCity
FROM Nations AS n; -- Outer query table



-- INTERSECT
-- INTERSECT is one of the easier and more intuitive methods used to check if data in one table is present in another.

-- You want to know which, if any, country capitals are listed as the nearest city to recorded earthquakes. You can get this information by comparing the Nations table with the Earthquakes table.



SELECT Capital
FROM Nations -- Table with capital cities

INTERSECT -- Add the operator to compare the two queries

SELECT NearestPop -- Add the city name column
FROM Earthquakes;




-- EXCEPT
-- EXCEPT does the opposite of INTERSECT. It is used to check if data, present in one table, is absent in another.

-- You want to know which countries have no recorded earthquakes. You can get this information by comparing the Nations table with the Earthquakes table.


SELECT Code2 -- Add the country code column
FROM Nations

EXCEPT -- Add the operator to compare the two queries

SELECT Country 
FROM Earthquakes; -- Table with country codes



-- Interrogating with INTERSECT
-- INTERSECT and EXCEPT are very useful for data interrogation.

-- The Earthquakes and NBA Season 2017-2018 databases both contain information on countries and cities. You are interested to know which countries are represented by players in the 2017-2018 NBA season and you believe you can get the results you require by querying the relevant tables across these two databases.

-- Use the INTERSECT operator between queries, but be careful and think about the results. Although both tables contain a country name column to compare, these are separate databases and the data may be stored differently.


SELECT CountryName 
FROM Nations -- Table from Earthquakes database

INTERSECT -- Operator for the intersect between tables

SELECT Country
FROM Players; -- Table from NBA Season 2017-2018 database



-- IN and EXISTS
-- You want to know which, if any, country capitals are listed as the nearest city to recorded earthquakes. You can get this information using INTERSECT and comparing the Nations table with the Earthquakes table. However, INTERSECT requires that the number and order of columns in the SELECT statements must be the same between queries and you would like to include additional columns from the outer query in the results.

-- You attempt two queries, each with a different operator that gives you the results you require.


-- First attempt
SELECT CountryName,
       Pop2017, -- 2017 country population
	   Capital, -- Capital city	   
       WorldBankRegion
FROM Nations
WHERE Capital IN -- Add the operator to compare queries
        (SELECT NearestPop 
	     FROM Earthquakes);



--          NOT IN and NOT EXISTS
-- NOT IN and NOT EXISTS do the opposite of IN and EXISTS respectively. They are used to check if the data present in one table is absent in another.

-- You are interested to know if there are some countries in the Nations table that do not appear in the Cities table. There may be many reasons for this. For example, all the city populations from a country may be too small to be listed, or there may be no city data for a particular country at the time the data was compiled.

-- You will compare the queries using country codes.



SELECT WorldBankRegion,
       CountryName
FROM Nations
WHERE Code2 NOT IN -- Add the operator to compare queries
	(SELECT CountryCode -- Country code column
	 FROM Cities);




--      NOT IN with IS NOT NULL
-- You want to know which country capitals have never been the closest city to recorded earthquakes. You decide to use NOT IN to compare Capital from the Nations table, in the outer query, with NearestPop, from the Earthquakes table, in a sub-query.



SELECT WorldBankRegion,
       CountryName,
       Capital -- Capital city name column
FROM Nations
WHERE Capital NOT IN
	(SELECT NearestPop -- City name column
     FROM Earthquakes);





--      INNER JOIN
-- An insurance company that specializes in sports franchises has asked you to assess the geological hazards of cities hosting NBA teams. You believe you can get this information by querying the Teams and Earthquakes tables across the Earthquakes and NBA Season 2017-2018 databases respectively. Your initial query will use EXISTS to compare tables. The second query will use a more appropriate operator.



-- Initial query
SELECT TeamName,
       TeamCode,
	   City
FROM Teams AS t -- Add table
WHERE EXISTS -- Operator to compare queries
      (SELECT 1 
	  FROM Earthquakes AS e -- Add table
	  WHERE t.City = e.NearestPop);



      Exclusive LEFT OUTER JOIN
-- An exclusive LEFT OUTER JOIN can be used to check for the presence of data in one table that is absent in another table. To create an exclusive LEFT OUTER JOIN the right query requires an IS NULL filter condition on the joining column.

-- Your sales manager is concerned that orders from French customers are declining. He wants you to compile a list of French customers that have not placed any orders so he can contact them.


-- First attempt
SELECT c.CustomerID,
       c.CompanyName,
	   c.ContactName,
	   c.ContactTitle,
	   c.Phone 
FROM Customers c
LEFT OUTER JOIN Orders o -- Joining operator
	ON c.CustomerID = o.CustomerID -- Joining columns
WHERE c.Country = 'France';




