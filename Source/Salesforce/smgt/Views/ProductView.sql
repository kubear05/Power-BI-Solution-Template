CREATE VIEW [Smgt].[ProductView]
AS
	SELECT 
		id			AS [Product Id],
		name		AS [Product Name],
		1			AS [level],
		Family		AS [Level1],
		Name		AS [Level2],
		NULL		AS [Level3]
	FROM dbo.Product2
	WHERE ( IsActive = 1)


