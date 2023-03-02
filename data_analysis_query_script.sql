--1: list the details of each employee: employee number, last name, first name, sex and salary for all employees
-- all attributes except salary are in employee table
-- can either use join or sub-query to add salary dimension

-- using join method
SELECT
 emp.emp_no as "Employee Nbr",
 emp.last_name as "Last Name",
 emp.first_name as "First Name",
 emp.sex as "sex",
 emp.hire_date as "Date Hired",
 s.salary as "Salary"
from employees emp
left join salaries as s on emp.emp_no = s.emp_no;

-- use subquery to add salary
SELECT
 employees.emp_no as "Employee Nbr",
 employees.last_name as "Last Name",
 employees.first_name as "First Name",
 employees.sex as "Sex",
 employees.hire_date as "Date Hired",
 	(select salary as "Salary" 
	  from salaries
	    where employees.emp_no = salaries.emp_no)
 from employees;
 
--2: list first name, last name and hire-date of employees hired in 1986
-- all attributes are in employee table
SELECT 
 first_name as "First Name",
 last_name as "Last Name",
 hire_date as "Date Hired"
 FROM employees
WHERE EXTRACT(YEAR FROM (hire_date)) = '1986';

--3: list manager of each department, dept number, description, employee number, first and last name
-- dept_manager table is the main or driving table -- contains manager emp_no and deot_no
-- employee first and last name is in employee table
-- department name is in department table
-- can either use join or sub-query logic to return desired results

-- join method
SELECT
 dm.dept_no as "Dept Nbr",
 dept.dept_name as "Dept Name",
 dm.emp_no as "Employee Nbr",
 em.last_name as "Last Name",
 em.first_name as "First Name"
from dept_manager as dm
left join departments as dept on dm.dept_no = dept.dept_no
left join employees as em on dm.emp_no = em.emp_no;

-- subquery method
SELECT
dm.dept_no as "Dept Nbr",
	(SELECT departments.dept_name as "Dept Name"
	   FROM departments 
	     WHERE departments.dept_no = dm.dept_no),
dm.emp_no as "Employee Nbr",		
	(SELECT employees.last_name as "Last Name"
	   FROM employees 
	 	WHERE employees.emp_no = dm.emp_no),
	(SELECT employees.first_name as "First Name"
	   FROM employees WHERE employees.emp_no = dm.emp_no)
FROM dept_manager as dm;

-- 4: SQL script approaches solution in 3 different ways
-- 4A: uses window logic such that an employee is only associated with 1 department
-- 4B: uses list aggregation to aggregate departments if an employee no appears in multiple
-- 4C: shows duplicate employee no, as uses the dept_emp table as the driving table 

-- return # of rows from dept_emp table (returns 331603 rows)
SELECT 
COUNT (emp_no)
FROM dept_emp;

-- return # of rows from employee table (returns 300024 rows). 
--Select DISTINCT returns same # of rows; no duplicates
SELECT DISTINCT
COUNT (*)
from employees;

--4A: list the dept_no, emp_no, first and last name and department name
--note: employees appear in many departments, from real world standpoint would only expect to see employee assigned to 1 dept.
-- used window logic to show only 1 department per employee. Ideally would partition or order by date, but no dates are given 

SELECT 
 de.emp_no as "Employee Nbr",
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
-- uses list aggregation to aggregate department no and name by employee; so that there are no duplicate rows for employees

SELECT 
 b.emp_no as "Employee Nbr",
 emp.last_name as "Last Name",
 emp.first_name as "First Name",
 b.dept_nbr as "Dept Nbr",
 b.dept_name as "Dept Name"
	FROM (
	SELECT 
	a.emp_no,
	STRING_AGG(a.dept_no,' / ') as Dept_Nbr,
	STRING_AGG(a.dept_name, ' / ') as Dept_Name

		FROM (
		SELECT
		de.emp_no,
		de.dept_no,
		dept.dept_name 
		 FROM dept_emp as de
		  LEFT JOIN departments as dept on de.dept_no = dept.dept_no

		group by 1,2,3) a
	group by 1) b

left join employees as emp on b.emp_no = emp.emp_no;

--4C: list the dept_no, emp_no, first and last name and department name. 
-- Uses dept_emp as driving table and shows duplicate employee ID (is not the preferred solution but answers question asked)

SELECT 
 de.emp_no as "Employee Nbr",
 emp.last_name as "Last Name",
 emp.first_name as "First Name",
 de.dept_no as "Dept Nbr",
 dept.dept_name as "Dept Name"
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
 b.emp_no as "Employee Nbr",
 emp.first_name as "First Name",
 emp.last_name as "Last Name",
 b.dept_nbr as "Dept Nbr",
 b.dept_name as "Dept Name"

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
 de.emp_no as "Employee Nbr",
 emp.last_name as "Last Name",
 emp.first_name as "First Name",
 de.dept_no as "Dept Nbr",
 dept.dept_name as "Dept Name"
from dept_emp de
left join employees as emp on de.emp_no = emp.emp_no
left join departments as dept on de.dept_no = dept.dept_no;

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

