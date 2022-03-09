-- -- In this chapter, we will
-- -- learn how to
-- -- use window
-- -- functions to perform calculations over time, including calculating running totals and moving averages, calculating intervals, and finding the maximum levels of overlap.

-- Contrasting ROW_NUMBER
-- (), RANK
-- (), and DENSE_RANK
-- ()
-- Among the ranking window functions, ROW_NUMBER
-- () is the most common, followed by RANK
-- () and DENSE_RANK
-- (). Each of these ranking functions
-- (as well as NTILE
-- ()) provides us
-- with a different way to rank records in SQL Server.

-- In this exercise, we would like to determine how frequently each we see incident type 3 in our data
-- set. We
-- would like to rank the number of incidents in descending order, such that the date
-- with the highest number of incidents has a row number, rank, and dense rank of 1, and so on. To make it easier to follow, we will only include dates
-- with at least 8 incidents.

SELECT
    ir.IncidentDate,
    ir.NumberOfIncidents,
    -- Fill in each window function and ordering
    -- Note that all of these are in descending order!
    ROW_NUMBER() OVER (ORDER BY ir.NumberOfIncidents DESC) AS rownum,
    RANK() OVER (ORDER BY ir.NumberOfIncidents DESC) AS rk,
    DENSE_RANK() OVER (ORDER BY ir.NumberOfIncidents DESC) AS dr
FROM dbo.IncidentRollup ir
WHERE
	ir.IncidentTypeID = 3
    AND ir.NumberOfIncidents >= 8
ORDER BY
	ir.NumberOfIncidents DESC;

--     Aggregate window functions
-- There are several aggregate window functions available to you. In this exercise, we will look at reviewing multiple aggregates over the same window.

-- Our window this time will be the entire data
-- set
-- , meaning that our OVER
-- () clause will remain empty.

SELECT
    ir.IncidentDate,
    ir.NumberOfIncidents,
    -- Fill in the correct aggregate functions
    -- You do not need to fill in the OVER clause
    SUM(ir.NumberOfIncidents) OVER () AS SumOfIncidents,
    MIN(ir.NumberOfIncidents) OVER () AS LowestNumberOfIncidents,
    MAX(ir.NumberOfIncidents) OVER () AS HighestNumberOfIncidents,
    COUNT(ir.NumberOfIncidents) OVER () AS CountOfIncidents
FROM dbo.IncidentRollup ir
WHERE
	ir.IncidentDate BETWEEN '2019-07-01' AND '2019-07-31'
    AND ir.IncidentTypeID = 3;

--     Running totals with SUM()
-- One of the more powerful uses of window functions is calculating running totals: an ongoing tally of a particular value over a given stretch of time. Here, we would like to use a window function to calculate how many incidents have occurred on each date and incident type in July of 2019 as well as a running tally of the total number of incidents by incident type. A window function will help us solve this problem in one query.

SELECT
    ir.IncidentDate,
    ir.IncidentTypeID,
    ir.NumberOfIncidents,
    -- Get the total number of incidents
    SUM(ir.NumberOfIncidents) OVER (
      	-- Do this for each incident type ID
		PARTITION BY ir.IncidentTypeID
      	-- Sort by the incident date
		ORDER BY ir.IncidentDate 
	) AS NumberOfIncidents
FROM dbo.IncidentRollup ir
    INNER JOIN dbo.Calendar c
    ON ir.IncidentDate = c.Date
WHERE
	c.CalendarYear = 2019
    AND c.CalendarMonth = 7
    AND ir.IncidentTypeID IN (1, 2)
ORDER BY
	ir.IncidentTypeID,
	ir.IncidentDate;


--     Seeing prior and future periods
-- The LAG() and LEAD() window functions give us the ability to look backward or forward in time, respectively. This gives us the ability to compare period-over-period data in a single, easy query.

-- In this exercise, we want to compare the number of security incidents by day for incident types 1 and 2 during July of 2019, specifically the period starting on July 2nd and ending July 31st.

SELECT
    ir.IncidentDate,
    ir.IncidentTypeID,
    -- Get the prior day's number of incidents
    LAG(ir.NumberOfIncidents, 1) OVER (
      	-- Partition by incident type ID
		PARTITION BY ir.IncidentTypeID
      	-- Order by incident date
		ORDER BY ir.IncidentDate
	) AS PriorDayIncidents,
    ir.NumberOfIncidents AS CurrentDayIncidents,
    -- Get the next day's number of incidents
    LEAD(ir.NumberOfIncidents, 1) OVER (
      	-- Partition by incident type ID
		PARTITION BY ir.IncidentTypeID
      	-- Order by incident date
		ORDER BY ir.IncidentDate
	) AS NextDayIncidents
FROM dbo.IncidentRollup ir
WHERE
	ir.IncidentDate >= '2019-07-02'
    AND ir.IncidentDate <= '2019-07-31'
    AND ir.IncidentTypeID IN (1, 2)
ORDER BY
	ir.IncidentTypeID,
	ir.IncidentDate;

--     Seeing the prior three periods
-- The LAG() and LEAD() window functions give us the ability to look backward or forward in time, respectively. This gives us the ability to compare period-over-period data in a single, easy query. Each call to LAG() or LEAD() returns either a NULL or a single row. If you want to see multiple periods back, you can include multiple calls to LAG() or LEAD().

-- In this exercise, we want to compare the number of security incidents by day for incident types 1 and 2 during July of 2019, specifically the period starting on July 2nd and ending July 31st. Management would like to see a rolling four-day window by incident type to see if there are any significant trends, starting two days before and looking one day ahead.

SELECT
    ir.IncidentDate,
    ir.IncidentTypeID,
    -- Fill in two periods ago
    LAG(ir.NumberOfIncidents, 2) OVER (
		PARTITION BY ir.IncidentTypeID
		ORDER BY ir.IncidentDate
	) AS Trailing2Day,
    -- Fill in one period ago
    LAG(ir.NumberOfIncidents, 1) OVER (
		PARTITION BY ir.IncidentTypeID
		ORDER BY ir.IncidentDate
	) AS Trailing1Day,
    ir.NumberOfIncidents AS CurrentDayIncidents,
    -- Fill in next period
    LEAD(ir.NumberOfIncidents, 1) OVER (
		PARTITION BY ir.IncidentTypeID
		ORDER BY ir.IncidentDate
	) AS NextDay
FROM dbo.IncidentRollup ir
WHERE
	ir.IncidentDate >= '2019-07-01'
    AND ir.IncidentDate <= '2019-07-31'
    AND ir.IncidentTypeID IN (1, 2)
ORDER BY
	ir.IncidentTypeID,
	ir.IncidentDate;

--     Calculating days elapsed
-- between incidents
-- Something you might have noticed in the prior two exercises is that we don't always have incidents on every day of the week, so calling LAG() and LEAD() the "prior day" is a little misleading; it's really the "prior period." Someone in management noticed this as well and, at the
-- end of July, wanted to know the number of days between incidents. To do this, we will calculate two
-- values:
-- the number of days since the prior incident and the number of days until the next incident.

-- Recall that DATEDIFF
-- () gives the difference between two dates. We can combine this
-- with LAG() and LEAD
-- () to get our results.

SELECT
    ir.IncidentDate,
    ir.IncidentTypeID,
    -- Fill in the days since last incident
    DATEDIFF(DAY, LAG(ir.IncidentDate, 1) OVER (
		PARTITION BY ir.IncidentTypeID
		ORDER BY ir.IncidentDate
	), ir.IncidentDate) AS DaysSinceLastIncident,
    -- Fill in the days until next incident
    DATEDIFF(DAY, ir.IncidentDate, LEAD(ir.IncidentDate, 1) OVER (
		PARTITION BY ir.IncidentTypeID
		ORDER BY ir.IncidentDate
	)) AS DaysUntilNextIncident
FROM dbo.IncidentRollup ir
WHERE
	ir.IncidentDate >= '2019-07-02'
    AND ir.IncidentDate <= '2019-07-31'
    AND ir.IncidentTypeID IN (1, 2)
ORDER BY
	ir.IncidentTypeID,
	ir.IncidentDate;

--     Analyze client data for potential fraud
-- In this final set of exercises, we will analyze day spa data to look for potential fraud. Our company gives each customer one pass for personal use and a single guest pass. We have check-in and check-out data for each client and guest passes tie back to the base customer ID. This means that there might be overlap when a client and guest both check in together. We want to see if there are at least three overlapping entries for a single client, as that would be a violation of our business rule.

-- The key to thinking about overlapping entries is to unpivot our data and think about the stream of entries and exits. We will do that first.

-- This section focuses on entrances:  CustomerVisitStart
    SELECT
        dsv.CustomerID,
        dsv.CustomerVisitStart AS TimeUTC,
        1 AS EntryCount,
        -- We want to know each customer's entrance stream
        -- Get a unique, ascending row number
        ROW_NUMBER() OVER (
      -- Break this out by customer ID
      PARTITION BY dsv.CustomerID
      -- Ordered by the customer visit start date
      ORDER BY dsv.CustomerVisitStart
    ) AS StartOrdinal
    FROM dbo.DaySpaVisit dsv
UNION ALL
    -- This section focuses on departures:  CustomerVisitEnd
    SELECT
        dsv.CustomerID,
        dsv.CustomerVisitEnd AS TimeUTC,
        -1 AS EntryCount,
        NULL AS StartOrdinal
    FROM dbo.DaySpaVisit dsv


--     Build a stream of events
-- In the prior exercise, we broke out day spa data into a stream of entrances and exits. Unpivoting the data allows us to move to the next step, which is to order the entire stream.

-- The results from the prior exercise are now in a temporary table called #StartStopPoints. The columns in this table are CustomerID, TimeUTC, EntryCount, and StartOrdinal. These are the only columns you will need to use in this exercise. TimeUTC represents the event time, EntryCount indicates the net change for the event (+1 or -1), and StartOrdinal appears for entrance events and gives the order of entry.

SELECT s.*,
    -- Build a stream of all check-in and check-out events
    ROW_NUMBER() OVER (
      -- Break this out by customer ID
      PARTITION BY s.CustomerID
      -- Order by event time and then the start ordinal
      -- value (in case of exact time matches)
      ORDER BY s.TimeUTC, s.StartOrdinal
    ) AS StartOrEndOrdinal
FROM #StartStopPoints s;


-- Complete the fraud analysis
-- So far, we have broken out day spa data into a stream of entrances and exits and ordered this stream chronologically. This stream contains two critical fields, StartOrdinal and StartOrEndOrdinal. StartOrdinal is the chronological ordering of all entrances. StartOrEndOrdinal contains all entrances and exits in order. Armed with these two pieces of information, we can find the maximum number of concurrent visits.

-- The results from the prior exercise are now in a temporary table called #StartStopOrder.

SELECT
    s.CustomerID,
    MAX(2 * s.StartOrdinal - s.StartOrEndOrdinal) AS MaxConcurrentCustomerVisits
FROM #StartStopOrder s
WHERE s.EntryCount = 1
GROUP BY s.CustomerID
-- The difference between 2 * start ordinal and the start/end
-- ordinal represents the number of concurrent visits
HAVING MAX(2 * s.StartOrdinal - s.StartOrEndOrdinal) > 2
-- Sort by the largest number of max concurrent customer visits
ORDER BY MaxConcurrentCustomerVisits DESC;

-- Working with different types of data
-- The examples in this course are based on a data set about chocolate ratings (one of the most commonly consumed candies in the world).

-- This data set contains

-- The ratings table: information about chocolate bars: the origin of the beans, percentage of cocoa and the rating of each bar.
-- The voters table: details about the people who participate in the voting process. It contains personal information of a voter: first and last name, email address, gender, country, the first time they voted and the total number of votes.
-- In this exercise, you will take a look at different types of data.

SELECT
    company,
    company_location,
    bean_origin,
    cocoa_percent,
    rating
FROM ratings
-- Location should be Belgium and the rating should exceed 3.5
WHERE company_location = 'Belgium'
    AND rating > 3.5;

--     Storing dates
-- in a database
-- In this exercise, you will practice your knowledge of the different data types you can
-- use in SQL Server. You will
-- add more columns to the voters table and decide which is the most appropriate data type for each of them.

-- The syntax for adding a new column in a table is the
-- following:

-- ALTER TABLE table_name
-- ADD column_name data_type
-- Remember, the most common date/time data types
-- are:

-- date
-- time
-- datetime
-- datetime2
-- smalldatetime.

ALTER TABLE voters
ADD last_vote_date date;

-- Implicit conversion
-- between data types
-- This is what you need to remember about implicit
-- conversion:

-- For comparing two values in SQL Server, they need to have the same data type.
-- If the data types are different, SQL Server implicitly converts one type to another, based on data type precedence.
-- The data type
-- with the lower precedence is converted to the data type
-- with the higher precedence.
-- In this exercise, you are going to test
-- if explicit conversion works between a numeric type and a character.
-- use information
-- from the conversion table, where the implicit and explicit conversions between all data types are presented. You are going to try an implicit conversion between two different data types.

-- For this, you will
-- use the
-- voters table and will compare the total_votes numeric column
-- with a character.

SELECT
    first_name,
    last_name,
    total_votes
FROM voters
WHERE total_votes > '120'

-- Data type precedence
-- In this exercise, you will evaluate the rating information from the ratings table and you will see what happens when a decimal value is compared to an integer.
-- Remember:
-- in SQL Server, data is implicitly converted behind the scenes from one type to another, in such a way that no data loss occurs.

SELECT
    bean_type,
    rating
FROM ratings
WHERE rating > 3;

-- CASTing data
-- It
-- happens often to need data in a certain type or format and to find that it's stored differently. For example:

-- Integrating data from multiple sources, having different data types, into a single one
-- Abstract data should be more readable (i.e. True/False instead of 1/0) Luckily, you don't need to make any changes in the data itself. You can
-- use functions
-- for explicitly converting to the data type you need
-- (using CAST
-- () and CONVERT
-- ()).
-- You are now going to explicitly convert data using the CAST
-- () function. Remember the
-- syntax:

-- CAST
-- (expression AS data_type [(length)])

SELECT
    -- Transform the year part from the birthdate to a string
    first_name + ' ' + last_name + ' was born in ' + CAST(YEAR(birthdate) AS nvarchar) + '.'
FROM voters;

-- CONVERTing data
-- Another
-- important function similar to CAST
-- () is CONVERT
-- (). They are very similar in functionality,
-- with the exception that
-- with CONVERT
-- () you can
-- use a
-- style parameter for changing the aspect of a date. Also, CONVERT
-- () is SQL Server specific, so its performance is slightly better than CAST
-- (). Nonetheless, it's important to know how to use both of them.

-- In this exercise, you are going to enhance your knowledge of the CONVERT() function.

SELECT
    email,
    -- Convert birthdate to varchar show it like: "Mon dd,yyyy" 
    CONVERT(varchar, birthdate, 107) AS birthdate
FROM voters;

-- Working with the correct data types
-- It’s now time to practice your understanding of various data types in SQL Server and how to convert them from one type to another. In this exercise, you will query the voters table. Remember that this table holds information about the people who provided ratings for the different chocolate flavors.

-- You are going to write a query that returns information (first name, last name, gender, country, number of times they voted) about the female voters from Belgium, who voted more than 20 times.

-- You will work with columns of different data types and perform both implicit and explicit conversions between different types of data (using CAST() and CONVERT() functions).

-- It sounds like a big query, but we will take it step-by-step and you will see the results in no time!

SELECT
    first_name,
    last_name,
    gender,
    country
FROM voters
WHERE country = 'Belgium'
    -- Select only the female voters
    AND gender ='F'
    -- Select only people who voted more than 20 times   
    AND total_votes > 20;

    