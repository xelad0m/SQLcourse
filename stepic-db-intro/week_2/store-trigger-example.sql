DROP TRIGGER IF EXISTS on_update_order;
DELIMITER //
CREATE TRIGGER on_update_order
  AFTER UPDATE
  ON sale FOR EACH ROW
BEGIN
  CALL update_order_history(NEW.id, NEW.status_id, NEW.sale_sum);
END
//