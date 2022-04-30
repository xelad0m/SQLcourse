USE project_simple;

SELECT
    AVG(DATEDIFF(project_finish, project_start)) as avg_days,	-- средняя длит. проекта
    MAX(DATEDIFF(project_finish, project_start)) as max_days,	-- макс.длит.проекта
    MIN(DATEDIFF(project_finish, project_start)) as min_days,  	-- можно задать синоним
    client_name													-- (!)
FROM project WHERE DATEDIFF(project_finish, project_start) > 0
GROUP BY client_name											-- (!) группировать по селекту, иначе первый попавшийся поставит
ORDER BY min_days DESC 											-- обратный порядок DESC
LIMIT 10;														-- топ-10