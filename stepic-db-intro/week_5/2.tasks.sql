explain
select number, code from sale 
join client on sale.client_id=client.id
join status on status.id=status_id
where status.id in (6, 7);