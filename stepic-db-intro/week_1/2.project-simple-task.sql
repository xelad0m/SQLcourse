use project_simple;
/* количество записей (заказов) */
-- select count(1) from project;

/*
Выведите в качестве результата одного запроса общее количество заказов, 
сумму стоимостей (бюджетов) всех проектов, средний срок исполнения заказа в днях.
NB! Для вычисления длительности проекта удобно использовать встроенную функцию datediff().
*/
select 
	count(1) as quantity,
    sum(budget) as amount,
    avg(datediff(project_finish, project_start)) as avg_days
from project;