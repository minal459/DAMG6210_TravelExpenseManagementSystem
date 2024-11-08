-------------------Insert--------------------------
INSERT INTO Department (DepartmentID, DepartmentName, Location) VALUES 
    (1, 'Finance', 'New York'),
    (2, 'IT', 'San Francisco'),
    (3, 'HR', 'Chicago'),
    (4, 'Marketing', 'Boston'),
    (5, 'Operations', 'Austin'),
    (6, 'Sales', 'Seattle'),
    (7, 'Customer Support', 'Orlando'),
    (8, 'Legal', 'Washington'),
    (9, 'RD', 'San Jose'),
    (10, 'Logistics', 'Dallas');



INSERT INTO Employee (EmployeeID, FirstName, LastName, DepartmentID, Email, Phone) VALUES 
(1, 'John', 'Doe', 1, 'john.doe@example.com', '1234567890'),
(2, 'Jane', 'Smith', 2, 'jane.smith@example.com', '0987654321'),
(3, 'Alice', 'Brown', 3, 'alice.brown@example.com', '1112223333'),
(4, 'Bob', 'White', 4, 'bob.white@example.com', '2223334444'),
(5, 'Carol', 'Black', 5, 'carol.black@example.com', '3334445555'),
(6, 'David', 'Green', 6, 'david.green@example.com', '4445556666'),
(7, 'Eve', 'Blue', 7, 'eve.blue@example.com', '5556667777'),
(8, 'Frank', 'Yellow', 8, 'frank.yellow@example.com', '6667778888'),
(9, 'Grace', 'Pink', 9, 'grace.pink@example.com', '7778889999'),
(10, 'Hank', 'Gray', 10, 'hank.gray@example.com', '8889990000');



INSERT INTO FinancialAuditor (AuditorID, FirstName, LastName, Email, Phone) VALUES 
(1, 'Lily', 'Evans', 'lily.evans@example.com', '1112223333'),
(2, 'James', 'Potter', 'james.potter@example.com', '2223334444'),
(3, 'Albus', 'Dumbledore', 'albus.d@example.com', '3334445555'),
(4, 'Minerva', 'McGonagall', 'minerva.m@example.com', '4445556666'),
(5, 'Severus', 'Snape', 'severus.s@example.com', '5556667777'),
(6, 'Sirius', 'Black', 'sirius.b@example.com', '6667778888'),
(7, 'Remus', 'Lupin', 'remus.l@example.com', '7778889999'),
(8, 'Horace', 'Slughorn', 'horace.s@example.com', '8889990000'),
(9, 'Gilderoy', 'Lockhart', 'gilderoy.l@example.com', '9990001111'),
(10, 'Rubeus', 'Hagrid', 'rubeus.h@example.com', '0001112222');




-- Insert valid status types into ExpenseStatus
INSERT INTO ExpenseStatus (StatusID, StatusName) VALUES (1, 'Pending');
INSERT INTO ExpenseStatus (StatusID, StatusName) VALUES (2, 'Approved');
INSERT INTO ExpenseStatus (StatusID, StatusName) VALUES (3, 'Rejected');



-- Insert valid expense types into ExpenseType
INSERT INTO ExpenseType (ExpenseTypeID, TypeName) VALUES (1, 'Meals');
INSERT INTO ExpenseType (ExpenseTypeID, TypeName) VALUES (2, 'Travel');
INSERT INTO ExpenseType (ExpenseTypeID, TypeName) VALUES (3, 'Accommodation');




INSERT INTO Administrator (AdminID, AdminName, Role, Email) VALUES 
(1, 'Admin1', 'Admin', 'admin1@example.com'),
(2, 'Admin2', 'Viewer', 'admin2@example.com'),
(3, 'Admin3', 'Deleter', 'admin3@example.com'),
(4, 'Admin4', 'Admin', 'admin4@example.com'),
(5, 'Admin5', 'Viewer', 'admin5@example.com'),
(6, 'Admin6', 'Deleter', 'admin6@example.com'),
(7, 'Admin7', 'Admin', 'admin7@example.com'),
(8, 'Admin8', 'Viewer', 'admin8@example.com'),
(9, 'Admin9', 'Deleter', 'admin9@example.com'),
(10, 'Admin10', 'Admin', 'admin10@example.com');

INSERT INTO Expense (ExpenseID, EmployeeID, ExpenseTypeID, AdminID, Amount, ExpenseDate, Description, StatusID) VALUES 
(1, 1, 1, 1, 150.00, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Lunch meeting with client', 1),
(2, 2, 2, 2, 2500.00, TO_DATE('2024-02-10', 'YYYY-MM-DD'), 'Flight for conference', 2),
(3, 3, 3, 1, 500.00, TO_DATE('2024-02-15', 'YYYY-MM-DD'), 'Hotel stay for training', 3),
(4, 4, 1, 2, 75.00, TO_DATE('2024-03-05', 'YYYY-MM-DD'), 'Team dinner', 1),
(5, 5, 2, 1, 300.00, TO_DATE('2024-03-20', 'YYYY-MM-DD'), 'Tickets for client event', 2),
(6, 6, 2, 1, 1200.00, TO_DATE('2024-04-02', 'YYYY-MM-DD'), 'Travel for on-site meeting', 3),
(7, 7, 1, 2, 90.00, TO_DATE('2024-04-12', 'YYYY-MM-DD'), 'Working lunch with partner', 1),
(8, 8, 3, 1, 600.00, TO_DATE('2024-04-22', 'YYYY-MM-DD'), 'Accommodation for training', 2),
(9, 9, 2, 2, 2750.00, TO_DATE('2024-05-05', 'YYYY-MM-DD'), 'International flight',3),
(10, 10, 1, 1, 200.00, TO_DATE('2024-05-15', 'YYYY-MM-DD'), 'Client entertainment', 1);



INSERT INTO Approval (ApprovalID, ExpenseID, AuditorID, AdminID, StatusID, ApprovalDate, Comments) VALUES 
(1, 1, 1, 1, 2, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Approved by Auditor'),
(2, 2, 2, 2, 2, TO_DATE('2024-02-11', 'YYYY-MM-DD'), 'Approved by Auditor'),
(3, 3, 3, 1, 3, TO_DATE('2024-02-16', 'YYYY-MM-DD'), 'Rejected due to policy'),
(4, 4, 4, 2, 1, TO_DATE('2024-03-06', 'YYYY-MM-DD'), 'Pending for more details'),
(5, 5, 5, 1, 1, TO_DATE('2024-03-21', 'YYYY-MM-DD'), 'Pending for more details'),
(6, 6, 6, 1, 3, TO_DATE('2024-04-03', 'YYYY-MM-DD'), 'Rejected due to policy'),
(7, 7, 7, 2, 2, TO_DATE('2024-04-13', 'YYYY-MM-DD'), 'Approved by Auditor'),
(8, 8, 8, 1, 1, TO_DATE('2024-04-23', 'YYYY-MM-DD'), 'Pending for more details'),
(9, 9, 9, 2, 2, TO_DATE('2024-05-06', 'YYYY-MM-DD'), 'Approved by Auditor'),
(10, 10, 10, 1, 1, TO_DATE('2024-05-16', 'YYYY-MM-DD'), 'Pending for more details');




INSERT INTO AuditLog (AuditID, AuditorID, ExpenseID, AdminID, ModifiedBy, ModificationDate, ActionTaken) VALUES
    (1, 1, 1, 1, 'Admin1', TO_DATE('2024-01-01', 'YYYY-MM-DD'), 'Created Expense'),
    (2, 2, 2, 2, 'Admin2', TO_DATE('2024-01-02', 'YYYY-MM-DD'), 'Approved Expense'),
    (3, 3, 3, 3, 'Admin3', TO_DATE('2024-01-03', 'YYYY-MM-DD'), 'Rejected Expense'),
    (4, 4, 4, 4, 'Admin4', TO_DATE('2024-01-04', 'YYYY-MM-DD'), 'Modified Expense Details'),
    (5, 5, 5, 5, 'Admin5', TO_DATE('2024-01-05', 'YYYY-MM-DD'), 'Processed Payment'),
    (6, 6, 6, 6, 'Admin6', TO_DATE('2024-01-06', 'YYYY-MM-DD'), 'Submitted Reimbursement'),
    (7, 7, 7, 7, 'Admin7', TO_DATE('2024-01-07', 'YYYY-MM-DD'), 'Manager Approval Pending'),
    (8, 8, 8, 8, 'Admin8', TO_DATE('2024-01-08', 'YYYY-MM-DD'), 'Cancelled Expense'),
    (9, 9, 9, 9, 'Admin9', TO_DATE('2024-01-09', 'YYYY-MM-DD'), 'Under Review'),
    (10, 10, 10, 10, 'Admin10', TO_DATE('2024-01-10', 'YYYY-MM-DD'), 'Deferred Expense');
    



-- Insert sample data into Notifications table
INSERT INTO Notifications (NotificationID, EmployeeID, AdminID, Message, NotificationDate, IsRead, AuditID) VALUES 
(1, 1, 1, 'Expense approval required', TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'N', 1),
(2, 2, 1, 'Expense processed successfully', TO_DATE('2024-02-11', 'YYYY-MM-DD'), 'Y', 2),
(3, 3, 2, 'More details required for expense', TO_DATE('2024-02-16', 'YYYY-MM-DD'), 'N', 3),
(4, 4, 2, 'Audit has been completed', TO_DATE('2024-03-06', 'YYYY-MM-DD'), 'Y', 4),
(5, 5, 3, 'Payment processed', TO_DATE('2024-03-21', 'YYYY-MM-DD'), 'N', 5),
(6, 6, 3, 'Reimbursement request submitted', TO_DATE('2024-04-03', 'YYYY-MM-DD'), 'Y', 6),
(7, 7, 4, 'Awaiting manager approval', TO_DATE('2024-04-13', 'YYYY-MM-DD'), 'N', 7),
(8, 8, 4, 'Expense cancelled by user', TO_DATE('2024-04-23', 'YYYY-MM-DD'), 'Y', 8),
(9, 9, 5, 'Expense under review', TO_DATE('2024-05-06', 'YYYY-MM-DD'), 'N', 9),
(10, 10, 5, 'Expense deferred until next month', TO_DATE('2024-05-16', 'YYYY-MM-DD'), 'N', 10);





INSERT INTO Reimbursement (ReimbursementID, ExpenseID, Amount, Status) VALUES
    (1, 1, 150.00, 'Pending'),
    (2, 2, 2500.00, 'Approved'),
    (3, 3, 500.00, 'Paid'),
    (4, 4, 75.00, 'Pending'),
    (5, 5, 300.00, 'Approved'),
    (6, 6, 1200.00, 'Paid'),
    (7, 7, 90.00, 'Pending'),
    (8, 8, 600.00, 'Approved'),
    (9, 9, 2750.00, 'Paid'),
    (10, 10, 200.00, 'Pending');



INSERT INTO Payment (PaymentID, EmployeeID, Amount, PaymentDate, PaymentMethod, ReimbursementID) VALUES 
(1, 1, 150.00, TO_DATE('2024-01-20', 'YYYY-MM-DD'), 'Direct Deposit', 1),
(2, 2, 2500.00, TO_DATE('2024-02-15', 'YYYY-MM-DD'), 'Check', 2),
(3, 3, 500.00, TO_DATE('2024-02-20', 'YYYY-MM-DD'), 'Direct Deposit', 3),
(4, 4, 75.00, TO_DATE('2024-03-10', 'YYYY-MM-DD'), 'Cash', 4),
(5, 5, 300.00, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Direct Deposit', 5),
(6, 6, 1200.00, TO_DATE('2024-04-05', 'YYYY-MM-DD'), 'Check', 6),
(7, 7, 90.00, TO_DATE('2024-04-15', 'YYYY-MM-DD'), 'Direct Deposit', 7),
(8, 8, 600.00, TO_DATE('2024-04-25', 'YYYY-MM-DD'), 'Direct Deposit', 8),
(9, 9, 2750.00, TO_DATE('2024-05-10', 'YYYY-MM-DD'), 'Check', 9),
(10, 10, 200.00, TO_DATE('2024-05-20', 'YYYY-MM-DD'), 'Cash', 10);




