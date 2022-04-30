USE test_tasks;	
DROP TABLE IF EXISTS author, genre, book;

CREATE TABLE author
    (
        author_id INT PRIMARY KEY AUTO_INCREMENT,
        name_author VARCHAR(50)
    );


INSERT INTO author (name_author)
VALUES ('Булгаков М.А.'),
       ('Достоевский Ф.М.'),
       ('Есенин С.А.'),
       ('Пастернак Б.Л.');

CREATE TABLE genre
    (
        genre_id INT PRIMARY KEY AUTO_INCREMENT,
        name_genre varchar(30)
    );

INSERT INTO genre (name_genre)
VALUES ('Роман'),
       ('Поэзия'),
       ('Приключения');

CREATE TABLE book
    (
        book_id serial
            PRIMARY KEY,
        title VARCHAR(50),
        author_id INT,
        genre_id int,
        price DECIMAL(8, 2),
        amount INT,
        FOREIGN KEY (author_id) REFERENCES author (author_id) ON DELETE CASCADE,
        FOREIGN KEY (genre_id) REFERENCES genre (genre_id) ON DELETE SET NULL
    );

INSERT INTO book (title, author_id, genre_id, price, amount)
VALUES ('Мастер и Маргарита', 1, 1, 670.99, 3),
       ('Белая гвардия ', 1, 1, 540.50, 5),
       ('Идиот', 2, 1, 460.00, 10),
       ('Братья Карамазовы', 2, 1, 799.01, 3),
       ('Игрок', 2, 1, 480.50, 10),
       ('Стихотворения и поэмы', 3, 2, 650.00, 15),
       ('Черный человек', 3, 2, 570.20, 6),
       ('Лирика', 4, 2, 518.99, 2);

/*Вывести название, жанр и цену тех книг, количество которых больше 8, в отсортированном по убыванию цены виде.*/	
SELECT title, name_genre, price
  FROM book INNER JOIN genre
    ON book.genre_id = genre.genre_id
 WHERE amount > 8
 ORDER BY price DESC;
 
 /*Вывести все жанры, которые не представлены в книгах на складе.*/
SELECT name_genre
  FROM genre LEFT OUTER JOIN book
    ON book.genre_id = genre.genre_id
 WHERE book.genre_id IS NULL;
 
/*Есть список городов, хранящийся в таблице city. Необходимо в каждом городе провести выставку 
книг каждого автора в течение 2020 года. Дату проведения выставки выбрать случайным образом. 
Создать запрос, который выведет город, автора и дату проведения выставки. Последний столбец назвать 
Дата. Информацию вывести, отсортировав сначала в алфавитном порядке по названиям городов, а потом 
по убыванию дат проведения выставок.*/
CREATE TABLE city
	(city_id INT PRIMARY KEY AUTO_INCREMENT,
     name_city varchar(50));

INSERT INTO city (name_city)
VALUES ('Москва'), ('Санкт-Петербург'), ('Владивосток');

SELECT name_city, name_author, 
	   DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 365) DAY) AS Дата
  FROM city, author
 ORDER BY name_city, Дата DESC;

/*Вывести информацию о тех книгах, их авторах и жанрах, цена которых принадлежит интервалу от 500  до 700 рублей  включительно.*/
SELECT title, name_author, name_genre, price, amount
FROM
    author 
    INNER JOIN  book ON author.author_id = book.author_id
    INNER JOIN genre ON genre.genre_id = book.genre_id
WHERE price BETWEEN 500 AND 700;

/*Вывести информацию о книгах (жанр, книга, автор), относящихся к жанру, включающему слово «роман» в отсортированном по названиям книг виде.*/
SELECT name_genre, title, name_author
  FROM author 
	   INNER JOIN  book ON author.author_id = book.author_id
	   INNER JOIN genre ON genre.genre_id = book.genre_id
 WHERE name_genre LIKE '%роман%'
 ORDER BY title;

/*Посчитать количество экземпляров  книг каждого автора из таблицы author.  Вывести тех авторов,
количество книг которых меньше 10, в отсортированном по возрастанию количества виде. 
Последний столбец назвать Количество.*/
INSERT INTO author (name_author)
VALUE ("Лермонтов М.Ю.");

SELECT name_author, sum(amount) AS Количество
  FROM author LEFT JOIN 
	   book ON book.author_id = author.author_id
 GROUP BY name_author
HAVING Количество < 10 OR Количество IS NULL
 ORDER BY Количество;

/*Вывести в алфавитном порядке всех авторов, которые пишут только в одном жанре. Поскольку у нас 
в таблицах так занесены данные, что у каждого автора книги только в одном жанре,  для этого запроса 
внесем изменения в таблицу book. Пусть у нас  книга Есенина «Черный человек» относится к жанру «Роман», 
а книга Булгакова «Белая гвардия» к «Приключениям» (эти изменения в таблицы уже внесены).*/
SELECT name_author
  FROM author 
	   INNER JOIN book
			ON book.author_id = author.author_id
	   INNER JOIN genre
			ON book.genre_id = genre.genre_id
 GROUP BY name_author
HAVING count(DISTINCT name_genre) = 1; -- количество уникальных

/*через вложенный запрос*/
SELECT name_author
  FROM author INNER JOIN
		( /* подзапрос, выбирающий уникальные комбинации автор/жанр*/
			SELECT author_id, genre_id 
			  FROM book
			 GROUP BY author_id, genre_id
		) AS query_in
        ON query_in.author_id = author.author_id
GROUP BY name_author
HAVING count(query_in.genre_id) = 1;

/*Вывести авторов, пишущих книги в самом популярном жанре. Указать этот жанр.*/
SELECT  name_author, name_genre
FROM 
    author 
    INNER JOIN book ON author.author_id = book.author_id
    INNER JOIN genre ON  book.genre_id = genre.genre_id
GROUP BY name_author,name_genre, genre.genre_id
HAVING genre.genre_id IN
         (/* выбираем автора, если он пишет книги в самых популярных жанрах*/
          SELECT query_in_1.genre_id
          FROM 
              ( /* выбираем код жанра и количество произведений, относящихся к нему */
                SELECT genre_id, SUM(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
               )query_in_1
          INNER JOIN 
              ( /* выбираем запись, в которой указан код жанра с максимальным количеством книг */
                SELECT genre_id, SUM(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
                ORDER BY sum_amount DESC
                LIMIT 1
               ) query_in_2
          ON query_in_1.sum_amount= query_in_2.sum_amount
         );  

/*Вывести информацию о книгах (название книги, фамилию и инициалы автора, название жанра, цену 
и количество экземпляров книги), написанных в самых популярных жанрах, в отсортированном в 
алфавитном порядке по названию книг виде. Самым популярным считать жанр, общее количество экземпляров 
книг которого на складе максимально.*/
SELECT title, name_author, name_genre, price, amount
  FROM book 
		INNER JOIN author 
			ON author.author_id = book.author_id
		INNER JOIN genre
			ON genre.genre_id = book.genre_id
WHERE genre.genre_id IN 
	(
		SELECT query_in_1.genre_id
		FROM 
			(/* выбираем код жанра и количество произведений, относящихся к нему */
			  SELECT genre_id, SUM(amount) AS sum_amount
			  FROM book
			  GROUP BY genre_id 
			) AS query_in_1
			INNER JOIN
			(/* выбираем запись, в которой указан код жанр с максимальным количеством книг */
			  SELECT genre_id, SUM(amount) AS sum_amount
			  FROM book
			  GROUP BY genre_id
			  ORDER BY sum_amount DESC
			  LIMIT 1							-- через max() не получается
			) AS query_in_2
		ON query_in_1.sum_amount = query_in_2.sum_amount 
    )
ORDER BY title;
 
/* Операция соединение, использование USING() */

/*USING позволяет указать набор столбцов, которые есть в обеих объединяемых таблицах. Если база данных хорошо спроектирована, 
а каждый внешний ключ имеет такое же имя, как и соответствующий первичный ключ (например, genre.genre_id = book.genre_id), тогда 
можно использовать предложение USING для реализации операции JOIN. 
При этом после SELECT, при использовании столбцов из USING(), необязательно указывать, из какой именно таблицы берется столбец.*/
SELECT title, name_author, author.author_id /* явно указать таблицу - обязательно */
FROM 
    author INNER JOIN book
    ON author.author_id = book.author_id;

SELECT title, name_author, author_id /* имя таблицы, из которой берется author_id, указывать не обязательно*/
FROM 
    author INNER JOIN book
    USING(author_id);
    
/*Если в таблицах supply  и book есть одинаковые книги, которые имеют равную цену,  вывести их название и автора, а также 
посчитать общее количество экземпляров книг в таблицах supply и book,  столбцы назвать Название, Автор  и Количество*/
SELECT book.title AS Название, 
	   name_author AS Автор, 
       book.amount + supply.amount AS Количество
  FROM author 
	INNER JOIN book USING(author_id)
	INNER JOIN supply USING(price);
    
/*Для каждого автора из таблицы author вывести количество книг, написанных им в каждом жанре.
Вывод: ФИО автора, жанр, количество. Отсортировать по фамилии, затем - по убыванию количества написанных книг.*/
SELECT name_author AS Автор, 
	   name_genre AS Жанр, 
	   IF(COUNT(book.title) > 0, COUNT(book.title), 0) AS Количество
  FROM author 
	   CROSS JOIN genre
	   LEFT JOIN book
         ON author.author_id = book.author_id AND
			genre.genre_id = book.genre_id
 GROUP BY name_author, genre.name_genre
 ORDER BY Автор, Количество DESC;







