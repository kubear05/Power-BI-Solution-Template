<# Description : Configures Sales Management Solution Template
   Date created: February 16th, 2016
#>

param([Parameter(Mandatory=$false)] $ini_path)

if ($ini_path -eq $null)
{
    $ini_path = ".\sample.ini"
}

$ErrorActionPreference = "Stop"

##########################################
# Install PBIST Modules
##########################################

$module_install_path = $env:ProgramFiles + "\PBIST\SM\PowerShell"

foreach ($module in Get-ChildItem -Filter *.psm1 | % {$_.BaseName})
{
    $d = "$module_install_path\$module"
    if ( !(Test-Path -Path $d) )
    {
        New-Item $d -ItemType Directory | Out-Null
    }
    "Copying module " + $module.ToUpper()
    Copy-Item ".\$module.psm1" $d -Force
}

$powershell_modules = [Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::Machine)
if (!($powershell_modules -like "*" + $module_install_path + "*"))
{
    $powershell_modules += ";" + $module_install_path
    [Environment]::SetEnvironmentVariable("PSModulePath", $powershell_modules, [System.EnvironmentVariableTarget]::Machine)
    $env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::Machine)
}

##########################################
# Read INI File
##########################################

# Import-Module .\pbist_utils.psm1 -DisableNameChecking

$ini = STParseIniFile -File $ini_path
$ini_root = "ROOT"

$sql_server = $ini[$ini_root].sql_server
$sql_db = $ini[$ini_root].sql_db
$ssas_db = $ini[$ini_root].ssas_db
$etl_type = $ini[$ini_root].etl_type

$scribe = $ini["scribe"]
$scribe_conn = $ini["scribe_connections"]

##########################################
# Deploy SQL Database
##########################################

$location = Get-Location
Import-Module SQLPS -DisableNameChecking -ErrorAction Stop
Set-Location -Path $location

$server = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Server -ArgumentList $sql_server
$sql_version = $server.Version.Major
if ($sql_version -lt 11)
{
   "ERROR: Only SQL server 2012 and up is supported"
    exit
}

if ($server.Databases.Contains($sql_db))
{
   "ERROR: SQL database [$sql_db] already exists"
   exit
}

$database = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Database -ArgumentList $server, $sql_db
$database.Collation = "Latin1_General_100_CI_AS"
$database.Create()

$sql_scripts = @("ScribeTables.sql", "SmgtTables.sql", "SmgtViews.sql")
foreach ($sql_script in $sql_scripts)
{
    Invoke-Sqlcmd -ServerInstance $sql_server -Database $sql_db -InputFile .\$sql_script
}

##########################################
# ETL Configuration
##########################################

$config_insert = "INSERT smgt.configuration (configuration_group, configuration_subgroup, [name], [value]) VALUES (N'{0}', N'connection_info', N'{1}', N'{2}');"

switch ($etl_type)
{
    "informatica"
    {

    }
    "scribe"
    {
        $scribe_names = @("user_id", "password", "org_id", "solution")
        $scribe_values = @("user", "pwd", "org_id", "solution_name")
        for ($i = 0; $i -lt $scribe_names.Count; $i++)
        {
            $scribe_query = $config_insert -f "scribe", $scribe_names[$i], $scribe[$scribe_values[$i]]
            Invoke-Sqlcmd -ServerInstance $sql_server -Database $sql_db -Query $scribe_query
        }
    }
}

# Create SQL Jobs & Restart SQL Server Agent
# Get-Service -ComputerName $sql_server SQLSERVERAGENT | Restart-Service

##########################################
# Deploy SSAS Database
##########################################

$deployment_utility = "{0}\Microsoft SQL Server\{1}0\Tools\Binn\ManagementStudio\Microsoft.AnalysisServices.Deployment.exe" -f ${env:ProgramFiles(x86)}, $sql_version

if (!(Test-Path -Path $deployment_utility))
{
    "ERROR: Analysis Services Deployment Utility is unavailable"
    exit
}

$as_db_file = ".\Model.asdatabase"

if (!(Test-Path -Path $as_db_file))
{
    "ERROR: Analysis Services Database file is missing"
    exit
}

Start-Process -FilePath $deployment_utility -ArgumentList $as_db_file -Wait

##########################################
# ETL Deployment
##########################################

switch($etl_type)
{
    "informatica"
    {

    }
    "scribe"
    {
        $auth = SUGet-AuthHeader -UserName $scribe["user"] -Password $scribe["pwd"]
        $agent_id = SUGet-AgentID -AgentName $scribe["agent_name"] -OrganizationID $scribe["org_id"] -AuthenticationHeader $auth
        $conn_id_src = SUNew-Connection -ConnectionType $scribe_conn["src.type"] -ConnectionName $scribe_conn["src.name"] -OrganizationID $scribe["org_id"] -AgentID $agent_id -AuthenticationHeader $auth
        $conn_id_target = SUNew-Connection -ConnectionType $scribe_conn["target.type"] -ConnectionName $scribe_conn["target.name"] -OrganizationID $sribe["org_id"] -AgentID $agent_id -AuthenticationHeader $auth
        $sol_id = SUNew-ReplicationSolution -SolutionName $scribe["solution_name"] -OrganizationID $scribe["org_id"] -AgentID $agent_id -ConnectionIDForSource $conn_id_src -ConnectionIDForTarget $conn_id_target -AuthenticationHeader $auth
    }
}