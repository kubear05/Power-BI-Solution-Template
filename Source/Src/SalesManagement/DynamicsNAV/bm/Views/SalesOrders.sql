CREATE VIEW [bm].[SalesOrder]
	AS 
	SELECT
       D.[Dim_SalesOrderNumber]                                AS [Order Number]
      ,D.[Dim_ItemNumber]                                      AS [Item #]
      ,D.[Fact_NonInventory]                                   AS [Non - Inventory]
      ,D.[Fact_UnitOfMeasure]                                  AS [Unit Of Measure]
      ,D.[Fact_UnitPrice]                                      AS [Unit Price]
      ,D.[Fact_Quantity]                                       AS [Quantity]
      ,D.[Fact_ExtendedPrice]                                  AS [Total Price]
      ,D.[Dim_ShipToAddressCode]                               AS [Ship To Address Code]
      ,T.[Dim_SalesOrderTypeName]                              AS [Sales Order Type Name]
	  ,H.[Fact_DocumentDate]                              AS [Document Date]
      ,H.[Fact_PostingDate]                              AS [Posting Date]
      ,H.[Dim_CustomerNumber]                              AS [ShipTo Customer]
      ,H.[Dim_BillToAddress]                              AS [BillTo Customer]
      ,H.[Dim_Salesperson]                              AS [Salesperson]
  FROM dbo.[GP_SalesOrderDetail] D
  left join dbo.[GP_SalesOrderType] T 
  ON D.[Dim_SalesOrderType] = T.[Dim_SalesOrderType]
  left join dbo.[GP_SalesOrderHeader] H
  ON H.Dim_SalesOrderNumber=D.Dim_SalesOrderNumber and H.[Dim_SalesOrderType] = D.[Dim_SalesOrderType]