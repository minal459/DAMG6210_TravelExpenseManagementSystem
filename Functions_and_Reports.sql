
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


