CREATE TABLE [dbo].[OpportunityLineItem](
	[Id] [nvarchar](18) NULL,
	[OpportunityId] [nvarchar](18) NULL,
	[SortOrder] [int] NULL,
	[PricebookEntryId] [nvarchar](18) NULL,
	[Product2Id] [nvarchar](18) NULL,
	[ProductCode] [nvarchar](255) NULL,
	[Name] [nvarchar](376) NULL,
	[Quantity] [float] NULL,
	[TotalPrice] [float] NULL,
	[UnitPrice] [float] NULL,
	[ListPrice] [float] NULL,
	[ServiceDate] [datetime] NULL,
	[Description] [nvarchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedById] [nvarchar](18) NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [nvarchar](18) NULL,
	[SystemModstamp] [datetime] NULL,
	[IsDeleted] [tinyint] NULL,
	[Opportunity_Opportunity_Import2_Id__c] [nvarchar](255) NULL,
	[SCRIBE_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SCRIBE_CREATEDON] [datetime] NOT NULL,
	[SCRIBE_MODIFIEDON] [datetime] NOT NULL,
	[SCRIBE_DELETEDON] [datetime] NULL,
 CONSTRAINT [PK_OpportunityLineItem] PRIMARY KEY CLUSTERED 
(
	[SCRIBE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

