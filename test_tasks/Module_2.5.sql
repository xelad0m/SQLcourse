USE module24;

/*Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве.*/
INSERT INTO client (name_client, city_id, email) 
SELECT 'Попов Илья', city_id, 'popov@test'
  FROM city
 WHERE name_city = 'Москва';

/*Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки».*/
INSERT INTO buy (buy_description, client_id)
SELECT "Связаться со мной по вопросу доставки", client_id
  FROM client
 WHERE client.name_client = 'Попов Илья';

/*В таблицу buy_book добавить заказ с номером 5. Этот заказ должен содержать книгу Пастернака «Лирика» в количестве 
двух экземпляров и книгу Булгакова «Белая гвардия» в одном экземпляре.*/
INSERT INTO buy_book (buy_id, book_id, amount)
VALUES ( (SELECT MAX(buy.buy_id) FROM buy),						-- id последнего заказа
		 (SELECT book.book_id 
			FROM book 
				 JOIN author USING (author_id)
		   WHERE author.name_author LIKE "Пастернак%" AND
				 book.title = "Лирика"),
		  2),
		( (SELECT MAX(buy.buy_id) FROM buy),					-- id последнего заказа
		 (SELECT book.book_id 
			FROM book 
				 JOIN author USING (author_id)
		   WHERE author.name_author LIKE "Булгаков%" AND
				 book.title = "Белая гвардия"),
		  1);

/*Количество тех книг на складе, которые были включены в заказ с номером 5, уменьшить на то количество, которое в заказе с номером 5  указано.*/
UPDATE book JOIN buy_book USING (book_id)
   SET book.amount = book.amount - buy_book.amount
 WHERE buy_book.buy_id  = (SELECT MAX(buy.buy_id) FROM buy);	-- id последнего заказа

/*Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который включить название книг, их автора, цену, 
количество заказанных книг и  стоимость. Последний столбец назвать Стоимость. Информацию в таблицу занести в 
отсортированном по названиям книг виде.*/
DROP TABLE IF EXISTS buy_pay;
CREATE TABLE buy_pay (
	title 		TEXT,
    name_author TEXT,
    price 		DECIMAL(8, 2),
    amount		INT,
    `Стоимость`	DECIMAL(8, 2));

INSERT INTO buy_pay (title, name_author, price, amount, `Стоимость`)
SELECT book.title, author.name_author, book.price, buy_book.amount, 
	   book.price * buy_book.amount AS `Стоимость`
  FROM buy
	   JOIN buy_book USING (buy_id)  
	   JOIN book USING (book_id)
       JOIN author USING (author_id)
 WHERE buy_book.buy_id  = (SELECT MAX(buy.buy_id) FROM buy)		-- id последнего заказа
 ORDER BY book.title;

SELECT * FROM buy_pay;

/*Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5. Куда включить номер заказа, количество книг 
в заказе (название столбца Количество) и его общую стоимость (название столбца Итого). Для решения используйте ОДИН запрос.*/
DROP TABLE IF EXISTS buy_pay;
CREATE TABLE buy_pay (
	buy_id 			INT NOT NULL,
    `Количество`	INT,
    `Итого`			DECIMAL(8, 2));
INSERT INTO buy_pay (buy_id, `Количество`, `Итого`)
SELECT (SELECT MAX(buy.buy_id) FROM buy),
	   SUM(query_in.amnt),
	   SUM(query_in.`Стоимость`) 
  FROM (SELECT book.title, author.name_author, book.price, 
			   buy_book.amount as amnt, 
			   book.price * buy_book.amount AS `Стоимость`
		  FROM buy
			   JOIN buy_book USING (buy_id)  
			   JOIN book USING (book_id)
               JOIN author USING (author_id)
		 WHERE buy_book.buy_id  = (SELECT MAX(buy.buy_id) FROM buy)) AS query_in;

SELECT * FROM buy_pay;

/*В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step, которые должен пройти этот заказ. 
В столбцы date_step_beg и date_step_end всех записей занести Null.*/
INSERT INTO buy_step (buy_id, step_id, date_step_beg, date_step_end)
SELECT (SELECT MAX(buy.buy_id) FROM buy), 
	   step_id,
       NULL,
       NULL 
  FROM step;

/*В таблицу buy_step занести дату 12.04.2020 выставления счета на оплату заказа с номером 5.
Правильнее было бы занести не конкретную, а текущую дату. Это можно сделать с помощью функции Now(). 
Но при этом в разные дни будут вставляться разная дата, и задание нельзя будет проверить, поэтому  вставим дату 12.04.2020.*/
UPDATE buy_step
   SET buy_step.date_step_beg = '2020-04-12'		-- NOW()
 WHERE buy_step.buy_id = (SELECT MAX(buy.buy_id) FROM buy) 
	   AND buy_step.step_id = (SELECT step_id FROM step WHERE name_step = 'Оплата');

/*Завершить этап «Оплата» для заказа с номером 5, вставив в столбец date_step_end дату 13.04.2020, и начать следующий этап 
(«Упаковка»), задав в столбце date_step_beg для этого этапа ту же дату.
Реализовать два запроса для завершения этапа и начала следующего. Они должны быть записаны в общем виде, чтобы его можно 
было применять для любых этапов, изменив только текущий этап. Для примера пусть это будет этап «Оплата».*/
UPDATE buy_step
   SET buy_step.date_step_end = '2020-04-13'
 WHERE buy_step.buy_id = (SELECT MAX(buy.buy_id) FROM buy) 
	   AND buy_step.step_id = (SELECT step_id FROM step WHERE name_step = 'Оплата');

UPDATE buy_step
   SET buy_step.date_step_beg = '2020-04-13'
 WHERE buy_step.buy_id = (SELECT MAX(buy.buy_id) FROM buy) 
	   AND buy_step.step_id = (SELECT step_id FROM step WHERE name_step = 'Упаковка');

/*Ввести количество заказов, находящихся в каждом из статусов.*/
SELECT name_step, 
	   COUNT(*) AS Количество
  FROM step
	   LEFT JOIN (SELECT * FROM buy_step 
				   WHERE buy_step.date_step_beg IS NOT NULL
						 AND buy_step.date_step_end IS NULL) AS temp USING (step_id)
 GROUP BY name_step;
	 
