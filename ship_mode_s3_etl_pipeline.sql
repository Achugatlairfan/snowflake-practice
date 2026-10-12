create or replace stage ship_mode_s3_stage
storage_integration = s3_integration
url = 's3://irfan-snowflake-s3-demo-2026/source_files/';

create or replace procedure export_ship_mode_to_s3()
returns string
language sql
as
$$
declare
    v_filename string;
    v_sql string;
begin
    v_filename := 'ship_mode_' ||
                  to_varchar(current_timestamp(), 'YYYYMMDDHH24MISS') ||
                  '.txt';

    v_sql := 'copy into @ship_mode_s3_stage/' || v_filename ||
             ' from (
                 select *
                 from snowflake_sample_data.tpcds_sf100tcl.ship_mode
             )' ||
             ' file_format = (
                    type = csv
                    field_optionally_enclosed_by = ''"''
                    compression = none
                )' ||
             ' single = true overwrite = true';

    execute immediate v_sql;

    return 'SHIP_MODE EXPORT COMPLETED: ' || v_filename;
end;
$$;

call export_ship_mode_to_s3();


create or replace table pre_stage_ship_mode as
select *
from snowflake_sample_data.tpcds_sf100tcl.ship_mode
where 1 = 0;


list @ship_mode_s3_stage;

copy into pre_stage_ship_mode
from @ship_mode_s3_stage/ship_mode_20261012091552.txt
file_format = (
    type = csv
    field_optionally_enclosed_by = '"'
    compression = none
)
on_error = 'abort_statement';

select * from pre_stage_ship_mode;


create or replace table stage_ship_mode as
select *,
current_timestamp() as insert_gmt_timestamp
from pre_stage_ship_mode
where 1 = 0;


insert into stage_ship_mode
select *,
current_timestamp() as insert_gmt_timestamp
from pre_stage_ship_mode;


select * from stage_ship_mode;

truncate table pre_stage_ship_mode;


copy into pre_stage_ship_mode
from @ship_mode_s3_stage/ship_mode_20261012091552.txt
file_format = (
    type = csv
    field_optionally_enclosed_by = '"'
    compression = none
)
on_error = 'abort_statement';
truncate table stage_ship_mode;

insert into stage_ship_mode
select *,
current_timestamp() as insert_gmt_timestamp
from pre_stage_ship_mode;

truncate table dim_ship_mode;

insert into dim_ship_mode
select *
from stage_ship_mode;


select current_database(), current_schema(), current_role();
show tables like 'DIM_SHIP_MODE' in schema ZOMATO.PUBLIC;


create or replace table zomato.public.dim_ship_mode as
select *
from zomato.public.stage_ship_mode
where 1 = 0;


truncate table zomato.public.dim_ship_mode;


insert into zomato.public.dim_ship_mode
select *
from zomato.public.stage_ship_mode;


select * from zomato.public.dim_ship_mode;

desc integration s3_integration;

