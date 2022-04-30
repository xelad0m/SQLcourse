/* 1.1 Отношение/таблица */

CREATE SCHEMA test_tasks;	-- создали новую схему (базу данных)
USE test_tasks;				-- используем ее

CREATE TABLE book (
             book_id INT PRIMARY KEY AUTO_INCREMENT,
             title 	VARCHAR(50),
             author VARCHAR(30),
             price 	DECIMAL(8, 2),
             amount INT);

INSERT INTO book (title, author, price, amount)
 VALUE ('Мастер и Маргарита', 'Булгаков М.А.', 670.99, 3);

INSERT INTO book (title, author, price, amount)
VALUES ('Белая гвардия', 'Булгаков М.А.', 540.50, 5),
	   ('Идиот', 'Достоевский Ф.М.', 460.00, 10),
       ('Братья Карамазовы', 'Достоевский Ф.М.', 799.01, 2);

INSERT INTO book (title, author, price, amount)
 VALUE ("Стихотворения и поэмы", "Есенин С.А.", 650, 15);
 
 
/* 1.2 Выбора данных*/


SELECT * 
  FROM book;

SELECT title, amount
  FROM book;
  
SELECT author, title, price
  FROM book;
  
SELECT title AS Название, 	
       author AS Автор
  FROM book;

/*Выборка данных с созданием вычисляемого столбца*/
SELECT title, amount,
       amount * 1.65 AS pack
  FROM book;
  
SELECT title, author, amount,
       ROUND(price*0.7, 2) AS new_price
  FROM book;

/* поднять цену книг Булгакова на 10%, а цену книг Есенина - на 5% */
SELECT author, title, 
       ROUND(IF(author = "Булгаков М.А.", price * 1.1, 
			 IF(author = "Есенин С.А.", price * 1.05, price)), 2) AS new_price
  FROM book;
  
/* Выборка данных по условию */
SELECT title, author, price
  FROM book
 WHERE amount < 10;						-- псевдонимы не могут использоваться, т.к. 
										-- вычисляется перед обращением к БД
 
SELECT title, author, price, amount
  FROM book
 WHERE (price < 500 OR price > 600) AND price * amount >= 5000;

SELECT title, author
  FROM book
 WHERE price BETWEEN 540.5 AND 800 
       AND amount IN (2, 3, 5, 7);

SELECT author, title
  FROM book
 WHERE amount BETWEEN 2 AND 14
 ORDER BY author DESC, title;

/* оператор LIKE % - 0 и более символов, _ - один символ 
	наприме LIKE "______%" - 5 и более символов*
    например NOT LIKE "% %" - не более одного слова */
INSERT INTO book (title, author, price, amount)
VALUES ("", "Иванов С.С.",  50.00, 10),
	   ("Дети полуночи", "Рушди Салман", 950.00, 5),
       ("Лирика", "Гумилев Н.С.", 460.00, 10),
       ("Поэмы", "Бехтерев С.С.", 460.00, 10),
       ("Капитанская дочка", "Пушкин А.С.", 520.50, 7 );
       
SELECT title, author
  FROM book
 WHERE title LIKE "%_ %_" AND 
       (author LIKE "% С._." OR author LIKE "% _.С.")
 ORDER BY title;
 
 /*
	1. Сменить всех авторов на "Донцова Дарья".
	2. К названию каждой книги в начале дописать "Евлампия Романова и".
	3. Цену поднять на 42%.
	4. Отсортировать по убыванию цены и убыванию названия.
*/

SELECT "Донцова Дарья" AS author, 
       CONCAT("Гарри Поттер и ", title) AS title,
       ROUND(price * 1.42, 2) AS price
  FROM book
 ORDER BY price DESC, title;

/* 1.3 Запросы, групповые операции */

SELECT DISTINCT amount 		-- уникальные значения получить можно так
  FROM book;
  
SELECT amount
  FROM book
 GROUP BY amount;		    -- или группировкой

INSERT INTO book (title, author, price, amount) 
VALUES ('Черный человек','Есенин С.А.', Null, Null);

SELECT author, COUNT(author), COUNT(amount), COUNT(*)	-- NULL не идет в COUNT
FROM book
GROUP BY author;

SELECT author AS Автор, 
       COUNT(title) AS Различных_книг,
       SUM(amount) AS Количество_экземпляров
  FROM book
 GROUP BY author;
 
 SELECT author,
        MIN(price) AS Минимальная_цена, 
        MAX(price) AS Максимальная_цена,
        ROUND(AVG(price), 2) AS Средняя_цена
   FROM book
  GROUP BY author;

SELECT author,
	   ROUND(SUM(price * amount), 2) AS Стоимость,
       ROUND(SUM(price * amount)*.18/1.18, 2) AS НДС,
	   ROUND(SUM(price * amount)* (1 - .18/1.18), 2) AS Стоимость_без_НДС
  FROM book
 GROUP BY author;

SELECT MIN(price) AS Минимальная_цена, 
       MAX(price) AS Максимальная_цена, 
       ROUND(AVG(price), 2) AS Средняя_цена
  FROM book;

/* В запросах с групповыми функциями вместо WHERE используется 
ключевое слово HAVING , которое размещается после оператора GROUP BY 
Обусловлено порядком выполнения запроса на сервере: 
    FROM
    WHERE
    GROUP BY
    HAVING
    SELECT
    ORDER BY */

SELECT ROUND(AVG(price), 2) AS Средняя_цена,
	   SUM(price * amount) AS Стоимость
  FROM book
 WHERE amount BETWEEN 5 AND 14;

SELECT author,
	   SUM(price * amount) AS Стоимость
  FROM book
 WHERE title NOT IN ("Идиот", "Белая гвардия")		-- WHERE  можно до агрегирования
 GROUP BY author
HAVING Стоимость > 5000								-- но уже после агрегирования фильровать может только HAVING
 ORDER BY Стоимость DESC;

/*Узнать сколько авторов, у которых есть книги со стоимостью более 500 
и количеством более 1 шт на складе, при количестве различных названий 
произведений не менее 2-х. Вывести автора, количество различных произведений 
автора, минимальную цену и количество книг */
SELECT author,
	   COUNT(title) AS Количество_произведений,
       MIN(price) AS Минимальная_цена,
       SUM(amount) AS Количество_книг
  FROM book
 WHERE price > 500 AND amount > 1
 GROUP BY author
HAVING Количество_произведений >= 2;

/* 1.4 Вложенные запросы */

/*Вывести информацию (автора, название и цену) о  книгах, цены которых меньше 
или равны средней цене книг на складе. Информацию вывести в отсортированном по 
убыванию цены виде. Среднее вычислить как среднее по цене книги.*/
SELECT author, title, price
  FROM book
 WHERE price <= 
	   (SELECT AVG(price)
          FROM book)
 ORDER BY price DESC;
/*Вывести информацию (автора, название и цену) о тех книгах, цены которых превышают 
минимальную цену книги на складе не более чем на 150 рублей в отсортированном по 
возрастанию цены виде.*/
SELECT author, title, price
  FROM book
 WHERE price - (SELECT MIN(price) FROM book) <= 150
 ORDER BY price;
/*Вывести информацию (автора, книгу и количество) о тех книгах, количество экземпляров 
которых в таблице book не дублируется.*/
SELECT author, title, amount
FROM book
WHERE amount IN (					-- отбираем те, которые попали в подзапрос
	  SELECT amount 
		FROM book 
       GROUP BY amount 				-- сначала группируем
      HAVING COUNT(amount) = 1);	-- потом отбираем нужные

/* Вывести информацию о книгах(автор, название, цена), цена которых меньше самой большой 
из минимальных цен, вычисленных для каждого автора.*/
SELECT author, title, price
FROM book
WHERE price < ANY (
        SELECT MIN(price) 
        FROM book 
        GROUP BY author 
      );
      
/*Вложенный запрос после SELECT*/
/*В этом случае результат выполнения запроса выводится в отдельном столбце результирующей таблицы.*/
/*Вывести информацию о книгах, количество экземпляров которых отличается от среднего количества 
экземпляров книг на складе более чем на 3,  а также указать среднее значение количества экземпляров книг.*/

SELECT title, author, amount, 
    (
     SELECT AVG(amount) 
     FROM book
    ) AS Среднее_количество 
FROM book
WHERE abs(amount - (SELECT AVG(amount) FROM book)) > 3;

/*Посчитать сколько и каких экземпляров книг нужно заказать поставщикам, чтобы на складе 
стало одинаковое количество экземпляров каждой книги, равное значению самого большего 
количества экземпляров одной книги на складе. Вывести название книги, ее автора, текущее 
количество экземпляров на складе и количество заказываемых экземпляров книг. 
Последнему столбцу присвоить имя Заказ.*/
SELECT title, author, amount,
	   (SELECT max(amount) FROM book) - amount AS Заказ		-- потому что сначала нужно узнать максимум
  FROM book
 WHERE (SELECT max(amount) FROM book) - amount <> 0;

/*посмотреть, при продаже всех книг, какая книга принесет больше всего выручки, в процентах*/
SELECT *,
	   ROUND(price*amount/(SELECT SUM(price * amount) FROM book)*100, 2) AS income_percent
  FROM book
 ORDER BY income_percent DESC;

/*Определить стоимость покупки, если купить самую дешевую книгу каждого автора.*/
SELECT author, MIN(price) FROM book GROUP BY author;	-- мин.цена по авторам
SELECT SUM(price)
  FROM book
 WHERE price IN (SELECT MIN(price) FROM book GROUP BY author);

