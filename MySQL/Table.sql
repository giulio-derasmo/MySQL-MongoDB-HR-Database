USE hr_database;

CREATE TABLE `Employee` (
  `id` int PRIMARY KEY,
  `first_name` varchar(20), 
  `middle_initial` varchar(20),
  `last_name`  varchar(20),
  `gender` varchar(5),
  `email` varchar(200),
  `age` int, /* va creata */
  `phone_no` character(12),
  `date_of_birth` datetime
);

CREATE TABLE `Hire` (
  `id_emp` int,
  `hire_id` int PRIMARY KEY,
  `department` varchar(40),
  `job_role` varchar(40),
  `jobLevel` int,
  `attrition` varchar(3),
  `hire_date` date,
  FOREIGN KEY (id_emp) REFERENCES Employee(id)
);

CREATE TABLE `Address` (
  `id_emp` int PRIMARY KEY,
  `country` varchar(50),
  `city` varchar(50),
  `state` character(2),
  `zip` int,
  `ssn` character(12),
  `region` varchar(50),
  FOREIGN KEY (id_emp) REFERENCES Employee(id)
);

CREATE TABLE `Login` (
  `id_emp` int PRIMARY KEY,
  `username` varchar(50),
  `password` varchar(50),
  FOREIGN KEY (id_emp) REFERENCES Employee(id)
);

CREATE TABLE `Education` (
  `id_emp` int PRIMARY KEY,
  `education_no` int,
  `educational_field` varchar(20),
  FOREIGN KEY (id_emp) REFERENCES Employee(id)
);

CREATE TABLE `Salary` (
  `id_emp` int,
  `hire_id` int,
  `daily_rate` int,
  `hourly_rate` int,
  `monthly_rate` int,
  `monthly_income` int,
  `percent_salary_hike` int, 
  PRIMARY KEY (`id_emp`, `hire_id`),
  FOREIGN KEY (id_emp) REFERENCES Employee(id),
  FOREIGN KEY (hire_id) REFERENCES Hire(hire_id)
);

CREATE TABLE `SatisfactionAndProductivity` (
  `id_emp` int,
  `hire_id` int,
  `job_satisfaction` int,
  `enviroment_satisfaction` int,
  `job_involment` int,
  `business_travel` varchar(100),
  `performance_rating` int, 
  PRIMARY KEY (`id_emp`, `hire_id`),
  FOREIGN KEY (id_emp) REFERENCES Employee(id),
  FOREIGN KEY (hire_id) REFERENCES Hire(hire_id)
);

CREATE TABLE `ExtraInfoHire` (
  `hire_id` int PRIMARY KEY,
  `quarter_of_joining` character(2), 
  `half_of_joining` varchar(5),
  `year_of_joining` int,
  `month_of_joining` varchar(10),
  `day_of_joining` int,
  `day_name` varchar(10),
  FOREIGN KEY (hire_id) REFERENCES Hire(hire_id)
);


CREATE TABLE `ExtraInfoEmployee` (
  `id_emp` int PRIMARY KEY,
  `fathers_name`  varchar(50),
  `mothers_name`  varchar(50),
  `mothers_last_name`  varchar(50),
  `weight` int,
  `marital_status`  varchar(20),
  `number_company_worked` int,
  `total_working_years` int,
  `work_life_balance` int,
  `distance_from_home` int,
  `years_in_company` int,
  FOREIGN KEY (id_emp) REFERENCES Employee(id)
);
