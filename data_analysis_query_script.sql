--1: list employee number, last name, first name, sex and salary for all employees
SELECT
emp_no as "Employee Nbr",
last_name as "Last Name",
first_name as "First Name",
sex as "sex",
hire_date as "Date Hired"
from employees;

--2: list the first name, last name and hire-date of employees hired in 1986
SELECT *
--EXTRACT YEAR(FROM(hire_date)) as "Year"
FROM employees
where EXTRACT(YEAR FROM (hire_date)) = '1986';

--3: list manager for each department, dept number, description, employee number, first and last name
SELECT
dm.dept_no as "Dept Nbr",
dept.dept_name as "Dept Name",
dm.emp_no as "Employee No.",
em.last_name as "Last Name",
em.first_name as "First Name"
from dept_manager as dm
left join departments as dept on dm.dept_no = dept.dept_no
left join employees as em on dm.emp_no = em.emp_no;

-- 4: There are 3 different solutions to address question 4; below syntax helps to frame up rationale (duplicate records)
-- return # of rows from dept_emp table (returns 331603 rows)
SELECT 
COUNT (emp_no)
FROM dept_emp;

-- return # of rows from employee table (returns 300024 rows). Select DISTINCT returns same # of rows; no duplicates
SELECT DISTINCT
COUNT (*)
from employees;

--dept_emp table has many employees associated with many departments.  Options 4A and 4B provide alternative solutions to join employee table with dept_emp and NOT cause duplicate records to employee table

--4A: list the dept_no, emp_no, first and last name and department name
--note: used window logic to show only 1 department per employee. Ideally would partition or order by date, but no dates are given 
--employees appear in many departments; from real world standpoint would only expect to see employee assigned to 1 dept 

SELECT 
de.emp_no as "Employee No.",
emp.last_name as "Last Name",
emp.first_name as "First Name",
de.dept_no as "Dept Nbr",
dept.dept_name as "Dept Name"

from (
	SELECT dept_emp. *,
		row_number() OVER (PARTITION BY emp_no ORDER BY emp_no ASC) AS ROW_NUMBER
	FROM dept_emp 

GROUP BY 1,2) as de
left join departments as dept on de.dept_no = dept.dept_no
left join employees as emp on de.emp_no = emp.emp_no

where row_number = 1;

--4B: list the dept_no, emp_no, first and last name and department name
-- uses string aggregation to aggregate department no and name by employee; so that there are no duplicate rows for employees

SELECT 
b.emp_no,
emp.last_name,
emp.first_name,
b.dept_nbr,
b.dept_name

from (
SELECT 
a.emp_no,
STRING_AGG(a.dept_no,' / ') as Dept_Nbr,
STRING_AGG(a.dept_name, ' / ') as Dept_Name

from (
SELECT
de.emp_no,
de.dept_no,
dept.dept_name 

from dept_emp as de
left join departments as dept on de.dept_no = dept.dept_no

group by 1,2,3) a
group by 1) b

left join employees as emp on b.emp_no = emp.emp_no;

--4C: list the dept_no, emp_no, first and last name and department name. Uses dept_emp as driving table and shows duplicate employee ID (is not the preferred solution but answers question asked)
SELECT 
de.emp_no,
emp.last_name,
emp.first_name,
de.dept_no,
dept.dept_name
from dept_emp de
left join employees as emp on de.emp_no = emp.emp_no
left join departments as dept on de.dept_no = dept.dept_no;

--5: list the first name, last name and sex of each employee whose name is Hercules and last name starts with "B"
SELECT
first_name as "First Name",
last_name as "Last Name",
sex as "Sex"
from employees
where first_name = 'Hercules'
and last_name like 'B%';

--6A: List each employee in the sales and development department, including employee number, first and last name
--Note: uses list aggregation method; such that lists multiple departments if employee is associated with more than 1
--Record count is identical between 
SELECT 
b.emp_no,
emp.first_name,
emp.last_name,
b.dept_nbr,
b.dept_name

from (
SELECT 
a.emp_no,
STRING_AGG(a.dept_no,' / ') as Dept_Nbr,
STRING_AGG(a.dept_name, ' / ') as Dept_Name

from (
SELECT
de.emp_no,
de.dept_no,
dept.dept_name 

from dept_emp as de
left join departments as dept on de.dept_no = dept.dept_no

group by 1,2,3) a
group by 1) b

left join employees as emp on b.emp_no = emp.emp_no

where b.dept_name like 'Sales%'
or b.dept_name like '%Sales'

group by 1,2,3,4,5
order by b.dept_name ASC;

--6B: List each employee in the sales and development department, including employee number, first and last name
-- Uses dept_emp as driving table, returns employee ID if department is sales or development; but does NOT show if that employee worked in NON-SALES/DEVELOPMENT at any time
SELECT 
de.emp_no,
emp.last_name,
emp.first_name,
de.dept_no,
dept.dept_name
from dept_emp de
left join employees as emp on de.emp_no = emp.emp_no
left join departments as dept on de.dept_no = dept.dept_no

where dept.dept_name in ('Sales')

group by 1,2,3,4,5;

--7A: List each employee in the sales and development department, including employee number, first and last name
--Note: uses list aggregation method; such that lists multiple departments if employee is associated with more than 1
--Record count is identical between 
SELECT 
b.emp_no,
emp.first_name,
emp.last_name,
b.dept_nbr,
b.dept_name

from (
SELECT 
a.emp_no,
STRING_AGG(a.dept_no,' / ') as Dept_Nbr,
STRING_AGG(a.dept_name, ' / ') as Dept_Name

from (
SELECT
de.emp_no,
de.dept_no,
dept.dept_name 

from dept_emp as de
left join departments as dept on de.dept_no = dept.dept_no

group by 1,2,3) a
group by 1) b

left join employees as emp on b.emp_no = emp.emp_no

where b.dept_name like 'Sales%'
or b.dept_name like '%Sales'
or b.dept_name like '%Development'
or b.dept_name like 'Development%'

group by 1,2,3,4,5
order by b.dept_name ASC;

--7B: List each employee in the sales and development department, including employee number, first and last name
-- Uses dept_emp as driving table, returns employee ID if department is sales or development; but does NOT show if that employee worked in NON-SALES/DEVELOPMENT at any time
SELECT 
de.emp_no,
emp.last_name,
emp.first_name,
de.dept_no,
dept.dept_name
from dept_emp de
left join employees as emp on de.emp_no = emp.emp_no
left join departments as dept on de.dept_no = dept.dept_no

where dept.dept_name in ('Sales', 'Development')

group by 1,2,3,4,5;

--8 List the frequency counts, in descending order, of all the employee last names 
-- if there are multiple last names with same frequency, order alphabetically

SELECT
last_name,
count(emp_no) as "last_name_occurs"
from employees
group by 1
order by
  2 DESC,
  1 ASC;

