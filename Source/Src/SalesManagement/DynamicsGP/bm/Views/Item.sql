CREATE VIEW bm.[Item]
	AS 
	SELECT [Dim_ItemNumber] AS [Item Number]
      ,[Dim_ItemDescription] AS [Item Description]
      ,[Fact_StandardCost] AS [Default Cost]
      ,ic.Dim_ItemClassDescription [Class Description]
  FROM [dbo].[GP_Item] i
  left join [dbo].GP_ItemClass ic on ic.Dim_ItemClass=i.Dim_ItemClass
