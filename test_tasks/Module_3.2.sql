USE module31;

/*В таблицу attempt включить новую попытку для студента Баранова Павла по дисциплине «Основы баз данных». Установить 
текущую дату в качестве даты выполнения попытки.*/
INSERT INTO attempt (student_id, subject_id, date_attempt, result)
SELECT student_id, subject_id, NOW(), NULL
  FROM student 
	   JOIN attempt USING (student_id)
       RIGHT JOIN subject USING (subject_id)
 WHERE name_student = 'Баранов Павел' AND
	   name_subject = 'Основы баз данных';

/*Случайным образом выбрать три вопроса (запрос) по дисциплине, тестирование по которой собирается проходить студент, 
занесенный в таблицу attempt последним, и добавить их в таблицу testing. id последней попытки получить как максимальное 
значение id из таблицы attempt.*/
INSERT INTO testing (attempt_id, question_id, answer_id)
SELECT 
	   (SELECT MAX(attempt_id) FROM attempt), 
       question_id, 
       NULL
  FROM question
 WHERE subject_id = (SELECT subject_id 
					   FROM attempt 
					  WHERE attempt_id = (SELECT MAX(attempt_id) FROM attempt))
 ORDER BY RAND()
 LIMIT 3;

/*Студент прошел тестирование (то есть все его ответы занесены в таблицу testing), далее необходимо вычислить 
результат(запрос) и занести его в таблицу attempt для соответствующей попытки.  Результат попытки вычислить 
как количество правильных ответов, деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100. 
Результат округлить до целого.*/
UPDATE attempt
   SET result = (SELECT ROUND(SUM(answer.is_correct) / 3 *100) AS Результат
	 			   FROM testing
 				 	    JOIN answer USING (answer_id)
				  WHERE testing.attempt_id = (SELECT MAX(attempt_id) FROM testing))
  WHERE attempt.attempt_id = (SELECT MAX(attempt_id) FROM testing);

/*Удалить из таблицы attempt все попытки, выполненные раньше 1 мая 2020 года. Также удалить и все 
соответствующие этим попыткам вопросы из таблицы testing*/
DELETE FROM attempt
 WHERE date_attempt < '2020-05-01'; 

/*Добавить новый столбец в таблицу попыток сдачи Well_done и добавить подпись студентам, результат которых 
более 67 баллов - Супер_молодец, у кого результат =67 - Молодец. У остальных оставить пустые значения. */
ALTER TABLE attempt
		ADD Well_done VARCHAR(16);
UPDATE attempt
   SET Well_done = IF(result > 67, 
					  "Супер_молодец", 
                      IF(result = 67, 
						 "Молодец", 
                         NULL));