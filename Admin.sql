BEGIN
    -- Drop the user if it exists to avoid conflict
    EXECUTE IMMEDIATE 'DROP USER TravelUser CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Ignore errors if the user does not exist
END;
/

-- Now, create the user
BEGIN
    EXECUTE IMMEDIATE 'CREATE USER TravelUser IDENTIFIED BY NeuBoston2024#';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating user TravelUser');
END;
/

ALTER USER TravelUser DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

ALTER USER TravelUser TEMPORARY TABLESPACE TEMP;

GRANT CONNECT, RESOURCE TO TravelUser;

ALTER SESSION SET CURRENT_SCHEMA = TravelUser;

GRANT CREATE SESSION, CREATE VIEW, CREATE TABLE, ALTER SESSION, CREATE SEQUENCE TO TravelUser;
GRANT CREATE SYNONYM, CREATE DATABASE LINK, RESOURCE, UNLIMITED TABLESPACE TO TravelUser;

GRANT CREATE TABLE TO TravelUser;


GRANT CREATE ANY CONTEXT TO TravelUser;
GRANT EXECUTE ON DBMS_SESSION TO TravelUser;

GRANT EXECUTE ON DBMS_RLS TO TravelUser;





-- Script for DataViewerUser
BEGIN
    -- Drop the user if it exists to avoid conflict
    EXECUTE IMMEDIATE 'DROP USER DataViewerUser CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Ignore errors if the user does not exist
END;
/ 

-- Create DataViewerUser
BEGIN
    EXECUTE IMMEDIATE 'CREATE USER DataViewerUser IDENTIFIED BY ViewOnly2024#';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating user DataViewerUser');
END;
/ 

ALTER USER DataViewerUser DEFAULT TABLESPACE users QUOTA 0 ON users;

ALTER USER DataViewerUser TEMPORARY TABLESPACE TEMP;

-- Grant necessary privileges to DataViewerUser
GRANT CREATE SESSION TO DataViewerUser;
GRANT SELECT ANY TABLE TO DataViewerUser;

-- Optionally, grant SELECT privileges for specific schemas or tables
-- Example: GRANT SELECT ON schema_name.table_name TO DataViewerUser;

GRANT SELECT, UPDATE (AMOUNT, EXPENSETYPEID, EXPENSEDATE, DESCRIPTION) ON TravelUser.Restricted_Expense TO DataViewerUser;

