/*Создаем схему*/
CREATE SCHEMA module24;
USE module24;
SET FOREIGN_KEY_CHECKS = 0;	-- чтобы удалять связанные таблицы не проверяя связи 

-- AUTHOR
DROP TABLE IF EXISTS author;
CREATE TABLE IF NOT EXISTS author
(
		author_id   INT PRIMARY KEY AUTO_INCREMENT,
		name_author TEXT
);
INSERT INTO author(name_author)
VALUES ('Булгаков М.А.'),
       ('Достоевский Ф.М.'),
       ('Есенин С.А.'),
       ('Пастернак Б.Л.'),
       ('Лермонтов М.Ю.');


-- GENRE
DROP TABLE IF EXISTS genre;
CREATE TABLE IF NOT EXISTS genre
(
		genre_id   INT PRIMARY KEY AUTO_INCREMENT,
		name_genre TEXT
);
INSERT INTO genre(name_genre)
VALUES ('Роман'),
       ('Поэзия'),
       ('Приключения');


-- BOOK
DROP TABLE IF EXISTS book;
CREATE TABLE IF NOT EXISTS book
(
		book_id   INT PRIMARY KEY AUTO_INCREMENT,
		title     TEXT,
		author_id INT NOT NULL,
		genre_id  INT,
		price     DECIMAL(8, 2),
		amount    INT,
		CONSTRAINT FK_book_author
				FOREIGN KEY (author_id) REFERENCES author (author_id) ON DELETE CASCADE,
		CONSTRAINT FK_book_genre
				FOREIGN KEY (genre_id) REFERENCES genre (genre_id) ON DELETE SET NULL
);
INSERT INTO book(title, author_id, genre_id, price, amount)
VALUES ('Мастер и Маргарита', 1, 1, 670.99, 3),
       ('Белая гвардия', 1, 1, 540.50, 5),
       ('Идиот', 2, 1, 460.00, 10),
       ('Братья Карамазовы', 2, 1, 799.01, 2),
       ('Игрок', 2, 1, 480.50, 10),
       ('Стихотворения и поэмы', 3, 2, 650.00, 15),
       ('Черный человек', 3, 2, 570.20, 6),
       ('Лирика', 4, 2, 518.99, 2);


-- CITY
DROP TABLE IF EXISTS city CASCADE;
CREATE TABLE IF NOT EXISTS city
(
		city_id       INT PRIMARY KEY AUTO_INCREMENT,
		name_city     TEXT,
		days_delivery INT
);
INSERT INTO city(name_city, days_delivery)
VALUES ('Москва', 5),
       ('Санкт-Петербург', 3),
       ('Владивосток', 12);


-- CLIENT
DROP TABLE IF EXISTS client;
CREATE TABLE IF NOT EXISTS client
(
		client_id   INT PRIMARY KEY AUTO_INCREMENT,
		name_client TEXT,
		city_id     INT,
		email       VARCHAR(255),
		CONSTRAINT FK_client_city
				FOREIGN KEY (city_id) REFERENCES city (city_id)
);
INSERT INTO client(name_client, city_id, email)
VALUES ('Баранов Павел', 3, 'baranov@test'),
       ('Абрамова Катя', 1, 'abramova@test'),
       ('Семенонов Иван', 2, 'semenov@test'),
       ('Яковлева Галина', 1, 'yakovleva@test');


-- BUY
DROP TABLE IF EXISTS buy;
CREATE TABLE IF NOT EXISTS buy
(
		buy_id          INT PRIMARY KEY AUTO_INCREMENT,
		buy_description TEXT,
		client_id       INT DEFAULT (NULL),
		CONSTRAINT FK_buy_client
				FOREIGN KEY (client_id) REFERENCES client (client_id)
);
INSERT INTO buy (buy_description, client_id)
VALUES ('Доставка только вечером', 1),
       (NULL, 3),
       ('Упаковать каждую книгу по отдельности', 2),
       (NULL, 1);


-- BUY_BOOK
DROP TABLE IF EXISTS buy_book;
CREATE TABLE IF NOT EXISTS buy_book
(
		buy_book_id INT PRIMARY KEY AUTO_INCREMENT,
		buy_id      INT,
		book_id     INT,
		amount      INT,
		CONSTRAINT FK_buy_book_buy
				FOREIGN KEY (buy_id) REFERENCES buy (buy_id),
		CONSTRAINT FK_buy_book_book
				FOREIGN KEY (book_id) REFERENCES book (book_id)
);
INSERT INTO buy_book(buy_id, book_id, amount)
VALUES (1, 1, 1),
       (1, 7, 2),
       (2, 8, 2),
       (3, 3, 2),
       (3, 2, 1),
       (3, 1, 1),
       (4, 5, 1);


-- STEP
DROP TABLE IF EXISTS step;
CREATE TABLE IF NOT EXISTS step
(
		step_id   INT PRIMARY KEY AUTO_INCREMENT,
		name_step TEXT
);
INSERT INTO step(name_step)
VALUES ('Оплата'),
       ('Упаковка'),
       ('Транспортировка'),
       ('Доставка');


-- BUY_STEP
DROP TABLE IF EXISTS buy_step;
CREATE TABLE IF NOT EXISTS buy_step
(
		buy_step_id   INT PRIMARY KEY AUTO_INCREMENT,
		buy_id        INT,
		step_id       INT,
		date_step_beg DATE,
		date_step_end DATE,
		CONSTRAINT FK_buy_step_buy
				FOREIGN KEY (buy_id) REFERENCES buy (buy_id),
		CONSTRAINT FK_buy_step_step
				FOREIGN KEY (step_id) REFERENCES step (step_id)
);
INSERT INTO buy_step(buy_id, step_id, date_step_beg, date_step_end)
VALUES (1, 1, '2020-02-20', '2020-02-20'),
       (1, 2, '2020-02-20', '2020-02-21'),
       (1, 3, '2020-02-22', '2020-03-07'),
       (1, 4, '2020-03-08', '2020-03-08'),
       (2, 1, '2020-02-28', '2020-02-28'),
       (2, 2, '2020-02-29', '2020-03-01'),
       (2, 3, '2020-03-02', NULL),
       (2, 4, NULL, NULL),
       (3, 1, '2020-03-05', '2020-03-05'),
       (3, 2, '2020-03-05', '2020-03-06'),
       (3, 3, '2020-03-06', '2020-03-10'),
       (3, 4, '2020-03-11', NULL),
       (4, 1, '2020-03-20', NULL),
       (4, 2, NULL, NULL),
       (4, 3, NULL, NULL),
       (4, 4, NULL, NULL);
       
       
       
       
/*Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве 
он заказал) в отсортированном по номеру заказа и названиям книг виде.*/
SELECT buy.buy_id, book.title, book.price, buy_book.amount
  FROM buy
	   JOIN buy_book ON buy.buy_id = buy_book.buy_id
       JOIN book ON buy_book.book_id = book.book_id
       JOIN client ON client.client_id = buy.client_id
 WHERE client.name_client = "Баранов Павел"
 ORDER BY buy.buy_id, book.title;
 
/*Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора (нужно посчитать, 
в каком количестве заказов фигурирует каждая книга).  Вывести фамилию и инициалы автора, название 
книги, последний столбец назвать Количество. Результат отсортировать сначала  по фамилиям авторов, 
а потом по названиям книг.*/
SELECT author.name_author, 
	   book.title, 
       COUNT(buy_book.amount) AS Количество
 FROM book
	  LEFT JOIN buy_book ON buy_book.book_id = book.book_id
      JOIN author ON author.author_id = book.author_id
GROUP BY book.book_id										-- почему только так работает? непонято...
ORDER BY author.name_author, book.title;

/*Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. Указать 
количество заказов в каждый город, этот столбец назвать Количество. Информацию вывести по 
убыванию количества заказов, а затем в алфавитном порядке по названию городов.*/
SELECT city.name_city, 
	   COUNT(DISTINCT buy_book.buy_id) AS Количество
  FROM buy_book
	   JOIN buy ON buy.buy_id = buy_book.buy_id
       JOIN client ON client.client_id = buy.client_id
       JOIN city ON city.city_id = client.city_id
 GROUP BY city.name_city
 ORDER BY Количество DESC, city.name_city;

/*Вывести номера всех оплаченных заказов и даты, когда они были оплачены.*/
SELECT buy_id, date_step_end
  FROM buy_step
 WHERE step_id = 1 AND date_step_end IS NOT NULL;

/*Вывести информацию о каждом заказе: его номер, кто его сформировал (фамилия пользователя) 
и его стоимость (сумма произведений количества заказанных книг и их цены), в отсортированном 
по номеру заказа виде. Последний столбец назвать Стоимость*/
SELECT buy_book.buy_id, 
	   client.name_client,
       SUM(book.price * buy_book.amount) AS Стоимость
  FROM buy_book
	   JOIN buy ON buy.buy_id = buy_book.buy_id
       JOIN client ON client.client_id = buy.client_id
       JOIN book ON book.book_id = buy_book.book_id
 GROUP BY buy_book.buy_id
 ORDER BY buy_book.buy_id;

/*Вывести номера заказов (buy_id) и названия этапов,  на которых они в данный момент находятся. 
Если заказ доставлен –  информацию о нем не выводить. Информацию отсортировать по возрастанию buy_id.*/
SELECT buy_step.buy_id, step.name_step
  FROM buy_step
	   JOIN step USING(step_id)
 WHERE buy_step.date_step_beg IS NOT NULL
	   AND buy_step.date_step_end IS NULL
 ORDER BY buy_step.buy_id;

/*В таблице city для каждого города указано количество дней, за которые заказ может быть доставлен в этот город 
(рассматривается только этап Транспортировка). Для тех заказов, которые прошли этап транспортировки, вывести 
количество дней за которое заказ реально доставлен в город. А также, если заказ доставлен с опозданием, указать 
количество дней задержки, в противном случае вывести 0. В результат включить номер заказа (buy_id), а также вычисляемые 
столбцы Количество_дней и Опоздание. Информацию вывести в отсортированном по номеру заказа виде.*/
SELECT buy.buy_id, 
	   DATEDIFF(buy_step.date_step_end, buy_step.date_step_beg) AS Количество_дней,
       IF(DATEDIFF(buy_step.date_step_end, buy_step.date_step_beg) - city.days_delivery > 0,
          DATEDIFF(buy_step.date_step_end, buy_step.date_step_beg) - city.days_delivery, 
          0) AS Опоздание
  FROM city
	   JOIN client USING (city_id)
       JOIN buy USING (client_id)
       JOIN buy_step USING (buy_id)
       JOIN step USING (step_id)
 WHERE step.name_step = 'Транспортировка' AND
	   buy_step.date_step_end IS NOT NULL;

/*Выбрать всех клиентов, которые заказывали книги Достоевского, информацию вывести в отсортированном по алфавиту виде.*/
SELECT client.name_client
  FROM client
	   JOIN buy USING (client_id)
       JOIN buy_book USING (buy_id)
       JOIN book USING (book_id)
       JOIN author USING (author_id)
 WHERE author.name_author = 'Достоевский Ф.М.'
 GROUP BY client.name_client
 ORDER BY client.name_client;

/*Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, указать это количество. 
Последний столбец назвать Количество.*/
SELECT genre.name_genre,
	   SUM(buy_book.amount) AS Количество
  FROM genre
	   JOIN book USING (genre_id)
       JOIN buy_book USING (book_id)
 GROUP BY genre.name_genre
 ORDER BY Количество DESC
 LIMIT 1;														-- вариант не срабоатет, если два жанра с макс объемом

-- EXPLAIN
SELECT genre.name_genre,
	   SUM(buy_book.amount)
  FROM genre
	   JOIN book USING (genre_id)
       JOIN buy_book USING (book_id)
 GROUP BY genre.name_genre
HAVING SUM(buy_book.amount) = 
	   (SELECT MAX(Количество) 
          FROM (SELECT SUM(buy_book.amount) AS Количество
			      FROM genre
					   JOIN book USING (genre_id)
					   JOIN buy_book USING (book_id)			
			     GROUP BY genre.name_genre) AS query_in); 		-- неужели без такого уродства в SQL никак ???

/*Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. Для этого вывести год, месяц, сумму выручки 
в отсортированном сначала по возрастанию месяцев, затем по возрастанию лет виде. Название столбцов: Год, Месяц, Сумма.*/
CREATE TABLE buy_archive (
	buy_archive_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_id INT,
    client_id INT,
    book_id INT,
    date_payment DATE,
    price  DECIMAL(8, 2),
    amount INT);
INSERT INTO buy_archive (buy_id, client_id, book_id, date_payment, price, amount)
VALUES 
( 2      , 1         , 1       , '2019-02-21'   , 670.60 , 2      ),
( 2      , 1         , 3       , '2019-02-21'   , 450.90 , 1      ),
( 1      , 2         , 2       , '2019-02-10'   , 520.30 , 2      ),
( 1      , 2         , 4       , '2019-02-10'   , 780.90 , 3      ),
( 1      , 2         , 3       , '2019-02-10'   , 450.90 , 1      ),
( 3      , 4         , 4       , '2019-03-05'   , 780.90 , 4      ),
( 3      , 4         , 5       , '2019-03-05'   , 480.90 , 2      ),
( 4      , 1         , 6       , '2019-03-12'   , 650.00 , 1      ),
( 5      , 2         , 1       , '2019-03-18'   , 670.60 , 2      ),
( 5      , 2         , 4       , '2019-03-18'   , 780.90 , 1      );

SELECT YEAR(buy_archive.date_payment) AS Год,
	   MONTHNAME(buy_archive.date_payment) AS Месяц,
       SUM(buy_archive.price * buy_archive.amount) AS Сумма
  FROM buy_archive
 GROUP BY Год, Месяц
 
UNION ALL 

SELECT YEAR(buy_step.date_step_end) AS Год,
	   MONTHNAME(buy_step.date_step_end) AS Месяц,
       SUM(book.price * buy_book.amount) AS Сумма
  FROM book
	   JOIN buy_book USING (book_id)
       JOIN buy USING (buy_id)
       JOIN buy_step USING (buy_id)
       JOIN step USING (step_id)
 WHERE step.name_step = 'Оплата' AND 
	   buy_step.date_step_end IS NOT NULL	
 GROUP BY Год, Месяц      
 ORDER BY Месяц, Год;
 
/*Для каждой отдельной книги необходимо вывести информацию о количестве проданных экземпляров и их стоимости за 
текущий и предыдущий год . Вычисляемые столбцы назвать Количество и Сумма. Информацию отсортировать по убыванию стоимости.
При вычислении Количества и Суммы для текущего года учитывать только те книги, которые уже оплачены 
(указана дата оплаты для шага "Оплата" в таблице buy_step*/
SELECT query_in.title, 
	   SUM(query_in.Количество) AS Количество, 
       SUM(query_in.Сумма) AS Сумма
  FROM 
	   (SELECT book.title,
			   SUM(buy_book.amount) AS Количество,			-- не перекрывает внешние алиасы
			   SUM(book.price * buy_book.amount) AS Сумма	
		  FROM book
			   JOIN buy_book USING (book_id)
               JOIN buy USING (buy_id)
               JOIN buy_step USING (buy_id)
               JOIN step USING (step_id)
		 WHERE step.name_step = 'Оплата' AND
			   buy_step.date_step_end IS NOT NULL
		 GROUP BY book.title

		 UNION ALL

		SELECT book.title,
			   SUM(buy_archive.amount) AS Количество,
			   SUM(buy_archive.price * buy_archive.amount) AS Сумма
		  FROM book
			   JOIN buy_archive USING (book_id)
		 GROUP BY book.title) AS query_in
 GROUP BY query_in.title
 ORDER BY Сумма DESC;

/*1.Вывести лучших клиентов (по общей сумме заказов)
2.То же для городов (из каких городов идут самые крупные заказы)
3.Таргетированная реклама. Рекомендации для заказчиков:
а)вывести другие книги заказанных вами авторов;
б)вывести другие книги заказанных вами жанров;
в)вывести названия книг, которые ни разу не были заказаны.*/
SELECT client.name_client, 
	   SUM(buy_book.amount * book.price) AS Сумма_заказов
  FROM book
	   JOIN buy_book USING (book_id)
       JOIN buy USING (buy_id)
       JOIN client USING (client_id)
 GROUP BY client.name_client
 ORDER BY Сумма_заказов DESC;

SELECT city.name_city, 
	   SUM(buy_book.amount * book.price) AS Сумма_заказов
  FROM book
	   JOIN buy_book USING (book_id)
       JOIN buy USING (buy_id)
       JOIN client USING (client_id)
       JOIN city USING (city_id)
 GROUP BY city.name_city
 ORDER BY Сумма_заказов DESC;

SELECT client.name_client, author.name_author, book.title AS Заказывали
  FROM book
	   JOIN author USING (author_id)
	   JOIN buy_book USING (book_id)
       JOIN buy USING (buy_id)
       JOIN client USING (client_id);

SELECT name_client, name_author, title AS Предложить
  FROM (SELECT name_client 
		  FROM client) AS query_1
	   CROSS JOIN (SELECT name_author, title, book_id
					 FROM author 
						  JOIN book USING(author_id)) AS query_2
WHERE (name_client, name_author, title) NOT IN 
			(SELECT name_client, name_author, title 
			   FROM author
					JOIN book USING(author_id)
				    JOIN buy_book USING(book_id)
				    JOIN buy USING(buy_id)
				    JOIN client USING(client_id))
       AND 
       (name_client, name_author) IN
			(SELECT name_client, name_author
               FROM author 
					JOIN book USING(author_id)
					JOIN buy_book USING(book_id)
					JOIN buy USING(buy_id)
					JOIN client USING(client_id))       
 ORDER BY name_client, name_author, title;  

SELECT book.title AS Не_заказывали
  FROM book
	   LEFT JOIN buy_book USING (book_id)
 WHERE buy_book.amount IS NULL;


  