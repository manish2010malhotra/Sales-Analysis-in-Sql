--create database Retail_basic_study

--use Retail_basic_study

select top 1 *from Transactions 
select  top 1 * from Customer
select  *from prod_cat_info

--Q1 
select count(*)as NO_OF_RECORDS from Customer
UNION ALL
select count(*)as NO_OF_RECORDS from Transactions
UNION ALL
select count(*)as NO_OF_RECORDS from prod_cat_info 

--Q2	
--select *from Transactions
Select count (distinct(transaction_id )) as total_returns from Transactions
where Qty<0

--Q3 covert datetype into another date type

select CONVERT(date,tran_date,105) as tran_date from Transactions

--Q4-- date difference between years , months , days --- {time range = max -min} -- new type--

select DATEDIFF(year,min(CONVERT(date,tran_date,105)),max(CONVERT(date,tran_date,105)))as diff_years,
DATEDIFF(MONTH,min(CONVERT(date,tran_date,105)),max(CONVERT(date,tran_date,105)))as diff_months,
DATEDIFF(DAY,min(CONVERT(date,tran_date,105)),max(CONVERT(date,tran_date,105)))as diff_day
from Transactions

--Q5--
 select prod_cat , prod_subcat from prod_cat_info
 where prod_subcat = 'DIY'

 ---DATA ANALYSIS---

select *from Transactions 
select * from Customer
select *from prod_cat_info

 ---Q1--
 select  top 1 Store_type, count(*) as frequency from Transactions
 group by store_type
 order by frequency desc

 ---Q2--
 
 select Gender ,count(*) as Total_count from Customer
  where Gender is not null
  group by Gender
  order by Gender desc

  --Q3--
  select top 1 city_code , count(*) as max_cust from Customer
  where city_code is not null
  group by city_code
  order by max_cust desc

 ---Q4--- total count

  select prod_cat ,count(*) as max_count from prod_cat_info
  where prod_cat ='books'
  group by prod_cat

--Q4 (a)-- name of the sub category under books category

select prod_cat ,prod_subcat from prod_cat_info
where prod_cat = 'books'

---Q5---
select prod_cat_code , max(qty) as Max_count from Transactions
group by prod_cat_code

---Q6--

select SUM(total_amt) as net_revenue from prod_cat_info as P1
inner join transactions as T1
ON P1.prod_cat_code = T1.prod_cat_code AND p1.prod_sub_cat_code=T1.prod_subcat_code
where prod_cat IN ('BOOKS','ELECTRONICS')

                              -------OR-------

select SUM(cast(total_amt as float)) as net_revenue from prod_cat_info as P1
inner join transactions as T1
ON P1.prod_cat_code = T1.prod_cat_code AND p1.prod_sub_cat_code=T1.prod_subcat_code
where prod_cat IN ('BOOKS','ELECTRONICS')

--Q7--

select count(*) as total_cust from (
select cust_id , COUNT(distinct(transaction_id)) as count_transactions from Transactions
where qty>0
group by cust_id
having COUNT(distinct(transaction_id)) >10) as T1

--Q8--
select sum(cast(total_amt as float)) as combined_revenue from prod_cat_info as P1
join transactions as T1
ON P1.prod_cat_code = T1.prod_cat_code AND p1.prod_sub_cat_code=T1.prod_subcat_code
where prod_cat in ('clothing', ' electronics') and Store_type = 'flagship store' and Qty>0

---Q9-- imp questions--

select  prod_subcat ,sum(total_amt) as total_revenue from Customer as C1
join Transactions as T1
on c1.customer_Id = t1.cust_id
join prod_cat_info as P1
on T1.prod_subcat_code = P1.prod_sub_cat_code
where Gender='M' and prod_cat ='Electronics'
group by prod_subcat


--Q10-- percentage sales ---important questions--

select  t2.prod_subcat , percentage_sales ,percentage_returns from(

select  Top 5 prod_subcat , (sum(cast(total_amt as float))/ (select (sum(cast(total_amt as float))) as total_sales 
from Transactions where qty>0)) as percentage_sales
from prod_cat_info as P1
inner join transactions as T1
ON P1.prod_cat_code = T1.prod_cat_code AND p1.prod_sub_cat_code=T1.prod_subcat_code
where qty >0
group by prod_subcat
order by percentage_sales desc) as T2

join

--percentage returns--
(
select  prod_subcat , (sum(cast(total_amt as float))/ (select (sum(cast(total_amt as float))) as total_sales 
from Transactions where qty<0)) as percentage_returns
from prod_cat_info as P1
inner join transactions as T1
ON P1.prod_cat_code = T1.prod_cat_code AND p1.prod_sub_cat_code=T1.prod_subcat_code
where qty<0
group by prod_subcat) as T3
on T2.prod_subcat =T3.prod_subcat

--Q11-- 
select top 1 *from Transactions 
select top 1 * from Customer
select top 1 *from prod_cat_info

---age of customers --

select * from (
select * from ( 
select cust_id , Datediff (YEAR,dob , max_date) as age , revenue from ( 
Select cust_id , DOB, max(convert(date , tran_date , 105)) as max_date , sum(cast(total_amt as float)) as revenue from Customer as t1 
join Transactions as t2 
on t1.customer_Id = t2.cust_id
where Qty>0
group by cust_id , DOB
) as A 
         )as B
where age between 25 and 35
) as C
Join (
----last 30 days of transactions 
select cust_id , convert(date  , tran_date , 105 ) as tran_date  from Transactions
group by cust_id, convert (date , tran_date , 105)
having convert (date , tran_date , 105) >=(
select DATEADD (day, -30 ,  max(convert(date , tran_date,105))) as cutoff_date from Transactions) ) as D 
on C.cust_id = D.cust_id

---Q12--
select top 1 prod_cat_code  , sum(returns) as total_returns from (
select  prod_cat_code , CONVERT(date , tran_date, 105) as tran_date , sum(qty) as returns from Transactions
where Qty <0
group by prod_cat_code ,  convert (date , tran_date , 105)
having  convert (date , tran_date , 105) >=(
select DATEADD (Month, -3 ,  max(convert(date , tran_date,105))) as cutoff_date from Transactions)) as A
group by prod_cat_code
order by total_returns

--Q13--

select store_type , sum(cast(total_amt as float)) as revenue , sum(qty) as quantity
from Transactions
where qty > 0
group by Store_type
order by revenue desc , quantity desc

--Q14--

select prod_cat_code , avg(cast(total_amt as float)) as avg_revenue from Transactions
where qty>0
group by prod_cat_code
having avg(cast(total_amt as float)) >= (select avg(cast(total_amt as float)) from Transactions where qty >0)

--Q15--

select prod_subcat_code ,sum(cast(total_amt as float)) as revenue , avg (cast(total_amt as float)) as avg_revenue
from Transactions
where qty > 0 and  prod_cat_code in (select  top 5 prod_cat_code  from Transactions
                                       where qty > 0
                                       group by prod_cat_code
                                       order by sum(qty)desc)
group by prod_subcat_code

