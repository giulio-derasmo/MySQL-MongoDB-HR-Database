// 1) Return ID, Email, Phone number whose born in South Carolina (SC) - Columbia 
db.Employee_info.find(
    //QUERY
    {
        $and: [{"address.state": "SC"}, 
            {"address.city": "Columbia"}]
    },
    //PROJECTION
    {   
        "_id": 1,
        "phone_no": 1,
        "email": 1
    })
    
    
// --------------------------------------------------------------------------------

// 2) Returns the top 3 departments with the greatest employees average total satisfaction
db.Analytics.aggregate([
    { $group: { _id: "$department",
                total_satisfaction: { $avg: "$job_satisfaction" } } },
    { $sort: { total_satisfaction: -1} },
    { $limit: 3 },
    {$project: { "_id": 0,
                "Departments_with_greater_satisfaction": "$_id",
                "total_satisfaction": 1}}
]);


// --------------------------------------------------------------------------------

// 3) Count the number of Employee hired on the second term of 2012 group by department 
db.Hire.aggregate([
    {
        $match: {
            $and: [{"Hire_date.year_of_joining": 2012}, 
                    {"Hire_date.quarter_of_joining": "Q2"}]
        }
    },
    {
        $group: {   _id: "$department", 
                    Number_of_employee: { $sum: 1 }}
    }, 
    {$project: {"_id": 0,
                "department": "$_id",
                "Number_of_employee": 1}}
])

// --------------------------------------------------------------------------------

// 4) How many are the employee younger than 30 years that are farther 
// than 35 km from home BUT don't travel frequently for work
db.Employee_info.aggregate([
    {   //REDUCE THE JOIN
        $match: {"age": {$lt: 30} }
    },
    {   //JOIN ON UNIQUE ID
        $lookup: {
               from: "Company",
               localField: "_id",
               foreignField: "id_emp", //speed up with Company index on id_emp
               as: "Emp_join_Company"
             }
    },
    {"$unwind":"$Emp_join_Company"},   //unlist the join
    {
       $match: 
           { $expr: 
                {  $and: [ {$eq: ["$Emp_join_Company.distance_from_home",35]},
                    {$ne: ["$Emp_join_Company.business_travel",'Travel-Frequently']}, 
                    ]
                }
            }
        }, 
    {
       $count: "Number of employee"
    }
])

// --------------------------------------------------------------------------------

// 5) Return the departments whose employees have an average weight less than 60
db.Employee_info.aggregate([
    {
        $group: { _id: "$department",    //here we use index
                   avgWeight: {$avg: "$weight"}}
    },
    {
        $match: { "avgWeight": {$lt: 60}   }
    }
])

// --------------------------------------------------------------------------------

// 6) Return the single employees that have left the company and are unsatisfied of 
// their work or the enviroment 
db.EmployeeFull.aggregate([
    //match
    {   
        $match: {
            $and: [{$expr: {$eq: ["$hire_info_date.attrition", "Yes"]} },
                    {$expr: 
                        {$or: [{$eq: ["$analytics.job_satisfaction", 1]}, 
                                {$eq: ["$analytics.enviroment_satisfaction", 1]} ]
                        }
                    },{$expr: {$eq: ["$marital_status", "Single"]} }
            ]
        } 
    },
    {
        $project: {
            _id: 0,
            first_name: 1,
            last_name: 1,
            gender: 1,
            age: 1
        }
    }
])

// --------------------------------------------------------------------------------

// 7) Return the number of employees hired between 2000 and 2014 with (job_involment + job_satisfaction) > 3
db.Hire.aggregate([
    {   //REDUCE THE JOIN
        $match: 
            {$expr: 
                {$and: [{$gt: [{$year: "$Hire_date.date_of_hiring"}, 2000] },
                        {$lt: [{$year: "$Hire_date.date_of_hiring"}, 2014] }]
                }
            }
    },
    {   //JOIN ON UNIQUE ID
        $lookup: {
               from: "Analytics",
               localField: "_id",
               foreignField: "hire_id", //index here!
               as: "Hire_join_Analytics"
             }
    },
    {"$unwind":"$Hire_join_Analytics"},
    {
       $match: 
           {$expr: {$gte: [{$add: ["$Hire_join_Analytics.job_involvement", 
                                    "$Hire_join_Analytics.job_satisfaction"] },3]} }
    },
    {
        $count: "count"
    }
])

// --------------------------------------------------------------------------------

// 8) Return the employee with a monthly salary greater than the average
// of the first 10k employees hired
db.Hire.aggregate([
    {$sort: {"Hire_date.date_of_hiring": 1}},
    {$lookup: {
                from: 'Company',
                localField: 'id_emp',
                foreignField: 'id_emp',
                as: 'company_info'
                }
    }, 
    {$unwind: '$company_info'}, 
    {$lookup: {
                from: 'Employee_info',
                localField: 'id_emp',
                foreignField: '_id',
                as: 'final_join'}},
    {$unwind: '$final_join'}, 
    {$project: {
            "_id": 0,
            "id_emp": 1, 
            "hire_date": '$Hire_date.date_of_hiring',
            "monthly_income": '$company_info.salary.monthly_income',
            "final_join.first_name": 1, "final_join.last_name": 1}
    },
    {$limit: 10000},
    {$group: { _id: null, 
                avgIncome: {$avg: "$monthly_income"}, 
                information: {$push: {
                            "id_emp": "$id_emp", "first name": "$final_join.first_name",
                            "monthly_income": "$monthly_income", 
                            "last name": "$final_join.last_name", "hire_date": "$hire_date"}}
            }
    },
    {$limit: 1},
    {$unwind: "$information"},
    {$match: {$expr: {$gt: ["$information.monthly_income", "$avgIncome"]}}},
    {$project: {_id: 0, "avgIncome": 0}}
], {allowDiskUse: true})

// --------------------------------------------------------------------------------

// 9) Employee who work more years, not married and with education grade of 5
db.Employee_info.aggregate([
  { //REDUCE JOIN
    $match: 
        {$expr: 
            {$and: [{"$ne": ["$marital_status",'Married']}, 
                    {"$eq": ["$education.education_no", 5]}]
            }
        }
  }, 
  {
      $lookup: {
             from: "Company",
             localField: "_id",
             foreignField: "id_emp",
             as: "Emp_join_Company"
           }
  },
  { $unwind: "$Emp_join_Company"},
  { $group:{_id:"$Emp_join_Company.total_working_years", count:{$sum:1}}},
  {$sort:{"_id":-1}},
  {$limit:1},
  {$project: {"count": 1, "_id": 0}}
], {allowDiskUse: true})


// --------------------------------------------------------------------------------

// 4) Return some employees attributes of the one that have maximum percentage salary hike
// ordered by date of birth
db.Employee_info.aggregate([
    {$lookup: {
           from: "Company",
           localField: "_id",
           foreignField: "id_emp",
           as: "Emp_join_Company"
         }
    },
    {$unwind: "$Emp_join_Company"},
    //FIND THE MAXIMUM
    {$group: {_id: "$Emp_join_Company.salary.percent_salary_hike",
                employee_info:{$push: {"emp_id": "$_id", "first_name": "$first_name", "last_name": "$last_name",
                                    "date_of_birth": "$date_of_birth", "gender": "$gender", "age": "$age"}}, 
                }},
    {$sort: {"_id": -1} },
    {$limit:1}, 
    //UNLIST 
    {$unwind: "$employee_info"},
    //SORT
    {$sort: {"employee_info.date_of_birth": -1}},
    //PROJECT
    {$project: {"_id":0, "employee_info": 1}},
],{allowDiskUse: true});

