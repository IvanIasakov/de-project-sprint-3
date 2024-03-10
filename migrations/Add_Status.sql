-- Добавление поля Статуса в user_order_log STAGING слоя без этого не работает даже исходный DAG
alter table staging.user_order_log add column status varchar(8) not null default 'shipped';
-- Добавление поля Статуса в f_sales для учета 
alter table mart.f_sales add column status varchar(8) not null default 'shipped';
--select distinct uol.date_time   from staging.user_order_log uol