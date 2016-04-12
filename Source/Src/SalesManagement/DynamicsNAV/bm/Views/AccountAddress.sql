CREATE VIEW bm.[AccountAddress]
	AS 
	SELECT [No_] AS [Account Number]
      ,NULL AS [Account Code]
      ,[Contact] AS [Primary Contact]
      ,[Address] AS [Addr Line 1]
      ,[Address 2] AS [Addr Line 2]
      ,NULL AS [Addr Line 3]
      ,[City] AS [City]
      ,[County] AS [State/Province]
      ,[Country_Region Code] AS Country
      ,[Post Code] AS [Postal Code]
  FROM [dbo].[Customer]
