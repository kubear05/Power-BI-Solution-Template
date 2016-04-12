CREATE TABLE [dbo].[GP_Customer](
	[Dim_CustomerNumber] [char](15) NOT NULL,
	[Dim_CustomerName] [char](65) NULL,
	[Dim_CustomerClass] [char](15) NULL,
	[Dim_AccountManager] [char](3) NULL
) ON [PRIMARY]