-- drop table if exists: employees
DROP TABLE IF EXISTS employees CASCADE;

-- create table: employees
CREATE TABLE employees (
	emp_no VARCHAR(6) NOT NULL PRIMARY KEY,
	emp_title_id VARCHAR(5),
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	sex VARCHAR(1) NOT NULL,
	hire_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES salaries(emp_no),
	FOREIGN KEY (emp_title_id) REFERENCES titles(title_id));

-- drop table if exists: departments
DROP TABLE IF EXISTS departments CASCADE;

-- create table: departments
CREATE TABLE departments (
	dept_no VARCHAR(4) PRIMARY KEY,
	dept_name VARCHAR(30) NOT NULL);

-- drop table if exists: dept_emp
DROP TABLE IF EXISTS dept_emp CASCADE;

-- create table: dept_emp
CREATE TABLE dept_emp (
	emp_no VARCHAR(6) NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	PRIMARY KEY (emp_no, dept_no),
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments(dept_no));
	
-- drop table if exists: dept_manager
DROP TABLE IF EXISTS dept_manager CASCADE;

-- create table: dept_manager
CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no VARCHAR(6) NOT NULL,
	PRIMARY KEY (dept_no, emp_no),
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments(dept_no));
	
-- drop table if exists: salaries
DROP TABLE IF EXISTS salaries CASCADE;

-- create table: salaries
CREATE TABLE salaries (
	emp_no VARCHAR(6) NOT NULL PRIMARY KEY,
	salary INTEGER);
	
-- drop table if exists: titles
DROP TABLE IF EXISTS titles CASCADE;

-- create table: titles
CREATE TABLE titles (
	title_id VARCHAR(10) PRIMARY KEY,
	title VARCHAR(30));
