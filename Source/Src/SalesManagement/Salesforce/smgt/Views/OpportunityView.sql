CREATE VIEW [Smgt].[OpportunityView]
AS
SELECT o.id									AS [Opportunity Id],
         o.NAME                                 AS [Opportunity Name],
         o.ownerid								AS [Owner Id],

         CASE WHEN o.IsClosed = 0 THEN NULL 
		 ELSE  CONVERT(DATE, o.CloseDate) END	AS [Actual Close Date],

         CASE WHEN o.IsClosed = 1 THEN NULL 
		 ELSE  CONVERT(DATE, o.CloseDate) END	AS [Estimated Close Date],

         o.Probability							AS [Close Probability],
         CASE WHEN o.accountid IS NULL then o.id ELSE o.accountid END	AS [Account Id],

         CASE WHEN o.IsClosed = 0 THEN NULL 
         ELSE o.Amount END						AS [Actual Value],
		 	
         o.Amount								AS [Estimated Value],
         o.ForecastCategoryName					AS [Status],
		 o.StageName							AS [Sales Stage],
		 s.SortOrder							AS [Sales Stage Code],
		 
		 CASE		WHEN o.IsClosed = 1 AND o.IsWon = 1 THEN 'Won'
		 ELSE CASE	WHEN o.IsClosed = 1 AND o.IsWon = 0 THEN 'Lost'
		 ELSE 'Open' END END 					AS [State], 
												
		 NULL									AS [Lead Id],
         o.Probability							AS [Opportunity Rating Name],
         o.LeadSource     						AS [Source]					 							
  FROM   dbo.opportunity o LEFT OUTER JOIN dbo.OpportunityStage s
                      ON o.StageName = s.MasterLabel