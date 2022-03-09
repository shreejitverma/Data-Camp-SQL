-- -- This final chapter
-- -- ends
-- -- with some database management-related topics. You will learn how to
-- -- grant database access based on user roles, how to partition tables into smaller pieces, what to keep in mind when integrating data, and which DBMS fits your business needs best.

-- Create a role
-- A database role is an entity that contains information that define the role's privileges and interact with the client authentication system. Roles allow you to give different people (and often groups of people) that interact with your data different levels of access.

-- Imagine you founded a startup. You are about to hire a group of data scientists. You also hired someone named Marta who needs to be able to login to your database. You're also about to hire a database administrator. In this exercise, you will
-- create these roles.
-- Create a data scientist role
CREATE ROLE data_scientist;

-- GRANT privileges and ALTER attributes
-- Once roles are created, you
-- grant them specific access control privileges on objects, like tables and views. Common privileges being
-- SELECT, 
-- INSERT,
-- UPDATE, etc.

-- Imagine you
-- 're a cofounder of that startup and you want all of your data scientists to be able to update and insert data in the long_reviews view. In this exercise, you will enable those soon-to-be-hired data scientists by granting their role (data_scientist) those privileges. Also, you'll give Marta's role a password.

-- Grant data_scientist update and insert privileges
GRANT UPDATE, INSERT ON long_reviews TO data_scientist;

-- Give Marta's role a password
ALTER ROLE marta WITH PASSWORD 's3cur3p@ssw0rd';

-- Add a user role to a group role
-- There are two types of roles: user roles and group roles. By assigning a user role to a group role, a database administrator can add complicated levels of access to their databases with one simple command.

-- For your startup, your search for data scientist hires is taking longer than expected. Fortunately, it turns out that Marta, your recent hire, has previous data science experience and she's willing to chip in the interim. In this exercise, you'll add Marta's user role to the data scientist group role. You'll then remove her after you complete your hiring process.

-- Add Marta to the data scientist group
GRANT data_scientist TO marta;

-- Celebrate! You hired data scientists.

-- Remove Marta from the data scientist group
REVOKE data_scientist FROM marta;

-- Creating vertical partitions
-- In the video, you learned about vertical partitioning and saw an example.

-- For vertical partitioning, there is no specific syntax in PostgreSQL. You have to create a new table with particular columns and copy the data there. Afterward, you can drop the columns you want in the separate partition. If you need to access the full table, you can do so by using a JOIN clause.

-- In this exercise and the next one, you'll be working with the example database called pagila. It's a database that is often used to showcase PostgreSQL features. The database contains several tables. We'll be working with the film table. In this exercise, we'll use the following columns:

-- film_id: the unique identifier of the film
-- long_description: a lengthy description of the film

-- Create a new table called film_descriptions
CREATE TABLE film_descriptions
(
    film_id INT,
    long_description TEXT
);

-- Copy the descriptions from the film table
INSERT INTO film_descriptions
SELECT film_id, long_description
FROM film;

Creating horizontal partitions
In the video, you also learned about horizontal partitioning.

The example of horizontal partitioning showed the syntax necessary to
create horizontal partitions in PostgreSQL.
If you need a reminder, you can have a look at the slides.

In this exercise, however, you'll be using a list partition instead of a range partition. For list partitions, you form partitions by checking whether the partition key is in a list of values or not.

To do this, we partition by LIST instead of RANGE. When creating the partitions, you should check if the values are IN a list of values.

-- We'll be using the following columns in this
-- exercise:

-- film_id:
-- the unique identifier of the film
-- title:
-- the title of the film
-- release_year:
-- the year it's released

-- Create a new table called film_partitioned
CREATE TABLE film_partitioned
(
    film_id INT,
    title TEXT NOT NULL,
    release_year TEXT
)
PARTITION BY RANGE
(release_year);

