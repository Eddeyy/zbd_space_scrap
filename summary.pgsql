select * from emp_exp_status;

select * from (
    select * from scrap
    order by id DESC
    limit 5
    ) sub 
    order by id asc;

select * from employee_status;

select * from (
    select * from expedition_status
    order by expedition_id DESC
    limit 5
    ) sub 
    order by expedition_id asc;

select * from ship_status;

update ship_engine set state='Working';
update ship set fuel=100;