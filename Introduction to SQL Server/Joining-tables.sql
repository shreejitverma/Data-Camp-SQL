-- This chapter covers
-- the basics of joining tables, using INNER, LEFT, and RIGHT joins, so that you can confidently retrieve data from multiple sources.

-- Inner Joins
-- - a perfect match
-- Let's use the Chinook database, which consists of tables related to an online store, to understand how inner joins work. The album table lists albums by multiple artists. The track table lists individual songs, each with a unique identifier, but also, an album_id column that links each track to an album.

-- Let's find the tracks that belong to each album.

SELECT
    track_id,
    name AS track_name,
    title AS album_title
FROM track
    -- Complete the join type and the common joining column
    INNER JOIN album on album.album_id = track.album_id;

-- Inner Joins
-- (II)
-- Here, you'll continue to practice your INNER JOIN skills. We'll
-- use the
-- album table as last time, but will join it to a new table - artist - which consists of two
-- columns:
-- artist_id and name.

-- Select album_id and title from album, and name from artist
SELECT
    album_id,
    title,
    name AS artist
-- Enter the main source table name
FROM album
    -- Perform the inner join
    INNER JOIN artist on artist.artist_id = album.artist_id;

-- Inner Join
-- (III) - Join 3 tables
-- We've seen how to join 2 tables together - album with track, and album with artist. In this exercise, you'll join all three tables to pull together a more complete result
-- set. You
-- 'll continue using INNER JOIN, but you need to specify more than one.

-- Here, note that because both track and artist contain a name column, you need to qualify where you are selecting the columns by prefixing the column name with the table name.

SELECT track_id,
    -- Enter the correct table name prefix when retrieving the name column from the track table
    track.name AS track_name,
    title as album_title,
    -- Enter the correct table name prefix when retrieving the name column from the artist table
    artist.name AS artist_name
FROM track
    -- Complete the matching columns to join album with track, and artist with album
    INNER JOIN album on album.album_id = track.album_id
    INNER JOIN artist on artist.artist_id = album.artist_id;

--     LEFT join
-- An INNER JOIN shows you exact matches. What about when you want to compare all the values in one table with another, to see which rows match? That's when you can use a LEFT JOIN.

-- A LEFT JOIN will return ALL rows in the first table, and any matching rows in the right table. If there aren't any matches in the right table for a particular row, then a NULL is returned. This quickly lets you assess the gaps in your data, and how many you have.
SELECT
    invoiceline_id,
    unit_price,
    quantity,
    billing_state
-- Specify the source table
FROM invoiceline
    -- Complete the join to the invoice table
    LEFT JOIN invoice
    ON invoiceline.invoice_id = invoice.invoice_id;

-- RIGHT JOIN
-- Let's now try some RIGHT joins. A RIGHT join will return all rows from the right hand table, plus any matches from the left hand side table.

-- In addition to performing a RIGHT join, you'll also learn how to avoid problems when different tables have the same column names, by fully qualifying the column in your
-- select statement. Remember, we do
-- this by prefixing the column name
-- with the table name.

-- For this exercise, we'll return to the Chinook database from earlier in the chapter.

-- SELECT the fully qualified album_id column from the album table
SELECT
    album.album_id,
    title,
    album.artist_id,
    -- SELECT the fully qualified name column from the artist table
    artist.name as artist
FROM album
    -- Perform a join to return only rows that match from both tables
    INNER JOIN artist ON album.artist_id = artist.artist_id
WHERE album.album_id IN (213,214)

-- Join the
-- UNION
-- You can write 2 or more
-- SELECT statements
-- and combine the results using UNION. For example, you may have two different tables
-- with similar column types.
-- If you wanted to combine these into one
-- set
-- of results, you'd use UNION. You'll see how to do this using the artist and album tables. In this exercise, you'll SELECT two common columns, and then add a description column so you can tell which table the columns originated from.

    SELECT
        album_id AS ID,
        title AS description,
        'Album' AS Source
    -- Complete the FROM statement
    FROM album
    -- Combine the result set using the relevant keyword
UNION
    SELECT
        artist_id AS ID,
        name AS description,
        'Artist'  AS Source
    -- Complete the FROM statement
    FROM artist;


-- In chapter
-- 4 of this course, you'll need this column for connecting the professors table with the universities table.

-- However, adding columns to existing tables is easy, especially if they're still empty.

-- To
-- add columns you can
-- use the
-- following SQL
-- query:

-- ALTER TABLE table_name
-- ADD COLUMN column_name data_type;

-- Add the university_shortname column
ALTER TABLE professors
ADD university_shortname text;

-- Print the contents of this table
SELECT *
FROM professors

-- RENAME
-- and
-- DROP COLUMNs in affiliations
-- As mentioned in the video, the still empty affiliations table has some flaws. In this exercise, you'll correct them as outlined in the video.

-- You'll
-- use the
-- following
-- queries:

-- To rename
-- columns:
-- ALTER TABLE table_name
-- RENAME COLUMN old_name TO new_name;
-- To
-- delete
-- columns:
-- ALTER TABLE table_name
-- DROP COLUMN column_name;

-- Rename the organisation column
-- ALTER TABLE affiliations
-- RENAME COLUMN organisation TO organization;

-- Migrate data
-- with
-- INSERT INTO
-- SELECT DISTINCT
--     Now it
-- 's finally time to migrate the data into the new tables. You'll
-- use the
-- following
-- pattern:

-- INSERT INTO ...
-- SELECT DISTINCT ... 
-- FROM ...;
-- It can be broken up into two
-- parts:

-- First
-- part:

-- SELECT DISTINCT column_name1, column_name2, ...
-- FROM table_a;
-- This selects all distinct values in table table_a – nothing new for you.

-- Second
-- part:

-- INSERT INTO table_b ...
-- ;
-- Take this part and append it to the first, so it inserts all distinct rows from table_a into table_b.

-- One last
-- thing:
-- It is important that you run all of the code at the same time once you have filled out the blanks.

-- Insert unique professors into the new table
INSERT INTO professors
SELECT DISTINCT firstname, lastname, university_shortname
FROM university_professors;

-- Doublecheck the contents of professors
SELECT *
FROM professors;

-- Delete tables
-- with
-- DROP TABLE
-- Obviously, the
-- university_professors table is now no longer needed and can safely be deleted.

-- For table deletion, you can
-- use the
-- simple
-- command:

-- DROP TABLE table_name;

-- Delete the university_professors table
DROP TABLE university_professors;

