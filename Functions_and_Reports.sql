
------------------------Reimbursement details----------------------------

SET SERVEROUTPUT ON;

-- PL/SQL block to fetch and print reimbursement details
DECLARE
    -- Cursor for fetching all reimbursement details
    CURSOR reimbursement_cursor IS
        SELECT * FROM ReimbursementDetails;

    -- Variables to hold data from the cursor
    v_ReimbursementID ReimbursementDetails.ReimbursementID%TYPE;
    v_EmployeeID ReimbursementDetails.EmployeeID%TYPE;
    v_FirstName ReimbursementDetails.FirstName%TYPE;
    v_LastName ReimbursementDetails.LastName%TYPE;
    v_ReimbursementAmount ReimbursementDetails.ReimbursementAmount%TYPE;
    v_PaymentMethod ReimbursementDetails.PaymentMethod%TYPE;
    v_PaymentDate ReimbursementDetails.PaymentDate%TYPE;

    -- Variables for aggregated data
    v_TotalReimbursements NUMBER;
    v_TotalReimbursedAmount NUMBER;
    v_AverageReimbursement NUMBER;
    v_MinReimbursement NUMBER;
    v_MaxReimbursement NUMBER;

BEGIN
    -- Fetch and print all reimbursement details
    DBMS_OUTPUT.PUT_LINE('--- All Reimbursement Details ---');
    OPEN reimbursement_cursor;
    LOOP
        FETCH reimbursement_cursor INTO v_ReimbursementID, v_EmployeeID, v_FirstName, v_LastName,
                                        v_ReimbursementAmount, v_PaymentMethod, v_PaymentDate;
        EXIT WHEN reimbursement_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ReimbursementID: ' || v_ReimbursementID ||
                             ', Employee: ' || v_FirstName || ' ' || v_LastName ||
                             ', Amount: $' || v_ReimbursementAmount ||
                             ', PaymentMethod: ' || v_PaymentMethod ||
                             ', PaymentDate: ' || TO_CHAR(v_PaymentDate, 'YYYY-MM-DD'));
    END LOOP;
    CLOSE reimbursement_cursor;

    -- Calculate total reimbursements, sum, and average
    SELECT COUNT(*), SUM(ReimbursementAmount), AVG(ReimbursementAmount),
           MIN(ReimbursementAmount), MAX(ReimbursementAmount)
    INTO v_TotalReimbursements, v_TotalReimbursedAmount, v_AverageReimbursement,
         v_MinReimbursement, v_MaxReimbursement
    FROM ReimbursementDetails;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Summary of Reimbursements ---');
    DBMS_OUTPUT.PUT_LINE('Total Reimbursements: ' || v_TotalReimbursements);
    DBMS_OUTPUT.PUT_LINE('Total Amount Reimbursed: $' || v_TotalReimbursedAmount);
    DBMS_OUTPUT.PUT_LINE('Average Reimbursement: $' || ROUND(v_AverageReimbursement, 2));
    DBMS_OUTPUT.PUT_LINE('Minimum Reimbursement: $' || v_MinReimbursement);
    DBMS_OUTPUT.PUT_LINE('Maximum Reimbursement: $' || v_MaxReimbursement);

    -- Find employees who received reimbursements greater than $1000
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Employees with Reimbursements > $1000 ---');
    FOR rec IN (SELECT EmployeeID, FirstName || ' ' || LastName AS EmployeeName,
                       ReimbursementID, ReimbursementAmount, PaymentMethod, PaymentDate
                FROM ReimbursementDetails
                WHERE ReimbursementAmount > 1000
                ORDER BY ReimbursementAmount DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('Employee: ' || rec.EmployeeName ||
                             ', ReimbursementID: ' || rec.ReimbursementID ||
                             ', Amount: $' || rec.ReimbursementAmount ||
                             ', PaymentMethod: ' || rec.PaymentMethod ||
                             ', PaymentDate: ' || TO_CHAR(rec.PaymentDate, 'YYYY-MM-DD'));
    END LOOP;

    -- Summarize payment methods
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Payment Methods Summary ---');
    FOR rec IN (SELECT PaymentMethod, COUNT(*) AS MethodUsageCount, SUM(ReimbursementAmount) AS TotalAmountByMethod
                FROM ReimbursementDetails
                GROUP BY PaymentMethod
                ORDER BY TotalAmountByMethod DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('PaymentMethod: ' || rec.PaymentMethod ||
                             ', UsageCount: ' || rec.MethodUsageCount ||
                             ', Total Amount: $' || rec.TotalAmountByMethod);
    END LOOP;
END;
/





------------------------All Expenses ---------------------------


SET SERVEROUTPUT ON;

DECLARE
    -- Variables for summary reports
    v_TotalExpenses NUMBER;
    v_TotalApprovedExpenses NUMBER;
    v_AverageExpenseAmount NUMBER;

BEGIN
    -- Report 1: All Expenses by Status
    DBMS_OUTPUT.PUT_LINE('--- Expenses by Status ---');
    FOR rec IN (SELECT * FROM ExpensesByStatus ORDER BY CurrentStatus, ExpenseDate) LOOP
        DBMS_OUTPUT.PUT_LINE('ExpenseID: ' || rec.ExpenseID ||
                             ', Employee: ' || rec.FirstName || ' ' || rec.LastName ||
                             ', Status: ' || rec.CurrentStatus ||
                             ', Amount: $' || rec.Amount ||
                             ', Description: ' || rec.Description ||
                             ', Date: ' || TO_CHAR(rec.ExpenseDate, 'YYYY-MM-DD'));
    END LOOP;

    -- Report 2: Total Expenses by Type
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Total Expenses by Type ---');
    FOR rec IN (SELECT * FROM TotalExpensesByType ORDER BY TotalAmount DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('Expense Type: ' || rec.ExpenseType ||
                             ', Total Amount: $' || rec.TotalAmount);
    END LOOP;

    -- Report 3: Approved Expenses Over Time
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Approved Expenses Over Time ---');
    FOR rec IN (SELECT * FROM ApprovedExpensesOverTime) LOOP
        DBMS_OUTPUT.PUT_LINE('ExpenseID: ' || rec.ExpenseID ||
                             ', Employee: ' || rec.FirstName || ' ' || rec.LastName ||
                             ', Amount: $' || rec.Amount ||
                             ', Approval Date: ' || TO_CHAR(rec.ApprovalDate, 'YYYY-MM-DD'));
    END LOOP;

    -- Summary Report 1: Total and Average Expenses
    SELECT SUM(Amount), AVG(Amount)
    INTO v_TotalExpenses, v_AverageExpenseAmount
    FROM Expense;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Summary: Total and Average Expenses ---');
    DBMS_OUTPUT.PUT_LINE('Total Expenses: $' || v_TotalExpenses);
    DBMS_OUTPUT.PUT_LINE('Average Expense Amount: $' || ROUND(v_AverageExpenseAmount, 2));

    -- Summary Report 2: Total Approved Expenses
    SELECT SUM(e.Amount)
    INTO v_TotalApprovedExpenses
    FROM Expense e
    JOIN Approval a ON e.ExpenseID = a.ExpenseID
    WHERE a.StatusID = (SELECT StatusID FROM ExpenseStatus WHERE StatusName = 'Approved');

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Summary: Total Approved Expenses ---');
    DBMS_OUTPUT.PUT_LINE('Total Approved Expenses: $' || v_TotalApprovedExpenses);

    -- Employees with the highest approved expenses
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Employees with the Highest Approved Expenses ---');
    FOR rec IN (SELECT emp.FirstName || ' ' || emp.LastName AS EmployeeName, SUM(e.Amount) AS TotalApproved
                FROM Expense e
                JOIN Approval a ON e.ExpenseID = a.ExpenseID
                JOIN Employee emp ON e.EmployeeID = emp.EmployeeID
                WHERE a.StatusID = (SELECT StatusID FROM ExpenseStatus WHERE StatusName = 'Approved')
                GROUP BY emp.FirstName, emp.LastName
                ORDER BY TotalApproved DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('Employee: ' || rec.EmployeeName ||
                             ', Total Approved: $' || rec.TotalApproved);
    END LOOP;
END;
/

---------------------------Detailed Pending Approvals-------------------------------
SET SERVEROUTPUT ON;

DECLARE
    -- Cursor for fetching pending approvals
    CURSOR pending_approvals_cursor IS
        SELECT *
        FROM PendingApprovals
        ORDER BY ApprovalDate;

    -- Variables to hold data from the cursor
    v_ApprovalID PendingApprovals.ApprovalID%TYPE;
    v_ExpenseID PendingApprovals.ExpenseID%TYPE;
    v_EmployeeID PendingApprovals.EmployeeID%TYPE;
    v_FirstName PendingApprovals.FirstName%TYPE;
    v_LastName PendingApprovals.LastName%TYPE;
    v_AuditorFirstName PendingApprovals.AuditorFirstName%TYPE;
    v_AuditorLastName PendingApprovals.AuditorLastName%TYPE;
    v_ApprovalDate PendingApprovals.ApprovalDate%TYPE;
    v_Comments PendingApprovals.Comments%TYPE;

    -- Variables for aggregated summary
    v_TotalPendingApprovals NUMBER;
    v_EarliestApprovalDate DATE;
    v_LatestApprovalDate DATE;

BEGIN
    -- Report 1: Detailed Pending Approvals
    DBMS_OUTPUT.PUT_LINE('--- Pending Approvals Report ---');
    OPEN pending_approvals_cursor;
    LOOP
        FETCH pending_approvals_cursor INTO v_ApprovalID, v_ExpenseID, v_EmployeeID, v_FirstName, v_LastName,
                                           v_AuditorFirstName, v_AuditorLastName, v_ApprovalDate, v_Comments;
        EXIT WHEN pending_approvals_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ApprovalID: ' || v_ApprovalID ||
                             ', ExpenseID: ' || v_ExpenseID ||
                             ', Employee: ' || v_FirstName || ' ' || v_LastName ||
                             ', Auditor: ' || v_AuditorFirstName || ' ' || v_AuditorLastName ||
                             ', Approval Date: ' || TO_CHAR(v_ApprovalDate, 'YYYY-MM-DD') ||
                             ', Comments: ' || v_Comments);
    END LOOP;
    CLOSE pending_approvals_cursor;

    -- Summary Report 1: Total Pending Approvals
    SELECT COUNT(*)
    INTO v_TotalPendingApprovals
    FROM PendingApprovals;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Summary: Total Pending Approvals ---');
    DBMS_OUTPUT.PUT_LINE('Total Pending Approvals: ' || v_TotalPendingApprovals);

    -- Summary Report 2: Earliest and Latest Pending Approval Dates
    SELECT MIN(ApprovalDate), MAX(ApprovalDate)
    INTO v_EarliestApprovalDate, v_LatestApprovalDate
    FROM PendingApprovals;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Summary: Approval Dates ---');
    DBMS_OUTPUT.PUT_LINE('Earliest Approval Date: ' || TO_CHAR(v_EarliestApprovalDate, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Latest Approval Date: ' || TO_CHAR(v_LatestApprovalDate, 'YYYY-MM-DD'));

    -- Report 2: Pending Approvals by Auditor
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Pending Approvals Grouped by Auditor ---');
    FOR rec IN (SELECT AuditorFirstName || ' ' || AuditorLastName AS AuditorName,
                       COUNT(*) AS TotalApprovals
                FROM PendingApprovals
                GROUP BY AuditorFirstName, AuditorLastName
                ORDER BY TotalApprovals DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('Auditor: ' || rec.AuditorName ||
                             ', Total Pending Approvals: ' || rec.TotalApprovals);
    END LOOP;
END;
/





----------------------------------Auditlog report----------------------------------------------
CREATE OR REPLACE FUNCTION get_total_logs 
RETURN NUMBER IS
    total_logs NUMBER;
BEGIN
    SELECT COUNT(*) INTO total_logs FROM AuditLog;
    RETURN total_logs;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error retrieving total logs: ' || SQLERRM);
END get_total_logs;
/

CREATE OR REPLACE PROCEDURE detailed_audit_logs IS
    CURSOR audit_log_cursor IS
        SELECT 
            AuditID,
            NVL(AuditorID, -1) AS AuditorID,
            ExpenseID,
            NVL(AdminID, -1) AS AdminID,
            ModifiedBy,
            ModificationDate,
            ActionTaken
        FROM AuditLog
        ORDER BY ModificationDate DESC;

    v_AuditID AuditLog.AuditID%TYPE;
    v_ExpenseID AuditLog.ExpenseID%TYPE;
    v_AdminID AuditLog.AdminID%TYPE;
    v_AuditorID AuditLog.AuditorID%TYPE;
    v_ModifiedBy AuditLog.ModifiedBy%TYPE;
    v_ModificationDate DATE;
    v_ActionTaken AuditLog.ActionTaken%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Detailed Audit Logs ---');
    OPEN audit_log_cursor;
    LOOP
        FETCH audit_log_cursor INTO v_AuditID, v_AuditorID, v_ExpenseID, v_AdminID, v_ModifiedBy, v_ModificationDate, v_ActionTaken;
        EXIT WHEN audit_log_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('AuditID: ' || v_AuditID ||
                             ', AuditorID: ' || CASE WHEN v_AuditorID = -1 THEN 'NULL' ELSE TO_CHAR(v_AuditorID) END ||
                             ', ExpenseID: ' || v_ExpenseID ||
                             ', AdminID: ' || CASE WHEN v_AdminID = -1 THEN 'NULL' ELSE TO_CHAR(v_AdminID) END ||
                             ', ModifiedBy: ' || v_ModifiedBy ||
                             ', ModificationDate: ' || TO_CHAR(v_ModificationDate, 'YYYY-MM-DD HH24:MI:SS') ||
                             ', ActionTaken: ' || v_ActionTaken);
    END LOOP;
    CLOSE audit_log_cursor;
END detailed_audit_logs;
/

CREATE OR REPLACE PROCEDURE logs_grouped_by_admin IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Audit Logs Grouped by Admin ---');
    FOR rec IN (SELECT NVL(AdminID, -1) AS AdminID, COUNT(*) AS TotalLogs
                FROM AuditLog
                GROUP BY AdminID
                ORDER BY TotalLogs DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('AdminID: ' || CASE WHEN rec.AdminID = -1 THEN 'NULL' ELSE TO_CHAR(rec.AdminID) END || ', Total Logs: ' || rec.TotalLogs);
    END LOOP;
END logs_grouped_by_admin;
/

CREATE OR REPLACE PROCEDURE logs_grouped_by_action IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Audit Logs Grouped by Action Taken ---');
    FOR rec IN (SELECT ActionTaken, COUNT(*) AS TotalActions
                FROM AuditLog
                GROUP BY ActionTaken
                ORDER BY TotalActions DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('ActionTaken: ' || rec.ActionTaken || ', Total Occurrences: ' || rec.TotalActions);
    END LOOP;
END logs_grouped_by_action;
/


CREATE OR REPLACE PROCEDURE logs_grouped_by_auditor IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Audit Logs Grouped by Auditor ---');
    FOR rec IN (SELECT NVL(AuditorID, -1) AS AuditorID, COUNT(*) AS TotalLogs
                FROM AuditLog
                GROUP BY AuditorID
                ORDER BY TotalLogs DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('AuditorID: ' || CASE WHEN rec.AuditorID = -1 THEN 'NULL' ELSE TO_CHAR(rec.AuditorID) END || ', Total Logs: ' || rec.TotalLogs);
    END LOOP;
END logs_grouped_by_auditor;
/

CREATE OR REPLACE PROCEDURE oldest_and_newest_logs IS
    oldest_date DATE;
    newest_date DATE;
BEGIN
    SELECT MIN(ModificationDate), MAX(ModificationDate)
    INTO oldest_date, newest_date
    FROM AuditLog;

    DBMS_OUTPUT.PUT_LINE('--- Oldest and Newest Audit Logs ---');
    DBMS_OUTPUT.PUT_LINE('Oldest Log Date: ' || TO_CHAR(oldest_date, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('Newest Log Date: ' || TO_CHAR(newest_date, 'YYYY-MM-DD HH24:MI:SS'));
END oldest_and_newest_logs;
/


CREATE OR REPLACE PROCEDURE detailed_audit_logs IS
    CURSOR audit_log_cursor IS
        SELECT 
            AuditID,
            NVL(AuditorID, -1) AS AuditorID,
            ExpenseID,
            NVL(AdminID, -1) AS AdminID,
            ModifiedBy,
            ModificationDate,
            ActionTaken
        FROM AuditLog
        ORDER BY ModificationDate DESC;

    v_AuditID AuditLog.AuditID%TYPE;
    v_ExpenseID AuditLog.ExpenseID%TYPE;
    v_AdminID AuditLog.AdminID%TYPE;
    v_AuditorID AuditLog.AuditorID%TYPE;
    v_ModifiedBy AuditLog.ModifiedBy%TYPE;
    v_ModificationDate DATE;
    v_ActionTaken AuditLog.ActionTaken%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Detailed Audit Logs ---');
    OPEN audit_log_cursor;
    LOOP
        FETCH audit_log_cursor INTO v_AuditID, v_AuditorID, v_ExpenseID, v_AdminID, v_ModifiedBy, v_ModificationDate, v_ActionTaken;
        EXIT WHEN audit_log_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('AuditID: ' || v_AuditID ||
                             ', AuditorID: ' || CASE WHEN v_AuditorID = -1 THEN 'NULL' ELSE TO_CHAR(v_AuditorID) END ||
                             ', ExpenseID: ' || v_ExpenseID ||
                             ', AdminID: ' || CASE WHEN v_AdminID = -1 THEN 'NULL' ELSE TO_CHAR(v_AdminID) END ||
                             ', ModifiedBy: ' || v_ModifiedBy ||
                             ', ModificationDate: ' || TO_CHAR(v_ModificationDate, 'YYYY-MM-DD HH24:MI:SS') ||
                             ', ActionTaken: ' || v_ActionTaken);
    END LOOP;
    CLOSE audit_log_cursor;
END detailed_audit_logs;
/

BEGIN
    -- Report 1: Detailed Audit Logs
    detailed_audit_logs;

    -- Report 2: Total Audit Logs Count
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Summary: Total Audit Logs ---');
    DBMS_OUTPUT.PUT_LINE('Total Audit Logs: ' || get_total_logs);

    -- Report 3: Logs Grouped by Admin
    DBMS_OUTPUT.PUT_LINE('');
    logs_grouped_by_admin;

    -- Report 4: Logs Grouped by Action Taken
    DBMS_OUTPUT.PUT_LINE('');
    logs_grouped_by_action;

    -- Report 5: Logs Grouped by Auditor
    DBMS_OUTPUT.PUT_LINE('');
    logs_grouped_by_auditor;

    -- Report 6: Oldest and Newest Logs
    DBMS_OUTPUT.PUT_LINE('');
    oldest_and_newest_logs;
END;
/

-----------------------Get Employee specific data------------------------

SET SERVEROUTPUT ON;

DECLARE
    -- Variables for testing the package
    v_TotalAmount NUMBER;
    v_EmployeeEmail VARCHAR2(100);
    v_IsFlagged BOOLEAN;
    v_FlaggedStatus VARCHAR2(10); -- For printing the boolean result as text

    -- Test data
    v_EmployeeID NUMBER := 1; -- Example Employee ID
    v_ExpenseID NUMBER := 2;  -- Example Expense ID
    v_AdminID NUMBER := 1;    -- Example Admin ID
BEGIN
    -- Approve an Expense
    DBMS_OUTPUT.PUT_LINE('--- Approve an Expense ---');
    BEGIN
        ExpenseManagementPkg.ApproveExpense(p_ExpenseID => v_ExpenseID, p_AdminID => v_AdminID);
        DBMS_OUTPUT.PUT_LINE('Expense ' || v_ExpenseID || ' has been successfully approved by Admin ' || v_AdminID);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error approving expense: ' || SQLERRM);
    END;

    -- Calculate Total Expenses for an Employee
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Calculate Total Expenses for an Employee ---');
    ExpenseManagementPkg.CalculateTotalExpenses(p_EmployeeID => v_EmployeeID, o_TotalAmount => v_TotalAmount);
    DBMS_OUTPUT.PUT_LINE('Total expenses for Employee ID ' || v_EmployeeID || ': $' || NVL(v_TotalAmount, 0));

    -- Get the Email of an Employee
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Get Employee Email ---');
    BEGIN
        v_EmployeeEmail := ExpenseManagementPkg.GetEmployeeEmail(p_EmployeeID => v_EmployeeID);
        DBMS_OUTPUT.PUT_LINE('Email for Employee ID ' || v_EmployeeID || ': ' || v_EmployeeEmail);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error retrieving email: ' || SQLERRM);
    END;

    -- Check if an Expense is Flagged
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Check if an Expense is Flagged ---');
    v_IsFlagged := ExpenseManagementPkg.IsExpenseFlagged(p_ExpenseID => v_ExpenseID);
    v_FlaggedStatus := CASE WHEN v_IsFlagged THEN 'Yes' ELSE 'No' END;
    DBMS_OUTPUT.PUT_LINE('Is Expense ID ' || v_ExpenseID || ' flagged? ' || v_FlaggedStatus);

END;
/

------------------------- Analysis Reports ---------------------------
--Top 5 Expenses by Amount
CREATE OR REPLACE FUNCTION get_top_5_expenses RETURN SYS_REFCURSOR AS
    v_cursor SYS_REFCURSOR; -- Declare a cursor to hold the query result
BEGIN
    -- Open the cursor for the top 5 expenses by amount
    OPEN v_cursor FOR
        SELECT ExpenseID, EmployeeID, Amount, Description
        FROM Expense
        ORDER BY Amount DESC
        FETCH FIRST 5 ROWS ONLY;

    -- Return the cursor
    RETURN v_cursor;
END get_top_5_expenses;
/

DECLARE
    v_cursor SYS_REFCURSOR;         -- Cursor to hold the result from the function
    v_expense_id NUMBER;            -- Variable to hold the Expense ID
    v_employee_id NUMBER;           -- Variable to hold the Employee ID
    v_amount NUMBER;                -- Variable to hold the Amount
    v_description VARCHAR2(200);    -- Variable to hold the Description
BEGIN
    -- Call the function to get the top 5 expenses
    v_cursor := get_top_5_expenses;

    -- Display report header
    DBMS_OUTPUT.PUT_LINE('Top 5 Expenses by Amount:');

    -- Fetch and display each record
    LOOP
        FETCH v_cursor INTO v_expense_id, v_employee_id, v_amount, v_description;
        EXIT WHEN v_cursor%NOTFOUND;

        -- Print each expense's details
        DBMS_OUTPUT.PUT_LINE('Expense ID: ' || v_expense_id || 
                             ', Employee ID: ' || v_employee_id || 
                             ', Amount: $' || v_amount || 
                             ', Description: ' || v_description);
    END LOOP;

    -- Close the cursor
    CLOSE v_cursor;
END;
/





--Top 5 Departments by Total Expenses

CREATE OR REPLACE FUNCTION get_top_5_departments_by_expenses RETURN SYS_REFCURSOR AS
    v_cursor SYS_REFCURSOR; -- Declare a cursor to hold the query result
BEGIN
    -- Open the cursor for the top 5 departments by total expenses
    OPEN v_cursor FOR
        SELECT d.DepartmentName, SUM(e.Amount) AS TotalAmount
        FROM Expense e
        JOIN Employee emp ON e.EmployeeID = emp.EmployeeID
        JOIN Department d ON emp.DepartmentID = d.DepartmentID
        GROUP BY d.DepartmentName
        ORDER BY SUM(e.Amount) DESC
        FETCH FIRST 5 ROWS ONLY;

    -- Return the cursor
    RETURN v_cursor;
END get_top_5_departments_by_expenses;
/

DECLARE
    v_cursor SYS_REFCURSOR;         -- Cursor to hold the result from the function
    v_department_name VARCHAR2(100); -- Variable to hold the Department Name
    v_total_amount NUMBER;           -- Variable to hold the Total Expenses
BEGIN
    -- Call the function to get the top 5 departments by total expenses
    v_cursor := get_top_5_departments_by_expenses;

    -- Display report header
    DBMS_OUTPUT.PUT_LINE('Top 5 Departments by Total Expenses:');

    -- Fetch and display each record
    LOOP
        FETCH v_cursor INTO v_department_name, v_total_amount;
        EXIT WHEN v_cursor%NOTFOUND;

        -- Print each department's details
        DBMS_OUTPUT.PUT_LINE('Department: ' || v_department_name || ', Total Expenses: $' || v_total_amount);
    END LOOP;

    -- Close the cursor
    CLOSE v_cursor;
END;
/

--Top 5 Employees by Total Expenses

CREATE OR REPLACE FUNCTION get_top_5_employees_by_expenses RETURN SYS_REFCURSOR AS
    v_cursor SYS_REFCURSOR; -- Declare a cursor to hold the query result
BEGIN
    -- Open the cursor for the top 5 employees by total expenses
    OPEN v_cursor FOR
        SELECT e.EmployeeID, SUM(ex.Amount) AS TotalAmount
        FROM Expense ex
        JOIN Employee e ON ex.EmployeeID = e.EmployeeID
        GROUP BY e.EmployeeID
        ORDER BY SUM(ex.Amount) DESC
        FETCH FIRST 5 ROWS ONLY;

    -- Return the cursor
    RETURN v_cursor;
END get_top_5_employees_by_expenses;
/

DECLARE
    v_cursor SYS_REFCURSOR;         -- Cursor to hold the result from the function
    v_employee_id NUMBER;           -- Variable to hold the Employee ID
    v_total_amount NUMBER;          -- Variable to hold the Total Expenses
BEGIN
    -- Call the function to get the top 5 employees by total expenses
    v_cursor := get_top_5_employees_by_expenses;

    -- Display report header
    DBMS_OUTPUT.PUT_LINE('Top 5 Employees by Total Expenses:');

    -- Fetch and display each record
    LOOP
        FETCH v_cursor INTO v_employee_id, v_total_amount;
        EXIT WHEN v_cursor%NOTFOUND;

        -- Print each employee's details
        DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_employee_id || ', Total Expenses: $' || v_total_amount);
    END LOOP;

    -- Close the cursor
    CLOSE v_cursor;
END;
/




--Top 5 Approved Expenses

CREATE OR REPLACE FUNCTION get_top_5_approved_expenses RETURN SYS_REFCURSOR AS
    v_cursor SYS_REFCURSOR; -- Declare a cursor to hold the query result
BEGIN
    -- Open the cursor for the top 5 approved expenses
    OPEN v_cursor FOR
        SELECT ExpenseID, EmployeeID, Amount, Description
        FROM Expense
        WHERE StatusID = 2 -- Approved
        ORDER BY Amount DESC
        FETCH FIRST 5 ROWS ONLY;

    -- Return the cursor
    RETURN v_cursor;
END get_top_5_approved_expenses;
/

DECLARE
    v_cursor SYS_REFCURSOR;         -- Cursor to hold the result from the function
    v_expense_id NUMBER;            -- Variable to hold the Expense ID
    v_amount NUMBER;                -- Variable to hold the Amount
    v_employee_id NUMBER;           -- Variable to hold the Employee ID
    v_description VARCHAR2(200);    -- Variable to hold the Description
BEGIN
    -- Call the function to get the top 5 approved expenses
    v_cursor := get_top_5_approved_expenses;

    -- Display report header
    DBMS_OUTPUT.PUT_LINE('Top 5 Approved Expenses:');

    -- Fetch and display each record
    LOOP
        FETCH v_cursor INTO v_expense_id, v_employee_id, v_amount, v_description;
        EXIT WHEN v_cursor%NOTFOUND;

        -- Print each expense's details
        DBMS_OUTPUT.PUT_LINE('Expense ID: ' || v_expense_id || 
                             ', Employee ID: ' || v_employee_id || 
                             ', Amount: $' || v_amount || 
                             ', Description: ' || v_description);
    END LOOP;

    -- Close the cursor
    CLOSE v_cursor;
END;
/

--Top 5 Pending Expenses by Amount

CREATE OR REPLACE FUNCTION get_top_5_pending_expenses RETURN SYS_REFCURSOR AS
    v_cursor SYS_REFCURSOR; -- Declare a cursor to hold the query result
BEGIN
    -- Open the cursor for the top 5 pending expenses by amount
    OPEN v_cursor FOR
        SELECT ExpenseID, EmployeeID, Amount, Description
        FROM Expense
        WHERE StatusID = 1 -- Pending status
        ORDER BY Amount DESC
        FETCH FIRST 5 ROWS ONLY;

    -- Return the cursor
    RETURN v_cursor;
END get_top_5_pending_expenses;
/

DECLARE
    v_cursor SYS_REFCURSOR;         -- Cursor to hold the result from the function
    v_expense_id NUMBER;            -- Variable to hold the Expense ID
    v_employee_id NUMBER;           -- Variable to hold the Employee ID
    v_amount NUMBER;                -- Variable to hold the Amount
    v_description VARCHAR2(200);    -- Variable to hold the Description
BEGIN
    -- Call the function to get the top 5 pending expenses by amount
    v_cursor := get_top_5_pending_expenses;

    -- Display report header
    DBMS_OUTPUT.PUT_LINE('Top 5 Pending Expenses by Amount:');

    -- Fetch and display each record
    LOOP
        FETCH v_cursor INTO v_expense_id, v_employee_id, v_amount, v_description;
        EXIT WHEN v_cursor%NOTFOUND; -- Exit loop when all rows are processed

        -- Print each expense's details
        DBMS_OUTPUT.PUT_LINE('Expense ID: ' || v_expense_id || 
                             ', Employee ID: ' || v_employee_id || 
                             ', Amount: $' || v_amount || 
                             ', Description: ' || v_description);
    END LOOP;

    -- Close the cursor
    CLOSE v_cursor;
END;
/

