START TRANSACTION ;
DROP SCHEMA IF EXISTS module33;
CREATE SCHEMA module33;
USE module33;
SET FOREIGN_KEY_CHECKS = 0;	

DROP TABLE IF EXISTS enrollee_subject;
DROP TABLE IF EXISTS program_enrollee;
DROP TABLE IF EXISTS program_subject;
DROP TABLE IF EXISTS enrollee_achievement;
DROP TABLE IF EXISTS achievement;
DROP TABLE IF EXISTS enrollee;
DROP TABLE IF EXISTS program;
DROP TABLE IF EXISTS subject;
DROP TABLE IF EXISTS department;
COMMIT ;

START TRANSACTION ;
CREATE TABLE department (
    `department_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_department` VARCHAR(30)
);
INSERT INTO department (`department_id`, `name_department`)
VALUES (1, 'Инженерная школа'), (2, 'Школа естественных наук');

CREATE TABLE subject (
    `subject_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_subject` VARCHAR(30)
);
INSERT INTO subject (`subject_id`, `name_subject`)
VALUES (1, 'Русский язык'), (2, 'Математика'), (3, 'Физика'), (4, 'Информатика');

CREATE TABLE program (
    `program_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_program` VARCHAR(50),
    `department_id` INT,
    `plan` INT,
    FOREIGN KEY (`department_id`) REFERENCES `department`(`department_id`) ON DELETE CASCADE
);
INSERT INTO program (`program_id`, `name_program`, `department_id`, `plan`)
VALUES (1, 'Прикладная математика и информатика', 2, 2),
(2, 'Математика и компьютерные науки', 2, 1),
(3, 'Прикладная механика', 1, 2),
(4, 'Мехатроника и робототехника', 1, 3);

CREATE TABLE enrollee (
    `enrollee_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_enrollee` VARCHAR(50)
);
INSERT INTO enrollee (`enrollee_id`, `name_enrollee`)
VALUES (1, 'Баранов Павел'), (2, 'Абрамова Катя'), (3, 'Семенов Иван'),
(4, 'Яковлева Галина'), (5, 'Попов Илья'), (6, 'Степанова Дарья');

CREATE TABLE achievement (
    `achievement_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_achievement` VARCHAR(30),
    `bonus` INT
);
INSERT INTO achievement (`achievement_id`, `name_achievement`, `bonus`)
VALUES (1, 'Золотая медаль', 5), (2, 'Серебряная медаль', 3),
    (3, 'Золотой значок ГТО', 3),(4, 'Серебряный значок ГТО', 1);

CREATE TABLE enrollee_achievement (
    `enrollee_achiev_id` INT PRIMARY KEY AUTO_INCREMENT,
    `enrollee_id` INT,
    `achievement_id` INT,
    FOREIGN KEY (`enrollee_id`) REFERENCES `enrollee`(`enrollee_id`) ON DELETE CASCADE,
    FOREIGN KEY (`achievement_id`) REFERENCES `achievement`(`achievement_id`) ON DELETE CASCADE
);
INSERT INTO enrollee_achievement (`enrollee_achiev_id`, `enrollee_id`, `achievement_id`)
VALUES (1, 1, 2), (2, 1, 3), (3, 3, 1), (4, 4, 4), (5, 5, 1),(6, 5, 3);

CREATE TABLE program_subject (
    `program_subject_id` INT PRIMARY KEY AUTO_INCREMENT,
    `program_id` INT,
    `subject_id` INT,
    `min_result` INT,
    FOREIGN KEY (`program_id`) REFERENCES `program`(`program_id`)  ON DELETE CASCADE,
    FOREIGN KEY (`subject_id`) REFERENCES `subject`(`subject_id`) ON DELETE CASCADE
);
INSERT INTO program_subject (`program_subject_id`, `program_id`, `subject_id`, `min_result`)
VALUES (1, 1, 1, 40),(2, 1, 2, 50), (3, 1, 4, 60), (4, 2, 1, 30),
       (5, 2, 2, 50),(6, 2, 4, 60), (7, 3, 1, 30),(8, 3, 2, 45),
       (9, 3, 3, 45),(10, 4, 1, 40), (11, 4, 2, 45), (12, 4, 3, 45);

CREATE TABLE program_enrollee (
    `program_enrollee_id` INT PRIMARY KEY AUTO_INCREMENT,
    `program_id` INT,
    `enrollee_id` INT,
    FOREIGN KEY (`program_id`) REFERENCES `program`(`program_id`) ON DELETE CASCADE,
    FOREIGN KEY (`enrollee_id`) REFERENCES enrollee(`enrollee_id`) ON DELETE CASCADE
);
INSERT INTO program_enrollee (`program_enrollee_id`, `program_id`, `enrollee_id`)
VALUES (1, 3, 1), (2, 4, 1), (3, 1, 1), (4, 2, 2), (5, 1, 2),
       (6, 1, 3), (7, 2, 3), (8, 4, 3), (9, 3, 4), (10, 3, 5),
       (11, 4, 5), (12, 2, 6), (13, 3, 6), (14, 4, 6);

CREATE TABLE enrollee_subject (
    `enrollee_subject_id` INT PRIMARY KEY AUTO_INCREMENT,
    `enrollee_id` INT,
    `subject_id` INT,
    `result` INT,
    FOREIGN KEY (`enrollee_id`) REFERENCES `enrollee`(`enrollee_id`) ON DELETE CASCADE,
    FOREIGN KEY (`subject_id`) REFERENCES `subject`(`subject_id`) ON DELETE CASCADE
);
INSERT INTO enrollee_subject (`enrollee_subject_id`, `enrollee_id`, `subject_id`, `result`)
VALUES (1, 1, 1, 68), (2, 1, 2, 70), (3, 1, 3, 41), (4, 1, 4, 75), (5, 2, 1, 75), (6, 2, 2, 70),
       (7, 2, 4, 81), (8, 3, 1, 85), (9, 3, 2, 67), (10, 3, 3, 90), (11, 3, 4, 78), (12, 4, 1, 82),
       (13, 4, 2, 86), (14, 4, 3, 70), (15, 5, 1, 65), (16, 5, 2, 67), (17, 5, 3, 60),
       (18, 6, 1, 90), (19, 6, 2, 92), (20, 6, 3, 88), (21, 6, 4, 94);
COMMIT;

/*Вывести абитуриентов, которые хотят поступать на образовательную программу «Мехатроника и робототехника» 
в отсортированном по фамилиям виде.*/
SELECT name_enrollee
  FROM enrollee
	   JOIN program_enrollee USING (enrollee_id)
       JOIN program USING (program_id)
 WHERE program_id = (SELECT program_id 
						FROM program 
					   WHERE name_program = 'Мехатроника и робототехника')
 ORDER BY name_enrollee;

/*Вывести образовательные программы, на которые для поступления необходим предмет «Информатика». 
Программы отсортировать в обратном алфавитном порядке.*/
SELECT name_program
  FROM program
	   JOIN program_subject USING (program_id)
       JOIN subject USING (subject_id)
 WHERE name_subject = 'Информатика'
 ORDER BY name_program DESC;
 
 /*Выведите количество абитуриентов, сдавших ЕГЭ по каждому предмету, максимальное, минимальное и 
 среднее значение баллов по предмету ЕГЭ. Вычисляемые столбцы назвать Количество, Максимум, Минимум, 
 Среднее. Информацию отсортировать по названию предмета в алфавитном порядке, среднее значение 
 округлить до одного знака после запятой.*/
SELECT name_subject,
       COUNT(DISTINCT enrollee_id) AS Количество,
       MAX(result) AS Максимум,
       MIN(result) AS Минимум,
       ROUND(AVG(result), 1) AS Среднее
  FROM subject
	   JOIN enrollee_subject USING (subject_id)
 GROUP BY name_subject
 ORDER BY name_subject;
 
/*Вывести образовательные программы, для которых минимальный балл ЕГЭ по каждому предмету больше или 
равен 40 баллам. Программы вывести в отсортированном по алфавиту виде.*/ 
SELECT name_program
  FROM program
	   JOIN program_subject USING (program_id)
 GROUP BY name_program
HAVING MIN(min_result) >= 40
 ORDER BY name_program; 
 
/*Вывести образовательные программы, которые имеют самый большой план набора,  вместе с этой величиной*/ 
SELECT name_program, plan
  FROM program
 WHERE plan = (SELECT MAX(plan) FROM program);

/*Посчитать, сколько дополнительных баллов получит каждый абитуриент. Столбец с дополнительными баллами 
назвать Бонус. Информацию вывести в отсортированном по фамилиям виде.*/
SELECT name_enrollee,
	   IF(SUM(bonus), SUM(bonus), 0) AS Бонус
  FROM enrollee
	   LEFT JOIN enrollee_achievement USING (enrollee_id)
       LEFT JOIN achievement USING (achievement_id)
 GROUP BY name_enrollee
 ORDER BY name_enrollee;

/*Выведите сколько человек подало заявление на каждую образовательную программу и конкурс на нее (число 
поданных заявлений деленное на количество мест по плану), округленный до 2-х знаков после запятой. В 
запросе вывести название факультета, к которому относится образовательная программа, название образовательной 
программы, план набора абитуриентов на образовательную программу (plan), количество поданных заявлений 
(Количество) и Конкурс. Информацию отсортировать в порядке убывания конкурса.*/
SELECT name_department, name_program, plan,
       COUNT(enrollee_id) AS Количество,
       ROUND(COUNT(enrollee_id) / plan, 2) AS Конкурс
  FROM department
	   JOIN program USING (department_id)
       JOIN program_enrollee USING (program_id)
 GROUP BY  name_department, name_program, plan
 ORDER BY Конкурс DESC;

/*Вывести образовательные программы, на которые для поступления необходимы предмет «Информатика» и «Математика» 
в отсортированном по названию программ виде.*/
SELECT name_program
  FROM program
	   JOIN program_subject USING (program_id)
       JOIN subject USING (subject_id)
 WHERE name_subject IN ('Информатика', 'Математика')
 GROUP BY name_program
HAVING COUNT(subject_id) = 2
 ORDER BY name_program;

/*Посчитать количество баллов каждого абитуриента на каждую образовательную программу, на которую он подал 
заявление, по результатам ЕГЭ. В результат включить название образовательной программы, фамилию и имя абитуриента, 
а также столбец с суммой баллов, который назвать itog. Информацию вывести в отсортированном сначала по 
образовательной программе, а потом по убыванию суммы баллов виде.*/ 
SELECT name_program, name_enrollee, 
	   SUM(result) AS itog
  FROM enrollee
	   JOIN program_enrollee USING (enrollee_id)
       JOIN program USING (program_id)
       JOIN program_subject USING (program_id)
       JOIN subject USING (subject_id)
       JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id 
								AND enrollee_subject.enrollee_id = enrollee.enrollee_id
 GROUP BY name_program, name_enrollee
 ORDER BY name_program, itog DESC;

/*Вывести название образовательной программы и фамилию тех абитуриентов, которые подавали документы на эту 
образовательную программу, но не могут быть зачислены на нее. Эти абитуриенты имеют результат по одному или 
нескольким предметам ЕГЭ, необходимым для поступления на эту образовательную программу, меньше минимального 
балла. Информацию вывести в отсортированном сначала по программам, а потом по фамилиям абитуриентов виде.*/
INSERT INTO enrollee_subject (enrollee_id, subject_id, result) VALUES (2, 3, 41);

SELECT name_program, name_enrollee
  FROM enrollee
	   JOIN program_enrollee USING (enrollee_id)
       JOIN program USING (program_id)
       JOIN program_subject USING (program_id)
       JOIN subject USING (subject_id)
       JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id 
							 AND enrollee_subject.enrollee_id = enrollee.enrollee_id
 WHERE enrollee_subject.result < program_subject.min_result
 ORDER BY name_program, name_enrollee;
 
/*Вывести по каждому предмету: минимум, максимум, среднее и количество сдавших предмет*/
SELECT LOWER(name_subject) AS предмет,
       MAX(result) AS максимум,
       MIN(result) AS минимум,
       ROUND(AVG(result), 1) AS среднее,
       COUNT(DISTINCT enrollee_id) AS количество
  FROM subject
	   JOIN enrollee_subject USING (subject_id)
 GROUP BY name_subject
 ORDER BY среднее DESC;