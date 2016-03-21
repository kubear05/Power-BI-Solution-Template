CREATE VIEW [Smgt].[TerritoryView]
AS
  SELECT
    NAME AS [Territory Name],
    territoryid AS [Territory Id]
  FROM   [territory]
  WHERE  ( scribe_deletedon IS NULL )