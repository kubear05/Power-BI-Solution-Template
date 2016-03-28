CREATE VIEW [Smgt].[QuotaView]
AS
  SELECT [Amount] AS [Amount],
         CONVERT(DATE, [date], 101) AS [Date],
         CONVERT(uniqueidentifier, [ownerid]) AS [Owner Id],
         CONVERT(uniqueidentifier, [productid]) AS [Product Id]
  FROM   [Smgt].[Quotas]