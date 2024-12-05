SELECT * FROM Expense;

----1. Successful Test Case:Submitted a new record  
BEGIN
    pkg_travel_expense.proc_admin_travel_expense_management(
        p_EmployeeID => 1,
        p_ExpenseTypeID => 1,
        p_AdminID => 2,
        p_Amount => 600,
        p_ExpenseDate => TO_DATE('2024-05-01', 'YYYY-MM-DD'),
        p_Description => 'Client Meeting',
        p_StatusID => 1,
        p_Comments => 'Approved'
    );
END;
/

SELECT * FROM Expense;


----2.Invalid Expense Date
BEGIN
    pkg_travel_expense.proc_admin_travel_expense_management(
        p_EmployeeID => 1,
        p_ExpenseTypeID => 1,
        p_AdminID => 2,
        p_Amount => 500,
        p_ExpenseDate => TO_DATE('2025-05-01', 'YYYY-MM-DD'), -- Future date
        p_Description => 'Invalid Date Test',
        p_StatusID => 2,
        p_Comments => 'Invalid Date'
    );
END;
/


----3. Invalid amount (exceeds limit)
BEGIN
    pkg_travel_expense.proc_admin_travel_expense_management(
        p_EmployeeID => 6,
        p_ExpenseTypeID => 1,
        p_AdminID => 3,
        p_Amount => 9090, -- Invalid amount exceeding limit
        p_ExpenseDate => TO_DATE('2024-03-20', 'YYYY-MM-DD'),
        p_Description => 'Invalid Amount Test',
        p_StatusID => 1,
        p_Comments => 'Amount exceeds limit'
    );
END;
/

----Test Case 4: Self-Approval
BEGIN
    pkg_travel_expense.proc_admin_travel_expense_management(
        p_EmployeeID   => 1,
        p_ExpenseTypeID => 1,
        p_AdminID       => 1, -- AdminID equals EmployeeID
        p_Amount        => 1000,
        p_ExpenseDate   => TO_DATE('2024-06-01', 'YYYY-MM-DD'),
        p_Description   => 'Self-Approval Test',
        p_StatusID      => 1,
        p_Comments      => 'Testing self-approval logic'
    );
END;
/

---4. Non-existent EmployeeID
BEGIN
    pkg_travel_expense.proc_admin_travel_expense_management(
        p_EmployeeID => 999, -- Non-existent EmployeeID
        p_ExpenseTypeID => 2,
        p_AdminID => 1,
        p_Amount => 400,
        p_ExpenseDate => TO_DATE('2024-03-15', 'YYYY-MM-DD'),
        p_Description => 'Invalid Employee Test',
        p_StatusID => 1,
        p_Comments => 'Non-existent EmployeeID'
    );
END;
/


---5.Expense Date in the Future
BEGIN
    pkg_travel_expense.proc_admin_travel_expense_management(
        p_EmployeeID => 1,
        p_ExpenseTypeID => 1,
        p_AdminID => 2,
        p_Amount => 500,
        p_ExpenseDate => SYSDATE + 5, -- Future date
        p_Description => 'Future Date Test',
        p_StatusID => 1,
        p_Comments => 'Testing with future date'
    );
END;
/

---6.High-Value Expense Without Audit Log
BEGIN
    pkg_travel_expense.proc_admin_travel_expense_management(
        p_EmployeeID => 1,
        p_ExpenseTypeID => 1,
        p_AdminID => 2,
        p_Amount => 2000, -- High-value amount
        p_ExpenseDate => SYSDATE - 1,
        p_Description => 'High-Value Expense Test',
        p_StatusID => 1,
        p_Comments => 'Testing high-value expense logging'
    );
END;
/



