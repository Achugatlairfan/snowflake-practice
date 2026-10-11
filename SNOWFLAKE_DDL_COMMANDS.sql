USE ZOMATO;
-- TASK1:step1CREATING STAGE_EMP TABLE WITH ONE COLUMN
create table stage_emp
(
emp_no number(10)
);

-- TASK1:step2:ADDING ADDITIONAL COLUMNS IN STAGE_EMP TABLE USING CREATE OR REPLACE
create or replace table stage_emp 
(
emp_no number(10),
emp_name varchar(20),
job varchar(20),
sal decimal
);

-- TASK2:step1CREATING CUSTOEMR TABLE WITH ONLY ONE COLUMN
create table stage_customer 
(
customer_id number (10)
);

task2:step2:ADDING ADDITIONAL COLUMNS TO STAGE_CUSTOER UNG CREAT OE REPLACE COMMAND 
create or replace table stage_customer
(
customer_id number(10),
customer_name varchar(30),
customer_address varchar(40)
);


-- creating a branch table :
create or replace table branch
(
branch_id number,
branch_name varchar(2),
city varchar(2),
state varchar(2),
country_id number);


-- creating a product table:
create or table product
(
product_id number,
product_name varchar(2),
category_id number,
price number,
offer_id number);

-- creating offer table:
create or replace table offer
(
offer_id number,
offer_name varchar(2),
discount number,
start_date varchar(2),
end_date varchar(2));


-- creating category table:
create or replace table category
(category_id number,
category_name varchar(2),
description varchar(2),
status varchar(2),
parent_id number);

-- creating a country table :
create table country
(country_id number,
country_name varchar(2),
country_code varchar(2),
currency_id number,
segment_id number);

-- creating a curency table:
create table currency
(currency_id number,
currency_name varchar(2),
currency_code varchar(2),
symbol varchar(2),
status varchar(2));

-- creating time_dimension_table:
create table time_dimension
(time_id number,
day_name varchar(2),
month_name varchar(2),
year number
);

-- creating a country segment table
create table country_segment
(segment_id number,
segment_name varchar(2),
region varchar(2),
country_id number,
status varchar(2));

-- creating table status odf country_code table:
create table states_of_country
(state_id number,
state_name varchar(2),
state_code varchar(2),
country_id number,
capital varchar(2));





-- 1) VARCHAR TO NUMBER
-- 3) VARCHAR TO DECIMAL
-- 4) DECIMAL TO VARCHAR
-- 5) NUMBER TO DECIMAL
-- 6) DECIMAL TO NUMBER

-- CREATING A RESTUATNTS TABLE 
CREATE OR REPLACE TABLE RESTAURANT(
RESTAURANT_ID INTEGER
);
-- AT TIME ADDING THE 3 COLUMNS, ONE COLUMN VARCHAR, NUMBER , DECIMAL
ALTER TABLE RESTAURANT ADD COLUMN RESTAURENT_NAME VARCHAR,PRICE DECIMAL,TOTAL_STAFF NUMBER ;
DESC TABLE RESTAURANT;

-- RENAMING THE TWO COLUMNS AT A TIME AND THOSE COLUMSNA RE BELONGS TO RESTUANTS TABLE 
ALTER TABLE RESTAURANT RENAME COLUMN PRICE TO DISH_PRICE;
ALTER TABLE RESTAURANT RENAME COLUMN RESTAURENT_NAME  TO RESTAURANT_NAME;

-- DROP TABLE THE COOLUMNS MORE THAN ONE USING THE ALTER STATEMENT
ALTER TABLE RESTAURANT DROP COLUMN DISH_PRICE,RESTAURANT_NAME;
DESC TABLE RESTAURANT;

-- #CHANGING THE DATA TYPE NUMBER TO VARCHAR
ALTER TABLE RESTAURANT ADD COLUMN RESTAURANT_ID_NEW VARCHAR(30);
UPDATE  RESTAURANT SET RESTAURANT_ID_NEW=RESTAURANT_ID;
ALTER TABLE RESTAURANT DROP COLUMN RESTAURANT_ID;
ALTER TABLE RESTAURANT RENAME COLUMN RESTAURANT_ID_NEW TO RESTAURANT_ID;

-- #CHANGING THE DATA TYPE NUMBER TO VARCHAR
ALTER TABLE RESTAURANT ADD COLUMN TOTAL_STAFF_NEW VARCHAR(20);
UPDATE RESTAURANT SET TOTAL_STAFF=TOTAL_STAFF_NEW;
ALTER TABLE RESTAURANT DROP COLUMN TOTAL_STAFF;
ALTER TABLE RESTAURANT RENAME COLUMN TOTAL_STAFF_NEW TO TOTAL_STAFF;

DESC TABLE RESTAURANT;





