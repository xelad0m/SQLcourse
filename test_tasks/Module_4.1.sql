/*4.1 База данных «Интернет-магазин книг», часть 1*/
DROP SCHEMA IF EXISTS module41;
CREATE SCHEMA module41;
USE module41;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS stat;
DROP TABLE IF EXISTS buy_step;
DROP TABLE IF EXISTS step;
DROP TABLE IF EXISTS buy_book;
DROP TABLE IF EXISTS buy;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS book;

DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS city;

/* author */
CREATE TABLE author (
    `author_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_author` VARCHAR(50) NOT NULL
);
INSERT INTO author (`author_id`, `name_author`)
VALUES  (1, 'Булгаков М.А.'), (2, 'Достоевский Ф.М.'), (3, 'Есенин С.А.'),
        (4, 'Пастернак Б.Л.'), (5, 'Лермонтов М.Ю.');
/* genre */
CREATE TABLE genre (
    `genre_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_genre` VARCHAR(50)
);
INSERT INTO genre (`genre_id`, `name_genre`)
VALUES (1, 'Роман'), (2, 'Поэзия'), (3, 'Приключения');
/* book */
CREATE TABLE book (
    `book_id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(50),
    `author_id` INT NOT NULL,
    `genre_id` INT,
    `price` DECIMAL(8,2),
    `amount` INT,
    FOREIGN KEY (`author_id`)  REFERENCES author (`author_id`) ON DELETE CASCADE,
    FOREIGN KEY (`genre_id`)  REFERENCES genre (`genre_id`) ON DELETE SET NULL
);
INSERT INTO book (book_id ,title ,author_id ,genre_id ,price ,amount)
VALUES
        (1, 'Мастер и Маргарита', 1, 1, 670.99, 3),
        (2, 'Белая гвардия', 1, 1, 540.50, 5),
        (3, 'Идиот', 2, 1, 460.00, 10),
        (4, 'Братья Карамазовы', 2, 1, 799.01, 2),
        (5, 'Игрок', 2, 1, 480.50, 10),
        (6, 'Стихотворения и поэмы', 3, 2, 650.00, 15),
        (7, 'Черный человек', 3, 2, 570.20, 6),
        (8, 'Лирика', 4, 2, 518.99, 2);
CREATE TABLE city (
    `city_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_city` VARCHAR(30) NOT NULL,
    `days_delivery` INT
);
INSERT INTO city (city_id, name_city, days_delivery)
VALUES (1, 'Москва', 5), (2, 'Санкт-Петербург', 3), (3, 'Владивосток', 12);
/* client */
CREATE TABLE client (
    `client_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_client` VARCHAR(50) NOT NULL,
    `city_id` INT DEFAULT NULL,
    `email` VARCHAR(30) DEFAULT NULL,
    FOREIGN KEY (`city_id`) REFERENCES city(`city_id`) ON DELETE SET NULL
);
INSERT INTO client (client_id, name_client, city_id, email)
VALUES
    (1, 'Баранов Павел', 3, 'baranov@test'),
    (2, 'Абрамова Катя', 1, 'abramova@test'),
    (3, 'Семенов Иван', 2, 'semenov@test'),
    (4, 'Яковлева Галина', 1, 'yakovleva@test');

/* buy */
CREATE TABLE buy (
    `buy_id` INT PRIMARY KEY AUTO_INCREMENT,
    `buy_description` VARCHAR(100),
    `client_id` INT,
    FOREIGN KEY (`client_id`) REFERENCES client(`client_id`) ON DELETE CASCADE
);
INSERT INTO buy (buy_id, buy_description, client_id) VALUES
    (1, 'Доставка только вечером', 1),
    (2, NULL, 3),
    (3, 'Упаковать каждую книгу по отдельности', 2),
    (4, NULL, 1);
/* buy_book */
CREATE TABLE buy_book (
    `buy_book_id` INT PRIMARY KEY AUTO_INCREMENT,
    `buy_id` INT,
    `book_id` INT,
    `amount` INT,
    FOREIGN KEY (`buy_id`) REFERENCES buy(`buy_id`) ON DELETE SET NULL ,
    FOREIGN KEY (`book_id`) REFERENCES book (`book_id`) ON DELETE SET NULL
);
INSERT INTO buy_book (buy_book_id, buy_id, book_id, amount) VALUES
(1, 1, 1, 1), (2, 1, 7, 2), (3, 2, 8, 2), (4, 3, 3, 2), (5, 3, 2, 1), (6, 3, 1, 1), (7, 4, 5, 1);

/* step */
CREATE TABLE step (
    `step_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name_step` VARCHAR(50)
);
INSERT INTO step (step_id, name_step) VALUES
(1, 'Оплата'), (2, 'Упаковка'), (3, 'Транспортировка'), (4, 'Доставка');

/* buy_step */
CREATE TABLE buy_step (
    `buy_step_id` INT PRIMARY KEY AUTO_INCREMENT,
    `buy_id` INT ,
    `step_id` INT DEFAULT NULL,
    `date_step_beg` DATE DEFAULT NULL ,
    `date_step_end` DATE DEFAULT NULL,
    FOREIGN KEY (`buy_id`) REFERENCES buy(`buy_id`),
    FOREIGN KEY (`step_id`) REFERENCES step(`step_id`)
);
INSERT INTO buy_step (buy_step_id, buy_id, step_id, date_step_beg, date_step_end) VALUES
(1, 1, 1, '2020-02-20', '2020-02-20'),
(2, 1, 2, '2020-02-20', '2020-02-21'),
(3, 1, 3, '2020-02-22', '2020-03-07'),
(4, 1, 4, '2020-03-08', '2020-03-08'),
(5, 2, 1, '2020-02-28', '2020-02-28'),
(6, 2, 2, '2020-02-29', '2020-03-01'),
(7, 2, 3, '2020-03-02', NULL),
(8, 2, 4, NULL, NULL),
(9, 3, 1, '2020-03-05', '2020-03-05'),
(10, 3, 2, '2020-03-05', '2020-03-06'),
(11, 3, 3, '2020-03-06', '2020-03-10'),
(12, 3, 4, '2020-03-11', NULL),
(13, 4, 1, '2020-03-20',NULL),
(14, 4, 2, NULL, NULL),
(15, 4, 3, NULL, NULL),
(16, 4, 4, NULL, NULL);


/* stat */
CREATE TABLE stat (
    `beg_range` INT,
    `end_range` INT
);
INSERT INTO stat (beg_range, end_range) VALUES
(0, 600), (600, 700), (700, 10000);

/*Провести аналитику по трем ценовым категориям (до 600 руб, от 600 руб до 700 руб, свыше 700 руб) и 
вывести среднюю цену  книги, общую стоимость остатков книг  в этой ценовой позиции и количество позиций. 
Среднюю цену и стоимость округлить до двух знаков после запятой. 
Информацию отсортировать по возрастанию нижней границы ценовой категории.*/
SELECT beg_range, 
	   end_range,
       ROUND(AVG(price), 2) AS Средняя_цена,
       SUM(price * amount) AS Стоимость,
       COUNT(amount) AS Количество
  FROM (
		SELECT beg_range, end_range, price, amount
		  FROM stat, book
		  WHERE price >= beg_range AND
				price < end_range
	    ) AS query_in
  GROUP BY beg_range, end_range
  ORDER BY beg_range;

/*Вывести всю информацию из таблицы book, упорядоченную по возрастанию длины названия книги.*/
SELECT * FROM book
 ORDER BY LENGTH(title);

/*Удалить из таблиц book и supply книги, цены которых заканчиваются на 99 копеек. 
Например, книга с ценой 670.99 должна быть удалена.*/
SELECT * FROM book
 WHERE CEIL(price) - price = 0.01;

/*Снизить цены книг, цена которых больше 600 рублей, на 20%. Вывести информацию о книгах, скидку 
(столбец sale_20) и цену книги со скидкой (price_sale).  Результаты округлить до двух знаков после 
запятой. Для тех книг, на которые скидка не действует, в последних двух столбцах вывести символ  "-".  
Отсортировать информацию сначала по фамилии автора, а потом по названию книги.*/
SELECT name_author, title, price,
	   IF(price > 600, ROUND(price * 0.2, 2), '-') AS sale_20,
       IF(price > 600, ROUND(price * 0.8, 2), '-') AS price_sale
  FROM book JOIN author USING (author_id)
 ORDER BY name_author, title;
 
/*Вывести авторов и суммарную стоимость их книг, если хотя бы одна их книга имеет цену выше средней по складу. 
Средняя цена рассчитывается как простое среднее, с помощью avg(). 
Информацию отсортировать по убыванию суммарной стоимости.*/
SELECT author_id, SUM(price * amount) AS Стоимость
  FROM book JOIN (
		SELECT author_id, ap
		  FROM book 
			   JOIN (SELECT author_id, AVG(price) AS ap
					   FROM book
					  GROUP BY author_id) AS q_in USING (author_id)
		 WHERE price >= ap
		) AS query_2 USING (author_id)
 GROUP BY author_id
 ORDER BY Стоимость DESC;

/*Вывести жанр(ы), в котором было заказано меньше всего экземпляров книг, указать это количество. 
Учитывать только жанры, в которых была заказана хотя бы одна книга.
При реализации в основном запросе не используйте LIMIT, поскольку жанров с минимальным количеством 
заказанных книг может быть несколько.*/
SELECT name_genre, 
	   SUM(buy_book.amount) AS Количество
  FROM book 
	   JOIN genre USING (genre_id)
       JOIN buy_book USING (book_id)
 GROUP BY name_genre
HAVING SUM(buy_book.amount) = (
								SELECT MIN(Количество) 
								  FROM (
										SELECT name_genre, 
											   SUM(buy_book.amount) AS Количество
										  FROM book 
											   JOIN genre USING (genre_id)
											   JOIN buy_book USING (book_id)
										 GROUP BY name_genre
										HAVING SUM(buy_book.amount) > 0
									   ) AS min_q 
								);

/*далее по другому варианте БД этому работает только на сайте*/

/*Создать новую таблицу store, в которую занести данные из таблиц book и supply, при условии, что количество книг 
будет больше среднего количества книг по двум таблицам; если книга есть в обеих таблицах, то стоимость выбрать 
большую из двух. Отсортировать данные из таблицы их по имени автора в алфавитном порядке и по убыванию цены. 
Вывести данные из полученной таблицы.*/
CREATE TABLE store AS
( WITH uni_all AS (SELECT *
                     FROM book 
                    UNION ALL 
                   SELECT * FROM supply),
       max_price AS (SELECT title, author, MAX(price) AS mp 
                       FROM uni_all
                      GROUP BY title, author)

SELECT uni_all.title, uni_all.author, mp AS price, SUM(amount) AS amount
  FROM uni_all JOIN max_price ON uni_all.title = max_price.title
 GROUP BY uni_all.title, uni_all.author, mp
HAVING SUM(amount) > (
                 SELECT SUM(amount) / COUNT(*) AS lim
                   FROM uni_all
                )
 ORDER BY uni_all.author, mp DESC);
 
 SELECT * FROM store;
 
 /*Объявить столбец "категории цены" (price_category): <500 - "низкая", 500 - 700 - "средняя", более 700 - "высокая"
Вывести автора, название, категорию, стоимость (цена * количество), исключив из авторов Есенина, из названий "Белую гвардию". 
Отсортировать по убыванию стоимости и названию (по возрастанию)*/
SELECT author, title, 
       CASE WHEN price<500 THEN 'низкая'
            WHEN price BETWEEN 500 AND 700 THEN 'средняя'
            WHEN price>700 THEN 'высокая'
       END AS price_category,
       SUM(price * amount) AS cost
  FROM book
 WHERE author NOT LIKE '%Есенин%' 
       AND title NOT LIKE '%гварди%'
 GROUP BY author, title, price_category
 ORDER BY cost DESC, author;

/*Для нечетного количества книг посчитать разницу максимальной стоимости (цена * количество) и стоимостью всех экземпляров 
конкретной книги. Отсортировать по этой разнице по убыванию. Вывести название, автора, количество, разницу с максимальной стоимостью.*/
SELECT title, author, amount,
       (SELECT MAX(price * amount) as max_cost FROM book) - price * amount AS Разница_с_макс_стоимостью
  FROM book
 WHERE amount % 2 = 1
 ORDER BY 4 DESC;

/*Магазин решил быстрее распродать остатки книг, цена которых выше 600, а также прописать условия доставки. 
Создать запрос на выборку, в котором:
    Столбцы назовите Наименование, Цена и  Стоимость доставки.
    Отберите все книги, цена которых выше 600.
    Если остаток по отдельной книге меньше или равен 5, то стоимость доставки будет 500 рублей, если больше 5, то доставка будет бесплатной (вместо стоимости доставки вставить Бесплатно).
    Отсортируйте значения по убыванию цены книг.*/
SELECT title AS Наименование, 
       price AS Цена,
       IF(amount <= 5, 500, 'Бесплатно') AS Стоимость_доставки
  FROM book
 WHERE price > 600
 ORDER BY price DESC;
 
/*На распродаже размер скидки устанавливается в зависимости от количества экземпляров книги в магазине и от цены книги: 
для книг в остатке не менее 5 шт скидка 50%, тогда как для книг в остатке менее 5 шт скидка устанавливается в зависимости 
от цены (на книги не дешевле 700 руб скидка 20%, на остальные 10%). Два последних столбца назвать Скидка и Цена_со_скидкой.  
Последний столбец округлить до двух знаков после запятой.*/
SELECT author, title, amount, price,
       IF(amount >= 5, '50%', IF(price < 700, '10%', '20%')) AS Скидка,
       ROUND(IF(amount >= 5, price * .5, IF(price < 700, price * .9, price * .8)), 2) AS Цена_со_скидкой          
  FROM book;

/*Определить стоимость доставки:
- для книг стоимостью 500 и менее, установить в размере 99.99
- при количестве книг на складе менее 5, установить в размере 149.99
- для остальных случаев доставка должна быть бесплатной
Определить новую стоимость для книг:
- для книг, совокупной стоимостью более 5000, добавить 20% к стоимости за экземпляр
- для остальных случаев снизить стоимость одного экземпляра на 20%
Настроить фильтр при выборке:
- только позиции творчества авторов: Булгаков и Есенин, при количестве экземпляров на складе: от 3 до 14 включительно.
Сортировку выполнить:
- по имени автора в порядке возрастания
- затем по названию в порядке убывания
- по стоимости доставки (от меньшей к большей)
В таблице должны быть отображены данные:
- автора
- название
- количество
- цену, как real_price
- новую цену, как new_price (округлить до двух знаков после запятой)
- стоимость доставки, как delivery_price */
SELECT author, title, amount, 
       book.price AS real_price,
       ROUND(np, 2) AS new_price,
       IF(amount < 5, 149.99, 0) AS delivery_price
  FROM book JOIN
       (SELECT title, price, SUM(price * amount) as tot,
               IF(SUM(price * amount) > 5000, price * 1.2, price * 0.8) as np
          FROM book
         GROUP BY title, price) AS query_in USING (title)
 WHERE author IN ('Булгаков М.А.', 'Есенин С.А.') AND
       amount BETWEEN 3 AND 14;

/*Вывести авторов и названия книг и их цену в двух столбцах - рубли и копейки.  Информацию отсортировать по убыванию копеек. */
SELECT author, title, 
       FLOOR(price) AS Рубли,
       ROUND((price - FLOOR(price)) * 100) As Копейки
  FROM book
 ORDER BY Копейки DESC;
 
/*В выборке:
- к имени автора добавить "Графоман и ";
- к названию книги дописать ". Краткое содержание.";
- цену на новый опус установить 40% от цены оригинала, но не более 250. (Если 40% больше 250, то цена должна быть 250);
- в зависимости от остатка на складе вывести "Спрос": до 3 (включительно) - высокий, до 10 (включительно) - средний, иначе низкий;
- добавить колонку "Наличие" в зависимости от количества: 1-2 шт - очень мало, 3-14 - в наличии, 15 и больше - много;
- отсортировать по цене по возрастанию, затем по Спросу от высокого к низкому, а затем по названию книги в алфавитном порядке.*/
SELECT CONCAT('Графоман и ', author) AS Автор,
       CONCAT(title, '. Краткое содержание.') AS Название,
       IF(250 < price * 0.4, 250, price * 0.4) AS Цена,
       CASE WHEN amount <= 3 THEN 'высокий'
            WHEN amount BETWEEN 4 AND 10 THEN 'средний'
            ELSE 'низкий'
            END AS Спрос,
       CASE WHEN amount BETWEEN 1 AND 2 THEN 'очень мало'
            WHEN amount BETWEEN 3 AND 14 THEN 'в наличии'
            ELSE 'много'
            END AS Наличие
  FROM book
 ORDER BY Цена, amount, title;

/*таперь опять задания на локальной БД*/

/*Для клиентов у которых сумма заказов выше средней по суммам заказов клиентов (общей стоимости всех заказов клиентов), 
вывести имя, общую сумму всех заказов, количество заказов, количество заказанных книг. Этим клиентам мы предложим 
специальную программу лояльности! Информацию отсортировать по имени клиентов ( в алфавитном порядке).*/
SELECT name_client, 
       SUM(price * buy_book.amount) AS Общая_сумма_заказов,
       COUNT(DISTINCT buy.buy_id) AS Заказов_всего,
       SUM(buy_book.amount) AS Книг_всего
  FROM client
	   JOIN buy USING (client_id)
       JOIN buy_book USING (buy_id)
       JOIN book USING (book_id)
 GROUP BY name_client
HAVING Общая_сумма_заказов > (SELECT SUM(price * buy_book.amount) / COUNT(DISTINCT buy_book.buy_id)  
								FROM book JOIN buy_book USING (book_id))
 ORDER BY name_client;

/*Составить рейтинг книг в зависимости от того, какая книга принесет больше всего выручки (в процентах), 
при условии продажи всех книг. Рейтинг отсортировать по убыванию выручки. Выручка в процентах вычисляется 
как стоимость всех экземпляров книги деленное на суммарную стоимость всех экземпляров книг на складе и 
умноженное на 100, полученный результат округлить до двух знаков после запятой.*/
SELECT author, title, price, amount,
       ROUND(price * amount / (SELECT SUM(price * amount) FROM book) * 100, 2) AS income_percent
  FROM book
 ORDER BY income_percent DESC;

/*Для каждого автора из таблицы author вывести количество книг, написанных им в каждом жанре.
Вывести: ФИО автора, жанр, количество.
Отсортировать: по фамилии, затем - по убыванию количества написанных книг, а затем в алфавитном порядке по названию жанра.
Важно! Реализовать задание одним запросом на выборку.*/
SELECT name_author, name_genre, COUNT(title) AS Количество
  FROM author AS a
       CROSS JOIN genre AS g
       LEFT JOIN book AS b ON a.author_id = b.author_id AND g.genre_id = b.genre_id
 GROUP BY name_author, name_genre
 ORDER BY name_author, Количество DESC, name_genre;

/*Вывести автора, название книги и цену. Выбрать книги с ценой 500 рублей и выше, отсортировать информацию в 
алфавитном порядке по автору и названию книги. Добавить столбец Подарок,  в котором вывести, какой подарок 
получает покупатель: если куплена книга от 500 рублей до 600 рублей (включительно), то подарок - ручка, 
от 600 до 700 (включительно) - детская раскраска, выше 700 - гороскоп.*/
SELECT author AS Автор, title AS Название_книги, price AS Цена,
	   CASE WHEN price between 500 and 600 THEN 'ручка' 
			WHEN price between 600 and 700 THEN 'детская раскраска'
            ELSE 'гороскоп'
            END AS Подарок
  FROM book
 WHERE price > 500
 ORDER BY author, title;

/*При анализе остатков книг на складе было решено дополнительно заказать книги авторов, у которых суммарное число 
экземпляров книг меньше 10. В таблице должны быть отображены авторы, наименьшее и наибольшее количество их книг.*/
SELECT author AS Автор,
       MIN(amount) AS Наименьшее_кол_во,
       MAX(amount) AS Наибольшее_кол_во
  FROM book
 GROUP BY author
HAVING Наибольшее_кол_во < 10;

/*В последний заказ (таблица buy_book) клиента Баранов Павел добавить по одному экземпляру всех книг Достоевского, 
которые есть в таблице book.*/
INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 
	   (SELECT MAX(buy_id) FROM buy JOIN client USING (client_id)
	     WHERE name_client = 'Баранов Павел') AS buy_id, 
	   book_id, 
       1 AS amount 
  FROM book JOIN author USING (author_id)
 WHERE name_author = 'Достоевский Ф.М.' AND 
	   book_id NOT IN (SELECT book_id FROM buy_book WHERE buy_id = 
								(SELECT MAX(buy_id) FROM buy JOIN client USING (client_id)
								  WHERE name_client = 'Баранов Павел'));

SELECT MAX(buy_id) FROM buy JOIN client USING (client_id)
	     WHERE name_client = 'Баранов Павел';

SELECT book_id FROM buy_book WHERE buy_id = 
								(SELECT MAX(buy_id) FROM buy JOIN client USING (client_id)
								  WHERE name_client = 'Баранов Павел')

/*Найти вопрос, с самой большой успешностью выполнения - "самый легкий" и вопрос, с самой 
маленькой успешностью выполнения - "самый сложный".  (Подробно про успешность на этом шаге). 
Вывести предмет, эти два вопроса и указание - самый сложный или самый легкий это вопрос. 
Сначала вывести самый легкий запроса, потом самый сложный.*/













