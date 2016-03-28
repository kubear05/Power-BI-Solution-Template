GO
TRUNCATE TABLE Smgt.ActualSales
GO
TRUNCATE TABLE Smgt.Quotas
GO
TRUNCATE TABLE Smgt.Targets
GO
TRUNCATE TABLE Smgt.userMapping
GO

:r .\postdeployment\InsertActualsSample2.sql
:r .\postdeployment\InsertTargetsSample2.sql
:r .\postdeployment\InsertQuotaSample2.sql
