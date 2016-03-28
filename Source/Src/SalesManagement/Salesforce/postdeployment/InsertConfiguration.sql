/*

-- Configuration entries
INSERT Smgt.configuration (configuration_group, configuration_subgroup, [name]) VALUES ('scribe', 'connection_info', 'user_id');
INSERT Smgt.configuration (configuration_group, configuration_subgroup, [name]) VALUES ('scribe', 'connection_info', 'password');
INSERT Smgt.configuration (configuration_group, configuration_subgroup, [name]) VALUES ('scribe', 'connection_info', 'org_id');
INSERT Smgt.configuration (configuration_group, configuration_subgroup, [name]) VALUES ('scribe', 'connection_info', 'solution');
*/

INSERT Smgt.configuration (configuration_group, configuration_subgroup, [name], [value]) VALUES (N'data', N'actual_sales', N'enabled', N'0');
INSERT Smgt.configuration (configuration_group, configuration_subgroup, [name], [value]) VALUES (N'SolutionTemplate', N'SalesManagement', N'version', N'1.0');
INSERT Smgt.configuration (configuration_group, configuration_subgroup, [name], [value], [visible]) VALUES (N'SolutionTemplate', N'SalesManagement', N'FiscalMonthStart', N'1', 1);
GO