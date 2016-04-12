
CREATE TABLE [dbo].[Salesperson](
	[timestamp] [timestamp] NOT NULL,
	[Code] [nvarchar](10) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Commission _] [decimal](38, 20) NOT NULL,
	[Global Dimension 1 Code] [nvarchar](20) NOT NULL,
	[Global Dimension 2 Code] [nvarchar](20) NOT NULL,
	[E-Mail] [nvarchar](80) NOT NULL,
	[Phone No_] [nvarchar](30) NOT NULL,
	[Job Title] [nvarchar](30) NOT NULL,
	[Search E-Mail] [nvarchar](80) NOT NULL,
	[E-Mail 2] [nvarchar](80) NOT NULL
 
) ON [PRIMARY]

GO

