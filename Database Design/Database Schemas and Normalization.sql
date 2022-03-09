-- In this chapter, you will
-- take your data modeling skills to the next level. You'll learn to implement star and snowflake schemas, recognize the importance of normalization and see how to normalize databases to different extents.

--     Querying the snowflake
-- schema
-- Imagine that you didn't have the data warehouse set up. Instead, you'll have to run this query on the company's operational database, which means you'll have to rewrite the previous query
-- with the following snowflake
-- schema:



-- The tables in this schema have been loaded. Remember, our goal is to find the amount of money made from the novel genre in each state.

-- Output each state and their total sales_amount
SELECT dim_state_sf.state, SUM(fact_booksales.sales_amount)
FROM fact_booksales
    -- Joins for genre
    JOIN dim_book_sf on dim_book_sf.book_id = fact_booksales.book_id
    JOIN dim_genre_sf on dim_genre_sf.genre_id = dim_book_sf.genre_id
    -- Joins for state 
    JOIN dim_store_sf on dim_store_sf.store_id =  fact_booksales.store_id
    JOIN dim_city_sf on dim_city_sf.city_id = dim_store_sf.city_id
    JOIN dim_state_sf on  dim_state_sf.state_id = dim_city_sf.state_id
-- Get all books with in the novel genre and group the results by state
WHERE  
    dim_genre_sf.genre = 'novel'
GROUP BY
    dim_state_sf.state;

--     Updating countries
-- Going through the company data, you notice there are some inconsistencies in the store addresses. These probably occurred during data entry, where people fill in fields using different naming conventions. This can be especially seen in the country field, and you decide that countries should be represented by their abbreviations. The only countries in the database are Canada and the United States, which should be represented as USA and CA.

-- In this exercise, you will compare the records that need to be updated in order to do this task on the star and snowflake schema. dim_store_star and dim_country_sf have been loaded.

-- Output records that need to be updated in the star schema
SELECT *
FROM dim_store_star
WHERE dim_store_star.country != 'USA' AND dim_store_star.country !='CA';

-- Extending the snowflake schema
-- The company is thinking about extending their business beyond bookstores in Canada and the US. Particularly, they want to expand to a new continent. In preparation, you decide a continent field is needed when storing the addresses of stores.

-- Luckily, you have a snowflake schema in this scenario. As we discussed in the video, the snowflake schema is typically faster to extend while ensuring data consistency. Along with dim_country_sf, a table called dim_continent_sf has been loaded. It contains the only continent currently needed, North America, and a primary key. In this exercise, you'll need to extend dim_country_sf to reference dim_continent_sf.

-- Add a continent_id column with default value of 1
ALTER TABLE dim_country_sf
ADD continent_id int NOT NULL DEFAULT(1);

-- Add the foreign key constraint
ALTER TABLE dim_country_sf ADD CONSTRAINT country_continent
   FOREIGN KEY (continent_id) REFERENCES dim_continent_sf(continent_id);

-- Output updated table
SELECT *
FROM dim_country_sf;