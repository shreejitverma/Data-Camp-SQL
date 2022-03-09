# Introduction, Review and The Order of Things !!
# In this chapter, students will learn how SQL code formatting, commenting, and aliasing is used to make queries easy to read and understand. Students will also be introduced to query processing order in the database versus the order of the SQL syntax in a query.


# Formatting - player BMI
# In this exercise, you are working with a team on a data analytics project, which has been asked to provide some statistics on NBA players to a health care company. You want to create a query that returns the Body Mass Index (BMI) for each player from North America.

# BMI=weight(kg)height(cm)2
# A colleague has passed you a query he was working on:

# select PlayerName, Country,
# round(Weight_kg/SQUARE(Height_cm/100),2) BMI 
# from Players Where Country = 'USA' 
# Or Country = 'Canada'
# order by BMI
# To make some sense of the code, you want to structure and format it in a way that is consistent and easy to read.


SELECT PlayerName, Country,
ROUND(Weight_kg/SQUARE(Height_cm/100),2) BMI
FROM Players WHERE Country = 'USA'
OR Country = 'Canada'
ORDER BY BMI;


# Commenting - player BMI
# Adding comments is a good way to convey what the query is about or information about certain parts of the query.

# The sample code is a query on the Players table that returns player name, country of origin and a calculated Body Mass Index (BMI). The WHERE condition is filtering for only players from North America.

# You will add the following comment.

# Returns the Body Mass Index (BMI) for all North American players from the 2017-2018 NBA season

# Also, you believe that ORDER BY is unnecessary in this query so it will be commented out and a comment added on the same line indicating it is not required.

/*
Return PlayerName, Country and BMI for country that either USA or Canada
From Players
Order by not required
*/
SELECT PlayerName, Country,
    ROUND(Weight_kg/SQUARE(Height_cm/100),2) BMI 
FROM Players 
WHERE Country = 'USA'
    OR Country = 'Canada';





# Commenting - how many Kiwis in the NBA?
# You and a friend would like to know how many New Zealanders (affectionately known as Kiwis) play in the NBA. Your friend attempts to write a query, but it is not very well formatted and contains several errors. You re-write the query, but you want to keep his original for comparison and future reference.

# This exercise requires you to create line comments and comment out blocks of code


-- Your friend's query
--First attempt, contains errors and inconsistent formatting
/*
select PlayerName, p.Country,sum(ps.TotalPoints) 
AS TotalPoints  
FROM PlayerStats ps inner join Players On ps.PlayerName = p.PlayerName
WHERE p.Country = 'New Zeeland'
Group 
by PlayerName, Country
order by Country;
*/


-- Second attempt - errors corrected and formatting fixed


SELECT p.PlayerName, p.Country,
		SUM(ps.TotalPoints) AS TotalPoints  
FROM PlayerStats ps 
INNER JOIN Players p
	ON ps.PlayerName = p.PlayerName
WHERE p.Country = 'New Zealand'
GROUP BY p.PlayerName, p.Country;




# Aliasing - team BMI
# A basketball statistician would like to know the average Body Mass Index (BMI) per NBA team, in particular, any team with an average BMI of 25 or more. To include Team in the query, you will need to join the Players table to the PlayerStats table. The query will require aliasing to:

# Easily identify joined tables and associated columns.
# Identify sub-queries.
# Avoid ambiguity in column names.
# Identify new columns.


SELECT Team, 
   ROUND(AVG(BMI),2) AS AvgTeamBMI -- Alias the new column
FROM PlayerStats AS  ps -- Alias PlayerStats table
INNER JOIN
		(SELECT PlayerName, Country,
			Weight_kg/SQUARE(Height_cm/100) BMI
		 FROM Players) AS p -- Alias the sub-query
             -- Alias the joining columns
	ON ps.PlayerName = p.PlayerName 
GROUP BY Team
HAVING AVG(BMI) >= 25;



# Syntax order - New Zealand earthquakes
# When executing a query, the processing order of the main SQL syntax is different from the written order in the query.

# You want a simple query that returns all the recorded earthquakes in New Zealand that had a magnitude of 7.5 or higher. You think the query out in a sentence before creating it.

# From the Earthquakes table, filter for only rows where Country equals 'NZ' and Magnitude greater than or equal to 7.5. Then, select the columns Date, Place, NearestPop, and Magnitude. Order the final results from the largest Magnitude to the smallest Magnitude.

# The sample code is arranged in the order that matches the above sentence, which is the same as the SQL syntax processing order in the database. You will need to reorder it so that it runs without error.


/*
Returns earthquakes in New Zealand with a magnitude of 7.5 or more
*/
SELECT Date, Place, NearestPop, Magnitude
	
FROM Earthquakes
WHERE Country = 'NZ'AND Magnitude >= 7.5

ORDER BY Magnitude DESC;



# Syntax order - Japan earthquakes
# Your friend is impressed by your querying skills. She decides to create a query on her own that shows all earthquakes in Japan that were a magnitude of 8 or higher. She has constructed a query based on how she thought about what she requires. Her query will produce an error because of the incorrect ordering of the syntax. Also, the code requires reformatting to make it easy to read.

# FROM Earthquakes WHERE Country = 'JP' AND Magnitude >= 8 SELECT Date, Place ,NearestPop, Magnitude ORDER BY Magnitude DESC;

# You will fix the query for her with a better coding format and correct the SQL syntax order.


-- Your query
SELECT Date, Place, NearestPop, Magnitude
    
FROM Earthquakes
WHERE Country = 'JP'
	AND Magnitude >= 8
ORDER BY Magnitude DESC;


# Syntax order - very large earthquakes
# When a query is executed it will stop at the first error it encounters and will return an error message. Because a query is processed in a stepped order the first error it stops at will be related to the processing order.

# FROM is processed first and checks that the queried table(s) exist in the database.
# WHERE is always processed after FROM if a row filtering condition is specified. Column(s) having the filtering condition applied must exist.
# SELECT is only processed once the data is ready to be extracted and displayed or returned to the user.
# This exercise has three queries—each contains errors. Your job is to find the errors and fix them.

# Note that the red text below the query result tab is a description of the error.


/*
Returns the location of the epicenter of earthquakes with a 9+ magnitude
*/

-- Replace Countries with the correct table name
SELECT n.CountryName AS Country
	,e.NearestPop AS ClosestCity
    ,e.Date
    ,e.Magnitude
FROM Nations AS n
INNER JOIN Earthquakes AS e
	ON n.Code2 = e.Country
WHERE e.Magnitude >= 9
ORDER BY e.Magnitude DESC;


