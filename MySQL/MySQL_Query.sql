### Select the database::
use hr_database;

### QUERY ::
# 1) Return the number of employee hired between 2000 and 2014 with (job_involment + job_satisfaction) > 3

# Non optimazed 
#EXPLAIN
SELECT 	count(*)
FROM 	employee 
where 	employee.id in (select 	hire.id_emp 
						from 	hire 
						where 	YEAR(hire_date) > 2000 and 
								YEAR(hire_date) < 2014 and 
								hire_id in (	select 	hire_id 
												from 	satisfactionandproductivity
												where 	(job_involment + job_satisfaction) >= 3));

# Optimazed using JOIN insted of NESTED QUERIES
#EXPLAIN
SELECT 	count(employee.id)
FROM	employee join hire on 
		employee.id = hire.id_emp join satisfactionandproductivity as sat_prod on 
										employee.id = sat_prod.id_emp
where 	(sat_prod.job_involment + sat_prod.job_satisfaction) >= 5 and 
		YEAR(hire_date) >= 2000 and YEAR(hire_date) < 2014 ;

# --------------------------------------------------------------------------------------------------------------------------------------

# 2) Return the employee with a monthly salary greater than the average of the first 10k employee hired

create view first_10k_employee_view as
select 	e.id, e.first_name, e.last_name, hire_id, hire_date
from 	employee as e join hire on id=id_emp
order by hire_date asc
limit 10000;

select 	id, first_name, last_name
from 	employee join salary on 
		id = id_emp 
where  	monthly_income > (	select 	avg(s2.monthly_income) 
							from 	first_10K_employee_view join salary as s2 on 
									id=s2.id_emp);


# Optimazed:
# MATERIALIZED VIEW vs VIEW

CREATE TABLE first_10k_employee (
select 	e.id as id_10k, e.first_name, e.last_name, hire_id, hire_date
from 	employee as e join hire on 
		e.id=id_emp
order by hire_date asc
limit 10000);

CREATE TABLE average_income_value(
select 	avg(monthly_income) as avg_inc
from 	first_10k_employee  join salary as s2 on
		id_10k = s2.id_emp );


select 	id, first_name, last_name
from 	employee join salary as s1 on 
		id = id_emp 
where   monthly_income 	> 	(	select 	avg_inc
								from 	average_income_value);

## reset 
drop table first_10k_employee ;
drop table average_income_value;
drop view first_10k_employee_view;

# --------------------------------------------------------------------------------------------------------------------------------------

# 3) Employee who work more years, not married and with education grade of 5

# Not optimazed
select count(*) as Employee_hard_worker_and_never_married
from employee
where id in (	select 	id_emp 
				from 	extrainfoemployee 
				where 	total_working_years = (select 	max(total_working_years)
												from 	extrainfoemployee )
						and marital_status NOT LIKE  'Married' 
						and id in (	select 	id_emp 
									from 	education 
									where 	education_no = 5));

# Optimized:  INDEX + MATERIALIZE TABLE
create index education_index 
on education(education_no DESC) ;

create index total_working_index 
on extrainfoemployee(total_working_years DESC);

create table max_working_years_ (
select 	max(total_working_years) as max_working_years
from 	extrainfoemployee) ;

# optimized with indexes, join, materialized view
select count(id) as Employee_hard_worker_and_never_married
from employee join extrainfoemployee as extra on id = extra.id_emp  join education on id = education.id_emp
where total_working_years = (	select max_working_years
								from 	max_working_years_ )
		and marital_status <>  'Married' 
		and education_no = 5;
        
# reset 
drop index education_index on education;
drop index total_working_index on extrainfoemployee;
drop table max_working_years_; 


# ----------------------------------------------------------------------------------------------------------------

# 4) Return some employees attributes of the one that have maximum percentage salary hike ordered by date of birth

# not optimazed
select id, first_name, last_name, date_of_birth, gender, age, job_role
from employee join hire on id=hire.id_emp 
where id in (	select id_emp 
				from salary 
                where percent_salary_hike in (	select max(percent_salary_hike) 
												from salary ))
order by date_of_birth desc;

# optimazed: INDEX + TABLE
create index perc_hike 
on salary(percent_salary_hike);

create table max_hike(
select max(percent_salary_hike) as maximum
from salary );

select id, first_name, last_name, date_of_birth, gender, age, job_role
from employee join hire on id=hire.id_emp join salary on id = salary.id_emp
where percent_salary_hike in (	select maximum
								from max_hike )
order by date_of_birth desc;

# reset 
drop index perc_hike  on salary;
drop table max_hike;


# 5) Return ID, Email, Phone number whose born in South Carolina (SC) - Columbia 
# USE: Explicit Join
select	id as ID, email as E_mail, phone_no as Phone_number
from 	employee join address on
		employee.id = address.id_emp
where 	address.state = 'SC' and address.city = 'Columbia';

# --------------------------------------------------------------------------------------------------------------------------------------

# 6) Returns the top 3 departments with the greatest employees average total satisfaction
# order by and limit to return the top 3

select distinct department as Departments_with_greater_satisfaction, avg(job_satisfaction) as total_satisfaction
from 	hire join satisfactionandproductivity as sat_and_prod on
		hire.id_emp = sat_and_prod.id_emp
group by department
order by total_satisfaction desc
limit 3;

# --------------------------------------------------------------------------------------------------------------------------------------

# 7) Count the number of Employee hired on the second term of 2012 group by department 
# USE: Nested query and Aggregation (N.B target list is homogeneus)

select	count(id_emp) as Number_of_employee, department as Department
from 	hire 
where 	YEAR(hire_date) = '2012' and hire_id = any (select	hire_id 
													from 	extrainfohire 
													where 	quarter_of_joining = 'Q2')
group by department;
   
# --------------------------------------------------------------------------------------------------------------------------------------

# 8) How many are the employee younger than 30 years that are farther than 35 km from home BUT don't travel frequently for work
# Difference / EXCEPT <-> not in  

select 	count(*) as Number_of_young_lazy_employee
from 	employee as emp join extrainfoemployee as extra_info on 
		emp.id = extra_info.id_emp
where 	emp.age < 30 and extra_info.distance_from_home = 35
		and emp.id not in  ( select id_emp
							from  	satisfactionandproductivity as sat_prod
							where   sat_prod.business_travel = 'Travel-Frequently');
                            
# --------------------------------------------------------------------------------------------------------------------------------------

# 9) Return the departments whose employees as an average of weight of 60
# USE: having

select 	department as Department_with_average_weight_less_60
from  	hire join extrainfoemployee as extra_info on 
		hire.id_emp = extra_info.id_emp
group by department
having 	avg(weight) < 60; 


# --------------------------------------------------------------------------------------------------------------------------------------

# 10) Return the single employees that have left the company and are unsatisfied of their work or the enviroment 
# USE: insted of = any we use IN and 3 nested queries and use of like for varchar

select	First_name as Name, last_name as Surname, gender as Gender, age as Age
from	employee
where 	id 	in	(select id_emp
				from hire
				where attrition like 'Yes')
		and id 	in 	(select id_emp 
					from satisfactionandproductivity
					where job_satisfaction = 1 or  enviroment_satisfaction = 1)
		and id in (	select 	id_emp
					from 	extrainfoemployee
                    where   marital_status like 'Single');

                



                    

