CREATE VIEW [Smgt].[ProductView]
AS
	SELECT 
		id			AS [Product Id],
		name		AS [Product Name],
		1			AS [level],
		Family		AS [Product Level 1],
		Name		AS [Product Level 2],
		NULL		AS [Product Level 3]
	FROM dbo.Product2
	WHERE ( IsActive = 1)


