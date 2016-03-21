CREATE VIEW [Smgt].[AccountView]
AS
  SELECT [Id]				AS [Account Id], 
         NAME				AS [Account Name],
         ownerid			AS [Owner Id],
         NULL				AS [Territory Id],
         [Industry]			AS [Industry],
         NULL				AS [Business Unit Id],
		 [BillingCity]		AS [City],
		 [BillingState]		AS [State],
		 [BillingCountry]	AS [Country],
		 [AnnualRevenue]	AS [Annual Revenue]
  
  FROM   dbo.account		
  WHERE (  IsDeleted = 0 )

  UNION ALL

    -- Creates a dummy account for opportunities that don't have an account.
    SELECT [Id]				AS [Account Id], 
         NULL				AS [Account Name],
         ownerid			AS [Owner Id],
         NULL				AS [Territory Id],
         NULL				AS [Industry],
         NULL				AS [Business Unit Id],
		 NULL				AS [City],
		 NULL				AS [State],
		 NULL				AS [Country],
		 NULL				AS [Annual Revenue]
  FROM   dbo.OPPORTUNITY		
  WHERE (  IsDeleted = 0 and ACCOUNTID is NULL)

