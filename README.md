# Power BI Solution Template

The Power BI Sales Management Solution Template reduces the time to implement a Power BI solution on Dynamics CRM or Salesforce.

Two deployment options are available depending on customer requirements. Both approaches benefit from fast ETL loads with incremental updates. Where they differ is where the model and data reside.

__Option 1 - Power BI Model__

In the Power BI Model, the model and data reside within the .pbix file. When published to PowerBI.com, the data can be refreshed from the source. Advantages of the Power BI Model approach include Cortana integration and natural language querying. The model data volume is limited to 250 MB (although this is the compressed figure – this restriction only becomes a factor for large CRM implementations).

__Option 2 - SSAS Model__

With this approach, the data and model reside in an instance of SQL Server Analysis Services separate from Power BI. This is recommended when data volumes exceed the 250MB limit or when performance requirements exceed what Power BI can provide.

The SSAS Model also supports row level security with rules derived from the source application (this feature will be supported in the Power BI Model in the summer of 2016).

## Option 1 - Power BI Model

### Prerequisites

The following software must be available:
* A Power BI Pro subscription.
* Salesforce data source requirements:
  * An [Informatica account](https://www.informatica.com/).
  * An on premise [Informatica Agent](https://network.informatica.com/docs/DOC-14954).
* Dynamics CRM data source requirements:
  * [Scribe Online account](http://www.scribesoft.com/products/scribe-online/) is required.
  * On premise [Scribe Agent](http://help.scribesoft.com/scribeonline/en/sol/agent/agentinstall.htm) must be installed.
  * Scribe API access range must include the server's ID Address (Organization tab -> Security).
  * Scribe Dynamics CRM and SQL Server Database connectors must be enabled.
* A destination database - either:
  * Azure SQL DB, or
  * SQL Server 2012 service pack 3 or later.
* PowerShell version 3 or later must be available on the machine where the installation script is run.

### Step 1: Configure the base INI file settings

A sample INI file has been provided (Release\Scripts\sample.ini) alongside the setup.ps1 script to configure the Solution.

#### Basic INI Contents

Key/Value | Meaning
--- | ---
`sql_server=[server name]` | SQL Server host and instance name to use (in the form of &lt;host&gt;\\&lt;instance&gt;, or &lt;instance&gt; for on premises connections)
`sql_database=[database name]` | SQL Server database name to create
`sql_user_id=[username]` `sql_password` | SQL Server username and password for SQL Server Authentication (comment or remove these two lines to use integrated authentication)
`use_ssas=[true | false]` | __Special Note:__ Set this to false for Power BI deployments
`ssas_server=[server name]` | Not applicable for this option
`ssas_database=[AS database name]` | Not applicable for this option
`type_etl=[informatica | scribe]` | ETL tool to use
`type_source=[dynamics | salesforce]` | Data source to replicate

### Step 2: Configure the ETL INI file settings

Refer to the addendums depending on the ETL tool selected - Informatica or Scribe.

### Step 3: Run setup.ps1

1. Open a new PowerShell console running as administrator.
2. Run the following PowerShell command to enable scripting for this session: `Set-ExecutionPolicy Bypass`
3. Navigate to the directory containing setup.ps1
4. Execute setup.ps1 with the following command: `.\setup.ps1`

### Step 4: Post Deployment

1. __If using Informatica, create a new Task using the newly created connections and select only the following entities to pull:__
  * account
  * lead
  * opportunity
  * OpportunityLineItem
  * OpportunityStage
  * product2
  * user
  * UserRole
2. __If using Scribe, edit the newly created Scribe Solution to pull only the following entities:__
  * account
  * businessunit
  * lead
  * opportunity
  * opportunityproduct
  * product
  * systemuser
  * systemusermanagermap
  * territory

### Step 5: Configure the Enterprise Gateway

[Power BI Enterprise Gateway](https://powerbi.microsoft.com/en-us/documentation/powerbi-gateway-enterprise/) must be installed and configured if the database resides on an on premise server or in a VM (either on premise or Azure).

### Step 6: Setting up the Dashboards using Power BI

Open Release\PowerBIReport\SalesManagementReportwithData.pbix

To refresh the report with data from the source CRM application, the data sources in the Power BI file must first be updated.

1. From the task bar, select "Edit Queries".
2. For each and every table in the model, repeat the following steps:
  1. Select "Advanced Editor".
  2. In the Advanced Editor, update the M script to refer to the data source instance and database name by replacing the highlighted areas:
`let`
  `Source = Sql.Databases("`[server name]`"),`
  `CRM = Source{[Name="`[database name]`"]}[Data],`
  `Smgt_AccountView = CRM{[Schema="Smgt",Item="AccountView"]}[Data]`
`in`
  `Smgt_AccountView`
3. After all tables' datasources have been updated, select "Close and Apply".
4. From the Report Editor, select "Refresh".

### Step 7: Publish the report to PowerBI.com

To publish the report, select the "Publish" icon in the task bar. For on premise data sources or data sources in Azure virtual machines, the Enterprise Gateway must be installed and configured.

__Congratulations__ - you have successfully deployed the solution template!

## Option 2 - SQL Server Analysis Services Model

### Prerequisites

The following software must be available:
* A Power BI Pro subscription.
* Salesforce data source requirements:
  * An [Informatica account](https://www.informatica.com/).
  * An on premise [Informatica Agent](https://network.informatica.com/docs/DOC-14954).
* Dynamics CRM data source requirements:
  * [Scribe Online account](http://www.scribesoft.com/products/scribe-online/) is required.
  * On premise [Scribe Agent](http://help.scribesoft.com/scribeonline/en/sol/agent/agentinstall.htm) must be installed.
  * Scribe API access range must include the server's ID Address (Organization tab -> Security).
  * Scribe Dynamics CRM and SQL Server Database connectors must be enabled.
* An Azure Virtual Machine with a minimum recommended size of A3 or an on premise server with equivalent or greater technical specifications.
* SQL Server Enterprise Edition with a SQL Server Database (2012 service pack 3 or later).
  * SQL Server Analysis Services must be available and configured in tabular mode.
  * SQL Server Agent must be enabled.
* PowerShell version 3 or later must be available on the machine where the installation script is run.
  * The Active Directory PowerShell module must be available (installed with [Remote Server Administration Tools](https://www.microsoft.com/en-us/download/details.aspx?id=45520)).

### Step 1: Configure the Base INI file Settings

#### Base INI Contents

Key/Value | Meaning
--- | ---
`sql_server=[server name]` | SQL Server host and instance name to use (in the form of &lt;host&gt;\\&lt;instance&gt;, or &lt;instance&gt; for on premises connections)
`sql_database=[database name]` | SQL Server database name to create
`sql_user_id=[username]` `sql_password` | SQL Server username and password for SQL Server Authentication (comment or remove these two lines to use integrated authentication)
`use_ssas=[true | false]` | __Special Note:__ Set this to true for SSAS deployments
`ssas_server=[server name]` | SQL Server Analysis Services host and instance name to use (in the form of &lt;host&gt;\\&lt;instance&gt;, or &lt;instance&gt; for on premises connections)
`ssas_database=[AS database name]` | SQL Server Analysis Services database name to create
`type_etl=[informatica | scribe]` | ETL tool to use
`type_source=[dynamics | salesforce]` | Data source to replicate

### Step 2: Configure the ETL INI file settings

Refer to the addendums depending on the ETL tool selected - Informatica or Scribe.

### Step 3: Run setup.ps1

1. Open a new PowerShell console running as administrator.
2. Run the following PowerShell command to enable scripting for this session: `Set-ExecutionPolicy Bypass`
3. Navigate to the directory containing setup.ps1
4. Execute setup.ps1 with the following command: `.\setup.ps1`

### Step 4: Post Deployment

1. __If using Informatica, create a new Task using the newly created connections and select only the following entities to pull:__
  * account
  * lead
  * opportunity
  * OpportunityLineItem
  * OpportunityStage
  * product2
  * user
  * UserRole
2. __If using Scribe, edit the newly created Scribe Solution to pull only the following entities:__
  * account
  * businessunit
  * lead
  * opportunity
  * opportunityproduct
  * product
  * systemuser
  * systemusermanagermap
  * territory
3. Configure the SQL Server Agent jobs
  1. Open SQL Server Configuration Manager and configure the SQL Server Agent to run as a domain account.
  2. In SQL Server Management Studio:
    1. Open the Properties of the newly created "Save credential" SQL Server Agent job and edit the job at the "Encrypt" step.
    2. Replace the following line with your ETL account password (Informatica or Scribe): `put password here, run, then set back to empty string`
    3. Run the "Save credential" job, then remove your password by editing the job again.
    4. Run the "Data load and processing" job to pull data from your source or create a schedule for when it should run.

### Step 5: Configure the Enterprise Gateway

[Power BI Enterprise Gateway](https://powerbi.microsoft.com/en-us/documentation/powerbi-gateway-enterprise/) must be installed and configured if the database resides on an on premise server or in a VM (either on premise or Azure).

### Step 6: Setting up the Dashboards using Power BI

1. Open Release\PowerBIReport\SalesManagementReport.pbix
2. The Connection to SQL Server Analysis Services generally needs to be updated.
3. Click "Edit" and enter the server name where SQL Server Analysis Services was installed.
4. Update the connection to SQL Server Database or SQL Server Analysis Services based on the deployed environment.

__Congratulations__ - you have successfully deployed the solution template!

## Addendum A: Populated Actual and Quota Values

## Addendum B: Informatica INI Contents

Key/Value | Meaning
--- | ---
`user=[Informatica account]` `password=[password]` | Informatica username and password
`url=https://app.informaticaondemand.com` | Informatica API url
`organization_id=11111` | Informatica organization ID
`task_name=[Informatica task name]` | Informatica task name to use
`source.agent_name` | Informatica agent name to use
`source.name=[SampleSource]` | Informatica source connection name to create
`source.user=[user@company.com]` `source.password=[password]` | The Salesforce username and password used by Informatica
`source.token=0000000000000000000000000` | The Salesforce Security Token - a 24 character string available in Salesforce
`target.agent_name=SampleAgent` | The name of the Informatica agent used to replicate data
`target.name=SampleTarget` | Informatica target connection name to create
`target.hostname=[server name]` | The same SQL Server name as used by the top level entry (see sql_server=)
`target.database=[database name]` | The same SQL Server database name as used by the top level entry (see sql_database=)
`target.user=[username]` `target.password=[password]` | SQL Server username and password

## Addendum C: Scribe INI Contents

Key/Value | Meaning
--- | ---
`user=user@company.com` `password=password` | Scribe username and password
`salt=ac103458-fcb6-41d3-94r0-43d25b4f4ff4` | Scribe salt to use (do not modify unless requested by Scribe)
`key=00000000-0000-0000-0000-000000000000` | Scribe encoding key to use (accessible from the Organization tab -> Security -> API Cryptographic Token)
`organization_id=11111` | Scribe organization ID (accessible from the Organization tab)
`agent_name=SampleAgent` | Scribe agent name to use
`solution_name=SampleSolution` | Scribe solution name to create (Maximum number of characters: 25)
`source.name=SampleSource` | Scribe source connection name to create (Maximum number of characters: 25)
`source.type=CRM` | Scribe source type (CRM)
`source.user=[username]` `source.password=password` | Dynamics CRM username and password
`source.organization=Microsoft` | Dynamics CRM organization name
`source.deploy=[deployment type]` | Dynamics CRM deployment type (Online | On-Premise | Partner-Hosted (IFD))
`source.url=https://disco.crm.dynamics.com` | Dynamics CRM url
`target.name=SampleTarget` | Scribe target connection name to create (Maximum number of characters: 25)
`target.type=MSSQL` | Scribe target type
`target.server=[server name]` | The same SQL Server name as used by the top level entry (see sql_server=)
`target.database=[database name]` | The same SQL Server database name as used by the top level entry (see sql_database=)
`target.authentication=SQL Server` | SQL Server Authentication type. Only SQL authentication is currently supported.
`target.user=[user name]` `target.password=[password]` | SQL Server username and password

## Addendum D: Changing the Fiscal Calendar

In order to change the fiscal start month, you will need to go to the Smgt.Configuration table and update the record FiscalMonthStart. By default, it is set to 1. To update it you would need to run the following script:

`UPDATE [Smgt].[configuration] SET [value] = 1 WHERE [name] = 'FiscalMonthStart'`

To support other types of fiscal calendars you would need to reinsert the data into the date table and ensure the fields beginning with Fiscal are populated including the calculated columns and measurers inside the date table within the model.
