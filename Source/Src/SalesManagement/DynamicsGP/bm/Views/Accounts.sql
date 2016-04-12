CREATE VIEW bm.[Customer]
	AS 
	SELECT [Dim_CustomerNumber] AS [Account Number]
      ,[Dim_CustomerName] AS [Account Name]
      ,[Dim_AccountManager] As [Account Manager]
	  ,cc.Dim_ClassDescription AS [Class Description]
  FROM [dbo].[GP_Customer] c
  left join GP_CustomerClass cc on cc.Dim_CustomerClass=c.Dim_CustomerClass
