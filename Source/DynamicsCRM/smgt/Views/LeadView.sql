CREATE VIEW [Smgt].[LeadView]
AS
  SELECT estimatedamount				AS [Estimated Amount],
         statuscode_displayname			AS [Status],
         leadqualitycode_displayname	AS [Lead Quality],
         [subject]						AS [Subject],
         jobtitle						AS [Job Title],
         leadid							AS [Lead Id],
         estimatedamount_base			AS [Estimated Amount Base],
         ownerid						AS [Owner Id],
         statecode_displayname			AS [State Code],
         campaignid						AS [Campaign Id],
         estimatedclosedate				AS [Estimated Close Date],
         leadsourcecode_displayname		AS [Lead Source Name],
         industrycode_displayname		AS [Industry Name],
         purchasetimeframe_displayname	AS [Purchase Time Frame],
		 createdon						AS [Created On],
		 companyname					AS [Company Name]
  FROM   dbo.lead
  WHERE  ( scribe_deletedon IS NULL )  