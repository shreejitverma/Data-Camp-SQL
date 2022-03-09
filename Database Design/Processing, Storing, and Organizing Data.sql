-- Querying the dimensional
-- model
-- Here it is! The schema reorganized using the dimensional
-- model:

-- Let's try to run a query based on this schema. How about we try to find the number of minutes we ran in July, 2019? We'll
-- break
-- this up in two steps. First, we'll get the total number of minutes recorded in the database. Second, we'll narrow down that query to week_id's from July, 2019.

SELECT
    -- Select the sum of the duration of all runs
    SUM(duration_mins)
FROM
    runs_fact;

--     Adding foreign keys
-- Foreign key references are essential to both the snowflake and star schema. When creating either of these schemas, correctly setting up the foreign keys is vital because they connect dimensions to the fact table. They also enforce a one-to-many relationship, because unless otherwise specified, a foreign key can appear more than once in a table and primary key can appear only once.

-- The fact_booksales table has three foreign keys: book_id, time_id, and store_id. In this exercise, the four tables that make up the star schema below have been loaded. However, the foreign keys still need to be added. 

-- Add the book_id foreign key
ALTER TABLE fact_booksales ADD CONSTRAINT sales_book
    FOREIGN KEY (book_id) REFERENCES dim_book_star (book_id);

-- Add the time_id foreign key
ALTER TABLE fact_booksales ADD CONSTRAINT sales_time
    FOREIGN KEY (time_id) REFERENCES dim_time_star (time_id);

-- Add the store_id foreign key
ALTER TABLE fact_booksales ADD CONSTRAINT sales_store
    FOREIGN KEY (store_id) REFERENCES dim_store_star (store_id);


--     Extending the book
-- dimension
-- In the video, we saw how the book dimension differed between the star and snowflake schema. The star schema's dimension table for books, dim_book_star, has been loaded and below is the snowflake schema of the book dimension. 

-- In this exercise, you are going to extend the star schema to meet part of the snowflake schema's criteria. Specifically, you will
-- create dim_author from the data provided in dim_book_star.

-- Create a new table for dim_author with an author column
CREATE TABLE dim_author
(
    author varchar(256) NOT NULL
);

-- Insert authors 
INSERT INTO dim_author
SELECT DISTINCT author
FROM dim_book_star;

-- Create a new table for dim_author with an author column
CREATE TABLE dim_author
(
    author varchar(256) NOT NULL
);

-- Insert authors 
INSERT INTO dim_author
SELECT DISTINCT author
FROM dim_book_star;

-- Output each state and their total sales_amount
SELECT dim_store_star.state, SUM(fact_booksales.sales_amount)
FROM fact_booksales
    -- Join to get book information
    JOIN dim_book_star on dim_book_star.book_id = fact_booksales.book_id
    -- Join to get store information
    JOIN dim_store_star on dim_store_star.store_id = fact_booksales.store_id
-- Get all books with in the novel genre
WHERE  
    dim_book_star.genre = 'novel'
-- Group results by state
GROUP BY
    dim_store_star.state;




