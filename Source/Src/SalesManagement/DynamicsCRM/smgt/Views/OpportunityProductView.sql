CREATE VIEW [Smgt].[OpportunityProductView]
AS
  SELECT CONVERT(UNIQUEIDENTIFIER, productid) AS [Product Id],
         opportunityid                        AS [Opportunity Id],
         baseamount_base                      AS [Revenue]
  FROM   dbo.opportunityproduct
  WHERE  ( scribe_deletedon IS NULL )