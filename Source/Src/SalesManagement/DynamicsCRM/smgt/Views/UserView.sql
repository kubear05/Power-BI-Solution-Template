CREATE VIEW [Smgt].[UserView]
AS
  SELECT 
		fullname									AS [Full Name],      
		systemuserid								AS [User Id],
		parentsystemuserid							AS [Parent User Id],
        hierarchylevel								AS [Hierarchy Level],
        managername 								AS [Manager Name]
  FROM [smgt].TempUserView
  
  UNION ALL
  SELECT b.fullname									AS [Full Name],                                
         b.systemuserid								AS [User Id],
         '00000000-0000-0000-0000-000000000000'		AS [Parent User Id],
         1                                          AS [Hierarchy Level],
         'Root'										AS [Manager Name]
FROM (SELECT DISTINCT fullname, systemuserid 
                  FROM      [dbo].systemuser
                  WHERE   isdisabled = 0 AND SCRIBE_DELETEDON is NULL AND systemuserid NOT IN
                                        (SELECT DISTINCT systemuserid
                                         FROM      [Smgt].TempUserView )) AS b
  
 UNION ALL
 SELECT 'Root'											AS [Full Name], 
		'00000000-0000-0000-0000-000000000000'			AS [User Id],
		'00000000-0000-0000-0000-000000000000'			AS [Parent User Id],
		1												AS [Hierarchy Level],
	    'Root'											AS [Manager Name]