CREATE TABLE [dbo].[systemusermanagermap] (
    [hierarchylevel]         INT              NULL,
    [versionnumber]          BIGINT           NULL,
    [parentsystemuserid]     UNIQUEIDENTIFIER NULL,
    [systemusermanagermapid] UNIQUEIDENTIFIER NULL,
    [systemuserid]           UNIQUEIDENTIFIER NULL,
    [SCRIBE_ID]              BIGINT           IDENTITY (1, 1) NOT NULL,
    [SCRIBE_CREATEDON]       DATETIME         NOT NULL,
    [SCRIBE_MODIFIEDON]      DATETIME         NOT NULL,
    [SCRIBE_DELETEDON]       DATETIME         NULL,
	CONSTRAINT [PK_systemusermanagermap] PRIMARY KEY CLUSTERED ([SCRIBE_ID] ASC)
);
GO

CREATE INDEX idx_systemuser_id ON dbo.systemusermanagermap (systemuserid) INCLUDE ( parentsystemuserid);
GO
