GO
USE [master];

PRINT N'Creating $(DatabaseName)...'
GO
CREATE DATABASE [$(DatabaseName)]
COLLATE Latin1_General_100_CI_AS;