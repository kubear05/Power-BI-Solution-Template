
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