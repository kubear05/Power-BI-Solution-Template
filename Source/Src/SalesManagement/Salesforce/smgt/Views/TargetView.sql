CREATE VIEW [Smgt].[TargetView]
AS
  SELECT CONVERT(uniqueidentifier,[productid]) AS [Product Id],
         CONVERT(uniqueidentifier,[businessunitid]) AS [Business Unit Id],
         CONVERT(uniqueidentifier,[territoryid]) AS [Territory Id],
         [target] AS [Target],
         CONVERT(DATE, [date], 101) AS [Date]
  FROM   [Smgt].[targets]
