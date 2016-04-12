CREATE VIEW bm.[Item]
	AS 
	SELECT I.[No_] AS [Item Number]
      ,I.[Description] AS [Item Description]
      ,I.[Unit Price] AS [Default Cost]
      ,P.[Description] [Class Description]
  FROM [dbo].[Item] I

  left join [dbo].[ProductGroup] P
  on P.[Code] = I.[Product Group Code]
