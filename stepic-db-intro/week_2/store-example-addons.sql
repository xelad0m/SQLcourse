use store;

# ALTER TABLE sale MODIFY id INTEGER AUTO_INCREMENT;
# ALTER TABLE sale_history MODIFY id INTEGER AUTO_INCREMENT;

# DELETE FROM sale WHERE id = 0;

# INTO sale (client_id, number, dt_created, dt_modified, sale_sum, status_id) 
# VALUES (1, 'ORD_52', '2016.05.24', '2016.05.24',1000, 7); 

# INSERT INTO sale (client_id, number, dt_created, dt_modified, sale_sum, status_id) 
# VALUES (1, 'ORD_56', now(), now(), 1000, 1); 

UPDATE sale SET status_id = 2 WHERE id = 56;
UPDATE sale SET status_id = 3, sale_sum = 2000 WHERE id = 55;
UPDATE sale SET status_id = 4 WHERE id = 55;
UPDATE sale SET status_id = 5 WHERE id = 1;