CREATE VIEW [Smgt].[QuotaView]
AS
  SELECT [Amount] AS Amount,
         CONVERT(DATE, [date], 101) AS [Date],
         [ownerid] AS [Owner Id],
         [productid] AS [Product Id]
  FROM   [Smgt].[Quotas]