/*Добавить таблицу 'best_offer_sale' со следующими полями:

    Название: `id`, тип данных: INT, возможность использования неопределенного значения: Нет, первичный ключ
    Название: `name`, тип данных: VARCHAR(255), возможность использования неопределенного значения: Да
    Название: `dt_start`, тип данных: DATETIME, возможность использования неопределенного значения: Нет
    Название: `dt_finish`, тип данных: DATETIME, возможность использования неопределенного значения: Нет
    */

/*CREATE TABLE IF NOT EXISTS `best_offer_sale` (
	`id` INT NOT NULL,
    `name` VARCHAR(255) NULL,
    `dt_start` DATETIME,
    `dt_finish` DATETIME,
    PRIMARY KEY (`id`));*/
    
    /*ENGINE = InnoDB                 -- можно не добавлять
    DEFAULT CHARACTER SET = utf8    
    COLLATE = utf8_general_ci;*/
    
/*пример изменения таблицы
/*этот код работает только если удалить процедуру и тригер because fu that`s why.
команды по изменению триггера кстати просто нет ((*/
-- DROP TRIGGER IF EXISTS store.on_update_order;
-- ALTER TABLE `store`.`sale`
--         DROP COLUMN dt_created,                                 -- удалить поля
--         DROP COLUMN dt_modified,
--         DROP FOREIGN KEY fk_order_status1,                      -- удалить ключ
--         DROP COLUMN status_id,
--         ADD COLUMN ts_modified TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,   -- добавить поле типа таймстемп
--         ADD COLUMN sale_status VARCHAR(45) NOT NULL DEFAULT 'new'       -- добавить поле и к нему    
-- 			CHECK (VALUE IN ('new', 'process', 'assembly', 				-- ахренннно )) парсится ок, но никоим образом не работает вообще))
-- 						'ready', 'delivering', 'issued', 'rejected'));	-- логика - якобы поддержка стандарта (АХРЕНЕТЬ!)

-- insert into `store`.`sale` (id, client_id, number, sale_sum, sale_status)
-- 	values (51, 1, '51', NULL, 'process');
--     
-- update `store`.`sale` set sale_status = 'ready' where `id` = 51;

-- insert into `store`.`sale` (id, client_id, number, sale_sum, sale_status)
-- 	values (52, 1, '52', NULL, 'process');

/*Удалите из таблицы 'client' поля 'code' и 'source_id'.
NB! Для удаления поля, являющегося внешним ключом, необходимо удалить ограничение 
внешнего ключа оператором 'DROP FOREIGN KEY <fk_name>', для данного задание имя 
первичного ключа: fk_client_source1. Удаление ограничения внешнего ключа и поля 
таблицы необходимо производить в рамках одного вызова ALTER TABLE.
*/
ALTER TABLE client
        DROP COLUMN code,                    	-- удалить поля
        DROP COLUMN source_id,
        DROP FOREIGN KEY fk_client_source1;   	-- удалить внеш.ключ
        
/*Удалите таблицу 'source'.
NB! Для удаления таблиц необходимо использовать оператор DROP TABLE.
*/
DROP TABLE source;

/*Добавьте в таблицу 'sale_has_good' следующие поля:
    Название: `num`, тип данных: INT, возможность использования неопределенного значения: Нет
    Название: `price`, тип данных: DECIMAL(18,2), возможность использования неопределенного значения: Нет
*/
ALTER TABLE sale_has_good
	ADD COLUMN num INT NOT NULL,
    ADD COLUMN price DECIMAL(18,2) NOT NULL;

/*Добавьте в таблицу 'client' поле 'source_id' тип данных: 
	INT, возможность использования неопределенного значения: Да. 
Для данного поля определите ограничение внешнего ключа как ссылку на поле 'id' таблицы 'source'.
NB! Для определения ограничения необходимо использовать оператор ADD CONSTRAINT. Определение ограничения
внешнего ключа и поля таблицы необходимо производить в рамках одного вызова ALTER TABLE. 
*/
CREATE TABLE IF NOT EXISTS `store`.`source` (
	`id` INT NOT NULL,
    `name` VARCHAR(255) NULL,
    PRIMARY KEY (`id`));
    
ALTER TABLE client
  ADD COLUMN source_id INT null,
  ADD CONSTRAINT fk_source_id FOREIGN KEY (source_id) REFERENCES source(id);
