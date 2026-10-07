-- ============================================================
-- CUSTOMER ETL PIPELINE
-- Snowflake + AWS S3
-- ============================================================
-- Purpose:
-- Export customer data from Snowflake to AWS S3,
-- load the data through PRE_STAGE and STAGE layers,
-- load the final DIM_CUSTOMER table,
-- and create an archive file in S3.
--
-- Architecture:
-- Snowflake CUSTOMER
--        ↓
-- AWS S3
--        ↓
-- PRE_STAGE_CUSTOMER
--        ↓
-- STAGE_CUSTOMER
--        ↓
-- DIM_CUSTOMER
--        ↓
-- AWS S3 Archive
-- ============================================================


-- ============================================================
-- 1. CREATE S3 STAGE
-- ============================================================
-- Creates a Snowflake external stage connected to the
-- AWS S3 bucket through the S3 storage integration.

CREATE OR REPLACE STAGE CUSTOMER_S3_STAGE
STORAGE_INTEGRATION = S3_INTEGRATION
URL = 's3://irfan-snowflake-s3-demo-2026/source_files/';


-- ============================================================
-- 2. EXPORT CUSTOMER DATA FROM SNOWFLAKE TO S3
-- ============================================================
-- Creates a dynamic procedure to export customer data
-- from Snowflake to an S3 text file.
--
-- Filename format:
-- dim_customer_YYYYMMDDHH24MISS.txt
--
-- LIMIT 1000 is used for testing/practice.

CREATE OR REPLACE PROCEDURE EXPORT_CUSTOMER_TO_S3()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    V_FILENAME STRING;
    V_SQL STRING;
BEGIN

    V_FILENAME := 'dim_customer_' ||
                  TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS') ||
                  '.txt';

    V_SQL := 'COPY INTO @CUSTOMER_S3_STAGE/' || V_FILENAME ||
             ' FROM (
                 SELECT *
                 FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER
                 LIMIT 1000
             )' ||
             ' FILE_FORMAT = (
                    TYPE = CSV
                    FIELD_OPTIONALLY_ENCLOSED_BY = ''"''
                    COMPRESSION = NONE
                )' ||
             ' SINGLE = TRUE OVERWRITE = TRUE';

    -- Executes the dynamically generated COPY INTO command.
    EXECUTE IMMEDIATE V_SQL;

    RETURN 'CUSTOMER EXPORT COMPLETED: ' || V_FILENAME;

END;
$$;


-- Execute the export procedure.
CALL EXPORT_CUSTOMER_TO_S3();


-- Verify the exported customer files in the S3 stage.
LIST @CUSTOMER_S3_STAGE
PATTERN = '.*dim_customer_.*\.txt';


-- ============================================================
-- 3. CREATE PRE-STAGE TABLE
-- ============================================================
-- Creates an empty PRE_STAGE_CUSTOMER table using the
-- structure of the CUSTOMER source table.
--
-- PRE_STAGE acts as the initial/raw staging layer.

CREATE OR REPLACE TABLE PRE_STAGE_CUSTOMER AS
SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER
WHERE 1 = 0;


-- ============================================================
-- 4. LOAD DATA INTO PRE-STAGE
-- ============================================================
-- Loads the exported customer file from S3 into
-- PRE_STAGE_CUSTOMER.

COPY INTO PRE_STAGE_CUSTOMER
FROM @CUSTOMER_S3_STAGE
PATTERN = '.*dim_customer_.*\.txt'
FILE_FORMAT = (
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    COMPRESSION = NONE
);


-- ============================================================
-- 5. CREATE STAGE TABLE
-- ============================================================
-- Creates STAGE_CUSTOMER using PRE_STAGE_CUSTOMER.
-- INSERT_GMT_TIMESTAMP records when the record enters
-- the staging layer.

CREATE OR REPLACE TABLE STAGE_CUSTOMER AS
SELECT
    *,
    CURRENT_TIMESTAMP()::TIMESTAMP AS INSERT_GMT_TIMESTAMP
FROM PRE_STAGE_CUSTOMER
WHERE 1 = 0;


-- ============================================================
-- 6. LOAD PRE-STAGE DATA INTO STAGE
-- ============================================================

INSERT INTO STAGE_CUSTOMER
SELECT
    *,
    CURRENT_TIMESTAMP()::TIMESTAMP AS INSERT_GMT_TIMESTAMP
FROM PRE_STAGE_CUSTOMER;


-- ============================================================
-- 7. FLUSH PRE-STAGE
-- ============================================================
-- Removes existing records from PRE_STAGE while keeping
-- the table structure.

TRUNCATE TABLE PRE_STAGE_CUSTOMER;


-- ============================================================
-- 8. FILL PRE-STAGE AGAIN
-- ============================================================
-- Reloads fresh customer data from the S3 file.

COPY INTO PRE_STAGE_CUSTOMER
FROM @CUSTOMER_S3_STAGE
PATTERN = '.*dim_customer_.*\.txt'
FILE_FORMAT = (
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    COMPRESSION = NONE
);


-- ============================================================
-- 9. LOAD DATA INTO STAGE
-- ============================================================

INSERT INTO STAGE_CUSTOMER
SELECT
    *,
    CURRENT_TIMESTAMP()::TIMESTAMP AS INSERT_GMT_TIMESTAMP
FROM PRE_STAGE_CUSTOMER;


-- ============================================================
-- 10. CREATE FINAL DIMENSION TABLE
-- ============================================================
-- Creates DIM_CUSTOMER using STAGE_CUSTOMER.
--
-- INSERT_GMT_TIMESTAMP:
-- Records when the record was inserted into the pipeline.
--
-- UPDATE_GMT_TIMESTAMP:
-- Records the timestamp associated with the DIM load/update.

CREATE OR REPLACE TABLE DIM_CUSTOMER AS
SELECT
    *,
    CURRENT_TIMESTAMP()::TIMESTAMP AS UPDATE_GMT_TIMESTAMP
FROM STAGE_CUSTOMER
WHERE 1 = 0;


-- ============================================================
-- 11. LOAD DATA INTO DIM_CUSTOMER
-- ============================================================

INSERT INTO DIM_CUSTOMER
SELECT
    *,
    CURRENT_TIMESTAMP()::TIMESTAMP AS UPDATE_GMT_TIMESTAMP
FROM STAGE_CUSTOMER;


-- ============================================================
-- 12. CREATE TEST ARCHIVE FILE
-- ============================================================
-- Creates an archive copy of DIM_CUSTOMER in S3.
--
-- This was used for testing the archive process.

COPY INTO @CUSTOMER_S3_STAGE/dim_customer_2026100721.txt
FROM (
    SELECT *
    FROM DIM_CUSTOMER
)
FILE_FORMAT = (
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    COMPRESSION = NONE
)
SINGLE = TRUE
OVERWRITE = TRUE;


-- ============================================================
-- 13. CREATE DYNAMIC ARCHIVE PROCEDURE
-- ============================================================
-- Creates an archive file from DIM_CUSTOMER.
--
-- Archive filename format:
-- dim_customer_YYYYMMDDHH24MI.txt

CREATE OR REPLACE PROCEDURE ARCHIVE_DIM_CUSTOMER()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    V_FILENAME STRING;
    V_SQL STRING;
BEGIN

    V_FILENAME := 'dim_customer_' ||
                  TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MI') ||
                  '.txt';

    V_SQL := 'COPY INTO @CUSTOMER_S3_STAGE/' || V_FILENAME ||
             ' FROM (SELECT * FROM DIM_CUSTOMER)' ||
             ' FILE_FORMAT = (
                    TYPE = CSV
                    FIELD_OPTIONALLY_ENCLOSED_BY = ''"''
                    COMPRESSION = NONE
                )' ||
             ' SINGLE = TRUE OVERWRITE = TRUE';

    -- Executes the dynamically generated archive command.
    EXECUTE IMMEDIATE V_SQL;

    RETURN 'ARCHIVE CREATED: ' || V_FILENAME;

END;
$$;


-- Execute the archive procedure.
CALL ARCHIVE_DIM_CUSTOMER();


-- Verify the generated archive files.
LIST @CUSTOMER_S3_STAGE
PATTERN = '.*dim_customer_.*\.txt';


-- ============================================================
-- 14. REMOVE ORIGINAL WORKING FILE
-- ============================================================
-- Removes the original working/export file after the
-- DIM load and archive creation are completed.
--
-- NOTE:
-- This command requires the AWS IAM role used by Snowflake
-- to have s3:DeleteObject permission on the S3 location.

REMOVE @CUSTOMER_S3_STAGE/dim_customer_20261007095053.txt;


-- ============================================================
-- END OF CUSTOMER ETL PIPELINE
-- ============================================================
