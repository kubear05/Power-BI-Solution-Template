CREATE TABLE [dbo].[Opportunity](
	[Id] [nvarchar](18) NULL,
	[IsDeleted] [tinyint] NULL,
	[AccountId] [nvarchar](18) NULL,
	[IsPrivate] [tinyint] NULL,
	[Name] [nvarchar](120) NULL,
	[Description] [nvarchar](max) NULL,
	[StageName] [nvarchar](40) NULL,
	[Amount] [float] NULL,
	[Probability] [float] NULL,
	[ExpectedRevenue] [float] NULL,
	[TotalOpportunityQuantity] [float] NULL,
	[CloseDate] [datetime] NULL,
	[Type] [nvarchar](40) NULL,
	[NextStep] [nvarchar](255) NULL,
	[LeadSource] [nvarchar](40) NULL,
	[IsClosed] [tinyint] NULL,
	[IsWon] [tinyint] NULL,
	[ForecastCategory] [nvarchar](40) NULL,
	[ForecastCategoryName] [nvarchar](40) NULL,
	[CampaignId] [nvarchar](18) NULL,
	[HasOpportunityLineItem] [tinyint] NULL,
	[Pricebook2Id] [nvarchar](18) NULL,
	[OwnerId] [nvarchar](18) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedById] [nvarchar](18) NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [nvarchar](18) NULL,
	[SystemModstamp] [datetime] NULL,
	[LastActivityDate] [datetime] NULL,
	[FiscalQuarter] [int] NULL,
	[FiscalYear] [int] NULL,
	[Fiscal] [nvarchar](6) NULL,
	[LastViewedDate] [datetime] NULL,
	[LastReferencedDate] [datetime] NULL,
	[DeliveryInstallationStatus__c] [nvarchar](255) NULL,
	[TrackingNumber__c] [nvarchar](12) NULL,
	[OrderNumber__c] [nvarchar](8) NULL,
	[CurrentGenerators__c] [nvarchar](100) NULL,
	[MainCompetitors__c] [nvarchar](100) NULL,
	[Import2_Id__c] [nvarchar](255) NULL,
	[Account_Account_Import2_Id__c] [nvarchar](255) NULL,
	[SCRIBE_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SCRIBE_CREATEDON] [datetime] NOT NULL,
	[SCRIBE_MODIFIEDON] [datetime] NOT NULL,
	[SCRIBE_DELETEDON] [datetime] NULL,
 CONSTRAINT [PK_Opportunity] PRIMARY KEY CLUSTERED 
(
	[SCRIBE_ID] ASC
)
);
GO

CREATE NONCLUSTERED INDEX idx_owner_id ON dbo.opportunity(ownerid);
GO

