/*В данном уроке с помощью запросов корректировки данных для базы данных «Абитуриент» формируется список абитуриентов, рекомендованных к зачислению в университет:

    создается таблица с суммой баллов абитуриентов по предметам ЕГЭ в соответствии с поданными заявлениями;
    из таблицы удаляются абитуриенты, если они не набрали минимального балла по предмету, необходимому для поступления на образовательную программу;
    абитуриентам, у которых есть медаль или значок ГТО, добавляются дополнительные баллы;
    абитуриенты сортируются в соответствии с набранными баллами по каждой образовательной программе;
    формируется список абитуриентов, рекомендованных к зачислению ( вставляется столбец для нумерации, осуществляется нумерация студентов по образовательной программе, выбираются абитуриенты с наибольшими баллами в соответствии с планом набора).
*/
USE module33;

/*Создать вспомогательную таблицу applicant,  куда включить id образовательной программы, id абитуриента, сумму баллов 
абитуриентов (столбец itog) в отсортированном сначала по id образовательной программы, а потом по убыванию суммы баллов 
виде (использовать запрос из предыдущего урока).*/
DROP TABLE IF EXISTS applicant;
CREATE TABLE applicant AS
SELECT program_id, enrollee.enrollee_id, 	
	   SUM(result) AS itog
  FROM enrollee
	   JOIN program_enrollee USING (enrollee_id)
       JOIN program USING (program_id)
       JOIN program_subject USING (program_id)
       JOIN subject USING (subject_id)
       JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id 
								AND enrollee_subject.enrollee_id = enrollee.enrollee_id
 GROUP BY program_id, enrollee_id
 ORDER BY program_id, itog DESC;

/*Из таблицы applicant, созданной на предыдущем шаге, удалить записи, если абитуриент на выбранную образовательную 
программу не набрал минимального балла хотя бы по одному предмету (использовать запрос из предыдущего урока).*/
DELETE FROM applicant
 WHERE (program_id, enrollee_id) IN 
		(SELECT program_id, enrollee.enrollee_id
		   FROM enrollee
				JOIN program_enrollee USING (enrollee_id)
				JOIN program USING (program_id)
				JOIN program_subject USING (program_id)
				JOIN subject USING (subject_id)
				JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id 
										 AND enrollee_subject.enrollee_id = enrollee.enrollee_id
		  WHERE enrollee_subject.result < program_subject.min_result
	      ORDER BY program_id, enrollee.enrollee_id
	);

/*Повысить итоговые баллы абитуриентов в таблице applicant на значения дополнительных баллов 
(использовать запрос из предыдущего урока).*/
UPDATE applicant,

(SELECT enrollee_id, SUM(bonus) AS bonus_temp
  FROM enrollee_achievement
       JOIN achievement USING (achievement_id)
 GROUP BY enrollee_id) AS sub_query
 
   SET applicant.itog = applicant.itog + sub_query.bonus_temp
 WHERE applicant.enrollee_id = sub_query.enrollee_id;

/*Поскольку при добавлении дополнительных баллов, абитуриенты по каждой образовательной программе могут следовать 
не в порядке убывания суммарных баллов, необходимо создать новую таблицу applicant_order на основе таблицы applicant. 
При создании таблицы данные нужно отсортировать сначала по id образовательной программы, потом по убыванию 
итогового балла. А таблицу applicant, которая была создана как вспомогательная, необходимо удалить.*/
CREATE TABLE applicant_order AS
SELECT * FROM applicant
 ORDER BY program_id, itog DESC;
DROP TABLE IF EXISTS applicant;

/*Включить в таблицу applicant_order новый столбец str_id целого типа , расположить его перед первым.*/
ALTER TABLE applicant_order ADD str_id INT FIRST;

/*Занести в столбец str_id таблицы applicant_order нумерацию абитуриентов, 
которая начинается с 1 для каждой образовательной программы.*/
SET @num_pr := 0;
SET @row_num := 1;

UPDATE applicant_order
   SET str_id = IF(program_id = @num_pr, 
				   @row_num := @row_num + 1, 
                   @row_num := 1 AND @num_pr := program_id);


/*Создать таблицу student,  в которую включить абитуриентов, которые могут быть рекомендованы к зачислению  
в соответствии с планом набора. Информацию отсортировать сначала в алфавитном порядке по названию программ, 
а потом по убыванию итогового балла.*/
DROP TABLE IF EXISTS student;
CREATE TABLE student AS
SELECT name_program, name_enrollee, itog
  FROM program
	   JOIN applicant_order USING (program_id)
       JOIN enrollee USING (enrollee_id)
 WHERE str_id <= plan
 ORDER BY name_program, itog DESC;

/*Через CREATE TABLE создать таблицу performance, которая будет содержать информацию по среднему баллу по каждому предмету 
и по проценту абитуриентов сдавших экзамены с баллом выше среднего.
После чего, через INSERT INTO добавить в таблицу дополнительную итоговую строку со средним баллом и с преуспевшими 
студентами рассчитанную по всем предметам и студентам совокупно.
Необходимо учесть:
1) Средний балл для расчёта преуспевших студентов (процент студентов у которых балл выше среднего) у каждого предмета свой.
2) Используя функцию CONCAT добавить к значениям преуспевших студентов знак процента.
3) Все названия на русском и начинаются с маленькой буквы используем функцию LOWER.
4) Округление до целого числа.
5) Сортировать по столбцу с процентом преуспевших студентов, по убыванию, при этом последняя строка - итог.
6) Использовать таблицы subject и enrollee_subject.*/
CREATE TABLE performance AS
SELECT DISTINCT LOWER(name_subject) AS предмет,
	   query_3.avrg AS среднее,
       query_2.above_avg AS преуспевшие_студенты
  FROM subject 
	   JOIN enrollee_subject USING (subject_id) 
       JOIN (SELECT subject_id,
				CONCAT(ROUND(COUNT(enrollee_id) / tot * 100), '%') AS above_avg
			   FROM enrollee_subject
				    JOIN (SELECT subject_id, 
								AVG(result) AS res,
								COUNT(enrollee_id) AS tot
						   FROM enrollee_subject
						  GROUP BY subject_id) AS query_in USING (subject_id)
			  WHERE enrollee_subject.result >= res
			  GROUP BY subject_id) AS query_2 USING (subject_id)
		JOIN (SELECT subject_id, ROUND(AVG(result)) AS avrg
				FROM enrollee_subject
			   GROUP BY subject_id) AS query_3 USING (subject_id);
