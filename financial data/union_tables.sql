-- STANDARDIZATION OF REPORTING DATES
-- Analyzing the data and combining with business knowledge, companies usually have different definitions of fiscal quarters and fiscal years. 
-- That is to say, fiscal quarters do not always line up with the calendar year.
-- As an investor to analyze the company stocks, I'll normalize "annually" and "quarterly" with the *internal reporting period* defined below.

with stock as (
    select stock from balanceSheetHistory_annually
    union
    select stock from cashflowStatement_annually
    union
    select stock from incomeStatementHistory_annually)
select * from stock;


-- create table for "annually" with standardized year

drop table if exists financial_data_root_a;
create table financial_data_root_a as
-- union the tables to have all the dates
with all_years as (
    select distinct stock, endDate from balanceSheetHistory_annually
    union
    select distinct stock, endDate from cashflowStatement_annually
    union
    select distinct stock, endDate from incomeStatementHistory_annually)
select distinct *,
    -- *internal reporting period*
    -- If the reporting month for "yearly" is before June, the yearly results count for the previous year. 
    -- If the reporting month for "yearly" is after june, the yearly results count for the current year
    case
    when cast(strftime("%m", endDate) as integer) between 1 and 6 then cast(strftime("%Y", endDate) as integer)-1
    when cast(strftime("%m", endDate) as integer) between 7 and 12 then cast(strftime("%Y", endDate) as integer)
    else null end as year
from all_years;
select * from financial_data_root_a;


-- create table for "quarterly" with standardized quarter

drop table if exists financial_data_root_q;
create table financial_data_root_q as
-- union the tables to have all the dates
with all_dates as (
    select distinct stock, endDate,  strftime("%Y", endDate) as year from balanceSheetHistory_quarterly
    union
    select distinct stock, endDate,  strftime("%Y", endDate) as year from cashflowStatement_quarterly
    union
    select distinct stock, endDate,  strftime("%Y", endDate) as year from incomeStatementHistory_quarterly)
select distinct *,
    -- *internal reporting period*
    -- The "quarterly" are to be analyzed separated from "annually".
    -- Normalize the fiscal quarters according to the standard quarters. 
    case 
    when cast(strftime("%m", endDate) as integer) between 1 and 3 then 1
    when cast(strftime("%m", endDate) as integer) between 4 and 6 then 2
    when cast(strftime("%m", endDate) as integer) between 7 and 9 then 3
    when cast(strftime("%m", endDate) as integer) between 10 and 12 then 4
else null end as quarter
from all_dates;
select * from financial_data_root_q;