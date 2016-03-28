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
