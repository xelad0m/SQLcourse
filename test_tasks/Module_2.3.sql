DROP TABLE IF EXISTS `author`;
CREATE TABLE author (
      author_id INT PRIMARY KEY AUTO_INCREMENT, 
      name_author VARCHAR(50) 
      ) ENGINE='InnoDB' AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
insert into author (name_author) value
('Булгаков М.А.'),
('Достоевский Ф.М.'),
('Есенин С.А.'),
('Пастернак Б.Л.'),
('Лермонтов М.Ю.');

DROP TABLE IF EXISTS `genre`;
CREATE TABLE genre (
      genre_id INT PRIMARY KEY AUTO_INCREMENT, 
      name_genre VARCHAR(50) 
      )ENGINE='InnoDB' AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
insert into genre (name_genre) value
('Роман'),
('Поэзия'),
('Приключения');

DROP TABLE IF EXISTS `book`;
CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50),
    author_id INT,
    genre_id INT,
    price DECIMAL(8 , 2 ),
    amount INT,
    FOREIGN KEY (author_id)
        REFERENCES author (author_id)
        ON DELETE CASCADE,
    FOREIGN KEY (genre_id)
        REFERENCES genre (genre_id)
        ON DELETE SET NULL
) ENGINE='InnoDB' AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
insert into book (title,author_id,genre_id,price,amount) values
	("Мастер и Маргарита",1,1,670.99,3),
	("Белая гвардия",1,1,540.50,12),
	("Идиот",2,1,460.00,13),
	("Братья Карамазовы",2,1,799.01,3),
	("Игрок",2,1,480.50,10),
	("Стихотворения и поэмы",3,2,650.00,15),
	("Черный человек",3,2,570.20,12),
	("Лирика",4,2,518.99,2);
-- ("Доктор Живаго",4,1,380.80,4),
-- ("Стихотворения и поэмы",5,2,255.90 ,4),
-- ("Остров сокровищ",6,3,599.99,5)  ;


DROP TABLE IF EXISTS `supply`;
CREATE TABLE IF NOT EXISTS `supply` (
  `supply_id` INT NOT NULL AUTO_INCREMENT,
  `title` varchar(50),
  `author` varchar(30),
  `price` decimal(8,2),
  `amount` INT,
  PRIMARY KEY (`supply_id`)
) ENGINE='InnoDB' AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

INSERT INTO `supply` (`title`, `author`, `price`, `amount`) VALUES
    ("Доктор Живаго","Пастернак Б.Л.",380.80,4),    
    ('Черный человек', 'Есенин С.А.', 570.20, 6),
    ('Белая гвардия', 'Булгаков М.А.', 540.50, 7),
    ('Идиот', 'Достоевский Ф.М.', 360.80, 3),
    ("Стихотворения и поэмы","Лермонтов М.Ю.",255.90,4),
    ("Остров сокровищ","Стивенсон Р.Л.",599.99,5);
    
USE test_tasks;
/*Для книг, которые уже есть на складе (в таблице book), но по другой цене, чем в поставке (supply),  
необходимо в таблице book увеличить количество на значение, указанное в поставке,  и пересчитать цену. 
А в таблице  supply обнулить количество этих книг*/
UPDATE book AS b
	   INNER JOIN author 
			 ON author.author_id = b.author_id
	   INNER JOIN supply AS s 
			 ON b.title = s.title 
				AND s.author = author.name_author
   SET b.price = (b.price * b.amount + s.price * s.amount) / (b.amount + s. amount),
	   b.amount = b.amount + s.amount,
	   s.amount = 0
 WHERE b.price <> s.price;
 
 /*Включить новых авторов в таблицу author с помощью запроса на добавление, а затем вывести все 
 данные из таблицы author.  Новыми считаются авторы, которые есть в таблице supply, но нет в таблице author.*/

SELECT supply.author											
FROM author 													-- из этой таблице все значения
     RIGHT JOIN supply ON author.name_author = supply.author	-- из этой только те, которых есть в первой	
	 -- supply													-- ИЛИ из этой все 
     -- LEFT JOIN author ON author.name_author = supply.author	-- из это только те, которых нет в первой
WHERE author.name_author IS NULL;								-- исключить те, которых нет в другой таблице

INSERT INTO author (name_author)
SELECT supply.author											
  FROM author 													-- из этой таблице все значения
       RIGHT JOIN supply ON author.name_author = supply.author	-- из этой только те, которых есть в первой	
 WHERE author.name_author IS NULL;
 
/*Добавить новые книги из таблицы supply в таблицу book на основе сформированного выше запроса. 
Затем вывести для просмотра таблицу book.*/
UPDATE supply AS s
   SET s.amount = 0
 WHERE s.supply_id IN (2, 3, 4);

INSERT INTO book (title, author_id, price, amount)
SELECT title, author_id, price, amount
FROM 
    author 
    INNER JOIN supply ON author.name_author = supply.author
WHERE amount <> 0;

/*Занести для книги «Стихотворения и поэмы» Лермонтова жанр «Поэзия», а для книги «Остров сокровищ» 
Стивенсона - «Приключения». (Использовать два запроса).*/
UPDATE book
   SET genre_id = (SELECT genre_id
				   FROM genre
                   WHERE name_genre = 'Поэзия')
WHERE title = "Стихотворения и поэмы";

UPDATE book
   SET genre_id = (SELECT genre_id
				   FROM genre
                   WHERE name_genre = 'Приключения')
WHERE title = "Остров сокровищ";

/*Удалить всех авторов и все их книги, общее количество книг которых меньше 20*/
DELETE FROM author 
 WHERE author_id IN 
		(SELECT author_id
		   FROM book
		  GROUP BY author_id
		 HAVING sum(amount) < 20);
		
/*Удалить все жанры, к которым относится меньше 4-х книг. 
В таблице book для этих жанров установить значение Null*/
DELETE FROM genre 
 WHERE genre_id IN
		(SELECT genre_id
		   FROM book
		  GROUP BY genre_id
		 HAVING count(title) < 4);

/*Удалить всех авторов, которые пишут в жанре "Поэзия". Из таблицы book удалить все книги 
этих авторов. В запросе для отбора авторов использовать полное название жанра, а не его id.*/
DELETE FROM author
 USING author
	   INNER JOIN book ON book.author_id = author.author_id
       INNER JOIN genre ON genre.genre_id = book.genre_id  
 WHERE book.genre_id IN 
		(SELECT genre_id 
           FROM genre 
          WHERE genre.name_genre = "Поэзия");

/*Нас взломали хакеры. В жанр добавлена новая запись "Страшилки". Теперь этот жанр присвоен всем 
книгам Достоевского и Булгакова, книги писателей в таблице supply увеличены на 100 единиц у каждого 
из указанных авторов. Задание - замоделировать такие изменения в базу данных.*/
INSERT INTO genre (name_genre) VALUES ('Страшилка');

UPDATE book
   SET genre_id = (
		SELECT genre_id
		  FROM genre
		 WHERE name_genre = 'Страшилка')
WHERE author_id IN (
		SELECT author_id
		  FROM author
		 WHERE name_author IN ('Достоевский Ф.М.', 'Булгаков М.А.'));

UPDATE supply
   SET amount = supply.amount + 100
 WHERE author IN ('Достоевский Ф.М.', 'Булгаков М.А.');
