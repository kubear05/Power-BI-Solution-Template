CREATE TABLE [dbo].[OpportunityStage]
(
	[Id] [nvarchar](18) NOT NULL,
	[MasterLabel] [nvarchar](255) NULL,
	[SortOrder] [int] NULL,
	[DefaultProbability] [float] NULL,
	[SCRIBE_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SCRIBE_CREATEDON] [datetime] NOT NULL,
	[SCRIBE_MODIFIEDON] [datetime] NOT NULL,
	[SCRIBE_DELETEDON] [datetime] NULL, 
    CONSTRAINT [PK_OpportunityStage] PRIMARY KEY ([SCRIBE_ID])
)
