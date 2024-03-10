--drop table if exists mart.f_customer_retention;

CREATE TABLE if not exists mart.f_customer_retention (
	new_customers_count int8 not NULL,
	returning_customers_count int8 not NULL,
	refunded_customer_count int8 not NULL,
	period_name text not NULL,
	period_id int4 not NULL,
	item_id int4 not NULL,
	new_customers_revenue numeric not NULL,
	returning_customers_revenue numeric not NULL,
	customers_refunded numeric not NULL
);

delete from mart.f_customer_retention;

with NewCustomer as 
(select 
fsal.item_id 
,dc.year_actual*100+dc.week_of_year as periodnum
,fsal.customer_id
,fsal.quantity
,fsal.payment_amount 
,case when 
	 count(dcu.customer_id) 
	     --Добавлено в группировку категория товара, т.е. теперь учитываются только вернувшиеся уникальные покупатели за той же категорией товара
	     over(partition by dcu.customer_id, dc.week_of_year,fsal.item_id ) = 1
	then 'neword' 
	else 'return' end 
	as Nstatus
,fsal.status
from mart.f_sales fsal
left join mart.d_customer dcu on fsal.customer_id = dcu.customer_id  
left join mart.d_calendar dc on fsal.date_id =dc.date_id
order by 2,3
--where fsal.item_id=7 and dc.week_of_year=10
)
INSERT INTO mart.f_customer_retention
(new_customers_count, returning_customers_count, refunded_customer_count, period_name, period_id, item_id, new_customers_revenue, returning_customers_revenue, customers_refunded)
select 
count(distinct case when Nstatus='neword' then customer_id end) as new_customers_count
,count(distinct case when Nstatus='return' then customer_id end) as returning_customers_count
,count(distinct case when status='refunded' then customer_id end) as refunded_customer_count
,'weekly' as period_name
,periodnum as period_id
,item_id 
,sum(distinct case when Nstatus='neword' then payment_amount else 0 end) as new_customers_revenue
,sum(distinct case when Nstatus='return' then payment_amount else 0 end) as returning_customers_revenue
,sum(distinct case when status='refunded' then -1*quantity else 0 end) as customers_refunded
from NewCustomer as nc group by periodnum,item_id

