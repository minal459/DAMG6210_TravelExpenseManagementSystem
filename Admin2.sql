
DECLARE
    table_not_exist EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_not_exist, -942); -- Error code for "table or view does not exist"
BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON Administrator TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON Approval TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON AuditLog TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON Department TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON Employee TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON Expense TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON ExpenseStatus TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON ExpenseType TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON FinancialAuditor TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON Notifications TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON Payment TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'GRANT INSERT, SELECT, UPDATE, DELETE ON Reimbursement TO TravelUser';
    EXCEPTION
        WHEN table_not_exist THEN
            NULL;
    END;
END;


