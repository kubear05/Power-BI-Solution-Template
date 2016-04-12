CREATE TABLE [dbo].[GP_Item](
	[Dim_ItemNumber] [char](31) NOT NULL,
	[Dim_ItemDescription] [char](101) NULL,
	[Fact_StandardCost] [numeric](19, 5) NULL,
	[Dim_ItemClass] [char](11) NULL
) ON [PRIMARY]