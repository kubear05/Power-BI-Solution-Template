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


GO


CREATE VIEW [Smgt].[ActualSalesView]
AS

  SELECT InvoiceId				AS [Invoice Id],
         ActualSales			AS [Actual Sales],
         InvoiceDate			AS [Invoice Date],
         [accountid]			AS [Account Id],
         [productid]			AS [Product Id]
  FROM   smgt.actualsales
  WHERE  EXISTS (SELECT *
                 FROM   smgt.configuration
                 WHERE  configuration_group = 'DATA'
                        AND configuration_subgroup = 'actual_sales'
                        AND [name] = 'enabled'
                        AND value = '1')

UNION ALL

-- This gets the Opportunity's OpportunityLineItem if they exist. Salesforce does not allow the total to not match the
-- sum - so no prorating.
SELECT
		op.ID										AS [Invoice Id],
        op.totalprice								AS [Actual Sales],
        o.closedate									AS [Invoice Date],
        o.accountid									AS [Account ID],
        op.product2id								AS [Product ID]
  FROM   dbo.opportunity AS o
         INNER JOIN dbo.opportunitylineitem AS op
                 ON o.id = op.opportunityid
  WHERE  o.iswon = 1
  AND NOT EXISTS (SELECT *
                 FROM   smgt.configuration
                 WHERE  configuration_group = 'DATA'
                        AND configuration_subgroup = 'actual_sales'
                        AND [name] = 'enabled'
                        AND value = '1')

  UNION ALL

  -- This gets the Opportunities for which there are no OpportunityProducts that can be used
  SELECT o.id					AS [Invoice Id],
         o.amount	            AS [Actual Sales],
         o.closedate			AS [Invoice Date],
         o.accountid			AS [Account ID],
         null					AS [Product ID]
  FROM   dbo.opportunity AS o
  WHERE  o.iswon=1
  AND NOT EXISTS (SELECT 1 FROM dbo.opportunitylineitem op where op.opportunityid=o.id)
         AND NOT EXISTS (SELECT *
                         FROM   smgt.configuration
                         WHERE  configuration_group = 'DATA'
                                AND configuration_subgroup = 'actual_sales'
                                AND [name] = 'enabled'
                                AND value = '1')

GO

CREATE VIEW [Smgt].[BusinessUnitView]
AS
WITH tree
		AS (SELECT [Id], Name, ParentRoleId, 0 AS [Level], CAST(id AS VARCHAR(MAX)) AS pth
		FROM UserRole
		WHERE parentroleid = ''

		UNION ALL

		SELECT	a.[Id],
				a.Name,
				a.ParentRoleId,
				t.[Level] + 1,
				t.pth + CAST(a.id AS VARCHAR(MAX)) 
		FROM tree as t
			JOIN UserRole as a ON a.ParentRoleId = t.Id)

		SELECT t.id as [Business Unit Id],
		t.Name AS [Business Unit Name],
		Level, 
		b.Name AS [Level1],
		c.Name AS [Level2],
		d.Name AS [Level3]  
		FROM tree t 
		LEFT JOIN UserRole b ON SUBSTRING(pth,1,18) = b.Id
		LEFT JOIN UserRole c ON SUBSTRING(pth,19,18) = c.Id
		LEFT JOIN UserRole d ON SUBSTRING(pth,37,18) = d.Id

GO

CREATE VIEW [Smgt].[DateView]
AS
  SELECT [date_key],
         [full_date] AS [Date],
         [day_of_week] AS [Day of the Week],
         [day_num_in_month] AS [Day Number of the Month],
		 [day_num_in_year] AS [Day Number of the Year],
         [day_name] AS [Day Name],
         [day_abbrev] AS [Day Abbreviated],
         [weekday_flag]  AS [Weekday Flag],
         [week_num_in_year] AS [Week Number in Year],
         [week_begin_date] AS [Week Begin Date],
         [week_begin_date_key],
         [month],
         [month_name] AS [Month Name],
         [month_abbrev],
         [quarter],
         [year],
         [yearmo],
         [fiscal_month] AS [Fiscal Month],
         [fiscal_quarter] AS [Fiscal Quarter],
         [fiscal_year] AS [Fiscal Year],
         [last_day_in_month_flag],
         [same_day_year_ago_date],
         [same_day_year_ago_key],
         [quarter_name],
         [fiscal_quarter_name] AS [Fiscal Quarter Name],
         [fiscalyearcompletename] AS [Fiscal Year Name],
         [fiscalquartercompletename] AS [Fiscal Quarter Full Name],
		 [FiscalMonthCompleteName] AS [Fiscal Month Full Name]
  FROM   [Smgt].[date]

GO

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

GO

CREATE VIEW [Smgt].[MeasuresView]
AS
  SELECT TOP 0 1 AS MeasureValues

GO

CREATE VIEW [Smgt].[OpportunityProductView]
AS
  SELECT [Product2Id]								AS [Product Id],
         Opportunityid								AS [Opportunity Id],
         [TotalPrice]								AS [Revenue]
  FROM   dbo.OpportunityLineItem

GO

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

GO

CREATE VIEW [Smgt].[ProductView]
AS
	SELECT 
		id			AS [Product Id],
		name		AS [Product Name],
		1			AS [level],
		Family		AS [Level1],
		Name		AS [Level2],
		NULL		AS [Level3]
	FROM dbo.Product2
	WHERE ( IsActive = 1)



GO

CREATE VIEW [Smgt].[QuotaView]
AS
  SELECT [quota],
         CONVERT(DATE, [date], 101) AS [Date],
         [ownerid] AS [Owner Id],
         [productid] AS [Product Id]
  FROM   [Smgt].[Quotas]

GO

CREATE VIEW [Smgt].[TargetView]
AS
  SELECT CONVERT(uniqueidentifier,[productid]) AS [Product Id],
         CONVERT(uniqueidentifier,[businessunitid]) AS [Business Unit Id],
         CONVERT(uniqueidentifier,[territoryid]) AS [Territory Id],
         [target] AS [Target],
         CONVERT(DATE, [date], 101) AS [Date]
  FROM   [Smgt].[targets]

GO

CREATE VIEW [Smgt].[TerritoryView]
AS
  SELECT
    NULL AS [Territory Name],
    NULL AS [territory Id]
  

GO

CREATE VIEW [Smgt].[UserMappingView]
	AS 
	SELECT 
		OwnerId AS [Owner Id],
		DomainUser AS [Domain User]
	 FROM [smgt].userMapping

GO

CREATE VIEW [Smgt].[UserView]
AS
SELECT	a.name										AS [Full Name], 
			a.id									AS [User Id], 
			a.managerid								AS [Parent User Id], 
			0										AS [hierarchy level], 
			b.name									AS [Manager Name]
  FROM dbo.[User] a
  join dbo.[user] b ON a.managerid = b.id
  
  UNION ALL
  
  SELECT b.name										AS [Full Name],                     
         b.id										AS [User Id], 
         '000000000000000000'						AS [Parent User Id], 
         1                                       AS [hierarchy level], 
         'Root'										AS [Manager Name]
FROM (SELECT  name, id 
		FROM      dbo.[User]
        WHERE   managerid = '' OR managerid IS NULL)  AS b
  
 UNION ALL
 SELECT 'Root'										AS [Full Name], 
		'000000000000000000'						AS [User Id], 
		'000000000000000000'						AS [Parent User Id], 
		1										AS [hierarchy level], 
	    'Root'										AS [Manager Name]

GO

CREATE VIEW [Smgt].[AccountSecurityView]
	AS 

  WITH tree([User Id], [parent user id], [full name], [Account ID])
       AS (SELECT [User Id],
                  [parent User Id],
                  [Full Name],
                  [Account ID]
           FROM   [Smgt].[accountview]
                  JOIN (SELECT [full name],
                               [User Id],
                               CASE
                                 WHEN [User Id] = [Parent User Id] THEN NULL
                                 ELSE [Parent User Id]
                               END AS [Parent User Id],
                               [manager name]
                        FROM   [Smgt].[userview]) systemuser
                    ON [Smgt].[accountview].[Owner Id] = systemuser.[User Id]
           UNION ALL
           SELECT parent.[User Id],
                  parent.[Parent User Id],
                  parent.[full name],
                  [Account ID]
           FROM   tree child
                  INNER JOIN (SELECT [full name],
                                     [User Id],
                                     CASE
                                       WHEN [User Id] = [Parent User Id] THEN NULL
                                       ELSE [Parent User Id]
                                     END AS [Parent User Id],
                                     [manager name]
                              FROM   [Smgt].[userview]) parent
                          ON child.[Parent User Id] = parent.[User Id]
           WHERE  child.[Parent User Id] IS NOT NULL)
  SELECT *
  FROM   tree

GO

CREATE VIEW [Smgt].[LeadSecurityView]
AS
  WITH tree([user id], [parent user id], [full name], [lead id])
       AS (SELECT [user id],
                  [parent user id],
                  [full name],
                  [lead id]
           FROM   [Smgt].leadview
                  JOIN (SELECT [full name],
                               [user id],
                               CASE
                                 WHEN [user id] = [Parent User Id] THEN NULL
                                 ELSE [Parent User Id]
                               END AS [Parent User Id],
                               [manager name]
                        FROM   [Smgt].[userview]) systemuser
                    ON [Smgt].leadview.[Owner Id]= systemuser.[user id]
           UNION ALL
           SELECT parent.[user id],
                  parent.[Parent User Id],
                  parent.[full name],
                  [lead id]
           FROM   tree child
                  INNER JOIN (SELECT [full name],
                                     [user id],
                                     CASE
                                       WHEN [user id] = [Parent User Id] THEN NULL
                                       ELSE [Parent User Id]
                                     END AS [Parent User Id],
                                     [manager name]
                              FROM   [Smgt].[userview]) parent
                          ON child.[Parent User Id] = parent.[user id]
           WHERE  child.[Parent User Id] IS NOT NULL)
  SELECT *
  FROM   tree

GO

CREATE VIEW [Smgt].[OpportunitySecurityView]
AS
  WITH tree([User Id], [parent user id], [full name], [Opportunity ID])
       AS (SELECT [User Id],
                  [parent User Id],
                  [Full Name],
                  [Opportunity ID]
           FROM   [Smgt].opportunityview
                  JOIN (SELECT [full name],
                               [User Id],
                               CASE
                                 WHEN [User Id] = [Parent User Id] THEN NULL
                                 ELSE [Parent User Id]
                               END AS [Parent User Id],
                               [manager name]
                        FROM   [Smgt].[userview]) systemuser
                    ON [Smgt].[opportunityview].[Owner Id] = systemuser.[User Id]
           UNION ALL
           SELECT parent.[User Id],
                  parent.[Parent User Id],
                  parent.[full name],
                  [Opportunity ID]
           FROM   tree child
                  INNER JOIN (SELECT [full name],
                                     [User Id],
                                     CASE
                                       WHEN [User Id] = [Parent User Id] THEN NULL
                                       ELSE [Parent User Id]
                                     END AS [Parent User Id],
                                     [manager name]
                              FROM   [Smgt].[userview]) parent
                          ON child.[Parent User Id] = parent.[User Id]
           WHERE  child.[Parent User Id] IS NOT NULL),
       
       accounttree([User Id], [parent user id], [full name], [Account ID])
       AS (SELECT [User Id],
                  [parent User Id],
                  [Full Name],
                  [Account ID]
           FROM   [Smgt].[accountview]
                  JOIN (SELECT [full name],
                               [User Id],
                               CASE
                                 WHEN [User Id] = [Parent User Id] THEN NULL
                                 ELSE [Parent User Id]
                               END AS [Parent User Id],
                               [manager name]
                        FROM   [Smgt].[userview]) systemuser
                    ON [Smgt].[accountview].[Owner Id] = systemuser.[User Id]
           UNION ALL
           SELECT parent.[User Id],
                  parent.[Parent User Id],
                  parent.[full name],
                  [Account ID]
           FROM   accounttree child
                  INNER JOIN (SELECT [full name],
                                     [User Id],
                                     CASE
                                       WHEN [User Id] = [Parent User Id] THEN NULL
                                       ELSE [Parent User Id]
                                     END AS [Parent User Id],
                                     [manager name]
                              FROM   [Smgt].[userview]) parent
                          ON child.[Parent User Id] = parent.[User Id]
           WHERE  child.[Parent User Id] IS NOT NULL)
  
  
  SELECT 
    [User Id], 
    [parent user id], 
    [full name], 
    [Opportunity ID]
  FROM   tree
  
  UNION ALL
  
  SELECT 
  accounttree.[User Id] AS [User Id],
  accounttree.[parent user id] AS [parent user id],
  accounttree.[full name] AS [full name],
  tree.[Opportunity ID] AS [Opportunity ID]
  FROM tree LEFT JOIN Smgt.OpportunityView ov ON tree.[Opportunity ID] = ov.[Opportunity Id] 
  LEFT OUTER JOIN accounttree ON ov.[Account Id] = accounttree.[Account ID]

GO

