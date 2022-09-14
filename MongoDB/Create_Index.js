db.Company.createIndex(
  {
      "id_emp": 1
  },
  {
      unique: true,
      sparse: true,
      expireAfterSeconds: 3600
  }
);

db.Hire.createIndex(
  {
      "id_emp": 1
  },
  {
      unique: true,
      sparse: true,
      expireAfterSeconds: 3600
  }
);

db.EmployeeFull.createIndex(
  {
      "department": 1
  },
  {
      expireAfterSeconds: 3600
  }
);

db.Analytics.createIndex(
  {
      "hire_id": 1
  },
  {
      unique: true,
      sparse: true,
      expireAfterSeconds: 3600
  }
);