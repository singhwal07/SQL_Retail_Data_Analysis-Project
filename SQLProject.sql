---SQL Project

--Q1 1.	What is the total number of rows in each of the 3 tables in the database?

--total Count of Customer Table
Select count(*) As TotalRecords from Customer

--total Count of Transactions Table
Select count(*) as TotalRecords from Transactions

--total Count of Prod_Cat_Info table
Select count(*) as TotalRecords from prod_cat_info


--Q2. What is the total number of transactions that have a return?

Select * from Transactions
Where Total_amt > 0


--Q3. As you would have noticed , the dates provided across the datasets are not in a
--correct format. As first, steps, please convert the date variable into valid date
--formats before preceding ahead.

--Converting Customer DOB variable into Date Format
Alter Table Customer
Alter Column DOB Date

--Converting Transactions table Tran_date column into Date Format
Alter Table Transactions
Alter Column tran_date Date


--Q4. What is the time range of the transactions data available for analysis? Show the output
--in the number of days, months and years simultaneously in different columns .

Select Datediff(Year, min(tran_date) , max(tran_date)) as Total_Year, 
Datediff(Month, min(tran_date), max(tran_date)) as Total_Month,
Datediff(Day, min(tran_date), max(tran_date)) as Total_Days from Transactions


--Q5. Which product category does the sub-category “DIY” belongs to.

Select Prod_cat from prod_cat_info
Where prod_subcat = 'DIY'


--Data Analysis


--Q1. Which channel is most frequently used for transactions?


Select Top 1 Store_type, count(*) as Total_Transactions from Transactions
group by Store_Type
order by Count(*) desc


--Q2. What is the count of Male and Female Customers in the database?

Select Gender , count(*) as Total_Customer from Customer
Where Gender is not null
group by Gender


--Q3.From which city do we have the maximum number of customers and how many?


Select Top 1 city_code , Count(customer_id) as Total_Customer from Customer
Where city_code is not null
group by city_code
Order by Count(customer_id)


--Q4. How many sub categories are there under the Books Category?


Select prod_cat , count(prod_subcat) as TotalSubCategory from prod_cat_info
Where prod_cat = 'Books'
group by prod_cat


--Q5. What is the maximum quantity of products ever ordered?


select max(qty) as MaxQty from Transactions


--Q6 What is the total net revenue generated in categories Electronics and Books?


Select P.prod_cat , convert(int,sum(T.Total_amt - T.Tax)) as Net_Revenue from prod_cat_info as P
left join Transactions as T on 
P.prod_cat_code = T.prod_cat_code and P.prod_sub_cat_code = T.prod_subcat_code
where P.prod_cat in ('Books','Electronics')
group by P.prod_cat


--Q7 How many customers have >10 transactions with us, excluding returns?


Select Count(Cust_id) as Total_Customer from 
(Select T.Cust_ID, Count(T.Cust_ID) as TotalTransactions from Transactions as T
where total_amt > 0
group by T.Cust_ID
having Count(T.Cust_ID) > 10 ) as tbl


--Q8 What is the combined revenue earned from the “Electronics” and “Clothing” 
--categories, from “Flagship stores”?


Select Sum(T.Total_amt - T.Tax) as TotalRevenue from Transactions as T
inner join prod_cat_info as P
on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
where P.prod_cat in ('Electronics','Clothing') and T.Store_type = 'Flagship store'


--Q9 What is the total revenue generated from “Male” customers in 
--“Electronics” category? Output Should be display revenue by prod sub-cat.


Select P.prod_subcat , convert(int,sum(T.Total_amt - T.Tax)) as Total_Revenue
from Customer as C inner join Transactions as T
on C.customer_Id = T.cust_id
inner join prod_cat_info as P
on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
Where C.Gender = 'M' and P.prod_cat = 'Electronics'
group by  p.prod_subcat


--Q10. What is the percentage of sales and returns by product sub category;
--display only top 5 subcategories in item of sales?


With Sales_table as
(Select P.Prod_SubCat, Sum(T.total_amt)as Total_Sales,
format(sum(T.total_amt) / (Select sum(total_amt) from Transactions),'P') as Sales_Percentage
from prod_cat_info as P inner join Transactions as T
on P.prod_cat_code = T.prod_cat_code and P.prod_sub_cat_code = T.prod_subcat_code
group by P.prod_subcat),
return_table as 
(Select P.Prod_SubCat, Sum(T.total_amt)as Total_Sales,
format(Sum(T.Total_amt) / (select sum(total_amt) from Transactions where Transactions.total_amt < 0),'P') as Return_Percentage
from prod_cat_info as P inner join Transactions as T
on P.prod_cat_code = T.prod_cat_code and P.prod_sub_cat_code = T.prod_subcat_code
where T.total_amt < 0
group by P.prod_subcat)
Select Top 5 S.Prod_SubCat, S.Total_Sales, S.Sales_Percentage, R.Return_Percentage from 
Sales_table as S left join Return_table as R
on S.Prod_SubCat = R.Prod_SubCat
order by S.total_sales Desc


--11. For all customer age between 25 to 35 years
--find the what is the total net revenue generated by 
--these consumers in last 30 days of transactions 
--from max transaction date available in the data.


declare @maxdate date
select @maxdate = max(tran_date) from Transactions
Select sum(T.total_amt-T.Tax) as TotalRevenue from Transactions as T inner join Customer as C
on T.cust_id = C.customer_Id
where Datediff(Year,DOB,getdate()) between 25 and 35 and T.tran_date >= DATEADD(Day,-30,@maxdate)


--Q12. Which product category has seen the max value of returns in the last 
--3 months of transactions?


declare @maxdate2 date
select @maxdate2 = max(tran_date) from Transactions
Select Top 1 P.Prod_cat,abs(sum(t.qty)) as TotalReturnSum, abs(Count(t.qty)) as TotalReturnTransactions
from Transactions as T inner join prod_cat_info as P
on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
where (T.qty < 0) and T.Tran_date between DateAdd(Month,-3,@maxdate2) and @maxdate2
group by P.Prod_cat
order by sum(t.qty)


--Q13 Which Store type sells the maximum products: 
--by value of sales amount and by quantity sold?


Select Top 1 Store_Type, sum(Qty) as TotalQty, sum(Total_amt) as TotalAmount from Transactions
group by Store_type
order by sum(Qty) desc


--Q14 What are the categories for which average revenue is above the overall average?


declare @avgsales float
select @avgsales = avg(total_amt - tax) from Transactions
Select P.Prod_cat , avg(T.Total_amt - T.tax) as AvgRevenue 
from prod_cat_info as P inner join Transactions as T
on P.prod_cat_code = T.prod_cat_code and P.prod_sub_cat_code = T.prod_subcat_code
group by P.Prod_cat
having avg(T.Total_amt - T.tax) > @avgsales


--Q15 Find the average and total revenue by each subcategory
--for the categories which are the among top 5 categories in terms of quantity sold?


Select P.prod_cat, P.Prod_subcat, convert(int,Avg(T.total_amt)) as Avg_Sales , convert(int,Sum(T.total_amt)) as TotalSales from 
prod_cat_info as P inner join Transactions as T
on p.prod_cat_code = T.prod_cat_code and P.prod_sub_cat_code = T.prod_subcat_code
where P.prod_cat in (
Select Top 5 P.Prod_Cat from prod_cat_info as P inner join Transactions as T
on P.prod_cat_code = T.prod_cat_code and P.prod_sub_cat_code = T.prod_subcat_code
group by P.prod_cat
Order by Sum(T.Qty) desc
)
group by P.prod_cat, P.Prod_subcat
order by P.prod_cat