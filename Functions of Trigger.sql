--1.
CREATE OR REPLACE FUNCTION func_expense_update (
    p_OldExpenseID IN NUMBER,
    p_NewAmount IN NUMBER,
    p_NewStatusID IN NUMBER
) RETURN VARCHAR2
IS
    v_OldAmount NUMBER;
    v_OldStatusID NUMBER;
    v_Message VARCHAR2(100);
BEGIN
    -- Fetch the current Amount and StatusID for the ExpenseID
    SELECT Amount, StatusID
    INTO v_OldAmount, v_OldStatusID
    FROM Expense
    WHERE ExpenseID = p_OldExpenseID;

    -- Check if Amount was updated
    IF v_OldAmount != p_NewAmount THEN
        UPDATE AuditLog
        SET ModificationDate = SYSDATE,
            ModifiedBy = 'System',
            ActionTaken = 'Amount Updated'
        WHERE ExpenseID = p_OldExpenseID;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No matching row exists in AuditLog for ExpenseID ' || p_OldExpenseID);
        END IF;

        v_Message := 'Amount Updated';
    -- Check if StatusID was updated
    ELSIF v_OldStatusID != p_NewStatusID THEN
        UPDATE AuditLog
        SET ModificationDate = SYSDATE,
            ModifiedBy = 'System',
            ActionTaken = 'Status Updated'
        WHERE ExpenseID = p_OldExpenseID;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No matching row exists in AuditLog for ExpenseID ' || p_OldExpenseID);
        END IF;

        v_Message := 'Status Updated';
    ELSE
        v_Message := 'No changes to update.';
    END IF;

    RETURN v_Message;
END;
/



--2.---
CREATE OR REPLACE FUNCTION func_status_change (
    p_ExpenseID IN NUMBER,
    p_NewStatusID IN NUMBER
) RETURN VARCHAR2
IS
BEGIN
    UPDATE AuditLog
    SET ModifiedBy = 'System',
        ModificationDate = SYSDATE,
        ActionTaken = 'Status Changed'
    WHERE ExpenseID = p_ExpenseID;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'No matching row exists in AuditLog for ExpenseID ' || p_ExpenseID);
    END IF;

    RETURN 'Status Changed Successfully';
END;
/

--3.
CREATE OR REPLACE FUNCTION func_validate_expense_date (
    p_ExpenseDate IN DATE
) RETURN VARCHAR2
IS
BEGIN
    IF p_ExpenseDate > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'ExpenseDate cannot be in the future.');
    END IF;

    RETURN 'Expense Date Validated';
END;
/


--4.
CREATE OR REPLACE FUNCTION func_validate_reimbursement_amount (
    p_ExpenseID IN NUMBER,
    p_Amount IN NUMBER
) RETURN VARCHAR2
IS
    v_ExpenseAmount NUMBER;
BEGIN
    SELECT Amount INTO v_ExpenseAmount FROM Expense WHERE ExpenseID = p_ExpenseID;

    IF p_Amount > v_ExpenseAmount THEN
        RAISE_APPLICATION_ERROR(-20002, 'Reimbursement amount cannot exceed the original expense amount.');
    END IF;

    RETURN 'Reimbursement Amount Validated';
END;
/


--5.
CREATE OR REPLACE FUNCTION func_flag_high_value_expense (
    p_ExpenseID IN NUMBER,
    p_Amount IN NUMBER
) RETURN VARCHAR2
IS
BEGIN
    IF p_Amount > 2500 THEN
        INSERT INTO AuditLog (
            ExpenseID, ModifiedBy, ModificationDate, ActionTaken
        ) VALUES (
            p_ExpenseID, 'System', SYSDATE, 'High-value expense flagged for review'
        );
    END IF;

    RETURN 'High-Value Expense Flagged';
END;
/

--6.
CREATE OR REPLACE FUNCTION func_handle_department_delete (
    p_DepartmentID IN NUMBER
) RETURN VARCHAR2
IS
BEGIN
    UPDATE Employee
    SET DepartmentID = NULL
    WHERE DepartmentID = p_DepartmentID;

    RETURN 'Department Employees Updated';
END;
/

--7.
CREATE OR REPLACE FUNCTION func_validate_self_approval (
    p_ExpenseID IN NUMBER,
    p_AdminID IN NUMBER
) RETURN VARCHAR2
IS
    v_EmployeeID NUMBER;
BEGIN
    SELECT EmployeeID INTO v_EmployeeID FROM Expense WHERE ExpenseID = p_ExpenseID;

    IF p_AdminID = v_EmployeeID THEN
        RAISE_APPLICATION_ERROR(-20003, 'Employees cannot approve their own expenses.');
    END IF;

    RETURN 'Approval Validated';
END;
/

--8.
CREATE OR REPLACE FUNCTION func_validate_unique_expense_type (
    p_TypeName IN VARCHAR2,
    p_ExpenseTypeID IN NUMBER
) RETURN VARCHAR2
IS
    v_Count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_Count
    FROM ExpenseType
    WHERE TypeName = p_TypeName
      AND ExpenseTypeID != NVL(p_ExpenseTypeID, -1);

    IF v_Count > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Expense type must be unique.');
    END IF;

    RETURN 'Unique Expense Type Validated';
END;
/
--9.
CREATE OR REPLACE FUNCTION FUNC_PREVENT_SELF_APPROVAL (
    p_AdminID IN NUMBER,
    p_ExpenseID IN NUMBER
)
RETURN VARCHAR2
IS
    v_EmployeeID NUMBER;
BEGIN
    -- Fetch the EmployeeID for the given ExpenseID
    SELECT EmployeeID INTO v_EmployeeID
    FROM Expense
    WHERE ExpenseID = p_ExpenseID;

    -- Check if the AdminID matches the EmployeeID
    IF p_AdminID = v_EmployeeID THEN
        RETURN 'Error: Admin cannot approve their own expense.';
    ELSE
        RETURN 'Self-approval validation passed.';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Error: Invalid ExpenseID.';
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
/

--10.
CREATE OR REPLACE FUNCTION FUNC_LOG_REIMBURSEMENT_PROCESSING (
    p_ReimbursementID IN NUMBER
)
RETURN VARCHAR2
IS
    v_ExpenseID NUMBER;
BEGIN
    -- Fetch the ExpenseID for the given ReimbursementID
    SELECT ExpenseID INTO v_ExpenseID
    FROM Reimbursement
    WHERE ReimbursementID = p_ReimbursementID;

    -- Insert a log into the AuditLog table
    INSERT INTO AuditLog (ExpenseID, ModifiedBy, ModificationDate, ActionTaken)
    VALUES (v_ExpenseID, 'System', SYSDATE, 'Reimbursement processed');

    RETURN 'Reimbursement processing logged successfully.';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Error: Invalid ReimbursementID.';
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
/