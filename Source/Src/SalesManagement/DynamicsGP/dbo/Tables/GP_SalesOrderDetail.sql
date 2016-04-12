CREATE TABLE [dbo].[GP_SalesOrderDetail](
	[Dim_SalesOrderType] [smallint] NOT NULL,
	[Dim_SalesOrderNumber] [char](21) NOT NULL,
	[Dim_ItemNumber] [char](31) NULL,
	[Dim_ItemDescription] [char](101) NULL,
	[Fact_NonInventory] [smallint] NULL,
	[Fact_UnitOfMeasure] [char](9) NULL,
	[Fact_UnitPrice] [numeric](19, 5) NULL,
	[Fact_Quantity] [numeric](19, 5) NULL,
	[Fact_ExtendedPrice] [numeric](19, 5) NULL,
	[Dim_ShipToAddressCode] [char](15) NULL
) ON [PRIMARY]