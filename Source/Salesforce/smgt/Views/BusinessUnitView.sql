CREATE VIEW [Smgt].[BusinessUnitView]
AS
WITH tree
		AS (SELECT [Id], Name, ParentRoleId, 0 AS [Level], CAST(id AS VARCHAR(MAX)) AS pth
		FROM UserRole
		WHERE parentroleid = ''

		UNION ALL

		SELECT	a.[Id],
				a.Name,
				a.ParentRoleId,
				t.[Level] + 1,
				t.pth + CAST(a.id AS VARCHAR(MAX)) 
		FROM tree as t
			JOIN UserRole as a ON a.ParentRoleId = t.Id)

		SELECT t.id as [Business Unit Id],
		t.Name AS [Business Unit Name],
		Level, 
		b.Name AS [Level1],
		c.Name AS [Level2],
		d.Name AS [Level3]  
		FROM tree t 
		LEFT JOIN UserRole b ON SUBSTRING(pth,1,18) = b.Id
		LEFT JOIN UserRole c ON SUBSTRING(pth,19,18) = c.Id
		LEFT JOIN UserRole d ON SUBSTRING(pth,37,18) = d.Id