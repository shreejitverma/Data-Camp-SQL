-- SELECTion Box
-- SELECT statements
-- to retrieve data from one or more columns. You'll also learn how to apply filters to both numeric and text data, and sort the results.

-- SELECT the country column FROM the eurovision table
SELECT country
FROM eurovision;

-- Now
-- that you've practiced how to select one column at a time, it's time to practice selecting more than one column. You'll continue working with the eurovision table.

-- Select country and event_year from eurovision
SELECT
    country,
    event_year
FROM
    eurovision;

-- Order by
-- In this exercise, you'll practice the use of ORDER BY using the grid dataset. It's loaded and waiting for you! It contains a subset of wider publicly available information on US power outages.

-- Some of the main columns
-- include:

-- description:
-- The reason/ cause of the outage.
-- nerc_region:
-- The North American Electricity Reliability Corporation was formed to ensure the reliability of the grid and comprises several regional entities).
-- demand_loss_mw:
-- How much energy was not transmitted/consumed during the outage.

-- Select the first 5 rows from the specified columns
SELECT
    TOP (5)
    description,
    event_date
FROM
    grid
-- Order your results by the event_date column
ORDER BY 
  event_date;

-- Where
-- You won
-- 't usually want to retrieve every row in your database. You'll have specific information you need in order to answer questions from your boss or colleagues.

-- The WHERE clause is essential for selecting, updating
-- (and deleting!) data from your tables. You'll continue working with the grid dataset for this exercise.

-- Select description and event_year
SELECT
    description,
    event_year
FROM
    grid
-- Filter the results
WHERE 
  description = 'Vandalism';

-- Working
-- with NULL values
-- A NULL value could mean 'zero' -
-- if something doesn't happen, it can't be logged in a table. However, NULL can also mean 'unknown' or 'missing'. So consider
-- if it is appropriate to replace them in your results. NULL values provide feedback on data quality.
-- If you have NULL values, and you didn't expect to have any, then you have an issue with either how data is captured or how it's entered in the database.

-- In this exercise, you'll practice filtering for NULL values, excluding them from results, and replacing them with alternative values.
-- Retrieve all columns
SELECT
    *
FROM
    grid
-- Return only rows where demand_loss_mw is missing or unknown  
WHERE 
  demand_loss_mw IS NULL;

-- Exploring classic rock
-- songs
-- It's time to rock and roll! In this set of exercises, you'll
-- use the
-- songlist table, which contains songs featured on the playlists of 25 classic rock radio stations.

-- First, let's get familiar with the data.

-- Retrieve the song, artist and release_year columns
SELECT
    song,
    artist,
    release_year
FROM
    songlist;

-- Exploring classic rock
-- songs - AND/OR
-- Having familiarized yourself
-- with the songlist table, you'll now extend your WHERE clause from the previous exercise.

SELECT
    song,
    artist,
    release_year
FROM
    songlist
WHERE 
  -- Retrieve records greater than and including 1980
  release_year >=1980
    -- Also retrieve records up to and including 1990
    AND release_year <= 1990
ORDER BY 
  artist, 
  release_year;

--   Using parentheses
-- in your queries
-- You can
-- use parentheses
-- to make the intention of your code clearer. This becomes very important when using AND and OR clauses, to ensure your queries
-- return the
-- exact subsets you need.
SELECT
    artist,
    release_year,
    song
FROM
    songlist
-- Choose the correct artist and specify the release year
WHERE 
  (
    artist LIKE 'B%'
    AND release_year = 1986
  )
    -- Or return all songs released after 1990
    OR release_year > 1990
-- Order the results
ORDER BY 
  release_year, 
  artist, 
  song;


  