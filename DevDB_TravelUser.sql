-- Drop existing tables to avoid conflicts during creation
DROP TABLE Department CASCADE CONSTRAINTS;
DROP TABLE Employee CASCADE CONSTRAINTS;
DROP TABLE FinancialAuditor CASCADE CONSTRAINTS;
DROP TABLE ExpenseStatus CASCADE CONSTRAINTS;
DROP TABLE ExpenseType CASCADE CONSTRAINTS;
DROP TABLE Administrator CASCADE CONSTRAINTS;
DROP TABLE Expense CASCADE CONSTRAINTS;
DROP TABLE Approval CASCADE CONSTRAINTS;
DROP TABLE AuditLog CASCADE CONSTRAINTS;
DROP TABLE Notifications CASCADE CONSTRAINTS;
DROP TABLE Reimbursement CASCADE CONSTRAINTS;
DROP TABLE Payment CASCADE CONSTRAINTS;




-- Department Table
CREATE TABLE Department (
    DepartmentID NUMBER PRIMARY KEY,    -- Primary Key for Department
    DepartmentName VARCHAR2(100) NOT NULL,  -- Name of the department
    Location VARCHAR2(100)              -- Location of the department
);
-- Employee Table
CREATE TABLE Employee (
    EmployeeID NUMBER PRIMARY KEY, 
    FirstName VARCHAR2(50) NOT NULL, 
    LastName VARCHAR2(50) NOT NULL, 
    Department VARCHAR2(50),
    Email VARCHAR2(100) UNIQUE NOT NULL,
    DepartmentID NUMBER,
    Phone VARCHAR2(15) CHECK (REGEXP_LIKE(Phone, '^[0-9]{10,15}$')),  -- Ensures valid phone numbers (10-15 digits)
    	
	-- Foreign Key constraint to link Employee to Department
    CONSTRAINT fk_employee_department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
        ON DELETE SET NULL  -- If department is deleted, set DepartmentID to NULL in Employee
);


-- Financial Auditor Table
CREATE TABLE FinancialAuditor (
    AuditorID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,  -- Each auditor has a unique email
    Phone VARCHAR2(15) CHECK (REGEXP_LIKE(Phone, '^[0-9]{10,15}$'))  -- Valid phone numbers
);

-- Expense Status Table
CREATE TABLE ExpenseStatus (
    StatusID NUMBER PRIMARY KEY,
    StatusName VARCHAR2(50) NOT NULL CHECK (StatusName IN ('Pending', 'Approved', 'Rejected'))  -- Enforce valid status values
);

-- Expense Type Table
CREATE TABLE ExpenseType (
    ExpenseTypeID NUMBER PRIMARY KEY,  -- Unique ID for each type of expense
    TypeName VARCHAR2(50) NOT NULL UNIQUE  -- Name of the expense type, ensuring uniqueness (e.g., Meals, Travel, Accommodation)
);

-- Administrator Table
CREATE TABLE Administrator (
    AdminID NUMBER PRIMARY KEY, 
    AdminName VARCHAR2(50) NOT NULL, 
    Role VARCHAR2(50) CHECK (Role IN ('Admin', 'Viewer', 'Deleter')),  -- Admin role includes viewer, deleter capabilities
    Email VARCHAR2(100) UNIQUE NOT NULL  -- Unique and Not Null
);

-- Expense Table
CREATE TABLE Expense (
    ExpenseID NUMBER PRIMARY KEY,
    EmployeeID NUMBER,  -- Foreign Key to Employee
    ExpenseTypeID NUMBER,  -- Foreign Key to ExpenseType
    AdminID NUMBER,  -- Link to Admin table for admin submitting/managing the expense
    Amount NUMBER(7, 2) NOT NULL CHECK (Amount > 0 AND Amount <= 5000),  -- Positive amount <= 5000
    ExpenseDate DATE NOT NULL,  -- ExpenseDate should be on or before today
    Description VARCHAR2(255),
    StatusID NUMBER,  -- Foreign Key to ExpenseStatus
    CONSTRAINT fk_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    CONSTRAINT fk_status FOREIGN KEY (StatusID) REFERENCES ExpenseStatus(StatusID),
    CONSTRAINT fk_expense_type FOREIGN KEY (ExpenseTypeID) REFERENCES ExpenseType(ExpenseTypeID),
    CONSTRAINT fk_expense_admin FOREIGN KEY (AdminID) REFERENCES Administrator(AdminID)  -- Link to Administrator
);



-- Approval Table
CREATE TABLE Approval (
    ApprovalID NUMBER PRIMARY KEY,
    ExpenseID NUMBER,  -- Foreign Key to Expense
    AuditorID NUMBER,  -- Foreign Key to FinancialAuditor
    AdminID NUMBER,  -- Link to Admin who handled the approval
    StatusID NUMBER,  -- Foreign Key to ExpenseStatus
    ApprovalDate DATE,  -- Approval Date cannot be in the future
    Comments VARCHAR2(255),
    CONSTRAINT fk_expense FOREIGN KEY (ExpenseID) REFERENCES Expense(ExpenseID),  -- Expense being approved
    CONSTRAINT fk_auditor FOREIGN KEY (AuditorID) REFERENCES FinancialAuditor(AuditorID),  -- Auditor who approved the expense
    CONSTRAINT fk_status_approval FOREIGN KEY (StatusID) REFERENCES ExpenseStatus(StatusID),
    CONSTRAINT fk_admin_approval FOREIGN KEY (AdminID) REFERENCES Administrator(AdminID)  -- Admin handling the approval
);

-- Audit Log Table
CREATE TABLE AuditLog (
    AuditID NUMBER PRIMARY KEY,
    AuditorID NUMBER,  -- Foreign Key to FinancialAuditor
    ExpenseID NUMBER,  -- Foreign Key to Expense
    AdminID NUMBER,  -- Link to Admin who made the modification
    ModifiedBy VARCHAR2(50),  -- Admin or Employee who made the modification
    ModificationDate DATE DEFAULT SYSDATE,  -- Automatically log the date of modification
    ActionTaken VARCHAR2(255),
    CONSTRAINT fk_audit_expense FOREIGN KEY (ExpenseID) REFERENCES Expense(ExpenseID),
    CONSTRAINT fk_audit_auditor FOREIGN KEY (AuditorID) REFERENCES FinancialAuditor(AuditorID),  -- Foreign Key to FinancialAuditor
    CONSTRAINT fk_audit_admin FOREIGN KEY (AdminID) REFERENCES Administrator(AdminID)  -- Foreign Key to Administrator
);



-- Notifications Table
CREATE TABLE Notifications (
    NotificationID NUMBER PRIMARY KEY,       -- Primary Key for Notifications
    EmployeeID NUMBER,                       -- Foreign Key to Employee
    AdminID NUMBER,                          -- Foreign Key to Administrator
    Message VARCHAR2(255),                   -- Notification message
    NotificationDate DATE,                   -- Date the notification was generated
    IsRead CHAR(1) CHECK (IsRead IN ('Y', 'N')),  -- Boolean field indicating if the notification has been read ('Y' or 'N'),
    AuditID NUMBER,
    CONSTRAINT fk_notification_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    CONSTRAINT fk_notification_admin FOREIGN KEY (AdminID) REFERENCES Administrator(AdminID),
    CONSTRAINT fk_notification_audit FOREIGN KEY (AuditID) REFERENCES AuditLog(AuditID)
        ON DELETE CASCADE
);

-- Reimbursement Table
CREATE TABLE Reimbursement (
    ReimbursementID NUMBER PRIMARY KEY,    -- Primary Key for Reimbursement
    ExpenseID NUMBER,                      -- Foreign Key from Expense
    Amount NUMBER(10, 2),                  -- Reimbursed Amount (with precision 2 for cents)
    Status VARCHAR2(20),                   -- Status of Reimbursement (e.g., Pending, Approved, Paid)
    
    -- Foreign Key constraint to link Reimbursement to an Expense
    CONSTRAINT fk_reimbursement_expense FOREIGN KEY (ExpenseID) REFERENCES Expense(ExpenseID)
        ON DELETE CASCADE
);

-- Payment Table
CREATE TABLE Payment (
    PaymentID NUMBER PRIMARY KEY,          -- Primary Key for Payment
    EmployeeID NUMBER,                     -- Foreign Key from Employee
    Amount NUMBER(10, 2),                  -- Payment Amount (with precision 2 for cents)
    PaymentDate DATE,                      -- Date of Payment
    PaymentMethod VARCHAR2(50),            -- Method of Payment (e.g., Direct Deposit, Check),
    ReimbursementID NUMBER,
    -- Foreign Key constraint to link Payment to an Employee
    CONSTRAINT fk_payment_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    CONSTRAINT fk_payment_reimbursement FOREIGN KEY (ReimbursementID) REFERENCES Reimbursement(ReimbursementID)
        ON DELETE CASCADE
);

-----------------------------------------Views---------------------------------------------------------------------------------------


DROP VIEW HighValueExpenses;
DROP VIEW ExpenseSummaryByEmployee;
DROP VIEW PendingApprovals;
DROP VIEW ExpensesByStatus;
DROP VIEW TotalExpensesByType;
DROP VIEW ApprovedExpensesOverTime;
DROP VIEW AdministratorActivityLog;
DROP VIEW ReimbursementDetails;

-- 1. View: High-Value Expenses
CREATE OR REPLACE VIEW HighValueExpenses AS
SELECT 
    e.ExpenseID,
    e.EmployeeID,
    emp.FirstName,
    emp.LastName,
    e.Amount,
    e.Description,
    e.ExpenseDate
FROM 
    Expense e
JOIN 
    Employee emp ON e.EmployeeID = emp.EmployeeID
WHERE 
    e.Amount > 1000;

SELECT * FROM HighValueExpenses;

-- 2. View: Expense Summary by Employee
CREATE OR REPLACE VIEW ExpenseSummaryByEmployee AS
SELECT 
    emp.EmployeeID,
    emp.FirstName,
    emp.LastName,
    et.TypeName AS ExpenseType,
    SUM(e.Amount) AS TotalAmount
FROM 
    Expense e
JOIN 
    Employee emp ON e.EmployeeID = emp.EmployeeID
JOIN 
    ExpenseType et ON e.ExpenseTypeID = et.ExpenseTypeID
GROUP BY 
    emp.EmployeeID, emp.FirstName, emp.LastName, et.TypeName;

SELECT * FROM ExpenseSummaryByEmployee;

-- 3. View: Pending Approvals
CREATE OR REPLACE VIEW PendingApprovals AS
SELECT 
    a.ApprovalID,
    e.ExpenseID,
    emp.EmployeeID,
    emp.FirstName,
    emp.LastName,
    fa.FirstName AS AuditorFirstName,
    fa.LastName AS AuditorLastName,
    a.ApprovalDate,
    a.Comments
FROM 
    Approval a
JOIN 
    Expense e ON a.ExpenseID = e.ExpenseID
JOIN 
    Employee emp ON e.EmployeeID = emp.EmployeeID
JOIN 
    FinancialAuditor fa ON a.AuditorID = fa.AuditorID
WHERE 
    a.StatusID = (SELECT StatusID FROM ExpenseStatus WHERE StatusName = 'Pending');

SELECT * FROM PendingApprovals;
-- 4. View: Expenses by Status
CREATE OR REPLACE VIEW ExpensesByStatus AS
SELECT 
    e.ExpenseID,
    e.EmployeeID,
    emp.FirstName,
    emp.LastName,
    es.StatusName AS CurrentStatus,
    e.Amount,
    e.Description,
    e.ExpenseDate
FROM 
    Expense e
JOIN 
    Employee emp ON e.EmployeeID = emp.EmployeeID
JOIN 
    ExpenseStatus es ON e.StatusID = es.StatusID;

-- 5. View: Total Expenses by Type
CREATE OR REPLACE VIEW TotalExpensesByType AS
SELECT 
    et.TypeName AS ExpenseType,
    SUM(e.Amount) AS TotalAmount
FROM 
    Expense e
JOIN 
    ExpenseType et ON e.ExpenseTypeID = et.ExpenseTypeID
GROUP BY 
    et.TypeName;

-- 6. View: Approved Expenses Over Time
CREATE OR REPLACE VIEW ApprovedExpensesOverTime AS
SELECT 
    e.ExpenseID,
    emp.EmployeeID,
    emp.FirstName,
    emp.LastName,
    e.Amount,
    a.ApprovalDate
FROM 
    Expense e
JOIN 
    Approval a ON e.ExpenseID = a.ExpenseID
JOIN 
    Employee emp ON e.EmployeeID = emp.EmployeeID
WHERE 
    a.StatusID = (SELECT StatusID FROM ExpenseStatus WHERE StatusName = 'Approved')
ORDER BY 
    a.ApprovalDate;

-- 7. View: Administrator Activity Log
CREATE OR REPLACE VIEW AdministratorActivityLog AS
SELECT 
    al.AuditID,
    admin.AdminID,
    admin.AdminName,
    al.ModifiedBy,
    al.ModificationDate,
    al.ActionTaken
FROM 
    AuditLog al
JOIN 
    Administrator admin ON al.AdminID = admin.AdminID
ORDER BY 
    al.ModificationDate DESC;

-- 8. View: Reimbursement Details
CREATE OR REPLACE VIEW ReimbursementDetails AS
SELECT 
    r.ReimbursementID,
    e.EmployeeID,
    emp.FirstName,
    emp.LastName,
    r.Amount AS ReimbursementAmount,
    p.PaymentMethod,
    p.PaymentDate
FROM 
    Reimbursement r
JOIN 
    Expense e ON r.ExpenseID = e.ExpenseID
JOIN 
    Employee emp ON e.EmployeeID = emp.EmployeeID
JOIN 
    Payment p ON r.ReimbursementID = p.ReimbursementID;
    

-------------------Insert--------------------------
INSERT INTO Department (DepartmentID, DepartmentName, Location) VALUES 
    (1, 'Finance', 'New York'),
    (2, 'IT', 'San Francisco'),
    (3, 'HR', 'Chicago'),
    (4, 'Marketing', 'Boston'),
    (5, 'Operations', 'Austin'),
    (6, 'Sales', 'Seattle'),
    (7, 'Customer Support', 'Orlando'),
    (8, 'Legal', 'Washington'),
    (9, 'RD', 'San Jose'),
    (10, 'Logistics', 'Dallas');



INSERT INTO Employee (EmployeeID, FirstName, LastName, DepartmentID, Email, Phone) VALUES 
(1, 'John', 'Doe', 1, 'john.doe@example.com', '1234567890'),
(2, 'Jane', 'Smith', 2, 'jane.smith@example.com', '0987654321'),
(3, 'Alice', 'Brown', 3, 'alice.brown@example.com', '1112223333'),
(4, 'Bob', 'White', 4, 'bob.white@example.com', '2223334444'),
(5, 'Carol', 'Black', 5, 'carol.black@example.com', '3334445555'),
(6, 'David', 'Green', 6, 'david.green@example.com', '4445556666'),
(7, 'Eve', 'Blue', 7, 'eve.blue@example.com', '5556667777'),
(8, 'Frank', 'Yellow', 8, 'frank.yellow@example.com', '6667778888'),
(9, 'Grace', 'Pink', 9, 'grace.pink@example.com', '7778889999'),
(10, 'Hank', 'Gray', 10, 'hank.gray@example.com', '8889990000');



INSERT INTO FinancialAuditor (AuditorID, FirstName, LastName, Email, Phone) VALUES 
(1, 'Lily', 'Evans', 'lily.evans@example.com', '1112223333'),
(2, 'James', 'Potter', 'james.potter@example.com', '2223334444'),
(3, 'Albus', 'Dumbledore', 'albus.d@example.com', '3334445555'),
(4, 'Minerva', 'McGonagall', 'minerva.m@example.com', '4445556666'),
(5, 'Severus', 'Snape', 'severus.s@example.com', '5556667777'),
(6, 'Sirius', 'Black', 'sirius.b@example.com', '6667778888'),
(7, 'Remus', 'Lupin', 'remus.l@example.com', '7778889999'),
(8, 'Horace', 'Slughorn', 'horace.s@example.com', '8889990000'),
(9, 'Gilderoy', 'Lockhart', 'gilderoy.l@example.com', '9990001111'),
(10, 'Rubeus', 'Hagrid', 'rubeus.h@example.com', '0001112222');




-- Insert valid status types into ExpenseStatus
INSERT INTO ExpenseStatus (StatusID, StatusName) VALUES (1, 'Pending');
INSERT INTO ExpenseStatus (StatusID, StatusName) VALUES (2, 'Approved');
INSERT INTO ExpenseStatus (StatusID, StatusName) VALUES (3, 'Rejected');



-- Insert valid expense types into ExpenseType
INSERT INTO ExpenseType (ExpenseTypeID, TypeName) VALUES (1, 'Meals');
INSERT INTO ExpenseType (ExpenseTypeID, TypeName) VALUES (2, 'Travel');
INSERT INTO ExpenseType (ExpenseTypeID, TypeName) VALUES (3, 'Accommodation');




INSERT INTO Administrator (AdminID, AdminName, Role, Email) VALUES 
(1, 'Admin1', 'Admin', 'admin1@example.com'),
(2, 'Admin2', 'Viewer', 'admin2@example.com'),
(3, 'Admin3', 'Deleter', 'admin3@example.com'),
(4, 'Admin4', 'Admin', 'admin4@example.com'),
(5, 'Admin5', 'Viewer', 'admin5@example.com'),
(6, 'Admin6', 'Deleter', 'admin6@example.com'),
(7, 'Admin7', 'Admin', 'admin7@example.com'),
(8, 'Admin8', 'Viewer', 'admin8@example.com'),
(9, 'Admin9', 'Deleter', 'admin9@example.com'),
(10, 'Admin10', 'Admin', 'admin10@example.com');




