alter table staging.user_order_log add column status varchar(8) not null default 'shipped';
alter table mart.f_sales add column status varchar(8) not null default 'shipped';
--select distinct uol.date_time   from staging.user_order_log uol