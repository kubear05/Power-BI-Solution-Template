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