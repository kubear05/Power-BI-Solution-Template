CREATE VIEW [Smgt].[TempUserView]
AS
  SELECT a.fullname,
         CONVERT(UNIQUEIDENTIFIER, a.systemuserid)       AS systemuserid,
         CONVERT(UNIQUEIDENTIFIER, a.parentsystemuserid) AS parentsystemuserid,
         a.hierarchylevel,
         systemuser_1.fullname                           AS managername
  FROM   (SELECT dbo.systemuser.fullname,
                 dbo.systemuser.systemuserid,
                 dbo.systemusermanagermap.parentsystemuserid,
                 dbo.systemusermanagermap.hierarchylevel
          FROM   dbo.systemusermanagermap
                 LEFT OUTER JOIN dbo.systemuser
                              ON dbo.systemusermanagermap.systemuserid = dbo.systemuser.systemuserid
		  WHERE systemusermanagermap.SCRIBE_DELETEDON is NULL) AS a
          LEFT OUTER JOIN dbo.systemuser AS systemuser_1
                      ON a.parentsystemuserid = systemuser_1.systemuserid
  WHERE  ( a.hierarchylevel = 1 )
  AND ( systemuser_1.isdisabled = 0 )
  AND ( scribe_deletedon IS NULL )