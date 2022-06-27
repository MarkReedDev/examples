-- A T-SQL script to add two Active Directory groups (ro/rw) as users 
-- into an Azure SQL database. Enterprise users requiring access
-- are then added into those groups, reducing administration
-- overhead.

-- Users should not be given master database access as this grants too many
-- permissions, insead users should be granted access on a db by db level.

-- It is assumed the admin has chosen the correct db in the drop down
-- above the query pane. Alternatively use the USE command, but this proved
-- cumbersome in multiple, rapid db deployments.

-- ***** SCRIPT START *****

-- Declare the variables
DECLARE @db NVARCHAR(5), @dbr NVARCHAR(8), @dbw NVARCHAR(8);

-- Set a common AD name for the group
SET @db = '<Common AD group name>';

-- Append the common name with -ro for read-only access.
-- *The group must already exist in AD.
SET @dbr = @db  + '-ro';
-- Append the common name with -rw for read-write access.
-- *The group must already exist in AD.
SET @dbw = @db  + '-rw';

-- Create the two users
EXEC ('CREATE USER [' + @dbr + '] FROM EXTERNAL PROVIDER');
EXEC ('CREATE USER [' + @dbw + '] FROM EXTERNAL PROVIDER');

-- Add the two users to the db_datareader role, read access is
-- not automatically granted with write access.
EXEC ('ALTER ROLE db_datareader ADD MEMBER [' + @dbr + ']');
EXEC ('ALTER ROLE db_datareader ADD MEMBER [' + @dbw + ']');

-- Add the rw user to db_datawriter
EXEC ('ALTER ROLE db_datawriter ADD MEMBER [' + @dbw + ']');

-- Display the role memberships for all users for the database
SELECT 
	roles.[name] as role_name,
	members.[name] as user_name
FROM sys.database_role_members 
    JOIN sys.database_principals roles ON database_role_members.role_principal_id = roles.principal_id
    JOIN sys.database_principals members ON database_role_members.member_principal_id = members.principal_id
ORDER BY 
	roles.[name],
	members.[name]

-- ***** SCRIPT END *****
