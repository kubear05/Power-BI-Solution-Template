CREATE VIEW [Smgt].[ConfigurationView]
AS
SELECT [id]
      ,[configuration_group]			as [Configuration Group]
      ,[configuration_subgroup]			as [Configuration Subgroup]
      ,[name]					as [Name]
      ,[value]					as [Value]		
  FROM [Smgt].[configuration] where visible=1
  