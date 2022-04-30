USE test_tasks;	

CREATE TABLE author
    (author_id 		INT PRIMARY KEY AUTO_INCREMENT,
	 name_author 	VARCHAR(50));

INSERT INTO author (name_author)
VALUES ('Булгаков М.А.'),
	   ('Достоевский Ф.М.'),
       ('Есенин С.А.'),
       ('Пастернак Б.Л.');

CREATE TABLE book1 (
		book_id INT PRIMARY KEY AUTO_INCREMENT,
        title 	VARCHAR(50),
        author_id INT NOT NULL,
        genre_id INT,
        price 	DECIMAL(8, 2),
        amount INT,
        FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,	-- при удалении автора, удалить все его книги
        FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) ON DELETE SET NULL);    -- при удалинии жанра, выставить жанр в NULL
        
INSERT INTO book (title, 	author_id, 	genre_id, 	price, 	amount)
VALUES ('Стихотворения и поэмы',3,2,650.00,15),
       ('Черный человек',3,2,570.20,6),
       ('Лирика',4,2,518.99,2);
