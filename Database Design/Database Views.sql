-- -- -- Get ready to work
-- -- -- with views! In this chapter, you will learn how to
-- -- -- create and query views. On top of that, you'll master more advanced capabilities to manage them and end by identifying the difference between materialized and non-materialized views.

-- -- Viewing views
-- -- Because
-- -- views are very useful, it's common to end up with many of them in your database. It's important to keep track of them so that database users know what is available to them.

-- -- The goal of this exercise is to get familiar
-- -- with viewing views within a database and interpreting their purpose. This is a skill needed when writing database documentation or organizing views.

-- -- Get all non-systems views
SELECT *
FROM information_schema.views
WHERE table_schema NOT IN ('pg_catalog', 'information_schema');

-- Creating and querying a view
-- Have you ever found yourself running the same query over and over again? Maybe, you used to keep a text copy of the query in your desktop notes app, but that was all before you knew about views!

-- In these Pitchfork reviews, we're particularly interested in high-scoring reviews and if there's a common thread between the works that get high scores. In this exercise, you'll make a view to help with this analysis so that we don't have to type out the same query often to get these high-scoring reviews.

-- Create a view for reviews with a score above 9
-- CREATE VIEW high_scores
-- AS
    SELECT *
    FROM reviews
    WHERE score > 9;

-- Creating a view from other views
-- Views can be created from queries that include other views. This is useful when you have a complex schema, potentially due to normalization, because it helps reduce the JOINS needed. The biggest concern is keeping track of dependencies, specifically how any modifying or dropping of a view may affect other views.

-- In the next few exercises, we'll continue using the Pitchfork reviews data. There are two views of interest in this exercise. top_15_2017 holds the top 15 highest scored reviews published in 2017 with columns reviewid,title, and score. artist_title returns a list of all reviewed titles and their respective artists with columns reviewid, title, and artist. From these views, we want to create a new view that gets the highest scoring artists of 2017.

-- Create a view with the top artists in 2017
CREATE VIEW top_artists_2017
AS
    -- with only one column holding the artist field
    SELECT artist_title.artist
    FROM artist_title
        INNER JOIN top_15_2017
        ON top_15_2017.reviewid = artist_title.reviewid;

-- Output the new view
SELECT *
FROM top_artists_2017;


-- Granting and revoking access
-- Access control is a key aspect of database management. Not all database users have the same needs and goals, from analysts, clerks, data scientists, to data engineers. As a general rule of thumb, write access should never be the default and only be given when necessary.

-- In the case of our Pitchfork reviews, we don't want all database users to be able to write into the long_reviews view. Instead, the editor should be the only user able to edit this view.

-- Revoke everyone's update and insert privileges
REVOKE UPDATE, INSERT ON long_reviews FROM PUBLIC;

-- Grant the editor update and insert privileges 
GRANT UPDATE, INSERT ON long_reviews TO editor; 

-- Creating
-- and refreshing a materialized view
-- The syntax for creating materialized and non-materialized views are quite similar because they are both defined by a query. One key difference is that we can refresh materialized views,
-- while no such concept exists for non-materialized views. It's important to know how to refresh a materialized view, otherwise the view will remain a snapshot of the time the view was created.

-- In this exercise, you will create a materialized view from the table genres. A new record will then be inserted into genres. To make sure the view has the latest data, it will have to be refreshed.

-- Create a materialized view called genre_count 
CREATE MATERIALIZED
VIEW genre_count AS
SELECT genre, COUNT(*)
FROM genres
GROUP BY genre;

INSERT INTO genres
VALUES
    (50000, 'classical');

-- Refresh genre_count
REFRESH MATERIALIZED VIEW genre_count;

SELECT *
FROM genre_count;

