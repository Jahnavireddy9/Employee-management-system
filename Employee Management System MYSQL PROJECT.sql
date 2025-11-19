CREATE DATABASE Employee_Management_System;
USE Employee_Management_System;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

# Analysis Questions
# 1. EMPLOYEE INSIGHTS
# How many unique employees are currently in the system?
SELECT 
CONCAT(FIRSTNAME," ",LASTNAME) Unique_Customers
FROM EMPLOYEE;

# Which departments have the highest number of employees?

SELECT J.JOBDEPT Department,
 COUNT(E.EMP_ID) Highest_Number_Of_Employees
 FROM JOBDEPARTMENT J INNER JOIN EMPLOYEE E 
 ON E.JOB_ID = J.JOB_ID GROUP BY jobdept;
 
 
# What is the average salary per department?
SELECT J.JOBDEPT Department, 
AVG(S.amount)  AVG_SALARY
 FROM EMPLOYEE E JOIN JOBDEPARTMENT J 
 ON E.JOB_ID = J.JOB_ID JOIN SALARYBONUS S 
 ON J.JOB_ID = S.JOB_ID GROUP BY J.JOBDEPT;

# Who are the top 5 highest-paid employees?

SELECT  CONCAT(FIRSTNAME," ",LASTNAME) FULL_NAME ,
 S.AMOUNT SALARY 
 FROM EMPLOYEE E JOIN SALARYBONUS S 
 ON E.JOB_ID = S.JOB_ID 
 ORDER BY S.AMOUNT DESC  LIMIT 5 ;


# What is the total salary expenditure across the company?
SELECT SUM(S.AMOUNT) Total_Salary
FROM SALARYBONUS S;

# 2. JOB ROLE AND DEPARTMENT ANALYSIS
# How many different job roles exist in each department?
SELECT jobdept department,COUNT(DISTINCT name) Job_Roles_Count 
FROM JOBDEPARTMENT 
GROUP BY JOBDEPT;

# What is the average salary range per department?
SELECT J.JOBDEPT Department, round(AVG(S.AMOUNT),2) AverageSalary
FROM JOBDEPARTMENT J INNER JOIN SALARYBONUS S  
ON J.JOB_ID = S.JOB_ID 
GROUP BY J.JOBDEPT;

# Which job roles offer the highest salary?
select distinct(j.name) JobRole , max(s.amount)  maxsalary  
from JOBDEPARTMENT J inner join salarybonus s 
on j.job_id = s.job_id 
group by j.name 
order by j.name  ;


# Which departments have the highest total salary allocation?

select j.name Department , max(s.amount)  highest_Salary  
from JOBDEPARTMENT J inner join salarybonus s 
on j.job_id = s.job_id 
group by j.name 
order by highest_Salary desc limit 1;


# 3. QUALIFICATION AND SKILLS ANALYSIS
# How many employees have at least one qualification listed?
select count(p.emp_id) employees_count_with_one_qualification
from  
(select e.emp_id 
from employee e inner join qualification q 
on e.emp_id = q.emp_id 
group by e.emp_id  
having count(qualid) = 1)as p;


# Which positions require the most qualifications?

 select q.Position JobPosition,count(q.qualid) total_qualification 
 from employee e inner join qualification q
 on e.emp_id = q.emp_id 
 group by q.Position 
 order by total_qualification desc ;   



# Which employees have the highest number of qualifications?
select e.emp_id , count(q.qualid) as Highest_Number_Of_Qualification
from employee e inner join qualification q 
on e.emp_id = q.emp_id 
group by e.emp_id 
order by count(q.qualid) desc;


# 4. LEAVE AND ABSENCE PATTERNS
# Which year had the most employees taking leaves?
select year(date) Year,count(leave_id) LeavesCount   
from leaves  
group by year(date)
having count(emp_id);



# What is the average number of leave days taken by its employees per department?
select    
j.name Department_name ,avg(leave_id) Number_of_leaves 
from employee e  join jobdepartment j  on e.job_id = j.job_id   
join leaves l on l.emp_id = e.emp_id
group by j.name 
order by number_of_leaves desc ;

# Which employees have taken the most leaves?
select   e.emp_id,
concat(e.firstname," ",e.lastname) full_name,
count(l.leave_id) leaves_count
from employee e inner join leaves l 
on e.emp_id = l.emp_id 
group by e.emp_id,concat(e.firstname," ",e.lastname)  
order by leaves_count desc ;


# What is the total number of leave days taken company-wide?
select  count(l.leave_id) Total_Leaves 
from employee e inner join leaves l on e.emp_id = l.emp_id;

# How do leave days correlate with payroll amounts?
select 
emp_id Employee_ID,
count(date) as leavesdays,
total_amount 
from
payroll
group by emp_id,total_amount;


# 5. PAYROLL AND COMPENSATION ANALYSIS
# What is the total monthly payroll processed?
select sum(total_amount),year(date),month(date) from payroll group by year(date), month(date);

#What is the average bonus given per department?
select  j.jobdept departname , avg(bonus) as avgbonus from jobdepartment j join salarybonus s on j.job_id = s.job_id group by j.jobdept ;

# Which department receives the highest total bonuses?
select  j.jobdept departname , 
sum(bonus) as Highest_bonus 
from jobdepartment j join salarybonus s 
on j.job_id = s.job_id 
group by j.jobdept 
order by Highest_bonus 
desc limit 1;


# What is the average value of total_amount after considering leave deductions?
select 
emp_id ,total_amount,avg(total_amount-(leave_id*100)) after_deductions
from  
payroll 
group by emp_id,total_amount;

# Which year had the highest number of employee promotions?
SELECT YEAR(DATE_IN) AS PROMOTION_YEAR, COUNT(*) AS TOTAL_PROMOTIONS
FROM QUALIFICATION 
GROUP BY PROMOTION_YEAR
ORDER BY TOTAL_PROMOTIONS DESC
LIMIT 1;