DROP PROCEDURE IF EXISTS update_order_history;
update_order_historyDELIMITER //
CREATE PROCEDURE update_order_history (
  sale_id_ INTEGER,
  status_id_ INTEGER,
  sale_sum_ DECIMAL(18,2)
)
BEGIN
  DECLARE now DATETIME;
  SET now = NOW();
  
  UPDATE sale_history 
    SET active_to = now 
  WHERE sale_id = sale_id_ AND
      #active_to IS NULL  
          active_to = '2000.01.01'
  LIMIT 1;

  INSERT INTO sale_history
         (sale_id, status_id, sale_sum, active_from, active_to)
    #VALUES (sale_id_, status_id_, sale_sum_, now, NULL);
    VALUES (sale_id_, status_id_, sale_sum_, now, '2000.01.01');        
END
//