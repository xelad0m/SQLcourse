USE project_simple;

-- количество строк в таблице
-- SELECT COUNT(1) FROM project;

-- среднее занчение по полю
-- SELECT AVG(budget) FROM project;

-- SELECT
-- 	project_finish,
--     project_start,
--     DATEDIFF(project_finish, project_start)
-- FROM project WHERE DATEDIFF(project_finish, project_start) > 0;

SELECT
    AVG(DATEDIFF(project_finish, project_start)),	-- средняя длит. проекта
    MAX(DATEDIFF(project_finish, project_start)),	-- макс.длит.проекта
    MIN(DATEDIFF(project_finish, project_start))
FROM project WHERE DATEDIFF(project_finish, project_start) > 0;