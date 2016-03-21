﻿CREATE TABLE [dbo].[territory] (
    [createdonbehalfbyyominame]  NVARCHAR (4000)  NULL,
    [modifiedonbehalfby]         UNIQUEIDENTIFIER NULL,
    [transactioncurrencyidname]  NVARCHAR (4000)  NULL,
    [manageridname]              NVARCHAR (4000)  NULL,
    [entityimage_timestamp]      BIGINT           NULL,
    [managerid]                  UNIQUEIDENTIFIER NULL,
    [createdonbehalfby]          UNIQUEIDENTIFIER NULL,
    [transactioncurrencyid]      UNIQUEIDENTIFIER NULL,
    [name]                       NVARCHAR (200)   NULL,
    [entityimageid]              UNIQUEIDENTIFIER NULL,
    [importsequencenumber]       INT              NULL,
    [organizationid]             UNIQUEIDENTIFIER NULL,
    [createdbyyominame]          NVARCHAR (4000)  NULL,
    [territoryid]                UNIQUEIDENTIFIER NULL,
    [modifiedbyname]             NVARCHAR (4000)  NULL,
    [versionnumber]              BIGINT           NULL,
    [modifiedby]                 UNIQUEIDENTIFIER NULL,
    [modifiedbyyominame]         NVARCHAR (4000)  NULL,
    [createdby]                  UNIQUEIDENTIFIER NULL,
    [organizationidname]         NVARCHAR (4000)  NULL,
    [modifiedon]                 DATETIME         NULL,
    [exchangerate]               DECIMAL (22, 10) NULL,
    [manageridyominame]          NVARCHAR (4000)  NULL,
    [modifiedonbehalfbyyominame] NVARCHAR (4000)  NULL,
    [createdbyname]              NVARCHAR (4000)  NULL,
    [createdon]                  DATETIME         NULL,
    [createdonbehalfbyname]      NVARCHAR (4000)  NULL,
    [description]                NVARCHAR (MAX)   NULL,
    [modifiedonbehalfbyname]     NVARCHAR (4000)  NULL,
    [overriddencreatedon]        DATETIME         NULL,
    [entityimage_url]            NVARCHAR (4000)  NULL,
    [SCRIBE_ID]                  BIGINT           IDENTITY (1, 1) NOT NULL,
    [SCRIBE_CREATEDON]           DATETIME         NOT NULL,
    [SCRIBE_MODIFIEDON]          DATETIME         NOT NULL,
    [SCRIBE_DELETEDON]           DATETIME         NULL,
    CONSTRAINT [PK_territory] PRIMARY KEY CLUSTERED ([SCRIBE_ID] ASC)
);

