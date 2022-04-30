USE module31;

/*Найти вопрос, с самой большой успешностью выполнения - "самый легкий" и вопрос, с самой 
маленькой успешностью выполнения - "самый сложный".  (Подробно про успешность на этом шаге). 
Вывести предмет, эти два вопроса и указание - самый сложный или самый легкий это вопрос. 
Сначала вывести самый легкий запроса, потом самый сложный.*/
(SELECT query_max.name_subject, query_max.name_question, "Самый сложный"
  FROM (
		SELECT name_subject, 
			   CONCAT(LEFT(name_question, 30), '...') AS name_question,
			   SUM(answer.is_correct) / COUNT(answer.question_id) * 100 AS success
		  FROM testing
			   JOIN answer USING (answer_id)
			   JOIN question ON question.question_id = answer.question_id		-- OR ambiguous column
			   JOIN subject USING (subject_id)
		 GROUP BY name_subject, name_question
         ORDER BY success
	   ) AS query_max
 LIMIT 1)
 
 UNION ALL 
 
 (SELECT query_min.name_subject, query_min.name_question, "Самый легкий"
  FROM (
		SELECT name_subject, 
			   CONCAT(LEFT(name_question, 30), '...') AS name_question,
			   SUM(answer.is_correct) / COUNT(answer.question_id) * 100 AS success
		  FROM testing
			   JOIN answer USING (answer_id)
			   JOIN question ON question.question_id = answer.question_id		-- OR ambiguous column
			   JOIN subject USING (subject_id)
		 GROUP BY name_subject, name_question
         ORDER BY success DESC
	   ) AS query_min
 LIMIT 1);

/*Для студентов, у которых количество попыток меньше 3 и максимальный балл < 70, 
в таблицу attempt добавить новые попытки по соответствующим предметам с текущей датой.*/
INSERT INTO attempt (student_id, subject_id, date_attempt, result)
WITH get_lucky AS 
(SELECT *,
	   MAX(result) OVER (partition by student_id) AS max_res,
       COUNT(attempt_id) OVER (partition by student_id) AS num_att
  FROM attempt)
  
SELECT student_id, subject_id, 
	   CURRENT_DATE() AS date_attempt, NULL AS result
  FROM get_lucky
 WHERE max_res < 70 AND num_att < 3;