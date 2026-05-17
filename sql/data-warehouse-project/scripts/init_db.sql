/*
=============================================================
Database Setup Script
=============================================================
- Purpose: Builds a fresh 'DataWarehouse' database.
- Folders: Sets up 'bronze', 'silver', and 'gold' schemas.
- DANGER: Deletes the existing database and all data before starting.
- Note: Do not run this without a backup copy of your data.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
