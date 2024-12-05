# Project Database Setup

This project involves setting up a database environment with specific user permissions and configurations. Please follow the steps below to ensure the database is configured correctly.

## Prerequisites

- Oracle Database or compatible database environment.
- Access to an SQL client to execute `.sql` files.

## Setup Instructions

### Flow

1. **Run `Admin.sql`**
   - This script sets up the initial configuration by creating new user and grants required permissions to the 'TravelUser' user.

2. **Run `DevDB_TravelUser.sql`**
   - This script creates necessary tables and views for the `TravelUser` user.

3. **Run `Admin2.sql`**
   - This script grants insert, select, update, delete to 'TravelUser' user.

4. **Run `DevDB_TravelUser2.sql`**
   - This script inserts data into tables.

5. **Run `Functions_and_Reports.sql`**
   - This script create reports


## Roles
Admin role - System Admin
App Admin role - TravelUser
Employee role - DataViewerUser

## Files for Presentation (Not to be run)
DevDB_DataViewerUser.sql
Functions of Triggers.sql
TestCaseOfNewRecord.sql
TestCases.sql
Validations.sql

### Notes

- Ensure that each script is run in the specified order to avoid permission issues.
- If any script fails due to missing tables or objects, please check if the previous scripts executed successfully.
- The scripts are designed to handle exceptions for missing tables, so if certain tables are not found, the script will continue without error.

## Troubleshooting

- **Permission Errors:** Ensure that each script is run in the correct order. Missing permissions can result if scripts are run out of sequence.
- **Table Not Found Errors:** If certain tables do not exist, the scripts are designed to skip permissions for them without causing the process to halt.

