-- In this final
-- chapter, you'll get really hands on! You've worked
-- with existing tables, but in this chapter, you'll get to CREATE and INSERT data into them. You'll also
-- UPDATE existing records and practice
-- DELETE statements
-- in a safe environment. This chapter ensures the course gives you a thorough introduction to the key aspects of working
-- with data in SQL Server.

-- Create tables
-- Say you want to create a table to consolidate some useful track information into one table. This will consist of the track name, the artist, and the album the track came from. You also want to store the track length in a different format to how it is currently stored in the track table. How can you go
-- about doing this
-- ? Using
-- CREATE TABLE. Recall the example from the
-- video:

-- CREATE TABLE test_table
-- (
--     test_date DATE,
--     test_name VARCHAR(20),
--     test_int INT
-- )
-- Let's get started!

-- Create the table
CREATE TABLE results
(
    -- Create track column
    track varchar(200),
    -- Create artist column
    artist varchar(120),
    -- Create album column
    album varchar(160),
);

-- Insert
-- This
-- exercise
-- consists
-- of two
-- parts:
-- In the first, you'll create a new table very similar to the one you created in the previous interactive exercise. After that, you'll
-- insert some
-- data
-- and
-- retrieve
-- it.

-- You'll continue working with the Chinook database here.

-- Create the table
CREATE TABLE tracks
(
    -- Create track column
    track varchar(200),
    -- Create album column
    album varchar(160),
    -- Create track_length_mins column
    track_length_mins INT
);
-- Select all columns from the new table
SELECT
    *
FROM
    tracks;

--     Update
-- You may sometimes have to
-- update the rows in a table.
-- For example, in the album table, there is a row
-- with a very long album title, and you may want to shorten it.

-- You don't want to delete the record - you just want to update it in place. To do this, you need to specify the album_id to ensure that only the desired row is updated and all others are not modified.

-- Select the album
SELECT
    title
FROM
    album
WHERE 
  album_id = 213;

--   Delete
-- You may not have
-- permissions to
-- delete from your
-- database, but it is safe to practice it here in this course!

-- Remember - there is no confirmation before deleting. When you
-- execute the statement, the record
-- (s) are deleted immediately. Always ensure you test
-- with a
-- SELECT and
-- WHERE
-- in a separate query to ensure you are selecting and deleting the correct records.
-- If you forget so specify a WHERE condition, you will
-- delete ALL rows from the
-- table.

-- Run the query
SELECT
    *
FROM
    album

--     DECLARE and
-- SET a variable
-- Using variables makes it easy to run a query multiple times,
-- with different values, without having to scroll down and amend the WHERE clause each time. You can quickly
-- update the variable at the top of the
-- query instead. This also helps provide greater security, but that is out of scope of this course.

-- Let's go back to the now very familiar grid table for this exercise, and use it to practice extracting data according to your newly defined variable.

-- Declare the variable @region, and specify the data type of the variable
DECLARE @region varchar(10)

-- Declare multiple variables
-- You've seen how to DECLARE and SET set 1 variable. Now, you'll
-- DECLARE and
-- SET multiple variables
-- . There is already one variable declared, however you need to overwrite this and
-- declare 3 new ones. The WHERE clause will also need to be modified to
-- return results
-- between a range of dates.

-- Declare @start
DECLARE @start DATE

-- SET @start to '2014-01-24'
SET @start = '2014-01-24'

-- Ultimate Power
-- Sometimes
-- you might want to 'save' the results of a query so you can do some more work
-- with the data. You can do that by creating a temporary table that remains in the database until SQL Server is restarted. In this final exercise, you'll select the longest track from every album and add that into a temporary table which you'll
-- create as part of the query.

SELECT album.title AS album_title,
    artist.name as artist,
    MAX(track.milliseconds / (1000 * 60) % 60 ) AS max_track_length_mins
-- Name the temp table #maxtracks
INTO #maxtracks
FROM album
    -- Join album to artist using artist_id
    INNER JOIN artist ON album.artist_id = artist.artist_id
    -- Join track to album using album_id
    INNER JOIN track ON track.album_id = album.album_id
GROUP BY artist.artist_id, album.title, artist.name,album.album_id
-- Run the final SELECT query to retrieve the results from the temporary table
SELECT album_title, artist, max_track_length_mins
FROM #maxtracks
ORDER BY max_track_length_mins DESC, artist;

