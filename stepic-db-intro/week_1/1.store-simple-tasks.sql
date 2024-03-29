use store_simple;

/*
Выведите количество товаров в каждой категории. 
Результат должен содержать два столбца: 
    название категории, 
    количество товаров в данной категории. 
*/
-- select 
-- 	category,
--     count(product_name) as num
-- from store
-- group by category
-- order by num desc
-- limit 5;

/*
Выведите 5 категорий товаров, продажи которых принесли наибольшую выручку. 
Под выручкой понимается сумма произведений стоимости товара на количество проданных единиц. 
Результат должен содержать два столбца: 
    название категории,
    выручка от продажи товаров в данной категории.
*/
select 
	category, 
    sum(price * sold_num) as rev
from store
group by category
order by rev desc
limit 5;
