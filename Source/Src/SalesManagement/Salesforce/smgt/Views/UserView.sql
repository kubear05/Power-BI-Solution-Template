CREATE VIEW [Smgt].[UserView]
AS
SELECT	a.name										AS [Full Name], 
			a.id									AS [User Id], 
			a.managerid								AS [Parent User Id], 
			0										AS [hierarchy level], 
			b.name									AS [Manager Name]
  FROM dbo.[User] a
  INNER JOIN dbo.[user] b ON a.managerid = b.id
  WHERE a.MANAGERID in (select id from dbo.[user] where isactive=1)
  
  UNION ALL
  
  SELECT b.name										AS [Full Name],                     
         b.id										AS [User Id], 
         '000000000000000000'						AS [Parent User Id], 
         1                                       AS [hierarchy level], 
         'Root'										AS [Manager Name]
FROM (SELECT  name, id 
		FROM      dbo.[User]
        WHERE   isactive=1 AND (managerid = '' OR managerid IS NULL OR 
			managerid NOT IN (SELECT id FROM dbo.[user] WHERE isactive=1 ) ) ) AS b
  
 UNION ALL

 SELECT 'Root'										AS [Full Name], 
		'000000000000000000'						AS [User Id], 
		'000000000000000000'						AS [Parent User Id], 
		1										AS [hierarchy level], 
	    'Root'										AS [Manager Name]