CREATE VIEW bm.[AccountAddress]
	AS 
	SELECT [Dim_CustomerNumber] AS [Account Number]
      ,[Dim_CustomerAddressCode] AS [Account Code]
      ,[Dim_PrimaryContactName] AS [Primary Contact]
      ,[Dim_Line1] AS [Addr Line 1]
      ,[Dim_Line2] AS [Addr Line 2]
      ,[Dim_Line3] AS [Addr Line 3]
      ,[Dim_City] AS [City]
      ,[Dim_StateOrProvince] AS [State/Province]
      ,[Dim_Country] AS Country
      ,[Dim_PostalCode] AS [Postal Code]
  FROM [dbo].[GP_Address]
