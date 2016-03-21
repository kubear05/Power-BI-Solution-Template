CREATE TABLE [dbo].[Scribe_ReplicationStatus] (
    [EntityName]        NVARCHAR (1024) NULL,
    [StartDate]         DATETIME        NULL,
    [EndDate]           DATETIME        NULL,
    [FatalLastAttempt]  TINYINT         NULL,
    [SCRIBE_ID]         BIGINT          IDENTITY (1, 1) NOT NULL,
    [SCRIBE_CREATEDON]  DATETIME        NOT NULL,
    [SCRIBE_MODIFIEDON] DATETIME        NOT NULL,
    [SCRIBE_DELETEDON]  DATETIME        NULL,
    CONSTRAINT [PK_Scribe_ReplicationStatus] PRIMARY KEY CLUSTERED ([SCRIBE_ID] ASC)
);

