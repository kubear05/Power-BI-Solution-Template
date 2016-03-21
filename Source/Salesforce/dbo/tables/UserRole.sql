CREATE TABLE [dbo].[UserRole](
	[Id] [nvarchar](18) NULL,
	[Name] [nvarchar](80) NULL,
	[ParentRoleId] [nvarchar](18) NULL,
	[RollupDescription] [nvarchar](80) NULL,
	[OpportunityAccessForAccountOwner] [nvarchar](40) NULL,
	[CaseAccessForAccountOwner] [nvarchar](40) NULL,
	[ContactAccessForAccountOwner] [nvarchar](40) NULL,
	[ForecastUserId] [nvarchar](18) NULL,
	[MayForecastManagerShare] [tinyint] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [nvarchar](18) NULL,
	[SystemModstamp] [datetime] NULL,
	[DeveloperName] [nvarchar](80) NULL,
	[PortalAccountId] [nvarchar](18) NULL,
	[PortalType] [nvarchar](40) NULL,
	[PortalAccountOwnerId] [nvarchar](18) NULL,
	[Account_PortalAccountId_Import2_Id__c] [nvarchar](255) NULL,
	[SCRIBE_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SCRIBE_CREATEDON] [datetime] NOT NULL,
	[SCRIBE_MODIFIEDON] [datetime] NOT NULL,
	[SCRIBE_DELETEDON] [datetime] NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[SCRIBE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


