// HIRE COLLECTION
db.Hire.update(
    // MATCH THE VALUE TO CHANGE:  TYPE2 (string) TO Date
    { "Hire_date.date_of_hiring" : { $type: 2 } },
    [{ $set: { "Hire_date.date_of_hiring": { $dateFromString : { dateString: "$Hire_date.date_of_hiring",
                                                        format: "%m-%d-%Y"}}}}],
    { multi: true }
);

// EMPLOYEE INFO COLLECTION
db.Employee_info.update(
    // MATCH THE VALUE TO CHANGE:  TYPE16 (string) TO Date
    { "date_of_birth" : { $type: 2 } },
    [{ $set: { "date_of_birth": { $dateFromString : { dateString: "$date_of_birth",
                                                      format: "%m-%d-%Y %H:%M:%S "}}}}], 
    { multi : true }
);

// EMPLOYEE FULL COLLECTION
db.EmployeeFull.update(
    // MATCH THE VALUE TO CHANGE:  TYPE2 (string) TO Date
    { "hire_info_date.Hire_date.date_of_hiring" : { $type: 2 } },
    [{ $set: { "hire_info_date.Hire_date.date_of_hiring": 
                    { $dateFromString : { dateString: "$hire_info_date.Hire_date.date_of_hiring",
                                                        format: "%m-%d-%Y"}}}}],
    { multi: true }
);

db.EmployeeFull.update(
    // MATCH THE VALUE TO CHANGE:  TYPE16 (string) TO Date
    { "date_of_birth" : { $type: 2 } },
    [{ $set: { "date_of_birth": { $dateFromString : { dateString: "$date_of_birth",
                                    format: "%m-%d-%Y %H:%M:%S "}}}}], 
    { multi : true }
);