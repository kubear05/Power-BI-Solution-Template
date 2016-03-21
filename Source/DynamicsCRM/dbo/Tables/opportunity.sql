﻿CREATE TABLE [dbo].[opportunity] (
    [contactid]                         UNIQUEIDENTIFIER NULL,
    [finaldecisiondate]                 DATETIME         NULL,
    [presentfinalproposal]              TINYINT          NULL,
    [budgetamount_base]                 DECIMAL (19, 4)  NULL,
    [budgetstatus]                      INT              NULL,
    [budgetstatus_displayname]          NVARCHAR (255)   NULL,
    [modifiedon]                        DATETIME         NULL,
    [overriddencreatedon]               DATETIME         NULL,
    [developproposal]                   TINYINT          NULL,
    [isrevenuesystemcalculated]         TINYINT          NULL,
    [contactidname]                     NVARCHAR (4000)  NULL,
    [confirminterest]                   TINYINT          NULL,
    [proposedsolution]                  NVARCHAR (MAX)   NULL,
    [freightamount]                     DECIMAL (15, 2)  NULL,
    [transactioncurrencyidname]         NVARCHAR (4000)  NULL,
    [new_forecast]                      DECIMAL (14, 4)  NULL,
    [campaignidname]                    NVARCHAR (4000)  NULL,
    [owningbusinessunit]                UNIQUEIDENTIFIER NULL,
    [completefinalproposal]             TINYINT          NULL,
    [accountid]                         UNIQUEIDENTIFIER NULL,
    [owneridyominame]                   NVARCHAR (4000)  NULL,
    [parentcontactid]                   UNIQUEIDENTIFIER NULL,
    [statuscode]                        INT              NULL,
    [statuscode_displayname]            NVARCHAR (255)   NULL,
    [estimatedclosedate]                DATETIME         NULL,
    [accountidyominame]                 NVARCHAR (4000)  NULL,
    [totallineitemamount_base]          DECIMAL (19, 4)  NULL,
    [identifypursuitteam]               TINYINT          NULL,
    [parentaccountidname]               NVARCHAR (4000)  NULL,
    [originatingleadidname]             NVARCHAR (4000)  NULL,
    [pursuitdecision]                   TINYINT          NULL,
    [contactidyominame]                 NVARCHAR (4000)  NULL,
    [initialcommunication]              INT              NULL,
    [initialcommunication_displayname]  NVARCHAR (255)   NULL,
    [parentaccountidyominame]           NVARCHAR (4000)  NULL,
    [exchangerate]                      DECIMAL (22, 10) NULL,
    [parentaccountid]                   UNIQUEIDENTIFIER NULL,
    [filedebrief]                       TINYINT          NULL,
    [pricelevelid]                      UNIQUEIDENTIFIER NULL,
    [createdon]                         DATETIME         NULL,
    [sendthankyounote]                  TINYINT          NULL,
    [customeridyominame]                NVARCHAR (4000)  NULL,
    [opportunityratingcode]             INT              NULL,
    [opportunityratingcode_displayname] NVARCHAR (255)   NULL,
    [salesstage]                        INT              NULL,
    [salesstage_displayname]            NVARCHAR (255)   NULL,
    [actualclosedate]                   DATETIME         NULL,
    [stepid]                            UNIQUEIDENTIFIER NULL,
    [identifycompetitors]               TINYINT          NULL,
    [completeinternalreview]            TINYINT          NULL,
    [evaluatefit]                       TINYINT          NULL,
    [totallineitemdiscountamount_base]  DECIMAL (19, 4)  NULL,
    [totaldiscountamount]               DECIMAL (17, 2)  NULL,
    [description]                       NVARCHAR (MAX)   NULL,
    [modifiedby]                        UNIQUEIDENTIFIER NULL,
    [discountamount_base]               DECIMAL (19, 4)  NULL,
    [parentcontactidyominame]           NVARCHAR (4000)  NULL,
    [modifiedonbehalfby]                UNIQUEIDENTIFIER NULL,
    [stepname]                          NVARCHAR (200)   NULL,
    [accountidname]                     NVARCHAR (4000)  NULL,
    [freightamount_base]                DECIMAL (19, 4)  NULL,
    [originatingleadidyominame]         NVARCHAR (4000)  NULL,
    [owningteam]                        UNIQUEIDENTIFIER NULL,
    [traversedpath]                     NVARCHAR (1250)  NULL,
    [presentproposal]                   TINYINT          NULL,
    [estimatedvalue]                    DECIMAL (15, 2)  NULL,
    [createdonbehalfbyname]             NVARCHAR (4000)  NULL,
    [owninguser]                        UNIQUEIDENTIFIER NULL,
    [captureproposalfeedback]           TINYINT          NULL,
    [actualvalue_base]                  DECIMAL (19, 4)  NULL,
    [schedulefollowup_qualify]          DATETIME         NULL,
    [totalamountlessfreight_base]       DECIMAL (19, 4)  NULL,
    [owneridtype]                       NVARCHAR (255)   NULL,
    [totalamountlessfreight]            DECIMAL (17, 2)  NULL,
    [modifiedonbehalfbyname]            NVARCHAR (4000)  NULL,
    [createdonbehalfbyyominame]         NVARCHAR (4000)  NULL,
    [new_forecast_base]                 DECIMAL (19, 4)  NULL,
    [customerid]                        UNIQUEIDENTIFIER NULL,
    [participatesinworkflow]            TINYINT          NULL,
    [totallineitemamount]               DECIMAL (17, 2)  NULL,
    [qualificationcomments]             NVARCHAR (MAX)   NULL,
    [opportunityid]                     UNIQUEIDENTIFIER NULL,
    [processid]                         UNIQUEIDENTIFIER NULL,
    [decisionmaker]                     TINYINT          NULL,
    [createdonbehalfby]                 UNIQUEIDENTIFIER NULL,
    [transactioncurrencyid]             UNIQUEIDENTIFIER NULL,
    [isprivate]                         TINYINT          NULL,
    [customerneed]                      NVARCHAR (MAX)   NULL,
    [new_addtoforecast]                 TINYINT          NULL,
    [campaignid]                        UNIQUEIDENTIFIER NULL,
    [resolvefeedback]                   TINYINT          NULL,
    [actualvalue]                       DECIMAL (15, 2)  NULL,
    [modifiedbyyominame]                NVARCHAR (4000)  NULL,
    [ownerid]                           UNIQUEIDENTIFIER NULL,
    [discountpercentage]                DECIMAL (5, 2)   NULL,
    [timeline]                          INT              NULL,
    [timeline_displayname]              NVARCHAR (255)   NULL,
    [originatingleadid]                 UNIQUEIDENTIFIER NULL,
    [scheduleproposalmeeting]           DATETIME         NULL,
    [purchasetimeframe]                 INT              NULL,
    [purchasetimeframe_displayname]     NVARCHAR (255)   NULL,
    [budgetamount]                      DECIMAL (15, 2)  NULL,
    [name]                              NVARCHAR (300)   NULL,
    [timezoneruleversionnumber]         INT              NULL,
    [salesstagecode]                    INT              NULL,
    [salesstagecode_displayname]        NVARCHAR (255)   NULL,
    [pricingerrorcode]                  INT              NULL,
    [pricingerrorcode_displayname]      NVARCHAR (255)   NULL,
    [createdbyname]                     NVARCHAR (4000)  NULL,
    [statecode]                         INT              NULL,
    [statecode_displayname]             NVARCHAR (255)   NULL,
    [customeridtype]                    NVARCHAR (255)   NULL,
    [schedulefollowup_prospect]         DATETIME         NULL,
    [modifiedonbehalfbyyominame]        NVARCHAR (4000)  NULL,
    [createdby]                         UNIQUEIDENTIFIER NULL,
    [estimatedvalue_base]               DECIMAL (19, 4)  NULL,
    [totaldiscountamount_base]          DECIMAL (19, 4)  NULL,
    [totallineitemdiscountamount]       DECIMAL (17, 2)  NULL,
    [stageid]                           UNIQUEIDENTIFIER NULL,
    [utcconversiontimezonecode]         INT              NULL,
    [customeridname]                    NVARCHAR (4000)  NULL,
    [importsequencenumber]              INT              NULL,
    [totalamount]                       DECIMAL (17, 2)  NULL,
    [customerpainpoints]                NVARCHAR (MAX)   NULL,
    [totalamount_base]                  DECIMAL (19, 4)  NULL,
    [totaltax]                          DECIMAL (17, 2)  NULL,
    [versionnumber]                     BIGINT           NULL,
    [pricelevelidname]                  NVARCHAR (4000)  NULL,
    [quotecomments]                     NVARCHAR (MAX)   NULL,
    [discountamount]                    DECIMAL (15, 2)  NULL,
    [totaltax_base]                     DECIMAL (19, 4)  NULL,
    [parentcontactidname]               NVARCHAR (4000)  NULL,
    [purchaseprocess]                   INT              NULL,
    [purchaseprocess_displayname]       NVARCHAR (255)   NULL,
    [modifiedbyname]                    NVARCHAR (4000)  NULL,
    [identifycustomercontacts]          TINYINT          NULL,
    [createdbyyominame]                 NVARCHAR (4000)  NULL,
    [owneridname]                       NVARCHAR (4000)  NULL,
    [prioritycode]                      INT              NULL,
    [prioritycode_displayname]          NVARCHAR (255)   NULL,
    [need]                              INT              NULL,
    [need_displayname]                  NVARCHAR (255)   NULL,
    [closeprobability]                  INT              NULL,
    [currentsituation]                  NVARCHAR (MAX)   NULL,
    [SCRIBE_ID]                         BIGINT           IDENTITY (1, 1) NOT NULL,
    [SCRIBE_CREATEDON]                  DATETIME         NOT NULL,
    [SCRIBE_MODIFIEDON]                 DATETIME         NOT NULL,
    [SCRIBE_DELETEDON]                  DATETIME         NULL,
    CONSTRAINT [PK_opportunity] PRIMARY KEY CLUSTERED ([SCRIBE_ID] ASC)
);
GO

CREATE NONCLUSTERED INDEX idx_owner_id ON dbo.opportunity(ownerid);
GO
