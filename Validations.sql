CREATE OR REPLACE PACKAGE pkg_travel_expense IS
    -- Procedure to manage travel expense
    PROCEDURE proc_admin_travel_expense_management (
        p_EmployeeID IN NUMBER,
        p_ExpenseTypeID IN NUMBER,
        p_AdminID IN NUMBER,
        p_Amount IN NUMBER,
        p_ExpenseDate IN DATE,
        p_Description IN VARCHAR2,
        p_StatusID IN NUMBER,
        p_Comments IN VARCHAR2
    );

    -- Utility Functions
    FUNCTION func_validate_expense_date(p_ExpenseDate DATE) RETURN VARCHAR2;
    FUNCTION func_flag_high_value_expense(p_Amount NUMBER) RETURN VARCHAR2;
    FUNCTION func_expense_update(
        p_ExpenseID NUMBER,
        p_Amount NUMBER,
        p_StatusID NUMBER
    ) RETURN VARCHAR2;
END pkg_travel_expense;
/
CREATE OR REPLACE PACKAGE BODY pkg_travel_expense IS

    -- Procedure to manage travel expenses
    PROCEDURE proc_admin_travel_expense_management (
        p_EmployeeID IN NUMBER,
        p_ExpenseTypeID IN NUMBER,
        p_AdminID IN NUMBER,
        p_Amount IN NUMBER,
        p_ExpenseDate IN DATE,
        p_Description IN VARCHAR2,
        p_StatusID IN NUMBER,
        p_Comments IN VARCHAR2
    )
    IS
        v_ExpenseID NUMBER;
        v_Result VARCHAR2(100);
        v_ExistingExpenseID NUMBER;
        v_ApprovalID NUMBER;
        v_AuditorID NUMBER;
        v_EmployeeExists NUMBER; -- To validate Employee ID
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Starting transaction...');
        SAVEPOINT before_transaction;

        -- Step 0: Validate Employee ID
        DBMS_OUTPUT.PUT_LINE('Validating Employee ID...');
        SELECT COUNT(*) INTO v_EmployeeExists FROM Employee WHERE EmployeeID = p_EmployeeID;
        IF v_EmployeeExists = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Error: Employee ID not found.');
            ROLLBACK TO before_transaction;
            RAISE_APPLICATION_ERROR(-20005, 'Employee ID not found.');
        END IF;

        -- Step 0.5: Validate Amount
        DBMS_OUTPUT.PUT_LINE('Validating Amount...');
        IF p_Amount <= 0 OR p_Amount > 5000 THEN
            DBMS_OUTPUT.PUT_LINE('Error: Invalid amount entered.');
            ROLLBACK TO before_transaction;
            RAISE_APPLICATION_ERROR(-20006, 'Invalid amount. Amount must be greater than 0 and less than or equal to 5000.');
        END IF;

        -- Step 1: Check if expense already exists
        DBMS_OUTPUT.PUT_LINE('Checking for existing expenses...');
        BEGIN
            SELECT ExpenseID INTO v_ExistingExpenseID
            FROM Expense
            WHERE EmployeeID = p_EmployeeID AND Amount = p_Amount AND ExpenseDate = p_ExpenseDate;

            -- If expense exists, update it
            DBMS_OUTPUT.PUT_LINE('Existing expense found with ID: ' || v_ExistingExpenseID);
            v_Result := func_expense_update(v_ExistingExpenseID, p_Amount, p_StatusID);

            IF v_Result != 'Expense Updated Successfully' THEN
                RAISE_APPLICATION_ERROR(-20014, 'Expense update validation failed.');
            END IF;

            DBMS_OUTPUT.PUT_LINE('Expense updated: ' || v_Result);
            ROLLBACK TO before_transaction; -- Rollback instead of committing
            RETURN;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('No existing expense found. Proceeding to add new expense...');
        END;

        -- Step 2: Validate Expense Date
        DBMS_OUTPUT.PUT_LINE('Validating expense date...');
        v_Result := func_validate_expense_date(p_ExpenseDate);
        IF v_Result != 'Valid Date' THEN
            DBMS_OUTPUT.PUT_LINE('Validation failed: ' || v_Result);
            ROLLBACK TO before_transaction;
            RAISE_APPLICATION_ERROR(-20004, 'Invalid expense date: ' || v_Result);
        END IF;

        -- Step 3: Add new expense
        DBMS_OUTPUT.PUT_LINE('Adding a new expense...');
        -- Use a temporary variable or control for sequential ExpenseID generation
        SELECT NVL(MAX(ExpenseID), 0) + 1 INTO v_ExpenseID FROM Expense WHERE ROWNUM = 1;

        DBMS_OUTPUT.PUT_LINE('Generated ExpenseID: ' || v_ExpenseID);

        INSERT INTO Expense (
            ExpenseID, EmployeeID, ExpenseTypeID, AdminID, Amount, ExpenseDate, Description, StatusID
        )
        VALUES (
            v_ExpenseID, p_EmployeeID, p_ExpenseTypeID, p_AdminID, p_Amount, p_ExpenseDate, p_Description, 1
        );

        -- Log Audit Entry
        DBMS_OUTPUT.PUT_LINE('Logging audit entry...');
        INSERT INTO AuditLog (
            AuditID, AuditorID, ExpenseID, AdminID, ModifiedBy, ModificationDate, ActionTaken
        )
        VALUES (
            (SELECT NVL(MAX(AuditID), 0) + 1 FROM AuditLog),
            NULL,
            v_ExpenseID,
            p_AdminID,
            'Admin',
            SYSDATE,
            'Expense Created'
        );

        -- Step 4: Check for high-value expenses
        DBMS_OUTPUT.PUT_LINE('Checking for high-value expenses...');
        v_Result := func_flag_high_value_expense(p_Amount);
        DBMS_OUTPUT.PUT_LINE('High-value expense check result: ' || v_Result);

        -- Step 5: Handle approval/rejection
        DBMS_OUTPUT.PUT_LINE('Handling approval or rejection...');
        BEGIN
            -- Validate self-approval
            IF p_AdminID = p_EmployeeID THEN
                DBMS_OUTPUT.PUT_LINE('Error: Self-approval detected. AdminID cannot equal EmployeeID.');
                ROLLBACK TO before_transaction; -- Rollback to savepoint
                RAISE_APPLICATION_ERROR(-20003, 'Employees cannot approve their own expenses.');
            END IF;

            -- Generate Approval ID
            SELECT NVL(MAX(ApprovalID), 0) + 1 INTO v_ApprovalID FROM Approval;

            -- Assign AuditorID dynamically
            SELECT AuditorID INTO v_AuditorID
            FROM (
                SELECT AuditorID, ROWNUM AS RANK
                FROM FinancialAuditor
                ORDER BY AuditorID
            )
            WHERE RANK = MOD(v_ApprovalID, (SELECT COUNT(*) FROM FinancialAuditor)) + 1;

            -- Insert Approval Record
            INSERT INTO Approval (
                ApprovalID, ExpenseID, AuditorID, AdminID, StatusID, ApprovalDate, Comments
            )
            VALUES (
                v_ApprovalID, v_ExpenseID, v_AuditorID, p_AdminID, p_StatusID, SYSDATE, p_Comments
            );

            DBMS_OUTPUT.PUT_LINE('Approval processed successfully.');
            ROLLBACK TO before_transaction; -- Rollback instead of committing
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error during approval process: ' || SQLERRM);
                ROLLBACK TO before_transaction;
                RAISE;
        END;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
            ROLLBACK TO before_transaction; -- Ensure rollback on errors
            RAISE;
    END;

    -- Function to validate expense date
    FUNCTION func_validate_expense_date(p_ExpenseDate DATE) RETURN VARCHAR2 IS
    BEGIN
        IF p_ExpenseDate > SYSDATE THEN
            RETURN 'Date cannot be in the future';
        ELSE
            RETURN 'Valid Date';
        END IF;
    END func_validate_expense_date;

    -- Function to flag high-value expenses
   FUNCTION func_flag_high_value_expense(p_Amount NUMBER) RETURN VARCHAR2 IS
BEGIN
    IF p_Amount > 1000 THEN
        DBMS_OUTPUT.PUT_LINE('High-value expense detected: Amount = ' || p_Amount);

        -- Log the high-value expense in the AuditLog table
        INSERT INTO AuditLog (AuditID, ExpenseID, ModifiedBy, ModificationDate, ActionTaken)
        VALUES (
            (SELECT NVL(MAX(AuditID), 0) + 1 FROM AuditLog), -- Generate AuditID
            (SELECT NVL(MAX(ExpenseID), 0) FROM Expense),   -- Fetch the current ExpenseID
            'System',                                       -- Modified by System
            SYSDATE,                                        -- Current date
            'High-value expense flagged for review'         -- Action description
        );

        -- Return a specific message
        RETURN 'High-value expense flagged and logged for review.';
    ELSE
        -- Return normal expense message
        RETURN 'Normal expense.';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        -- Raise an application error if logging fails
        RAISE_APPLICATION_ERROR(-20010, 'Error flagging high-value expense: ' || SQLERRM);
END func_flag_high_value_expense;



    -- Function to update expenses
    FUNCTION func_expense_update(
        p_ExpenseID NUMBER,
        p_Amount NUMBER,
        p_StatusID NUMBER
    ) RETURN VARCHAR2 IS
    BEGIN
        UPDATE Expense
        SET Amount = p_Amount, StatusID = p_StatusID
        WHERE ExpenseID = p_ExpenseID;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20012, 'Expense update failed. No rows affected.');
        END IF;

        RETURN 'Expense Updated Successfully';
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error during expense update: ' || SQLERRM;
    END func_expense_update;

END pkg_travel_expense;
/

