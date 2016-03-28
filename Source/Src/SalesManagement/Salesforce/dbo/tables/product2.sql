CREATE TABLE [dbo].[Product2](
	[Id] [nvarchar](18) NULL,
	[Name] [nvarchar](255) NULL,
	[ProductCode] [nvarchar](255) NULL,
	[Description] [nvarchar](4000) NULL,
	[IsActive] [tinyint] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedById] [nvarchar](18) NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [nvarchar](18) NULL,
	[SystemModstamp] [datetime] NULL,
	[Family] [nvarchar](40) NULL,
	[IsDeleted] [tinyint] NULL,
	[LastViewedDate] [datetime] NULL,
	[LastReferencedDate] [datetime] NULL,
	[SCRIBE_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SCRIBE_CREATEDON] [datetime] NOT NULL,
	[SCRIBE_MODIFIEDON] [datetime] NOT NULL,
	[SCRIBE_DELETEDON] [datetime] NULL,
 CONSTRAINT [PK_Product2] PRIMARY KEY CLUSTERED 
(
	[SCRIBE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

