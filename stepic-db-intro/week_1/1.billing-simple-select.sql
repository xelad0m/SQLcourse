USE billing_simple;

SELECT 
    *
FROM
    billing
WHERE
	sum > 900 AND currency IN ('CHF', 'GBP');