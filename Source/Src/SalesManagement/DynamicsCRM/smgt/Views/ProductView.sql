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
         CONVERT(VARCHAR, b.NAME) AS [Product Level 1],
         CONVERT(VARCHAR, c.NAME) AS [Product Level 2],
         CONVERT(VARCHAR, d.NAME) AS [Product Level 3]
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