create database upi_ecosystem;

use upi_ecosystem;


create table Remmiter_Banks (
UPI_Remitter_Banks text,
Date datetime,
Approved_percent double,
Bank_Decline_percent double,
Technical_Decline_percent double,
Debit_Reversal_Success_percent double,
Total_Debit_Reversal_Count_In_Million double,
Total_Volume_In_Million double
);

create table UPI_apps(
Application_Name text,
Date text,
Volume_B2B_Miilon double,
Value_B2B_Cr double,
Volume_B2C_Million double,
Value_B2C_Cr double,
Volume_Milllion double,
Value_Cr double,
Volume_Customer_Million double,
Value_Customer_Cr double
);

create table Benefeciary_banks(
Sr_No int,
UPI_Beneficiary_Banks text,
Date datetime,
Approved_percent double,
Deemed_Approved_percent double,
Bank_Decline_percent double,
Technical_Decline_percent double,
Total_Volume_In_Mn double
);



/*
load large dataset
using cmd promt

LOAD DATA LOCAL INFILE "C:\\Users\\SUDESHNA\\OneDrive\\Sudeshna Dey\\IVY\\Projects\\UPI Transaction-Benificiary-BenificiaryBank\\upi_apps.csv" 
INTO TABLE upi_apps						
FIELDS TERMINATED BY ','											
ENCLOSED BY '"'											
LINES TERMINATED BY '\r\n' IGNORE 1 ROWS; 

"C:\Users\SUDESHNA\OneDrive\Sudeshna Dey\IVY\Projects\UPI Transaction-Benificiary-BenificiaryBank\UPI_apps.csv"
"C:\Users\SUDESHNA\OneDrive\Sudeshna Dey\IVY\Projects\UPI Transaction-Benificiary-BenificiaryBank\Beneficiary_Banks.csv"

*/

set sql_safe_updates = 0;

alter table upi_apps
add column Date_new datetime;

update upi_apps
set date_new = str_to_date(date, '%d-%m-%Y %H:%i');

alter table upi_apps
drop column date;

alter table benefeciary_banks
add column Date_new datetime;

update benefeciary_banks
set date_new = str_to_date(date, '%Y-%m-%d %H:%i:%s');

alter table benefeciary_banks
drop column date;


select * from upi_apps;
select * from remmiter_banks;
select * from benefeciary_banks;


-- --------------------------- DATA ANALYSIS -----------------------------
-- ---------------- Part 1 ---- (UPI_Apps) -----------------------------
-- - Which are the top 3 applications by total transaction value across all months?

select  Application_Name,
		round(sum(value_customer_cr)) as total_transaction_value_Cr
from upi_apps
group by Application_Name
order by total_transaction_value_Cr desc limit 5 ;


-- - What is the month-over-month percentage change in transaction volume for each application?

with trans as(
 select month(date_new) as mnth,
		monthname(date_new) as month_name,
        round(sum(Volume_Customer_Million)) as current_month,
		lag(round(sum(Volume_Customer_Million)),1,0) over(order by month(date_new) asc) as previous_month
from upi_apps
group by mnth, month_name)
			
            select month_name, current_month, previous_month,
            round(((current_month - previous_month) / previous_month) * 100) as MOM_chang_percent
            from trans
;


-- - Which applications have B2B transaction value greater than B2C value for more than 3 months?


with cte2 as (
	with cte as (
select Application_Name,
		month(date_new) as mnth,
		round(sum(Value_B2B_Cr)) as b2b_transaction,
        round(sum(Value_B2C_Cr)) as b2c_transaction
from upi_apps
where Value_B2B_Cr <> 0 and Value_B2C_Cr <> 0
group by 1,2
order by 2)
        select Application_Name, mnth,
				case when b2b_transaction > b2c_transaction then 'B2B'  end as status
		from cte)
				select 	Application_Name,
				count(status) as no_of_mnths
				from cte2 
				where status = 'B2B'
				group by Application_Name having count(status) > 3

;



-- - Which month had the highest average transaction value per customer (Value / Volume)?


select monthname(date_new) as mnth_name,
		round(avg(Value_Customer_Cr / volume_customer_million)) as avg_transaction_value_cr
from upi_apps
group by mnth_name
order by avg_transaction_value_cr desc limit 1  ;


-- - For each application, what is the percentage share of B2C & B2B volume in total volume?

create view UPI_app_annual_share as (
with cte as ( select  Application_Name, year(Date_new) as year,
			sum(Volume_B2C_Million)  as total_B2c_volume,
			sum(Volume_B2B_Miilon)  as total_B2B_volume,
			sum(Volume_Milllion) as total_volume from upi_apps
			group by Application_Name, year )
				select Application_Name, year,
				round(( total_B2c_volume / total_volume ) * 100, 2) as B2C_percent_share,
				round(( total_B2B_volume / total_volume ) * 100, 2) as B2B_percent_share from cte
				where total_B2c_volume <> 0 and total_B2B_volume <> 0
				order by year , B2C_percent_share desc , B2B_percent_share desc );
-- create views
select * from upi_app_annual_share;
       
	
       
       
-- ------------------ Part 2 ---- (Remmiter & Benefeciary) -----------------------------

-- - Which remitter banks have the highest average debit reversal success rates?

select UPI_Remitter_Banks, 
		round(avg(Debit_Reversal_Success_percent),2)  as Avg_debit_reversal_success_rate
from remmiter_banks 
group by UPI_Remitter_Banks 
order by Avg_debit_reversal_success_rate desc
;



-- - Which beneficiary banks show consistently high “Deemed Approved %” over 3 consecutive months?


WITH avg_val AS ( SELECT AVG(Deemed_Approved_percent) AS avg_approved FROM benefeciary_banks ),
	cte AS (SELECT 
    UPI_Beneficiary_Banks,
    date_new,
    MONTH(date_new) AS month,
    YEAR(date_new) AS year,
    Deemed_Approved_percent,
    LAG(Deemed_Approved_percent, 1) OVER (PARTITION BY UPI_Beneficiary_Banks ORDER BY YEAR(date_new), MONTH(date_new)) AS prev_1,
    LAG(Deemed_Approved_percent, 2) OVER (PARTITION BY UPI_Beneficiary_Banks ORDER BY YEAR(date_new), MONTH(date_new)) AS prev_2,
    LAG(MONTH(date_new), 1) OVER (PARTITION BY UPI_Beneficiary_Banks ORDER BY YEAR(date_new), MONTH(date_new)) AS prev_m1,
    LAG(MONTH(date_new), 2) OVER (PARTITION BY UPI_Beneficiary_Banks ORDER BY YEAR(date_new), MONTH(date_new)) AS prev_m2
from benefeciary_banks
)
SELECT 
  UPI_Beneficiary_Banks,
  date_new AS Current_Month,
  Deemed_Approved_percent as Current_Month_Percent,
  prev_1 AS Previous_Month_Percent,
  prev_2 AS Two_Months_Ago_Percent
FROM cte, avg_val
WHERE 
  Deemed_Approved_percent > avg_approved AND
  prev_1 > avg_approved AND
  prev_2 > avg_approved AND
  prev_m1 = month - 1 AND
  prev_m2 = month - 2
ORDER BY UPI_Beneficiary_Banks, date_new;





-- - Which months show a remitter bank with BD% > 10% and TD% > 5%?

select  
rank() over(partition by year(date_new) order by avg(Bank_Decline_percent) desc, 
			avg(Technical_Decline_percent) desc) as rn,
		UPI_Beneficiary_Banks,
		year(date_new) as year,
		month(date_new) as month,
        avg(Bank_Decline_percent) as BD_grt_thn_10,
        avg(Technical_Decline_percent) as TD_grt_thn_5
from benefeciary_banks
where Bank_Decline_percent > 0.01 -- 10% for this data
and Technical_Decline_percent > 0.005 -- 5%
group by UPI_Beneficiary_Banks , year, month
order by rn asc, year, BD_less_thn_10 desc;


-- - Which banks appear in both remitter and beneficiary tables, and how do their approval rates compare?

select r.UPI_Remitter_Banks as bank_name,
		round(avg(r.Approved_percent),2) as remitter_approved_percent,
        round(avg(b.Approved_percent),2) as beneficiary_approved_percent
from remmiter_banks as r join benefeciary_banks as b
on r.UPI_Remitter_Banks = b.UPI_Beneficiary_Banks
group by bank_name
order by remitter_approved_percent desc;

-- -- ------------------ Part 3 ---- (Advance-Joins_Window_Subqueary) -----------------------------

-- For banks that are both remitters and beneficiaries, is there a mismatch in sent vs. received volumes in the same month?

create view bank_volume_Mismatch as (
SELECT 
    r.UPI_Remitter_Banks AS Bank_Name,
    year(r.date) as year, month(r.date) as month,
    SUM(r.Total_Volume_In_Million) AS Sent_Volume_M,
    SUM(b.Total_Volume_In_Mn) AS Received_Volume_M,
    round(abs(SUM(r.Total_Volume_In_Million) - SUM(b.Total_Volume_In_Mn)),2) AS Volume_Difference_M
FROM remmiter_banks r
JOIN benefeciary_banks b
    ON r.UPI_Remitter_Banks = b.UPI_Beneficiary_Banks
   AND r.date = b.date_new
GROUP BY Bank_Name, year, month
order by year, month 
);



-- - Calculate the difference between each bank’s 3-month moving average of approval % and the current month’s approval %.

create view consistent_high_approval as (
with cte as (
		select UPI_Remitter_Banks,
		 date,
        round(Approved_percent,3) as current_mnth_approval,
        round(avg(Approved_percent) over(partition by UPI_Remitter_Banks order by date rows between 2 preceding and current row),3) as Moving_avg_3_mnths_approval
from remmiter_banks)

			select UPI_Remitter_Banks, date,
            current_mnth_approval,
            Moving_avg_3_mnths_approval,
            round(current_mnth_approval - Moving_avg_3_mnths_approval, 3) as deveiation_from_mov_avg
            from cte 
            order by UPI_Remitter_Banks, date
            );
		
-- check views
select *  from consistent_high_approval;
            
-- - Find the month when a remitter bank first entered the top 5 by total volume
-- store in procedure for dynamicaly use topN

delimiter //
create procedure get_topN_entry_by_volume_filtered (in top_n int)
begin
with cte as (	
		select UPI_Remitter_Banks, 
		date,
        Total_Volume_In_Million,
        rank() over(partition by date order by Total_Volume_In_Million desc) as rnk
from remmiter_banks)
                select UPI_Remitter_Banks,
                min(date) as first_top_N_entry
                from cte 
                where rnk <= top_n 
                group by UPI_Remitter_Banks
                order by first_top_N_entry;
end //
delimiter ;

-- check topN 
call get_topN_entry_by_volume_filtered (5);
