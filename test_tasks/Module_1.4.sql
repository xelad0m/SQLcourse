USE test_tasks;		

CREATE TABLE fine
    (
        fine_id INTEGER PRIMARY KEY AUTO_INCREMENT,
        name varchar(30),
        number_plate varchar(6),
        violation varchar(50),
        sum_fine decimal(8, 2),
        date_violation date,
        date_payment date
    );

INSERT INTO fine (name, number_plate, violation, sum_fine, date_violation, date_payment)
VALUES ('Баранов П.Е.', 'Р523ВТ', 'Превышение скорости(от 40 до 60)', NULL, '2020-02-14 ', NULL),
       ('Абрамова К.А.', 'О111АВ', 'Проезд на запрещающий сигнал', NULL, '2020-02-23', NULL),
       ('Яковлев Г.Р.', 'Т330ТТ', 'Проезд на запрещающий сигнал', NULL, '2020-03-03', NULL),
       ('Баранов П.Е.', 'Р523ВТ', 'Превышение скорости(от 40 до 60)', 500.00, '2020-01-12', '2020-01-17'),
       ('Абрамова К.А.', 'О111АВ', 'Проезд на запрещающий сигнал', 1000.00, '2020-01-14', '2020-02-27'),
       ('Яковлев Г.Р.', 'Т330ТТ', 'Превышение скорости(от 20 до 40)', 500.00, '2020-01-23', '2020-02-23'),
       ('Яковлев Г.Р.', 'М701АА', 'Превышение скорости(от 20 до 40)', NULL, '2020-01-12', NULL),
       ('Колесов С.П.', 'К892АХ', 'Превышение скорости(от 20 до 40)', NULL, '2020-02-01', NULL);

CREATE TABLE traffic_violation
    (
        violation_id serial
            PRIMARY KEY,
        violation varchar(50),
        sum_fine decimal(8, 2)
    );

INSERT INTO traffic_violation (violation, sum_fine)
VALUES ('Превышение скорости(от 20 до 40)', 500),
       ('Превышение скорости(от 40 до 60)', 1000),
       ('Проезд на запрещающий сигнал', 1000);
       
/*Занести в таблицу fine суммы штрафов, которые должен оплатить водитель, в соответствии с данными 
из таблицы traffic_violation. При этом суммы заносить только в пустые поля столбца  sum_fine.*/
UPDATE fine AS f, traffic_violation AS tv
   SET f.sum_fine = tv.sum_fine
 WHERE f.violation = tv.violation AND f.sum_fine IS NULL;
 
 /*Вывести фамилию, номер машины и нарушение только для тех водителей, которые на одной машине 
 нарушили одно и то же правило два и более раз. При этом учитывать все нарушения, независимо от 
 того оплачены они или нет. Информацию отсортировать в алфавитном порядке, сначала по фамилии водителя, 
 потом по номеру машины и, наконец, по нарушению.*/
 SELECT name, number_plate, violation, SUM(sum_fine)
   FROM fine
  GROUP BY name, number_plate, violation
 HAVING COUNT(name) >= 2
  ORDER BY name, number_plate, violation;
   
/*В таблице fine увеличить в два раза сумму неоплаченных штрафов для отобранных на предыдущем шаге записей. */
UPDATE fine, 
	(SELECT name, number_plate, violation					-- таблица исходных данных для обновления
	   FROM fine
	  GROUP BY name, number_plate, violation
	 HAVING COUNT(name) >= 2
 	  ORDER BY name, number_plate, violation) AS query_in
   SET fine.sum_fine = 2 * fine.sum_fine
 WHERE fine.name = query_in.name AND
	   fine.number_plate = query_in.number_plate AND
       fine.violation = query_in.violation AND
       fine.date_payment IS NULL;

/*  в таблицу fine занести дату оплаты соответствующего штрафа из таблицы payment; 
    уменьшить начисленный штраф в таблице fine в два раза  (только для тех штрафов, 
    информация о которых занесена в таблицу payment) , если оплата произведена не позднее 20 дней со дня нарушения.
*/
CREATE TABLE payment 
	   (payment_id 		INTEGER PRIMARY KEY AUTO_INCREMENT,
		name  	  		varchar(30),
		number_plate 	varchar(6),
        violation 		varchar(50),
        date_violation 	date,
        date_payment 	date);
        
INSERT INTO payment (name, number_plate, violation, date_violation, date_payment)
VALUES ("Яковлев Г.Р.", "М701АА", "Превышение скорости(от 20 до 40)", "2020-01-12", "2020-01-22"),
	   ("Баранов П.Е.", "Р523ВТ", "Превышение скорости(от 40 до 60)", "2020-02-14", "2020-03-06"),
       ("Яковлев Г.Р.", "Т330ТТ", "Проезд на запрещающий сигнал", "2020-03-03", "2020-03-23");

UPDATE fine AS f, payment AS p
   SET f.date_payment = p.date_payment,
	   f.sum_fine = IF (DATEDIFF(p.date_payment, p.date_violation) > 20,
						f.sum_fine, f.sum_fine / 2)
 WHERE f.date_payment IS NULL AND
	   f.name = p.name AND
       f.number_plate = p.number_plate AND
       f.violation = p.violation;
       
/*Создать новую таблицу back_payment, куда внести информацию о неоплаченных штрафах 
(Фамилию и инициалы водителя, номер машины, нарушение, сумму штрафа  и  дату нарушения) из таблицы fine.*/
CREATE TABLE back_payment AS
SELECT name, number_plate, violation, sum_fine, date_violation
  FROM fine
 WHERE date_payment IS NULL;
 
/*Удалить из таблицы fine информацию о нарушениях, совершенных раньше 1 февраля 2020 года. */
DELETE FROM fine
 WHERE date_violation < "2020-02-01";












