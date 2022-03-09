-- Query information_schema
-- with
-- SELECT
--     information_schema
-- is a meta-database that holds information about your current database. information_schema has multiple tables you can query
-- with the known
-- SELECT *
-- FROM
-- syntax:

-- tables:
-- information about all tables in your current database
-- columns:
-- information about all columns in all of the tables in your current database
-- …
-- In this exercise, you'll only need information from the 'public' schema, which is specified as the column table_schema of the tables and columns tables. The 'public' schema holds information about user-defined tables and databases. The other types of table_schema hold system information – for this course, you're only interested in user-defined stuff.

-- Query the right table in information_schema
SELECT table_name
FROM information_schema.tables
-- Specify the correct table_schema value
WHERE table_schema = 'public';

-- CREATE your first
-- few TABLEs
-- You'll now start implementing a better database model. For this, you'll
-- create tables for the professors and universities entity types. The other tables will be created for you.

-- The syntax for creating simple tables is as
-- follows:

-- CREATE TABLE table_name
-- (
--     column_a data_type,
--     column_b data_type,
--     column_c data_type
-- );
-- Attention:
-- Table and columns names, as well as data types, don't need to be surrounded by quotation marks.

-- Create a table for the professors entity type
CREATE TABLE professors
(
    firstname text,
    lastname text
);

-- Print the contents of this table
SELECT *
FROM professors

-- ADD a
-- COLUMN
-- with
-- ALTER TABLE
-- Oops! We forgot to
-- add the university_shortname column to the professors table. You've probably already noticed:



-- In chapter 4 of this course, you'll need this column for connecting the professors table
-- with the universities table.

-- However, adding columns to existing tables is easy, especially
-- if they're still empty.

-- To add columns you can use the following SQL query:

-- ALTER TABLE table_name
-- ADD COLUMN column_name data_type;