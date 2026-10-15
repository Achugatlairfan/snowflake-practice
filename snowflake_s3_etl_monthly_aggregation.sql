-- =====================================================
-- project: snowflake etl and monthly aggregation
-- technologies: snowflake sql, aws s3
-- =====================================================

-- select the database and schema
use zomato;
use schema public;

-- =====================================================
-- task 1: create customer table and insert 100 records
-- =====================================================

create or replace table customer (
    customer_id number,
    customer_name varchar(50),
    city varchar(50),
    salary number
);

-- insert 100 customer records into the customer table
insert into customer (customer_id, customer_name, city, salary)
values
(1, 'irfan', 'bangalore', 35000),
(2, 'rahul', 'hyderabad', 42000),
(3, 'ahmed', 'chennai', 38000),
(4, 'priya', 'mumbai', 50000),
(5, 'sneha', 'pune', 45000),
(6, 'arjun', 'delhi', 55000),
(7, 'faizan', 'bangalore', 32000),
(8, 'ayesha', 'hyderabad', 48000),
(9, 'kiran', 'chennai', 40000),
(10, 'vijay', 'mumbai', 60000),
(11, 'rohan', 'pune', 36000),
(12, 'neha', 'delhi', 52000),
(13, 'imran', 'bangalore', 41000),
(14, 'pooja', 'hyderabad', 47000),
(15, 'amit', 'chennai', 39000),
(16, 'divya', 'mumbai', 58000),
(17, 'karan', 'pune', 43000),
(18, 'sana', 'delhi', 49000),
(19, 'arif', 'bangalore', 37000),
(20, 'meena', 'hyderabad', 53000),
(21, 'nikhil', 'chennai', 44000),
(22, 'ananya', 'mumbai', 61000),
(23, 'sameer', 'pune', 34000),
(24, 'farah', 'delhi', 46000),
(25, 'rohit', 'bangalore', 51000),
(26, 'kavya', 'hyderabad', 40000),
(27, 'asif', 'chennai', 35000),
(28, 'deepa', 'mumbai', 56000),
(29, 'manoj', 'pune', 48000),
(30, 'nisha', 'delhi', 42000),
(31, 'adnan', 'bangalore', 45000),
(32, 'swati', 'hyderabad', 59000),
(33, 'harish', 'chennai', 38000),
(34, 'megha', 'mumbai', 62000),
(35, 'zaid', 'pune', 39000),
(36, 'rekha', 'delhi', 47000),
(37, 'vikram', 'bangalore', 54000),
(38, 'aliya', 'hyderabad', 36000),
(39, 'suresh', 'chennai', 50000),
(40, 'riya', 'mumbai', 43000),
(41, 'danish', 'pune', 57000),
(42, 'sonia', 'delhi', 41000),
(43, 'faheem', 'bangalore', 49000),
(44, 'lavanya', 'hyderabad', 44000),
(45, 'akash', 'chennai', 53000),
(46, 'simran', 'mumbai', 37000),
(47, 'rahim', 'pune', 60000),
(48, 'divya', 'delhi', 46000),
(49, 'tarun', 'bangalore', 39000),
(50, 'ishita', 'hyderabad', 55000),
(51, 'shahid', 'chennai', 42000),
(52, 'keerthi', 'mumbai', 48000),
(53, 'pranav', 'pune', 35000),
(54, 'afreen', 'delhi', 51000),
(55, 'ajay', 'bangalore', 58000),
(56, 'monika', 'hyderabad', 40000),
(57, 'irshad', 'chennai', 45000),
(58, 'swetha', 'mumbai', 52000),
(59, 'ganesh', 'pune', 38000),
(60, 'shreya', 'delhi', 63000),
(61, 'arshad', 'bangalore', 47000),
(62, 'bindu', 'hyderabad', 36000),
(63, 'mohit', 'chennai', 54000),
(64, 'reshma', 'mumbai', 41000),
(65, 'faiz', 'pune', 49000),
(66, 'harini', 'delhi', 44000),
(67, 'rahul', 'bangalore', 57000),
(68, 'nikita', 'hyderabad', 39000),
(69, 'shankar', 'chennai', 46000),
(70, 'tanvi', 'mumbai', 60000),
(71, 'basheer', 'pune', 43000),
(72, 'anjali', 'delhi', 52000),
(73, 'roshan', 'bangalore', 35000),
(74, 'tejaswini', 'hyderabad', 48000),
(75, 'kamal', 'chennai', 56000),
(76, 'farhan', 'mumbai', 40000),
(77, 'preethi', 'pune', 45000),
(78, 'manish', 'delhi', 59000),
(79, 'irfan', 'bangalore', 42000),
(80, 'divakar', 'hyderabad', 51000),
(81, 'shoaib', 'chennai', 37000),
(82, 'soumya', 'mumbai', 53000),
(83, 'abhishek', 'pune', 46000),
(84, 'afsha', 'delhi', 39000),
(85, 'mahesh', 'bangalore', 61000),
(86, 'navya', 'hyderabad', 44000),
(87, 'syed', 'chennai', 50000),
(88, 'keerthi', 'mumbai', 36000),
(89, 'anil', 'pune', 55000),
(90, 'faiza', 'delhi', 47000),
(91, 'pradeep', 'bangalore', 40000),
(92, 'shruthi', 'hyderabad', 58000),
(93, 'zaheer', 'chennai', 43000),
(94, 'amrutha', 'mumbai', 49000),
(95, 'vinay', 'pune', 38000),
(96, 'saniya', 'delhi', 62000),
(97, 'raghu', 'bangalore', 45000),
(98, 'harsha', 'hyderabad', 52000),
(99, 'shabana', 'chennai', 41000),
(100, 'teja', 'mumbai', 57000);

-- verify the total number of customer records
select count(*) from customer;

-- =====================================================
-- task 2: create csv file format and s3 stage
-- =====================================================

-- create a csv file format for exporting and loading data
create or replace file format customer_csv_format
type = csv
field_optionally_enclosed_by = '"'
skip_header = 1;

-- create a stage connected to the aws s3 source_files folder
create or replace stage customer_export_stage
url = 's3://irfan-snowflake-s3-demo-2026/source_files/'
storage_integration = S3_INTEGRATION
file_format = customer_csv_format;

-- export customer records to a csv file in s3
copy into @customer_export_stage/customer_100_records.csv
from customer
file_format = (format_name = 'customer_csv_format')
header = true
single = true
overwrite = true;

-- =====================================================
-- task 3: load customer data into prestage_customer
-- =====================================================

-- create the prestage table to hold the loaded customer data
create or replace table prestage_customer (
    customer_id number,
    customer_name varchar(50),
    city varchar(50),
    salary number
);

-- load customer records from the s3 csv file into prestage
copy into prestage_customer
from @customer_export_stage/customer_100_records.csv
file_format = (format_name = 'customer_csv_format')
on_error = 'abort_statement';

-- verify the number of records loaded into prestage
select count(*) from prestage_customer;

-- =====================================================
-- task 4: load customer data into stage_customer
-- =====================================================

-- create the stage table
create or replace table stage_customer (
    customer_id number,
    customer_name varchar(50),
    city varchar(50),
    salary number
);

-- transfer all records from prestage to stage
insert into stage_customer
select *
from prestage_customer;

-- verify the number of records in stage
select count(*) from stage_customer;

-- =====================================================
-- task 5: load customer data into dim_customer
-- =====================================================

-- create the dimension table
create or replace table dim_customer (
    customer_id number,
    customer_name varchar(50),
    city varchar(50),
    salary number
);

-- transfer customer records from stage into the dimension table
insert into dim_customer
select *
from stage_customer;

-- inspect the dimension table
select * from dim_customer;

-- read individual csv fields directly from the staged file
select $1, $2, $3, $4
from @customer_export_stage/customer_100_records.csv
(file_format => 'customer_csv_format');

-- =====================================================
-- task 6: empty employee data validation
-- =====================================================

-- create an empty employee source table
create or replace table employee_source (
    employee_id number,
    employee_name varchar(50),
    department varchar(50),
    salary number
);

-- check whether the employee source contains any records
select count(*) from employee_source;

-- attempt to export the employee source data to s3
copy into @customer_export_stage/employee_empty.csv
from employee_source
file_format = (format_name = 'customer_csv_format')
header = true
single = true
overwrite = true;

-- create the employee prestage table
create or replace table prestage_employee (
    employee_id number,
    employee_name varchar(50),
    department varchar(50),
    salary number
);

-- load the employee csv file into prestage
copy into prestage_employee
from @customer_export_stage/employee_empty.csv
file_format = (format_name = 'customer_csv_format')
on_error = 'abort_statement';

-- create the employee stage table
create or replace table stage_employee (
    employee_id number,
    employee_name varchar(50),
    department varchar(50),
    salary number
);

-- create a procedure that loads employee data only when records exist
create or replace procedure load_employee_to_stage()
returns varchar
language sql
as
$$
declare
    total_records number;
begin
    -- count records in the prestage table
    select count(*) into :total_records
    from prestage_employee;

    -- load data only if the record count is greater than zero
    if (total_records > 0) then
        insert into stage_employee
        select * from prestage_employee;

        return 'data loaded successfully into stage_employee';

    -- return a message when there are no records to load
    else
        return 'data is less than or equal to 0';
    end if;
end;
$$;

-- execute the employee loading procedure
call load_employee_to_stage();

-- list files available in the s3 stage
list @customer_export_stage;

-- =====================================================
-- task 7: monthly lineitem aggregation
-- =====================================================

-- view the sample lineitem data
select *
from snowflake_sample_data.tpch_sf1.lineitem;

-- create a local copy of the shared sample lineitem table
create or replace table lineitem_copy as
select *
from snowflake_sample_data.tpch_sf1.lineitem;

-- add a number column to store the year and month from l_shipdate
alter table lineitem_copy
add column modify_data number;

-- store the ship date in yyyymm numeric format
-- example: 1996-02-10 becomes 199602
update lineitem_copy
set modify_data = to_number(to_char(l_shipdate, 'YYYYMM'));

-- aggregate quantity, extended price, discount, and tax by year and month
select
    modify_data,
    sum(l_quantity) as total_quantity,
    sum(l_extendedprice) as total_extendedprice,
    sum(l_discount) as total_discount,
    sum(l_tax) as total_tax
from lineitem_copy
group by modify_data
order by modify_data;
