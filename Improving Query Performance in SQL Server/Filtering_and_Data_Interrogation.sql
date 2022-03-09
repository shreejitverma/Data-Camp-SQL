-- Filtering and Data Interrogation !!
-- This chapter introduces filtering with WHERE and HAVING and some best practices for how (and how not) to use these keywords. Next, it explains the methods used to interrogate data and the effects these may have on performance. Finally, the chapter goes over the roles of DISTINCT() and UNION in removing duplicates and their potential effects on performance.


-- Column does not exist
-- When using WHERE as a filter condition, it is important to think about the processing order in the query. In this exercise, you want a query that returns NBA players with average total rebounds of 12 or more per game. The following formula calculates average total rebounds from the PlayerStats table;

-- AverageTotalRebounds=(DefensiveRebounds+OffensiveRebounds)GamesPlayed
-- The first query in Step 1 returns an error. Select Run Code to view the error. The second query, in Step 2, will give you the results you want, without error, by using a sub-query.

-- Note that GamesPlayed is CAST AS numeric to ensure we get decimal points in our output, as opposed to whole numbers.


-- First query
SELECT PlayerName, 
    Team, 
    Position,
    (DRebound+ORebound)/CAST(GamesPlayed AS INT) AS AvgRebounds
FROM PlayerStats
WHERE AvgRebounds >= 12;




-- Functions in WHERE
-- You want to know which players from the 2017-2018 NBA season went to college in Louisiana. You ask a friend to make the query for you. It looks like he overcomplicated the WHERE filter condition by unnecessarily applying string functions and, also, it does not give you precisely what you want because he forgot how to spell Louisiana. You will simplify his query to return exactly what you require.


SELECT PlayerName, 
      Country,
      College, 
      DraftYear, 
      DraftNumber 
FROM Players 
/*WHERE UPPER(LEFT(College,5)) LIKE 'LOU%'; */
                   -- Add the new wildcard filter
WHERE College LIKE 'Louisiana%'



-- Filtering with WHERE and HAVING
-- WHERE and HAVING can be used as filters in the same query. But how we use them, where we use them and what we use them for is quite different.

-- You want a query that returns the total points contribution of a teams Power Forwards where their total points contribution is greater than 3000.



SELECT Team, 
	SUM(TotalPoints) AS TotalPFPoints
FROM PlayerStats
-- Filter for only rows with power forwards
WHERE Position = 'PF'
GROUP BY Team
-- Filter for total points greater than 3000
HAVING SUM(TotalPoints) > 3000;



-- SELECT what you need
-- Your friend is a seismologist, and she is doing a study on earthquakes in South East Asia. She asks you for a query that returns coordinate locations, strength, depth and nearest city of all earthquakes in Papua New Guinea and Indonesia.

-- All the information you need is in the Earthquakes table, and your initial interrogation of the data tells you that the column for the country code is Country and that the Codes for Papua New Guinea and Indonesia are PG and ID respectively.


SELECT * -- Select all rows and columns
FROM Earthquakes;



-- Limit the rows with TOP
-- Your seismologist friend that is doing a study on earthquakes in South East Asia has asked you to subset a query that you provided her. She wants two additional queries for earthquakes recorded in Indonesia and Papua New Guinea. The first returning the ten shallowest earthquakes and the second the upper quartile of the strongest earthquakes.


SELECT TOP 10 -- Limit the number of rows to ten
      Latitude,
      Longitude,
	  Magnitude,
	  Depth,
	  NearestPop
FROM Earthquakes
WHERE Country = 'PG'
	OR Country = 'ID'
ORDER BY depth ASC; -- Order results from shallowest to deepest



-- Remove duplicates with DISTINCT()
-- You want to know the closest city to earthquakes with a magnitude of 8 or higher. You can get this information from the Earthquakes table. However, a simple query returns duplicate rows because some cities have experienced more than one magnitude 8 or higher earthquake.

-- You can remove duplicates by using the DISTINCT() clause. Once you have your results, you would like to know how many times each city has experienced an earthquake of magnitude 8 or higher.

-- Note that IS NOT NULL is being used because many earthquakes do not occur near any populated area, thankfully


SELECT NearestPop, -- Add the closest city
		Country 
FROM Earthquakes
WHERE Magnitude >= 8
	AND NearestPop IS NOT NULL
ORDER BY NearestPop;


-- UNION and UNION ALL
-- You want a query that returns all cities listed in the Earthquakes database. It should be an easy query on the Cities table. However, to be sure you get all cities in the database you will append the query to the Nations table to include capital cities as well. You will use UNION to remove any duplicate rows.

-- Out of curiosity, you want to know if there were any duplicate rows. If you do the same query but append with UNION ALL instead, and compare the number of rows returned in each query, UNION ALL will return more rows if there are duplicates.


SELECT CityName AS NearCityName, -- City name column
	   CountryCode
FROM Cities

UNION -- Append queries

SELECT Capital AS NearCityName, -- Nation capital column
       Code2 AS CountryCode
FROM Nations;



