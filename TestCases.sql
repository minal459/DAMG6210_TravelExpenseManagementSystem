-----Views--------
SELECT * FROM HighValueExpenses;

SELECT * FROM ExpenseSummaryByEmployee;

SELECT * FROM PendingApprovals;

SELECT * FROM ExpensesByStatus;

SELECT * FROM TotalExpensesByType;

SELECT * FROM ApprovedExpensesOverTime;

SELECT * FROM AdministratorActivityLog;

SELECT * FROM ReimbursementDetails;

-----Triggers---------

--1. Auto-Insertion of Audit Logs on Expense Modifications
SELECT * FROM Expense;
SELECT * FROM AuditLog;

UPDATE Expense
SET Amount = 700
WHERE ExpenseID = 1;


SELECT * FROM Expense;


SELECT *
FROM AuditLog
WHERE ExpenseID = 1;


ROLLBACK;
--2. Audit Trail for Expense Status Changes
SELECT * FROM Expense;
SELECT * FROM AuditLog;

UPDATE Expense
SET StatusID = 2
WHERE ExpenseID = 1;

SELECT *
FROM AuditLog
WHERE ExpenseID = 1;

ROLLBACK;

--3. Prevent Future Expense Dates

SELECT * FROM Expense;

-- Test Insert with a valid ExpenseDate
INSERT INTO Expense (ExpenseID, Amount, StatusID, ExpenseDate)
VALUES (11, 100, 1, SYSDATE - 1); -- ExpenseDate is one day in the past
ROLLBACK;

-- Test Update with a valid ExpenseDate
UPDATE Expense
SET ExpenseDate = SYSDATE
WHERE ExpenseID = 1; -- ExpenseDate is set to the current date
ROLLBACK;

-- Test Insert with a future ExpenseDate
INSERT INTO Expense (ExpenseID, Amount, StatusID, ExpenseDate)
VALUES (2, 200, 1, SYSDATE + 1); -- ExpenseDate is one day in the future

-- Test Update with a future ExpenseDate
UPDATE Expense
SET ExpenseDate = SYSDATE + 1
WHERE ExpenseID = 1; -- ExpenseDate is set to one day in the future


--4. Reimbursement Amount Validation
-- Assume an Expense with ExpenseID = 1 and Amount = 100 already exists
INSERT INTO Reimbursement (ReimbursementID, ExpenseID, Amount)
VALUES (2, 1, 720); -- Invalid Reimbursement Amount


--5.
-- Insert a high-value expense into the Expense table
-- Try inserting a record with an expense date in the future
INSERT INTO Expense (ExpenseID, Amount, StatusID, ExpenseDate)
VALUES (12, 2000, 1, TO_DATE('2025-01-01', 'YYYY-MM-DD'));

-- Insert a valid record
INSERT INTO Expense (ExpenseID, Amount, StatusID, ExpenseDate)
VALUES (12, 2000, 1, SYSDATE);

ROLLBACK;

SELECT * FROM EXPENSE;

--6.(Enforce Valid Department Assignment)error--
DELETE FROM Department
WHERE DepartmentID = 2;

SELECT * FROM Department;
ROLLBACK;

DELETE FROM Department WHERE DepartmentID = 99;

--7.---unsuccesull testcases-Insert approval where AdminID = EmployeeID.--
INSERT INTO Approval (ApprovalID, ExpenseID, AuditorID, AdminID, StatusID, ApprovalDate, Comments) VALUES (3, 1, 1, 1, 2, SYSDATE, 'Approved');

---Insert approval with invalid ExpenseID.---
INSERT INTO Approval (ApprovalID, ExpenseID, AuditorID, AdminID, StatusID, ApprovalDate, Comments) VALUES (4, 99, 1, 1, 2, SYSDATE, 'Approved');

---sucessfull---
-- Successful Test Case
INSERT INTO Approval (ApprovalID, ExpenseID, AuditorID, AdminID, StatusID, ApprovalDate, Comments)
VALUES (11, 1, 1, 2, 2, TO_DATE('2024-06-01', 'YYYY-MM-DD'), 'Approved');

SELECT * FROM Approval;
ROLLBACK;


--8. trg_unique_expense_type (Ensure Unique Expense Types)
INSERT INTO ExpenseType (ExpenseTypeID, TypeName)
VALUES (13, 'Client Gifts');
-- Expected: Success

SELECT * FROM ExpenseType;
ROLLBACK;


----------Packages ---------------
--TEST 1
SELECT * FROM AuditLog;
SELECT * FROM Expense;
BEGIN
    -- Call the procedure
    ExpenseManagementPkg.ApproveExpense(p_ExpenseID => 4, p_AdminID => 2);

    -- Output message to confirm execution
    DBMS_OUTPUT.PUT_LINE('ApproveExpense executed for ExpenseID 4 by AdminID 2.');
    --ROLLBACK; -- Revert all changes
END;
/
ROLLBACK;
 --TEST 2
DECLARE
    v_TotalAmount NUMBER;
BEGIN
    ExpenseManagementPkg.CalculateTotalExpenses(p_EmployeeID => 1, o_TotalAmount => v_TotalAmount);
    DBMS_OUTPUT.PUT_LINE('Total Expenses: ' || v_TotalAmount);
END;
/

SELECT SUM(Amount) AS TotalAmount
FROM Expense
WHERE EmployeeID = 1;

ROLLBACK;

--Call GetEmployeeEmail
DECLARE
    v_Email VARCHAR2(100);
BEGIN
    v_Email := ExpenseManagementPkg.GetEmployeeEmail(p_EmployeeID => 1);
    DBMS_OUTPUT.PUT_LINE('Employee Email: ' || v_Email);
END;
/

SELECT Email
FROM Employee
WHERE EmployeeID = 1;

ROLLBACK;

--Call IsExpenseFlagged

DECLARE
    v_Flagged BOOLEAN;
BEGIN
    v_Flagged := ExpenseManagementPkg.IsExpenseFlagged(p_ExpenseID => 9);
    IF v_Flagged THEN
        DBMS_OUTPUT.PUT_LINE('The expense is flagged.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('The expense is not flagged.');
    END IF;
END;
/

SELECT ExpenseID, Amount
FROM Expense
WHERE ExpenseID = 9;

ROLLBACK;


---------  Reimbursement done when status is approved by admin----------------------

SELECT * FROM EXPENSESTATUS;
SELECT * FROM EXPENSE;
BEGIN
    sp_update_expense_details(p_ExpenseID => 2); -- Pass the desired ExpenseID
END;
/
ROLLBACK;


