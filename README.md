# Power BI Solution Template

The Power BI Solution Template brings together opportunity, target and actual sales data to provide a complete sales management reporting solution. The following instructions will help you configure and deploy the Solution Template.

## Prerequisites

* An Azure Virtual Machine with a minimum recommended size of A3 or an on premise server with equivalent or greater technical specifications.
  * PowerShell version 3 or greater must be available on the server.
  * The Active Directory PowerShell module must be available (This is installed alongside [Remote Server Administration Tools](https://www.microsoft.com/en-us/download/details.aspx?id=45520)).
* SQL Server Enterprise Edition with a SQL Server Database (2012 service pack 3 or later).
  * SQL Server Analysis Server in tabular mode is optional.
  * SQL Server Agent must be enabled.
* A Power BI Pro Subscription
* If using Salesforce as a data source:
  * An [Informatica account](https://www.informatica.com/).
  * An on premise [Informatica Agent](https://network.informatica.com/docs/DOC-14954).
* If using Dynamics CRM as a data source:
  * A [Scribe Online account](http://www.scribesoft.com/products/scribe-online/).
    * API access range must include the server's IP Address (Organization tab &gt; Security).
    * Replication Services must be enabled.
    * Dynamics CRM and SQL Server Database connectors must be enabled.
  * An on premise [Scribe Agent](http://help.scribesoft.com/scribeonline/en/sol/agent/agentinstall.htm).

## Step 1: Configure the INI file

A sample INI file has been provided (Scripts\sample.ini) alongside the setup.ps1 script to configure the Solution.

### INI Root

Key/Value | Meaning
--- | ---
`sql_server=servername` | SQL Server host and instance name to use (in the form of &lt;host&gt;\\&lt;instance&gt;, or &lt;instance&gt; for on premises connections)
`sql_database=CRM`	| SQL Server database name to create
`sql_user_id=sa` `sql_password=password`	| SQL Server username and password for SQL Server Authentication (comment or remove these two lines to use integrated authentication)
`ssas_server=servername`	| SQL Server Analysis Services host and instance name to use (in the form of &lt;host&gt;\\&lt;instance&gt;, or &lt;instance&gt; for on premises connections)
`ssas_database=SalesManagementTabularModel`	| SQL Server Analysis Services database name to create
`use_ssas=true`	| Optionally toggle using SQL Server Analysis Services
`type_etl`	| ETL tool to use (informatica \| scribe)
`type_source=salesforce`	| Data source to replicate (dynamics \| salesforce)

### Informatica and Informatica Connections

Key/Value	| Meaning
--- | ---
`user=user@company.com` `password=password`	| Informatica username and password
`url=https://app.informaticaondemand.com`	| Informatica API URL
`organization_id=11111`	| Informatica organization ID
`task_name=SampleTask`	| Informatica task name to use
`source.agent_name=SampleAgent`	| Informatica agent name to use
`source.name=SampleSource`	| Informatica connection name to create
`source.user=user@company.com` `source.password`	| Salesforce username and password
`source.token=0000000000000000000000000`	| Salesforce API token to use
`target.agent_name=SampleAgent`	| Informatica agent name to use
`target.name=SampleTarget`	| Informatica connection name to create
`target.hostname=servername`	| The same SQL Server name as used by the top level entry (see sql_server=)

### Scribe and Scribe Connections

Key/Value | Meaning
--- | ---
`user=user@company.com` `password=password`	| Scribe username and password
`salt=ac103458-fcb6-41d3-94r0-43d25b4f4ff4`	| Scribe salt to use
`key=00000000-0000-0000-0000-000000000000`	| Scribe encoding key to use (accessible from the Organization tab &gt; Security &gt; API Cryptographic Token)
`organization_id=11111`	| Scribe organization ID (accessible from the Organization tab)
`agent_name=SampleAgent`	| Scribe agent name to use
`solution_name=SampleSolution`	| Scribe solution name to create
`source.name=SampleSource`	| Scribe connection name to create
`source.type=CRM`	| Scribe source type (CRM)
`source.user=user@company.com` `source.password=password`	| Dynamics CRM username and password
`source.organization=Microsoft`	| Dynamics CRM organization name
`source.deploy=Online`	| Dynamics CRM deployment type (Online \| On-Premise \| Partner-Hosted (IFD))
`source.url=https://disco.crm.dynamics.com`	| Dynamics CRM url
`target.name=SampleTarget`	| Scribe connection name to create
`target.type=MSSQL`	| Scribe target type
`target.server=servername`	| The same SQL Server name as used by the top level entry (see sql_server=)
`target.database=CRM`	| The same SQL Server database name as used by the top level entry (see sql_database=)
`target.authentication=SQL Server`	| SQL Server authentication type
`target.user=sa` `target.password=password`	| SQL Server username and password

## Step 2: Run setup.ps1

1. Open a new PowerShell console running as Administrator.
2. Run the following PowerShell command to enable scripting for this session: `Set-ExecutionPolicy ByPass`
3. Navigate to the directory containing setup.ps1.
4. Execute setup.ps1 with the following command: `.\setup.ps1`

## Step 3: Post Deployment

1. If using Informatica, create a new Task using the newly created connections and select only the following entities to pull:
  * account
  * lead
  * opportunity
  * OpportunityLineItem
  * OpportunityStage
  * product2
  * user
  * UserRole
2. If using Scribe, edit the newly created Scribe solution to pull only the following entities:
  * account
  * businessunit
  * lead
  * opportunity
  * opportunityproduct
  * product
  * systemuser
  * systemusermanagermap
  * territory
3. If using SQL Server Analysis Services, configure the SQL Server Agent Jobs
  1. Open SQL Server Configuration Manager and configure the SQL Server Agent to run as a domain account.
  2. Open the Properties of the newly created "Save credential" job and edit the job at the "Encrypt" step.
  3. Replace the following line with your ETL account password (Informatica or Scribe): `put password here, run, then set this back to an empty string`
  4. Run the "Data load and processing" job to pull data from your source or create a schedule for when it should run.

## Step 4: Configure the Power BI Enterprise Gateway

If you want to publish to PowerBI.com, download and set up the [Power BI Enterprise Gateway](https://powerbi.microsoft.com/en-us/documentation/powerbi-gateway-enterprise/).

## Step 5: Setting up the dashboards using Power BI

1. Open PowerBIReport\SalesManagementReport.pbix and update the connection to SQL Server Database or SQL Server Analysis Services based on the deployed environment (this will repopulate the graphs inside Power BI).
2. Optionally publish the desktop file to https://www.powerbi.com and configure the gateway connection (refer to the link in step 4).

Congratulations - you have successfully deployed the Solution Template!
