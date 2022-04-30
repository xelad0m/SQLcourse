/*В университете реализуется on-line тестирование по нескольким дисциплинам. Каждая дисциплина включает некоторое 
количество вопросов. Ответы на вопрос представлены в виде вариантов ответов, один из этих вариантов правильный.*/
DROP SCHEMA IF EXISTS module31;
CREATE SCHEMA module31;
USE module31;

CREATE TABLE subject (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    name_subject varchar(30)
);

INSERT INTO subject (subject_id,name_subject) VALUES 
    (1,'Основы SQL'),
    (2,'Основы баз данных'),
    (3,'Физика');

CREATE TABLE student (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name_student varchar(50)
);

INSERT INTO student (student_id,name_student) VALUES
    (1,'Баранов Павел'),
    (2,'Абрамова Катя'),
    (3,'Семенов Иван'),
    (4,'Яковлева Галина');

CREATE TABLE attempt (
    attempt_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    subject_id INT,
    date_attempt date,
    result INT,
    FOREIGN KEY (student_id) REFERENCES student (student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subject (subject_id) ON DELETE CASCADE
);

INSERT INTO attempt (attempt_id,student_id,subject_id,date_attempt,result) VALUES
    (1,1,2,'2020-03-23',67),
    (2,3,1,'2020-03-23',100),
    (3,4,2,'2020-03-26',0),
    (4,1,1,'2020-04-15',33),
    (5,3,1,'2020-04-15',67),
    (6,4,2,'2020-04-21',100),
    (7,3,1,'2020-05-17',33);

CREATE TABLE question (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    name_question varchar(100), 
    subject_id INT,
    FOREIGN KEY (subject_id) REFERENCES subject (subject_id) ON DELETE CASCADE
);

INSERT INTO question (question_id,name_question,subject_id) VALUES
    (1,'Запрос на выборку начинается с ключевого слова:',1),
    (2,'Условие, по которому отбираются записи, задается после ключевого слова:',1),
    (3,'Для сортировки используется:',1),
    (4,'Какой запрос выбирает все записи из таблицы student:',1),
    (5,'Для внутреннего соединения таблиц используется оператор:',1),
    (6,'База данных - это:',2),
    (7,'Отношение - это:',2),
    (8,'Концептуальная модель используется для',2),
    (9,'Какой тип данных не допустим в реляционной таблице?',2);

CREATE TABLE answer (
    answer_id INT PRIMARY KEY AUTO_INCREMENT,
    name_answer varchar(100),
    question_id INT,
    is_correct BOOLEAN,
    CONSTRAINT answer_ibfk_1 FOREIGN KEY (question_id) REFERENCES question (question_id) ON DELETE CASCADE
);

INSERT INTO answer (answer_id,name_answer,question_id,is_correct) VALUES
    (1,'UPDATE',1,FALSE),
    (2,'SELECT',1,TRUE),
    (3,'INSERT',1,FALSE),
    (4,'GROUP BY',2,FALSE),
    (5,'FROM',2,FALSE),
    (6,'WHERE',2,TRUE),
    (7,'SELECT',2,FALSE),
    (8,'SORT',3,FALSE),
    (9,'ORDER BY',3,TRUE),
    (10,'RANG BY',3,FALSE),
    (11,'SELECT * FROM student',4,TRUE),
    (12,'SELECT student',4,FALSE),
    (13,'INNER JOIN',5,TRUE),
    (14,'LEFT JOIN',5,FALSE),
    (15,'RIGHT JOIN',5,FALSE),
    (16,'CROSS JOIN',5,FALSE),
    (17,'совокупность данных, организованных по определенным правилам',6,TRUE),
    (18,'совокупность программ для хранения и обработки больших массивов информации',6,FALSE),
    (19,'строка',7,FALSE),
    (20,'столбец',7,FALSE),
    (21,'таблица',7,TRUE),
    (22,'обобщенное представление пользователей о данных',8,TRUE),
    (23,'описание представления данных в памяти компьютера',8,FALSE),
    (24,'база данных',8,FALSE),
    (25,'file',9,TRUE),
    (26,'INT',9,FALSE),
    (27,'VARCHAR',9,FALSE),
    (28,'DATE',9,FALSE);

CREATE TABLE testing (
    testing_id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT,
    question_id INT,
    answer_id INT,
    FOREIGN KEY (attempt_id) REFERENCES attempt (attempt_id) ON DELETE CASCADE
);

INSERT INTO testing (testing_id,attempt_id,question_id,answer_id) VALUES
    (1,1,9,25),
    (2,1,7,19),
    (3,1,6,17),
    (4,2,3,9),
    (5,2,1,2),
    (6,2,4,11),
    (7,3,6,18),
    (8,3,8,24),
    (9,3,9,28),
    (10,4,1,2),
    (11,4,5,16),
    (12,4,3,10),
    (13,5,2,6),
    (14,5,1,2),
    (15,5,4,12),
    (16,6,6,17),
    (17,6,8,22),
    (18,6,7,21),
    (19,7,1,3),
    (20,7,4,11),
    (21,7,5,16);
    
/*Вывести студентов, которые сдавали дисциплину «Основы баз данных», указать дату попытки и результат. 
Информацию вывести по убыванию результатов тестирования.*/
SELECT student.name_student, attempt.date_attempt, attempt.result
  FROM student
	   JOIN attempt USING (student_id)
       JOIN subject USING (subject_id)
 WHERE subject.subject_id = 
	   (SELECT subject_id 
		  FROM subject 
		 WHERE name_subject = 'Основы баз данных')
 ORDER BY result DESC;
    
/*Вывести, сколько попыток сделали студенты по каждой дисциплине, а также средний результат попыток, 
который округлить до 2 знаков после запятой. Под результатом попытки понимается процент правильных 
ответов на вопросы теста, который занесен в столбец result.  В результат включить название дисциплины, 
а также вычисляемые столбцы Количество и Среднее. Информацию вывести по убыванию средних результатов.*/
SELECT subject.name_subject,
	   COUNT(attempt.subject_id) AS Количество,
       ROUND(AVG(attempt.result), 2) AS Среднее
  FROM attempt 
       RIGHT JOIN subject USING (subject_id)
 GROUP BY subject.name_subject
 ORDER BY Среднее DESC;
 
/*Вывести студентов (различных студентов), имеющих максимальные результаты попыток. Информацию отсортировать 
в алфавитном порядке по фамилии студента.*/
SELECT student.name_student,
	   attempt.result
  FROM student
	   JOIN attempt USING (student_id)
 WHERE attempt.result = (SELECT MAX(attempt.result) FROM attempt)
 ORDER BY name_student;
 
/*Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой 
и последней попыткой. В результат включить фамилию и имя студента, название дисциплины и вычисляемый столбец 
Интервал. Информацию вывести по возрастанию разницы. Студентов, сделавших одну попытку по дисциплине, не учитывать. */
SELECT student.name_student,
	   subject.name_subject,
       DATEDIFF(query_in.last, query_in.first) AS Интервал
  FROM (SELECT student_id, subject_id, 
			   MAX(date_attempt) AS last, 
               MIN(date_attempt) AS first
		  FROM attempt
		 GROUP BY student_id, subject_id
		HAVING first <> last) AS query_in
	   JOIN student USING (student_id)
       JOIN subject USING (subject_id)
 ORDER BY Интервал;
-- OR
SELECT student.name_student,
	   subject.name_subject,
       DATEDIFF(MAX(attempt.date_attempt), MIN(attempt.date_attempt)) AS Интервал
  FROM attempt
	   JOIN student USING (student_id)
       JOIN subject USING (subject_id)
 GROUP BY name_student, name_subject
HAVING Интервал <> 0
 ORDER BY Интервал;

/*Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). Вывести 
дисциплину и количество уникальных студентов (столбец назвать Количество), которые по ней проходили 
тестирование . Информацию отсортировать сначала по убыванию количества, а потом по названию дисциплины. 
В результат включить и дисциплины, тестирование по которым студенты еще не проходили, в этом случае 
указать количество студентов 0.*/
SELECT name_subject,
	   COUNT(DISTINCT student_id) AS Количество
  FROM attempt 
	   RIGHT JOIN subject USING (subject_id)
 GROUP BY subject_id
 ORDER BY Количество DESC, name_subject;

/*Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». В результат включите столбцы 
question_id и name_question.*/
SELECT question_id, name_question
  FROM question
	   JOIN subject USING (subject_id)
 WHERE subject_id = (SELECT subject_id FROM subject WHERE name_subject = 'Основы баз данных')
 ORDER BY RAND()  -- SQL shuffle (VERY slow)
 LIMIT 3;
 
/*Вывести вопросы, которые были включены в тест для Семенова Ивана по дисциплине «Основы SQL» 2020-05-17  
(значение attempt_id для этой попытки равно 7). Указать, какой ответ дал студент и правильный он или нет 
(вывести Верно или Неверно). В результат включить вопрос, ответ и вычисляемый столбец  .*/
SELECT name_question, name_answer, 
	   IF(is_correct = 0, 'Неверно', 'Верно') AS Результат
  FROM question
	   JOIN testing USING (question_id)
       JOIN answer USING (answer_id),
(SELECT attempt_id 
  FROM attempt 
	   JOIN student USING (student_id)
 WHERE student.name_student = 'Семенов Иван' AND
	   attempt.date_attempt = '2020-05-17') AS choose_test
  
 WHERE testing.attempt_id = choose_test.attempt_id;

/*Посчитать результаты тестирования. Результат попытки вычислить как количество правильных ответов, деленное 
на 3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до двух знаков после запятой. 
Вывести фамилию студента, название предмета, дату и результат. Последний столбец назвать Результат. 
Информацию отсортировать сначала по фамилии студента, потом по убыванию даты попытки.*/
SELECT name_student, name_subject, date_attempt,
	   ROUND(SUM(answer.is_correct) / 3 * 100, 2) AS Результат
  FROM testing
	   JOIN answer USING (answer_id)
       JOIN attempt USING (attempt_id)
       JOIN student USING (student_id)     
       JOIN subject USING (subject_id)
 GROUP BY name_student, name_subject, date_attempt
 ORDER BY name_student, date_attempt DESC;

/*Для каждого вопроса вывести процент успешных решений, то есть отношение количества верных ответов к общему количеству 
ответов, значение округлить до 2-х знаков после запятой. Также вывести название предмета, к которому относится вопрос, 
и общее количество ответов на этот вопрос. В результат включить название дисциплины, вопросы по ней (столбец назвать Вопрос), 
а также два вычисляемых столбца Всего_ответов и Успешность. Информацию отсортировать сначала по названию дисциплины, потом 
по убыванию успешности, а потом по тексту вопроса в алфавитном порядке.*/
-- Поскольку тексты вопросов могут быть длинными, обрезать их 30 символов и добавить многоточие "...".
SELECT name_subject, 
	   CONCAT(LEFT(name_question, 30), '...') AS Вопрос,
       COUNT(answer.question_id) AS Всего_ответов,
       ROUND(SUM(answer.is_correct) / COUNT(answer.question_id) * 100, 2) AS Успешность
  FROM testing
	   JOIN answer USING (answer_id)
       JOIN question ON question.question_id = answer.question_id		-- OR ambiguous column
       JOIN subject USING (subject_id)
 GROUP BY name_subject, name_question
 ORDER BY name_subject, Успешность DESC, name_question;
 
/*Найти вопрос, на который было дано максимальное количество правильных ответов - "Самый легкий" и вопрос, на который 
было дано минимальное количество правильных ответов - "Самый сложный"*/
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
       
