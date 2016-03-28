CREATE VIEW [Smgt].[LeadView]
AS
  SELECT NULL									AS [Estimated Amount],
         [Status] 								AS [Status],
		 NULL									AS [Lead Quality],
         NULL 									AS [Subject],
         [Title] 								AS [Job Title],
         [Id] 									AS [Lead Id],
         NULL									AS [Estimated Amount Base],
         [OwnerId] 								AS [Owner Id],
         NULL 									AS [State Code],
         NULL									AS [Campaign Id],
         NULL 									AS [Estimated Close Date],
         [LeadSource] 							AS [Lead Source Name],
         [Industry] 							AS [Industry Name],
         NULL            						AS [Purchase Time Frame],
         [CreatedDate]                			AS [Created On],
         NULL    								AS [Company Name]
  FROM   dbo.lead
