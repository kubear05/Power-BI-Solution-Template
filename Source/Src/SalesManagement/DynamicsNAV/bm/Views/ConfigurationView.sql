CREATE VIEW [bm].[ConfigurationView]
AS
SELECT [id]
      ,[configuration_group]			as [Configuration Group]
      ,[configuration_subgroup]			as [Configuration Subgroup]
      ,[name]					as [Name]
      ,[value]					as [Value]		
  FROM [bm].[configuration] where visible=1
  