CREATE TABLE [dbo].[GP_SalesOrderHeader](
	[Dim_SalesOrderType] [smallint] NOT NULL,
	[Dim_SalesOrderNumber] [char](21) NOT NULL,
	[Fact_DocumentDate] [datetime] NULL,
	[Fact_PostingDate] [datetime] NULL,
	[Dim_CustomerNumber] [char](15) NULL,
	[Dim_BillToAddress] [char](15) NULL,
	[Fact_ExtendedPrice] [numeric](19, 5) NULL,
	[Fact_FreightAmount] [numeric](19, 5) NULL,
	[Fact_TaxAmount] [numeric](19, 5) NULL,
	[Dim_Salesperson] [char](15) NULL
) ON [PRIMARY]