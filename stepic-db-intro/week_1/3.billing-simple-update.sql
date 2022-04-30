-- SELECT * FROM billing
-- 	WHERE payer_email = 'pasha@mail.com' 
--     AND recipient_email = 'katya@mail.com'
--     AND sum = 300;

UPDATE billing 
	SET currency = 'USD'
WHERE payer_email = 'pasha@mail.com' 
    AND recipient_email = 'katya@mail.com'
    AND sum = 300;
    
UPDATE billing 
	SET payer_email = 'igor@mail.com'
WHERE payer_email = 'alex@mail.com';

DELETE FROM billing
	WHERE payer_email = '' OR recipient_email = '' 
    OR payer_email is NULL OR recipient_email is NULL;

SELECT * FROM billing
	WHERE payer_email = 'igor@mail.com';