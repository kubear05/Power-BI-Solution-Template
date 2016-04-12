CREATE TABLE [dbo].[GP_Address](
	[Dim_CustomerNumber] [char](15) NOT NULL,
	[Dim_CustomerAddressCode] [char](15) NOT NULL,
	[Dim_PrimaryContactName] [char](61) NULL,
	[Dim_Line1] [char](61) NULL,
	[Dim_Line2] [char](61) NULL,
	[Dim_Line3] [char](61) NULL,
	[Dim_City] [char](35) NULL,
	[Dim_StateOrProvince] [char](29) NULL,
	[Dim_Country] [char](61) NULL,
	[Dim_PostalCode] [char](11) NULL
) ON [PRIMARY]