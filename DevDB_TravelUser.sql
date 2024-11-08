-- Drop Department table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Department CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Ignore errors if table does not exist
END;
/

-- Drop Employee table if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Employee CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Repeat for other tables
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE FinancialAuditor CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ExpenseStatus CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ExpenseType CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Administrator CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Expense CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Approval CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AuditLog CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Notifications CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Reimbursement CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Payment CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/



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

-- Drop HighValueExpenses view if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW HighValueExpenses';
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Ignore errors if the view does not exist
END;
/

-- Drop ExpenseSummaryByEmployee view if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW ExpenseSummaryByEmployee';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Drop PendingApprovals view if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW PendingApprovals';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Drop ExpensesByStatus view if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW ExpensesByStatus';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Drop TotalExpensesByType view if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW TotalExpensesByType';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Drop ApprovedExpensesOverTime view if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW ApprovedExpensesOverTime';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/


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
    

