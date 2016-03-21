﻿GO
TRUNCATE TABLE Smgt.configuration
GO
TRUNCATE TABLE Smgt.date

:r .\postdeploymentBuild.sql

:r .\postdeployment\InsertDates.sql
:r .\postdeployment\InsertConfiguration.sql
:r .\postdeployment\create_job.sql

-- CREATE login for SSAS
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name='NT SERVICE\MSSQLServerOLAPService')
BEGIN
    CREATE LOGIN [NT SERVICE\MSSQLServerOLAPService] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english];
END;
GO

USE [$(DatabaseName)]
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name='NT SERVICE\MSSQLServerOLAPService')
BEGIN
    CREATE USER [NT SERVICE\MSSQLServerOLAPService] FOR LOGIN [NT SERVICE\MSSQLServerOLAPService] WITH DEFAULT_SCHEMA=[dbo]
END;
GO

ALTER ROLE [db_datareader] ADD MEMBER [NT SERVICE\MSSQLServerOLAPService]
GO