/* Выведите все позиций списка товаров принадлежащие какой-либо категории 
с названиями товаров и названиями категорий. Список должен быть отсортирован 
по названию товара, названию категории. 

select good.name as good_name, category.name as category_name
	from good
    inner join category_has_good
    on good.id = category_has_good.good_id
    inner join category
    on category.id = category_has_good.category_id
    order by good_name, category_name;
*/

/* Выведите список клиентов (имя, фамилия) и количество заказов данных клиентов, имеющих статус "new".

select client.first_name as f_name, client.last_name as l_name, count(sale.client_id) as new_sale_num
	from client
    inner join sale on client.id = sale.client_id
    inner join status on status.id = sale.status_id
    where status.name = 'new'
    group by sale.client_id
    order by new_sale_num desc;
*/

/* Выведите список товаров с названиями товаров и названиями категорий, в том числе товаров, не принадлежащих ни одной из категорий.

select good.name as good_name, category.name as category_name
	from good 
    left outer join category_has_good on good.id = category_has_good.good_id
    left outer join category on category.id = category_has_good.category_id
    order by good_name, category_name;
*/

/* Выведите список товаров с названиями категорий, в том числе товаров, не принадлежащих ни к одной из категорий, 
в том числе категорий не содержащих ни одного товара.

select good.name as good_name, category.name as category_name
	from good 
    left outer join category_has_good on good.id = category_has_good.good_id
    left outer join category on category.id = category_has_good.category_id
union
select good.name as good_name, category.name as category_name
	from good 
    right outer join category_has_good on good.id = category_has_good.good_id
    right outer join category on category.id = category_has_good.category_id;
*/

/* Выведите список всех источников клиентов и суммарный объем заказов по каждому источнику. Результат должен включать 
также записи для источников, по которым не было заказов.

select source.name as s_name, sum(sale.sale_sum) as sale_sum
	from source
    left outer join client on client.source_id = source.id
    left outer join sale on sale.client_id = client.id
    group by s_name
    order by sale_sum desc;
*/

/* Выведите названия товаров, которые относятся к категории 'Cakes' 
или фигурируют в заказах текущий статус которых 'delivering'. 
Результат не должен содержать одинаковых записей. 
В запросе необходимо использовать оператор UNION для объединения выборок по разным условиям.

select good.name as good_name from good 
	inner join category_has_good 
		on category_has_good.good_id = good.id
			inner join category 
				on category.id = category_has_good.category_id
    where category.name = 'Cakes'
union
select good.name as good_name from good 
	inner join sale_has_good 
		on sale_has_good.good_id = good.id
			inner join sale on sale.id = sale_has_good.sale_id
				inner join status 
					on status.id = sale.status_id
    where status.name = 'delivering';
*/

/* Выведите список всех категорий продуктов и количество продаж товаров, относящихся к данной категории. 
Под количеством продаж товаров подразумевается суммарное количество единиц товара данной категории, 
фигурирующих в заказах с любым статусом.


select category.name as name, count(sale.id) as sale_num 
	from category
    left outer join category_has_good on category_has_good.category_id = category.id
		left outer join good on good.id = category_has_good.good_id
			left outer join sale_has_good on sale_has_good.good_id = good.id
				left outer join sale on sale.id = sale_has_good.sale_id
	group by name;
*/

/* Выведите список источников, из которых не было клиентов, либо клиенты пришедшие из которых не совершали заказов 
или отказывались от заказов. Под клиентами, которые отказывались от заказов, необходимо понимать клиентов, у которых 
есть заказы, которые на момент выполнения запроса находятся в состоянии 'rejected'. В запросе необходимо использовать 
оператор UNION для объединения выборок по разным условиям.
*/

select source.name as source_name from source
	where not exists (select * from client where client.source_id = source.id)
union
select source.name as source_name from source
	inner join client on client.source_id = source.id
		inner join sale on sale.client_id = client.id
			inner join status on status.id = sale.status_id
	where status.name = 'rejected';