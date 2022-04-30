SELECT * FROM billing
	WHERE payer_email = 'pasha@mail.com' 
    AND recipient_email = 'katya@mail.com'
    AND sum = 300;

insert into billing values(
	'pasha@mail.com',
    'katya@mail.com',
    '300.00',
    'EUR',
    '2016-02-14',
    'Valentines day present)');