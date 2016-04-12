CREATE VIEW [dbo].[UserView]
	AS 
	SELECT [Dim_SalespersonID]            AS [User ID]
    ,[Dim_FirstName]                      AS [First Name]            
    ,[Dim_LastName]                       AS [Last Name]

FROM [GP_SalesPerson]
