CREATE VIEW [Smgt].[OpportunityProductView]
AS
  SELECT [Product2Id]								AS [Product Id],
         Opportunityid								AS [Opportunity Id],
         [TotalPrice]								AS [Revenue]
  FROM   dbo.OpportunityLineItem
