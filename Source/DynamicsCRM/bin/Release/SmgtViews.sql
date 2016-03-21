CREATE VIEW [Smgt].[AccountView]
AS
  SELECT accountid						AS [Account Id], 
         NAME							AS [Account Name],
         ownerid						AS [Owner Id],
         territoryid					AS [Territory Id],
         CONVERT(INT, industrycode)		AS [Industry],
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
         NULL							AS [Owner Id],
         NULL							AS [Territory Id],
         NULL							AS [Industry],
         owningbusinessunit				AS [Business Unit Id],
		 NULL							AS [City],
		 NULL							AS [State],
		 NULL							AS [Country],
		 NULL							AS [Annual Revenue]
  FROM   dbo.opportunity
  WHERE ( parentaccountid IS NULL AND scribe_deletedon IS NULL )

GO

CREATE VIEW [smgt].[ActualSalesView]
AS
  SELECT InvoiceId								AS [Invoice Id],
         ActualSales							AS [Actual Sales],
         CONVERT(Date,InvoiceDate)				AS [Invoice Date],
         CONVERT(uniqueidentifier,[accountId])	AS [Account Id],
         CONVERT(uniqueidentifier, [productId]) AS [Product Id]
  FROM   smgt.actualsales

  WHERE  EXISTS (SELECT *
                 FROM   smgt.configuration
                 WHERE  configuration_group = 'DATA'
                        AND configuration_subgroup = 'actual_sales'
                        AND [name] = 'enabled'
                        AND value = '1')

UNION ALL

-- This gets the Opportunity's OpportunityProducts that can be prorated.
SELECT
		CONVERT(VARCHAR(50), op.OpportunityProductid)							AS [Invoice Id],
         op.baseamount_base * o.actualvalue_base/o.totallineitemamount_base     AS [Actual Sales],   -- Allocate line items based on ratio to actual total
         CONVERT(Date,o.actualclosedate)													AS [Invoice Date],
         CONVERT(uniqueidentifier,o.parentaccountid)							AS [Account ID],
         CONVERT(uniqueidentifier, op.productid)								AS [Product ID]
  FROM   dbo.opportunity AS o
         INNER JOIN dbo.opportunityproduct AS op
                 ON o.opportunityid = op.opportunityid
  WHERE  o.statuscode_displayname = 'Won'
  AND op.baseamount_base>0 and not op.baseamount_base is null
  AND NOT EXISTS (SELECT *
                 FROM   smgt.configuration
                 WHERE  configuration_group = 'DATA'
                        AND configuration_subgroup = 'actual_sales'
                        AND [name] = 'enabled'
                        AND value = '1')

  UNION ALL
  -- This gets the Opportunities for which there are no OpportunityProducts that can be used
  SELECT CONVERT(VARCHAR(50), o.opportunityid)			AS [Invoice Id],
         o.actualvalue_base								AS [Actual Sales],
         CONVERT(Date,o.actualclosedate)				AS [Invoice Date],
         CONVERT(uniqueidentifier,o.parentaccountid)	AS [Account ID],
         null											AS [Product ID]
  FROM   dbo.opportunity AS o
  WHERE  o.statuscode_displayname = 'Won'
  AND NOT EXISTS (SELECT 1 FROM OpportunityProduct op where op.opportunityid=o.opportunityid and op.baseamount_base>0)
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
       AS (SELECT parentbusinessunitid,
                  parentbusinessunitidname,
                  businessunitid,
                  NAME,
                  0                                                                AS Level,
                  Cast(businessunitid AS VARCHAR(max))                             AS pth
           FROM   [dbo].businessunit
           WHERE  parentbusinessunitid IS NULL
           AND ( scribe_deletedon IS NULL )
           UNION ALL
           SELECT a.parentbusinessunitid,
                  a.parentbusinessunitidname,
                  a.businessunitid,
                  a.NAME,
                  t.level + 1,
                  t.pth + Cast(a.businessunitid AS VARCHAR(max))
           FROM   tree AS t
                  JOIN businessunit AS a
                    ON a.parentbusinessunitid = t.businessunitid)
  SELECT hierarchy.businessunitid AS [Business Unit Id],
         hierarchy.NAME AS [Business Unit Name],
         level,
         CONVERT(VARCHAR, b.NAME) AS Level1,
         CONVERT(VARCHAR, c.NAME) AS Level2,
         CONVERT(VARCHAR, d.NAME) AS Level3
  FROM   (SELECT businessunitid,
                 NAME,
                 level,
                 CONVERT(UNIQUEIDENTIFIER, NULLIF(Substring(pth, 1, 36), ''))  AS Level1,
                 CONVERT(UNIQUEIDENTIFIER, NULLIF(Substring(pth, 37, 36), '')) AS Level2,
                 CONVERT(UNIQUEIDENTIFIER, NULLIF(Substring(pth, 73, 36), '')) AS Level3
          FROM   tree) AS hierarchy
         LEFT JOIN businessunit AS b
                ON b.businessunitid = level1
         LEFT JOIN businessunit AS c
                ON c.businessunitid = level2
         LEFT JOIN businessunit AS d
                ON d.businessunitid = level3;

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

GO

CREATE VIEW [Smgt].[MeasuresView]
AS
  SELECT TOP 0 1 AS MeasureValues

GO

CREATE VIEW [Smgt].[OpportunityProductView]
AS
  SELECT CONVERT(UNIQUEIDENTIFIER, productid) AS [Product Id],
         opportunityid                        AS [Opportunity Id],
         baseamount_base                      AS [Revenue]
  FROM   dbo.opportunityproduct
  WHERE  ( scribe_deletedon IS NULL )

GO

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
         o.salesstage_displayname					AS [Sales Stage],
         o.statecode_displayname					AS [State],
         o.originatingleadid						AS [Lead Id],
         o.opportunityratingcode_displayname		AS [Opportunity Rating Name],
         NULL										AS [Source]
  FROM   dbo.opportunity o 
  WHERE  ( o.scribe_deletedon IS NULL )
GO

GO

CREATE VIEW [Smgt].[ProductView]
AS
  WITH tree
       AS (SELECT parentproductid,
                  parentproductidname,
                  productid,
                  NAME,
                  0                                                           AS Level,
                  Cast(productid AS VARCHAR(max))                             AS pth
           FROM   product
           WHERE  parentproductid IS NULL
                  AND ( scribe_deletedon IS NULL )
           UNION ALL
           SELECT a.parentproductid,
                  a.parentproductidname,
                  a.productid,
                  a.NAME,
                  t.[level] + 1,
                  t.pth + Cast(a.productid AS VARCHAR(max))
           FROM   tree AS t
                  JOIN product AS a
                    ON a.parentproductid = t.productid)
  SELECT hierarchy.productid AS [Product Id],
         hierarchy.NAME AS [Product Name],
         [level],
         CONVERT(VARCHAR, b.NAME) AS Level1,
         CONVERT(VARCHAR, c.NAME) AS Level2,
         CONVERT(VARCHAR, d.NAME) AS Level3
  FROM   (SELECT productid,
                 NAME,
                 [level],
                 CONVERT(UNIQUEIDENTIFIER, NULLIF(Substring(pth, 1, 36), ''))  AS Level1,
                 CONVERT(UNIQUEIDENTIFIER, NULLIF(Substring(pth, 37, 36), '')) AS Level2,
                 CONVERT(UNIQUEIDENTIFIER, NULLIF(Substring(pth, 73, 36), '')) AS Level3
          FROM   tree) AS hierarchy
         LEFT JOIN product AS b
                ON b.productid = level1
         LEFT JOIN product AS c
                ON c.productid = level2
         LEFT JOIN product AS d
                ON d.productid = level3;

GO

CREATE VIEW [Smgt].[QuotaView]
AS
  SELECT [quota],
         CONVERT(DATE, [date], 101) AS [Date],
         CONVERT(uniqueidentifier, [ownerid]) AS [Owner Id],
         CONVERT(uniqueidentifier, [productid]) AS [Product Id]
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

CREATE VIEW [Smgt].[TempUserView]
AS
  SELECT a.fullname,
         CONVERT(UNIQUEIDENTIFIER, a.systemuserid)       AS systemuserid,
         CONVERT(UNIQUEIDENTIFIER, a.parentsystemuserid) AS parentsystemuserid,
         a.hierarchylevel,
         systemuser_1.fullname                           AS managername
  FROM   (SELECT dbo.systemuser.fullname,
                 dbo.systemuser.systemuserid,
                 dbo.systemusermanagermap.parentsystemuserid,
                 dbo.systemusermanagermap.hierarchylevel
          FROM   dbo.systemusermanagermap
                 LEFT OUTER JOIN dbo.systemuser
                              ON dbo.systemusermanagermap.systemuserid = dbo.systemuser.systemuserid) AS a
         LEFT OUTER JOIN dbo.systemuser AS systemuser_1
                      ON a.parentsystemuserid = systemuser_1.systemuserid
  WHERE  ( a.hierarchylevel = 1 )
  AND ( systemuser_1.isdisabled = 0 )
  AND ( scribe_deletedon IS NULL )

GO

CREATE VIEW [Smgt].[TerritoryView]
AS
  SELECT
    NAME AS [Territory Name],
    territoryid AS [Territory Id]
  FROM   [territory]
  WHERE  ( scribe_deletedon IS NULL )

GO

CREATE VIEW [Smgt].[UserMappingView]
	AS 
	SELECT 
		OwnerId AS [Owner Id],
		DomainName AS [Domain Name]
	 FROM [smgt].userMapping

GO

CREATE VIEW [Smgt].[UserView]
AS
  SELECT 
		fullname									AS [Full Name],      
		systemuserid								AS [User Id],
		parentsystemuserid							AS [Parent User Id],
        hierarchylevel								AS [Hierarchy Level],
        managername 								AS [Manager Name]
  FROM [smgt].TempUserView
  
  UNION ALL
  SELECT b.fullname									AS [Full Name],                                
         b.systemuserid								AS [User Id],
         '00000000-0000-0000-0000-000000000000'		AS [Parent User Id],
         1                                          AS [Hierarchy Level],
         'Root'										AS [Manager Name]
FROM (SELECT DISTINCT fullname, systemuserid 
                  FROM      [dbo].systemuser
                  WHERE   isdisabled = 0 AND SCRIBE_DELETEDON is NULL AND systemuserid NOT IN
                                        (SELECT DISTINCT systemuserid
                                         FROM      [Smgt].TempUserView )) AS b
  
 UNION ALL
 SELECT 'Root'											AS [Full Name], 
		'00000000-0000-0000-0000-000000000000'			AS [User Id],
		'00000000-0000-0000-0000-000000000000'			AS [Parent User Id],
		1												AS [Hierarchy Level],
	    'Root'											AS [Manager Name]

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
           WHERE  child.[Parent User Id] IS NOT NULL)
  SELECT *
  FROM   tree

GO

