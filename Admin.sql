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

