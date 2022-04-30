explain											-- показатель план, который СУБД выбрала для выполнения запроса
												-- сам запрос не будет выполняться
select * from sale_has_good
join sale on sale.id = sale_has_good.sale_id
join good on good.id = sale_has_good.good_id	-- сначала возльмет эту таблицу, т.к. так меньше всего кортежей
union											
select * from sale_has_good
join sale on sale.id = sale_has_good.sale_id
join good on good.id = sale_has_good.good_id;
