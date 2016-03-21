CREATE VIEW [Smgt].[AccountView]
AS
  SELECT accountid						AS [Account Id], 
         NAME							AS [Account Name],
         ownerid						AS [Owner Id],
         territoryid					AS [Territory Id],
         industrycode_displayname		AS [Industry],
         owningbusinessunit				AS [Business Unit Id],
		 address1_city					AS [City],
		 address1_stateorprovince		AS [State],
		 address1_country				AS [Country],
		 revenue						AS [Annual Revenue]
  FROM   dbo.account
  WHERE ( scribe_deletedon IS NULL )
  
  UNION ALL 

  SELECT opportunityid					AS [Account Id], 
         NULL							AS [Account Name],
         ownerid					    AS [Owner Id],
         NULL							AS [Territory Id],
         NULL							AS [Industry],
         owningbusinessunit				AS [Business Unit Id],
		 NULL							AS [City],
		 NULL							AS [State],
		 NULL							AS [Country],
		 NULL							AS [Annual Revenue]
  FROM   dbo.opportunity
  WHERE ( parentaccountid IS NULL AND scribe_deletedon IS NULL )
