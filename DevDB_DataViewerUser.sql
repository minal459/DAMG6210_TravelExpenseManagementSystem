SELECT * FROM TravelUser.Expense;

CREATE TABLE unauthorized_table (
    id NUMBER PRIMARY KEY
);

SELECT * FROM TravelUser.Expense;

UPDATE TravelUser.Restricted_Expense
SET AMOUNT = 500
WHERE EMPLOYEEID = 1 AND EXPENSETYPEID = 1;
COMMIT;





