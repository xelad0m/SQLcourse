USE module35; 		-- lesson_3_5.sql

/*Отобрать все шаги, в которых рассматриваются вложенные запросы (то есть в названии шага упоминаются вложенные запросы). 
Указать к какому уроку и модулю они относятся. Для этого вывести 3 поля:
    в поле Модуль указать номер модуля и его название через пробел;
    в поле Урок указать номер модуля, порядковый номер урока (lesson_position) через точку и название урока через пробел;
    в поле Шаг указать номер модуля, порядковый номер урока (lesson_position) через точку, порядковый номер шага 
    (step_position) через точку и название шага через пробел.
Длину полей Модуль и Урок ограничить 19 символами, при этом слишком длинные надписи обозначить многоточием в конце 
(16 символов - это номер модуля или урока, пробел и  название Урока или Модуля к ним присоединить "..."). 
Информацию отсортировать по возрастанию номеров модулей, порядковых номеров уроков и порядковых номеров шагов.*/
SELECT CONCAT(LEFT(CONCAT(module_id, ' ', module_name), 16), '...') AS Модуль,
	   CONCAT(LEFT(CONCAT(module_id, '.', lesson_position, ' ', lesson_name), 16), '...') AS Урок,
       CONCAT(module_id, '.', lesson_position, '.', step_position, ' ', step_name) AS Шаг
  FROM module
	   JOIN lesson USING (module_id)
       JOIN step USING (lesson_id)
 WHERE step_name LIKE '%вложенн%запр%'
 ORDER BY Модуль, Урок, Шаг;

/*Заполнить таблицу step_keyword следующим образом: если ключевое слово есть в названии шага, 
то включить в step_keyword строку с id шага и id ключевого слова. */
INSERT INTO step_keyword (step_id, keyword_id)
SELECT step_id, keyword_id
  FROM step
	   CROSS JOIN keyword 
 WHERE step_name REGEXP  CONCAT('\\b', keyword_name, '\\b')		-- \\b начало/конец строки
 ORDER BY keyword_id;
 
/*Реализовать поиск по ключевым словам. Вывести шаги, с которыми связаны ключевые слова MAX и 
AVG одновременно. Для шагов указать id модуля, позицию урока в модуле, позицию шага в уроке 
через точку, после позиции шага перед заголовком - пробел. Позицию шага в уроке вывести в виде 
двух цифр (если позиция шага меньше 10, то перед цифрой поставить 0). Столбец назвать Шаг. 
Информацию отсортировать по первому столбцу в алфавитном порядке.*/
SELECT CONCAT(module_id, '.', 
		      lesson_position, '.', 
              IF(step_position < 10, CONCAT('0', step_position), step_position), ' ', 
              step_name) AS Шаг
  FROM step
	   JOIN step_keyword USING (step_id)
       JOIN keyword USING (keyword_id)
       JOIN lesson USING (lesson_id)
       JOIN module USING (module_id)
 WHERE keyword_name IN ('MAX', 'AVG')
 GROUP BY module_id, lesson_id, step_id, step_name
 HAVING COUNT(*) = 2
 ORDER BY Шаг;

/*Посчитать, сколько студентов относится к каждой группе. Столбцы назвать Группа, Интервал, Количество. Указать границы интервала.*/
SELECT Группа, 
	   CASE
			WHEN Группа = "I" THEN 'от 0 до 10'
			WHEN Группа = "II" THEN 'от 11 до 15'
			WHEN Группа = "III" THEN 'от 16 до 27'
			ELSE "больше 27"
	   END AS Интервал,
       COUNT(Группа) AS Количество
  FROM
    (
     SELECT student_name, rate, 
			CASE
				WHEN rate <= 10 THEN "I"
				WHEN rate <= 15 THEN "II"
				WHEN rate <= 27 THEN "III"
				ELSE "IV"
			END AS Группа
	FROM      
		(
		 SELECT student_name, count(*) as rate
		 FROM 
			 (
			  SELECT student_name, step_id
			  FROM 
				  student 
				  INNER JOIN step_student USING(student_id)
			  WHERE result = "correct"
			  GROUP BY student_name, step_id
			 ) query_in
		 GROUP BY student_name 
		 ORDER BY 2
		) query_in_1
	) query_in_2
 GROUP BY Группа
 ORDER BY Группа;

/*Исправить запрос примера так: для шагов, которые  не имеют неверных ответов,  указать 100 как 
процент успешных попыток, если же шаг не имеет верных ответов, указать 0. Информацию отсортировать 
сначала по возрастанию успешности, а затем по названию шага в алфавитном порядке.*/
WITH get_count_correct (st_n_c, count_correct) 
  AS (	/*step - correct*/
    SELECT step_name, count(*)
    FROM 
        step 
        INNER JOIN step_student USING (step_id)
    WHERE result = "correct"
    GROUP BY step_name
   ),
  get_count_wrong (st_n_w, count_wrong) 
  AS ( /* step - wrong */
    SELECT step_name, count(*)
    FROM 
        step 
        INNER JOIN step_student USING (step_id)
    WHERE result = "wrong"
    GROUP BY step_name
   )  
SELECT st_n_c AS Шаг,
    IF(ROUND(count_correct / (count_correct + count_wrong) * 100) IS NULL,
       100, ROUND(count_correct / (count_correct + count_wrong) * 100)) AS Успешность
FROM  
    get_count_correct 
    LEFT JOIN get_count_wrong ON st_n_c = st_n_w
UNION
SELECT st_n_w AS Шаг,
    IF(ROUND(count_correct / (count_correct + count_wrong) * 100) IS NULL,
       0, ROUND(count_correct / (count_correct + count_wrong) * 100)) AS Успешность
FROM  
    get_count_correct 
	RIGHT JOIN get_count_wrong ON st_n_c = st_n_w
ORDER BY Успешность, Шаг;

/*Вычислить прогресс пользователей по курсу. Прогресс вычисляется как отношение верно пройденных шагов к общему 
количеству шагов в процентах, округленное до целого. В нашей базе данные о решениях занесены не для всех шагов, 
поэтому общее количество шагов определить как количество различных шагов в таблице step_student.
    Тем пользователям, которые прошли все шаги (прогресс = 100%) выдать "Сертификат с отличием". 
    Тем, у кого прогресс больше или равен 80% -  "Сертификат". Для остальных записей в столбце Результат задать пустую строку ("").
    Информацию отсортировать по убыванию прогресса, затем по имени пользователя в алфавитном порядке.
*/
SET @max_progress = (SELECT COUNT(DISTINCT step_id) FROM step_student);
WITH student_progress (student_name, progress) AS
    (
	 SELECT student_name, 
			ROUND(COUNT(DISTINCT step_id) / @max_progress * 100) AS progress
	   FROM student
			JOIN step_student USING (student_id)
	  WHERE result = 'correct'
	  GROUP BY student_name
    )
SELECT student_name AS 'Студент',
	   progress AS 'Прогресс',
	   CASE 
		    WHEN progress = 100 THEN 'Сертификат с отличием'
            WHEN progress <= 80 THEN 'Сертификат'
            ELSE ''
	   END AS 'Результат'
  FROM student_progress
ORDER BY progress DESC, student_name;

/*Оконные функции позволяют получить некоторую дополнительную информацию о выборке данных .  
С помощью оконных функций можно реализовать вычисления для набора строк, некоторым образом связанных с текущей строкой.
Синтаксис оконных функций:

	название_функции(выражение) 
	  OVER (
			PARTITION BY столбец_1, столбец_2, ... 	- это окно (часть таблицы, по умолчаю вся таблица)
			ORDER BY ... 							- сортировка 
			ROWS BETWEEN 							- границы окна
			  ...
	  )
*/
SELECT student_name, count(DISTINCT step_id) AS Kоличество,

    ROW_NUMBER() OVER (ORDER BY count(DISTINCT step_id) DESC) AS Номер 
	/*В этом запросе после того, как были выбраны все студенты, посчитаны их шаги с правильными ответами, 
    с помощью оконной функции была выполнена сортировка по количеству верных шагов (count(DISTINCT step_id))  
    и пронумерованы строки (функция ROW_NUMBER()).*/

FROM student INNER JOIN step_student USING (student_id)
WHERE result = "correct"
GROUP BY student_name;

SELECT student_name, count(DISTINCT step_id) AS Kоличество,

    ROW_NUMBER() OVER (ORDER BY  count(DISTINCT step_id) DESC) AS Номер,
    RANK() OVER (ORDER BY  count(DISTINCT step_id) DESC) AS Ранг,
    DENSE_RANK() OVER (ORDER BY  count(DISTINCT step_id) DESC) AS Рейтинг

FROM student INNER JOIN step_student USING (student_id)
WHERE result = "correct"
GROUP BY student_name;

/*Для каждого студента указать, на сколько меньше он прошел шагов, чем идущий перед ним по рейтингу студент.*/
SELECT student_name, count(DISTINCT step_id) AS Количество,
       -- LAG(count(DISTINCT step_id)) 
	   -- OVER (ORDER BY  count(DISTINCT step_id) DESC) - count(DISTINCT step_id) AS Разница
	   IFNULL(LAG(count(DISTINCT step_id)) 
              OVER (ORDER BY  count(DISTINCT step_id) DESC) - count(DISTINCT step_id), 
              0) AS Разница
              
FROM student INNER JOIN step_student USING (student_id)
WHERE result = "correct"
GROUP BY student_name;

/*Для студента с именем student_61 вывести все его попытки: название шага, результат и дату 
отправки попытки (submission_time). Информацию отсортировать по дате отправки попытки и указать, 
сколько минут прошло между отправкой соседних попыток. Название шага ограничить 20 символами и 
добавить "...". Столбцы назвать Студент, Шаг, Результат, Дата_отправки, Разница.*/
SELECT student_name AS Студент, 
	   CONCAT(LEFT(step_name, 20), '...') AS Шаг,
       result AS Результат, 
       FROM_UNIXTIME(submission_time) AS Дата_отправки, 
       SEC_TO_TIME(IFNULL(submission_time - LAG(submission_time) OVER (ORDER BY submission_time), 0)) AS Разница
  FROM student
	   JOIN step_student USING (student_id)
       JOIN step USING (step_id)
 WHERE student_name = 'student_61'
 ORDER BY Дата_отправки;
 
 /*Посчитать среднее время, за которое пользователи проходят урок по следующему алгоритму:
    для каждого пользователя вычислить время прохождения шага как сумму времени, потраченного на каждую попытку 
    (время попытки - это разница между временем отправки задания и временем начала попытки), при этом попытки, 
    которые длились больше 4 часов не учитывать, так как пользователь мог просто оставить задание открытым в браузере, 
    а вернуться к нему на следующий день;
    для каждого студента посчитать общее время, которое он затратил на каждый урок;
    вычислить среднее время выполнения урока в часах, результат округлить до 2-х знаков после запятой;
    вывести информацию по возрастанию времени, пронумеровав строки, для каждого урока указать номер модуля и его позицию в нем.
Столбцы результата назвать Номер, Урок, Среднее_время*/
SET @row_number = 0;
SELECT (@row_number:=@row_number + 1) AS Номер,		-- сходу не работает, т.к. нумерует до создания и сортировки таблиц
	   Урок, Среднее_время
 FROM (
		SELECT CONCAT(module_id, '.', lesson_position, ' ', lesson_name) AS Урок, 
			   ROUND(AVG(lesson_time), 2) AS Среднее_время
		  FROM 
			   (
				SELECT student_id, lesson_id, SUM(step_time) / 3600 AS lesson_time
				  FROM (
						SELECT student_id, lesson_id, step_id, SUM(submission_time - attempt_time) AS step_time
						  FROM step_student JOIN step USING (step_id)
						 WHERE submission_time - attempt_time < 4 * 60 * 60
						 GROUP BY student_id, lesson_id, step_id
						) AS query_in_step
						JOIN lesson USING (lesson_id)
				GROUP BY student_id, lesson_id 
			   ) AS query_in_lesson
			   JOIN lesson USING (lesson_id)
			   JOIN module USING (module_id)
		 GROUP BY lesson_id
		 ORDER BY Среднее_время
	   ) query_all;

/*Вычислить, сколько шагов прошел пользователь по каждому модулю. Ранжировать пользователей по убыванию результатов в каждом модуле.*/
WITH get_rate_lesson(mod_id, stud, rate) 
AS
(
   SELECT module_id, student_name, count(DISTINCT step_id)
   FROM student INNER JOIN step_student USING(student_id)
                INNER JOIN step USING (step_id)
                INNER JOIN lesson USING (lesson_id)
   WHERE result = "correct"
   GROUP BY module_id, student_name
)
SELECT mod_id AS Модуль, stud AS Студент, rate AS Рейтинг,
    ROW_NUMBER() OVER (PARTITION BY mod_id ORDER BY  rate DESC) AS Номер,
    RANK() OVER (PARTITION BY mod_id ORDER BY  rate DESC) AS Ранг,
    DENSE_RANK() OVER (PARTITION BY mod_id ORDER BY  rate DESC) AS Рейтинг  
FROM get_rate_lesson; 

/*Посчитать, сколько шагов пройдено пользователями по каждому уроку. Вывести максимальное и минимальное значение пройденных шагов по каждому модулю.*/

WITH get_rate_lesson(mod_id, les, rate) 
AS
(
   SELECT module_id, CONCAT(module_id,'.', lesson_position), count(DISTINCT step_id)
   FROM step_student INNER JOIN step USING (step_id)
                     INNER JOIN lesson USING (lesson_id)
   WHERE result = "correct"
   GROUP BY module_id, 2
)
SELECT mod_id AS Модуль, les AS Урок, rate AS Пройдено_шагов, 
    MAX(rate) OVER (PARTITION BY mod_id) AS Максимум_по_модулю,
    MIN(rate) OVER (PARTITION BY mod_id) AS Минимум_по_модулю
FROM get_rate_lesson;

/*Вычислить рейтинг каждого студента относительно студента, прошедшего наибольшее количество шагов в 
модуле (вычисляется как отношение количества пройденных студентом шагов к максимальному количеству 
пройденных шагов, умноженное на 100). Вывести номер модуля, имя студента, количество пройденных им 
шагов и относительный рейтинг. Относительный рейтинг округлить до одного знака после запятой. 
Столбцы назвать Модуль, Студент, Пройдено_шагов и Относительный_рейтинг  соответственно. Информацию 
отсортировать сначала по возрастанию номера модуля, потом по убыванию относительного рейтинга и, наконец, 
по имени студента в алфавитном порядке.*/
SELECT DISTINCT module_id AS Модуль, 
	   student_name AS Студент,  
       COUNT(step_id) OVER(PARTITION BY module_id, student_name) AS Пройдено_шагов
  FROM module
	   JOIN lesson USING (module_id)
       JOIN step USING (lesson_id)
       JOIN step_student USING (step_id)
       JOIN student USING (student_id)
 WHERE result = 'correct';

WITH get_rate_module(mod_id, student_name, rate) 
AS
(
   SELECT module_id,student_name,count(DISTINCT step_id)
   FROM step_student JOIN step USING (step_id)
                     JOIN lesson USING (lesson_id)
                     JOIN student USING (student_id)
   WHERE result = "correct"
   GROUP BY module_id, 2
)
SELECT mod_id AS Модуль, 
	   student_name AS Студент, 
	   rate AS Пройдено_шагов,
       ROUND(rate / MAX(rate) OVER (PARTITION BY mod_id) * 100, 1) AS Относительный_рейтинг
  FROM get_rate_module
 ORDER BY Модуль, Относительный_рейтинг DESC, Студент;

/*Проанализировать, в каком порядке и с каким интервалом пользователь отправлял последнее верно выполненное задание каждого урока. 
В базе занесены попытки студентов  для трех уроков курса, поэтому анализ проводить только для этих уроков.
Для студентов прошедших как минимум по одному шагу в каждом уроке, найти последний пройденный шаг каждого урока 
- крайний шаг, и указать:
    имя студента;
    номер урока, состоящий из номера модуля и через точку позиции каждого урока в модуле;
    время отправки  - время подачи решения на проверку;
    разницу во времени отправки между текущим и предыдущим крайним шагом в днях, при этом для первого шага поставить 
    прочерк ("-"), а количество дней округлить до целого в большую сторону.
Столбцы назвать  Студент, Урок,  Макс_время_отправки и Интервал  соответственно. Отсортировать результаты по имени студента в 
алфавитном порядке, а потом по возрастанию времени отправки.*/
WITH get_last
AS 
	(
    SELECT student_name AS Студент, 
		   CONCAT(module_id, '.', lesson_position) AS Урок, 
           MAX(submission_time) AS mt
	FROM step_student JOIN step USING(step_id) JOIN lesson USING(lesson_id) JOIN student USING(student_id)
	WHERE result = 'correct'
	GROUP BY student_name, lesson_id 
	),
filter_min 
AS
	(
	SELECT Студент
    FROM get_last
	GROUP BY Студент
	HAVING COUNT(*) >= 3 
    )
SELECT Студент, Урок, 
       FROM_UNIXTIME(mt) AS Макс_время_отправки, 
       IFNULL(CEIL((mt - LAG(mt) OVER(PARTITION BY Студент ORDER BY mt)) / 86400), '-') AS Интервал
  FROM get_last JOIN filter_min USING(Студент)
 ORDER BY Студент, Макс_время_отправки;
 
/*Для студента с именем student_59 вывести следующую информацию по всем его попыткам:
    информация о шаге: номер модуля, символ '.', позиция урока в модуле, символ '.', позиция шага в модуле;
    порядковый номер попытки для каждого шага - определяется по возрастанию времени отправки попытки;
    результат попытки;
    время попытки (преобразованное к формату времени) - определяется как разность между временем отправки попытки и 
    времени ее начала, в случае если попытка длилась более 1 часа, то время попытки заменить на среднее время всех 
    попыток пользователя по всем шагам без учета тех, которые длились больше 1 часа;
    относительное время попытки  - определяется как отношение времени попытки (с учетом замены времени попытки) к 
    суммарному времени всех попыток  шага, округленное до двух знаков после запятой  .
Столбцы назвать  Студент,  Шаг, Номер_попытки, Результат, Время_попытки и Относительное_время. Информацию 
отсортировать сначала по возрастанию id шага, а затем по возрастанию номера попытки (определяется по времени отправки попытки).*/
WITH sub_time 
AS (/*время каждой попытки*/ 
	SELECT student_name, 
		   CONCAT(module_id, '.', lesson_position, '.', step_position) AS full_step, 
           step_id,
           submission_time,
           result,
           ROW_NUMBER() OVER (PARTITION BY step_id ORDER BY submission_time) AS att_num,
		   SEC_TO_TIME(submission_time - attempt_time) AS att_time
      FROM step_student JOIN step USING(step_id) JOIN lesson USING(lesson_id) JOIN student USING(student_id)
	 WHERE student_name = 'student_59'
	),
avg_time AS
    (/*среднее время попыток, длящихся менее 1 часа*/ 
	 SELECT student_name,
	 	    SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(att_time)))) as avgt
	   FROM sub_time
	  WHERE TIME_TO_SEC(att_time) < 60 * 60
	  GROUP BY student_name
	),
rel_time AS
	(/*соединение двух первых запросов*/
	 SELECT *,
			IF(TIME_TO_SEC(att_time) < 60 * 60, att_time, avgt) as att
	   FROM sub_time JOIN avg_time USING (student_name)
    )
SELECT student_name AS Студент,
	   full_step AS Шаг,
       att_num AS Номер_попытки,
	   result AS Результат,
       att as Время_попытки,
       ROUND(TIME_TO_SEC(att) / (SUM(TIME_TO_SEC(att)) OVER (PARTITION BY full_step)) * 100, 2) AS Относительное_время
  FROM rel_time
 ORDER BY step_id, submission_time; 

/*Необходимо выделить группы обучающихся по способу прохождения шагов:
    I группа - это те пользователи, которые после верной попытки решения шага делают неверную 
    (скорее всего для того, чтобы поэкспериментировать или проверить, как работают примеры);
    II группа - это те пользователи, которые делают больше одной верной попытки для одного шага 
    (возможно, улучшают свое решение или пробуют другой вариант);
    III группа - это те пользователи, которые не смогли решить задание какого-то шага 
    (у них все попытки по этому шагу - неверные).
Вывести группу (I, II, III), имя пользователя, количество шагов, которые пользователь выполнил 
по соответствующему способу. Столбцы назвать Группа, Студент, Количество_шагов. Отсортировать 
информацию по возрастанию номеров групп, потом по убыванию количества шагов и, наконец, по имени 
студента в алфавитном порядке.*/
SELECT g_name AS Группа, student_name AS Студент, COUNT(student_name) AS Количество_шагов
  FROM (
		SELECT DISTINCT 'I' AS g_name, student_name, step_id, result, prev_result
		  FROM (
				SELECT student_name, step_id, result,
					   LAG(result) OVER (PARTITION BY student_name, step_id ORDER BY submission_time) AS prev_result
				  FROM step_student JOIN student USING(student_id)
				 ORDER BY student_name, step_id, submission_time
			   ) AS corr_worng
		 WHERE (result, prev_result) = ('wrong', 'correct')
		 ORDER BY student_name, step_id
		) AS g1 GROUP BY g_name, student_name

UNION ALL 
  
SELECT g_name AS Группа, student_name AS Студент, COUNT(student_name) AS Количество_шагов
  FROM (
		SELECT 'II' AS g_name, student_name, step_id, 
			   SUM(CASE WHEN result = 'correct' THEN 1 ELSE 0 END) AS corr_num
		  FROM step_student JOIN student USING(student_id)
		 GROUP BY student_name, step_id
		HAVING corr_num > 1
		 ORDER BY student_name, step_id
		) AS g2 GROUP BY g_name, student_name

UNION ALL

SELECT g_name AS Группа, student_name AS Студент, COUNT(student_name) AS Количество_шагов
  FROM (
		SELECT 'III' AS g_name, student_name, step_id, 
			   COUNT(result) AS tot_num,
			   SUM(CASE WHEN result = 'wrong' THEN 1 ELSE 0 END) AS wrong_num
		  FROM step_student JOIN student USING(student_id)
		 GROUP BY student_name, step_id
		HAVING tot_num = wrong_num
		 ORDER BY student_name, step_id
       ) AS g3 GROUP BY g_name, student_name

 ORDER BY Группа, Количество_шагов DESC, Студент;