CREATE VIEW [Smgt].[OpportunityView]
AS
  SELECT o.opportunityid							AS [Opportunity Id],
         o.NAME										AS [Opportunity Name],
         o.ownerid									AS [Owner Id],
         CONVERT(DATE, o.actualclosedate)			AS [Actual Close Date],
         CONVERT(DATE, o.estimatedclosedate)		AS [Estimated Close Date],
         o.closeprobability							AS [Close Probability],
         CASE WHEN o.parentaccountid is NULL THEN o.opportunityid ELSE o.parentaccountid END AS [Account Id],
         o.actualvalue								AS [Actual Value],	
         o.estimatedvalue							AS [Estimated Value],
         o.statuscode_displayname					AS [Status],
		 case when stepname is null or CHARINDEX('-',o.stepname)=0 then null else  left(o.stepname,CHARINDEX('-',o.stepname)-1) end
													AS [Sales Stage Code],
         o.stepname									AS [Sales Stage],
         o.statecode_displayname					AS [State],
         o.originatingleadid						AS [Lead Id],
         o.opportunityratingcode_displayname		AS [Opportunity Rating Name],
         NULL										AS [Source]
  FROM   dbo.opportunity o 
  WHERE  ( o.scribe_deletedon IS NULL )