CREATE VIEW bm.[Customer]
	AS 
	SELECT C.[No_] AS [Account Number]
      ,C.[Name] AS [Account Name]
      ,P.[Name] As [Account Manager]
	  ,C.[Customer Posting Group] AS [Segment]
  FROM [dbo].[Customer] C
    left join [dbo].[SalesPerson] P
  on C.[Salesperson Code] = P.[Code]

  
