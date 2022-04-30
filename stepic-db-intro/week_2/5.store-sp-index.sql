explain 
select * from good								-- сканируется все 20 кортежей
-- where name like 'Zen%';							-- начинаются с Zen
where name like 'Z%';							-- если сделать более расплывчатый запрос, то с индексом будет просматриваеться уже 2 кортежа

/*
explain 
select * from good								
where name = 'Zenron';							-- тип сканирования ref
*/

/*select * from good order by name;				-- видно, что шаблону Z% соотв. 2 позиции
*/

create index good_name_index on good(name);		-- если создать индекс, то сканирование типа range и только 1 строка (О(1))
drop index good_name_index on good;