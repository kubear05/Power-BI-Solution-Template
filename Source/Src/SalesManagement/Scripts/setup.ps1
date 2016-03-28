<#
    .SYNOPSIS
        Configures a Sales Management Solution Template.
    .DESCRIPTION
        Reads a provided ini file to run sql and ssas scripts, and then deploys an ETL solution.
    .EXAMPLE
        .\setup.ps1
    .EXAMPLE
        .\setup.ps1 Scripts\sample.ini
    .EXAMPLE
        .\setup.ps1 -IniPath Scripts\sample.ini
#>

param(
    [Parameter(Mandatory=$false)] $IniPath,
    [switch] $Uninstall
)

$dirDBScripts = "DBScripts"
$dirModel = "Model"
$dirScripts = "Scripts"

if ($IniPath -eq $null)
{
    $IniPath = "$dirScripts\sample.ini"
}

$ErrorActionPreference = "Stop"

#============================================================================================
# Install PBIST Modules and Scripts
#============================================================================================

if ($Uninstall)
{
    "Removing installed modules and scripts"

    $pbistPath = $env:ProgramFiles + "\PBIST"

    if (Test-Path -Path $pbistPath)
    {
        Remove-Item -Force -Recurse $pbistPath
    }

    $moduleInstallPath = $pbistPath + "\SM\PowerShell\Modules"
    $powershellModules = [Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::Machine)
    if ($powershellModules -like "*;" + $moduleInstallPath + "*")
    {
        $powershellModules = $powershellModules.replace(";$moduleInstallPath", [string]::Empty)
        [Environment]::SetEnvironmentVariable("PSModulePath", $powershellModules, [System.EnvironmentVariableTarget]::Machine)
        $env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::Machine)
    }

    # Import pbist_utils for INI parsing only for this session
    Import-Module ".\$dirScripts\pbist_utils.psm1" -DisableNameChecking -Force -WarningAction SilentlyContinue
}
else
{
    "Installing modules and scripts"

    $pbistPowerShellPath = $env:ProgramFiles + "\PBIST\SM\PowerShell"

    $modules = Get-ChildItem $dirScripts -Filter *.psm1 | % {$_.BaseName}
    $moduleInstallPath = "$pbistPowerShellPath\Modules"
    foreach ($module in $modules)
    {
        # Remove the module from the session if it already exists
        Remove-Module "$module.psm1" -Force -ErrorAction SilentlyContinue

        $dir = "$moduleInstallPath\$module"
        if (!(Test-Path -Path $dir))
        {
            New-Item $dir -ItemType Directory | Out-Null
        }
        "Copying module $module"
        Copy-Item "$dirScripts\$module.psm1" $dir -Force
    }

    $powershellModules = [Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::Machine)
    if (!($powershellModules -like "*" + $moduleInstallPath + "*"))
    {
        $powershellModules += ";" + $moduleInstallPath
        [Environment]::SetEnvironmentVariable("PSModulePath", $powershellModules, [System.EnvironmentVariableTarget]::Machine)
        $env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::Machine)
    }

    # Force load the modules we just copied
    foreach ($module in $modules)
    {
        Import-Module "$module.psm1" -DisableNameChecking -Force -WarningAction SilentlyContinue
    }

    $scriptInstallPath = "$pbistPowerShellPath\Scripts"
    if (!(Test-Path -Path $scriptInstallPath))
    {
        New-Item $scriptInstallPath -ItemType Directory | Out-Null
    }
    $pbistScripts = Get-ChildItem $dirScripts -Filter *.ps1 | % {$_.Name}
    foreach ($pbistScript in $pbistScripts)
    {
        "Copying script $pbistScript"
        Copy-Item "$dirScripts\$pbistScript" $scriptInstallPath -Force
    }
}

#============================================================================================
# Read INI File
#============================================================================================

"Reading INI File"

$ini = STParseIniFile -File $IniPath
$iniRoot = $ini["ROOT"]

$sqlDatabase = $iniRoot["sql_database"]
$sqlServer = $iniRoot["sql_server"]
$ssasDatabase = $iniRoot["ssas_database"]
$ssasServer = $iniRoot["ssas_server"]
$typeETL = $iniRoot["type_etl"]
$typeSource = $iniRoot["type_source"]

$sqlUserID = $iniRoot["sql_user_id"]
$sqlPassword = $iniRoot["sql_password"]

$sqlHostIndex = $sqlServer.IndexOf("\")
if ($sqlHostIndex -ne -1)
{
    $sqlHost = $sqlServer.Substring(0, $sqlHostIndex)
}
else
{
    $sqlHost = $sqlServer
}

$missingUser = [string]::IsNullOrEmpty($sqlUserID)
$missingPassword = [string]::IsNullOrEmpty($sqlPassword)
$isSQLBasicAuth = !($missingUser) -and !($missingPassword)
if ($missingUser -and !($missingPassword))
{
    "ERROR: SQL Password is present but SQL User ID is missing"
    exit
}
if (!($missingUser) -and $missingPassword)
{
    "ERROR: SQL User ID is present but SQL Password is missing"
    exit
}

$useSSAS = $iniRoot["use_ssas"]
$useSSAS = $useSSAS -eq "true" -or $useSSAS -eq "1"

$informatica = $ini["informatica"]
$informaticaConn = $ini["informatica_connections"]

$scribe = $ini["scribe"]
$scribeConn = $ini["scribe_connections"]

switch ($typeETL)
{
    "informatica"
    {
        if ($informatica -eq $null -or $informaticaConn -eq $null)
        {
            "ERROR: Informatica settings missing from INI file"
            exit
        }
        break
    }
    "scribe"
    {
        if ($scribe -eq $null -or $scribeConn -eq $null)
        {
            "ERROR: Scribe settings missing from INI file"
            exit
        }

        $scribeSolutionName = $scribe["solution_name"]
        if ([string]::IsNullOrEmpty($scribeSolutionName))
        {
            "ERROR: Scribe solution name missing from INI file"
            exit
        }

        if ($scribeSolutionName.Length -gt 25)
        {
            "ERROR: Scribe solution name cannot be greater than 25 characters"
            exit
        }

        break
    }
}

#============================================================================================
# Deploy SQL Database
#============================================================================================

if ($Uninstall)
{
    "Removing SQL Database"
}
else
{
    "Deploying SQL Database"
}

if ([string]::IsNullOrEmpty($sqlServer))
{
    "ERROR: SQL Server Name not provided in INI file"
    exit
}

if ([string]::IsNullOrEmpty($sqlDatabase))
{
    "ERROR: SQL Server Database Name not provided in INI file"
    exit
}

$location = Get-Location
Import-Module SQLPS -DisableNameChecking -ErrorAction Stop
Set-Location -Path $location

$server = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Server -ArgumentList $sqlServer
if ($isSQLBasicAuth)
{
    $connectionContext = $server.ConnectionContext
    $connectionContext.LoginSecure = $false
    $connectionContext.Login = $sqlUserID
    $connectionContext.Password = $sqlPassword
    $server = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Server -ArgumentList $connectionContext
}
$sqlVersion = $server.Version.Major
if ($sqlVersion -lt 11)
{
    "ERROR: Only SQL server 2012 and up is supported"
    exit
}
$serverContainsDB = ($server.Databases | Where-Object {$_.Name -eq $sqlDatabase}) -ne $null
$serverIsAzure = $server.Edition -eq "SQL Azure"

if ($serverIsAzure)
{
    $useSSAS = $false
}
if ($useSSAS -and [string]::IsNullOrEmpty($ssasDatabase))
{
    "ERROR: SSAS Database Name not provided in INI file"
    exit
}

switch ($typeSource)
{
    "dynamics"
    {
        $dbScriptType = "Dynamics"
        break
    }
    "salesforce"
    {
        $dbScriptType = "Salesforce"
        break
    }
    default
    {
        "ERROR: Invalid data source type provided in INI file"
        exit
    }
}

if ($Uninstall)
{
    if ($serverContainsDB)
    {
        if ($serverIsAzure)
        {
            $preInput = "{0}\{1}PreDeploy.sql" -f $dirDBScripts, $dbScriptType
            $preVars = @("DatabaseName = $sqlDatabase")
            if ($isSQLBasicAuth)
            {
                Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -InputFile $preInput -Variable $preVars -Username $sqlUserID -Password $sqlPassword
            }
            else
            {
                Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -InputFile $preInput -Variable $preVars
            }
        }
        else
        {
            $queryRemoveConnections = "ALTER DATABASE [$sqlDatabase] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE"
            $queryDelete = "DROP DATABASE $sqlDatabase"
            if ($isSQLBasicAuth)
            {
                Invoke-Sqlcmd -ServerInstance $sqlServer -Query $queryRemoveConnections -Username $sqlUserID -Password $sqlPassword
                Invoke-Sqlcmd -ServerInstance $sqlServer -Query $queryDelete -Username $sqlUserID -Password $sqlPassword
            }
            else
            {
                Invoke-Sqlcmd -ServerInstance $sqlServer -Query $queryRemoveConnections
                Invoke-Sqlcmd -ServerInstance $sqlServer -Query $queryDelete
            }
        }
    }
}
else
{
    if (!$serverContainsDB)
    {
        if ($serverIsAzure)
        {
            "ERROR: SQL Azure Server missing database specified in INI file"
            exit
        }
        else
        {
            $database = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Database -ArgumentList $server, $sqlDatabase
            $database.Collation = "Latin1_General_100_CI_AS"
            $database.Create()
        }
    }

    $preInput = "{0}\{1}PreDeploy.sql" -f $dirDBScripts, $dbScriptType
    $preVars = @("DatabaseName = $sqlDatabase")
    if ($isSQLBasicAuth)
    {
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -InputFile $preInput -Variable $preVars -Username $sqlUserID -Password $sqlPassword
    }
    else
    {
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -InputFile $preInput -Variable $preVars
    }

    $sqlScripts = @("ScribeTables.sql", "SmgtTables.sql", "SmgtViews.sql")
    foreach ($sqlScript in $sqlScripts)
    {
        if ($isSQLBasicAuth)
        {
            Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -InputFile "$dirDBScripts\$dbScriptType$sqlScript" -Username $sqlUserID -Password $sqlPassword
        }
        else
        {
            Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -InputFile "$dirDBScripts\$dbScriptType$sqlScript"
        }
    }

    $postNonAzureScripts = @(("{0}\{1}CreateJob.sql" -f $dirDBScripts, $dbScriptType), ("{0}\{1}CreateSSASUserSecurity.sql" -f $dirDBScripts, $dbScriptType))
    $postInput = "{0}\{1}PostDeploy.sql" -f $dirDBScripts, $dbScriptType
    $postVars = "SQL_SERVER = $sqlServer", "DatabaseName = $sqlDatabase", "SSAS_DB = $ssasDatabase", "ProgramFiles=$env:ProgramFiles"

    if ($isSQLBasicAuth)
    {
        if (!$serverIsAzure)
        {
            foreach($postScript in $postNonAzureScripts)
            {
                Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -InputFile $postScript -Variable $postVars -Username $sqlUserID -Password $sqlPassword
            }
        }
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -InputFile $postInput -Variable $postVars -Username $sqlUserID -Password $sqlPassword
    }
    else
    {
        if (!$serverIsAzure)
        {
            foreach ($postScript in $postNonAzureScripts)
            {
                Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -InputFile $postScript -Variable $postVars
            }
        }
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -InputFile $postInput -Variable $postVars
    }
}

#============================================================================================
# ETL Configuration
#============================================================================================

if ($Uninstall)
{
    if (!$serverIsAzure)
    {
        "Deleting SQL Server Agent Jobs"
    
        $agentJobs = @("Data load and processing", "Save credential")
        foreach ($agentJob in $agentJobs)
        {
            $agentJobObject = $server.Jobserver.Jobs | Where-Object {$_.Name -like $agentJob}
            if ($agentJobObject -ne $null)
            {
                $agentJobObject.Drop()
            }
        }
    }
}
else
{
    "Configuring ETL"

    $configInsert = "INSERT smgt.configuration (configuration_group, configuration_subgroup, [name], [value]) VALUES (N'{0}', N'{1}', N'{2}', N'{3}');"

    switch ($typeETL)
    {
        "informatica"
        {
            $configINI = $informatica
            $configNames = @("user_id", "password", "organization_id", "task", "url")
            $configValues = @("user", "password", "organization_id", "task_name", "url")
            break
        }
        "scribe"
        {
            $configINI = $scribe
            $configNames = @("user_id", "password", "organization_id", "solution")
            $configValues = @("user", "password", "organization_id", "solution_name")
            break
        }
        default
        {
            "ERROR: Invalid ETL type provided in INI file"
            exit
        }
    }

    for ($i = 0; $i -lt $configNames.Count; $i++)
    {
        $configQuery = $configInsert -f $typeETL, "connection_info", $configNames[$i], $configINI[$configValues[$i]]
        if ($isSQLBasicAuth)
        {
            Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $configQuery -Username $sqlUserID -Password $sqlPassword
        }
        else
        {
            Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $configQuery
        }
    }

    $configQueryETL = $configInsert -f "SolutionTemplate", "SalesManagement", "etl", $typeETL
    $configQuerySource = $configInsert -f "SolutionTemplate", "SalesManagement", "source", $typeSource
    if ($isSQLBasicAuth)
    {
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $configQueryETL -UserName $sqlUserID -Password $sqlPassword
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $configQuerySource -UserName $sqlUserID -Password $sqlPassword
    }
    else
    {
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $configQueryETL
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $configQuerySource
    }

    if (!$serverIsAzure)
    {
        $sqlServerAgent = Get-Service -ComputerName $sqlHost SQLSERVERAGENT -ErrorAction SilentlyContinue
        if ($sqlServerAgent -ne $null)
        {
            "Restarting SQL Server Agent"
            Restart-Service $sqlServerAgent -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        else
        {
            "Skipping SQL Server Agent Restart"
        }
    }
}

#============================================================================================
# Deploy SSAS Database
#============================================================================================

if ($useSSAS)
{
    if ([string]::IsNullOrEmpty($ssasServer))
    {
        $ssasServer = $sqlServer
    }

    if ($Uninstall)
    {
        "Removing SSAS Database"

        $ssas = New-Object -TypeName Microsoft.AnalysisServices.Server
        $ssas.Connect($ssasServer)
        $ssasDatabaseObject = $ssas.Databases.FindByName($ssasDatabase)
        if ($ssasDatabaseObject -ne $null)
        {
            $ssasDatabaseObject.Drop()
        }
    }
    else
    {
        "Deploying SSAS Database"

        $deploymentUtility = "{0}\Microsoft SQL Server\{1}0\Tools\Binn\ManagementStudio\Microsoft.AnalysisServices.Deployment.exe" -f ${env:ProgramFiles(x86)}, $sqlVersion

        if (!(Test-Path -Path $deploymentUtility))
        {
            "ERROR: Analysis Services Deployment Utility is unavailable"
            exit
        }

        $ssasDatabaseFile = "$dirModel\Model.asdatabase"
        $ssasDatabaseTargetFile = "$dirModel\Model.deploymenttargets"

        if (!(Test-Path -Path $ssasDatabaseFile) -or !(Test-Path -Path $ssasDatabaseTargetFile))
        {
            "ERROR: Analysis Services Database file is missing"
            exit
        }

        $location = Get-Location
        $xml = New-Object XML

        $xml.Load("$location\$ssasDatabaseFile")
        $xml.Database.ID = $ssasDatabase
        $xml.Database.Name = $ssasDatabase
        $xml.Database.DataSources.DataSource.ConnectionString = $xml.Database.DataSources.DataSource.ConnectionString -replace "(Initial Catalog=)(.*?)(;)", "Initial Catalog=$sqlDatabase;"
        $xml.Save("$location\$ssasDatabaseFile")

        $xml.Load("$location\$ssasDatabaseTargetFile")
        $xml.DeploymentTarget.Database = $ssasDatabase
        $xml.DeploymentTarget.Server = $ssasServer
        $xml.DeploymentTarget.ConnectionString = $xml.DeploymentTarget.ConnectionString -replace "(DataSource=)(.*?)(;)", "DataSource=$ssasServer;"
        $xml.Save("$location\$ssasDatabaseTargetFile")

        Start-Process -FilePath $deploymentUtility -ArgumentList $ssasDatabaseFile, "/s" -Wait
    }
}
else
{
    if ($Uninstall)
    {
        "Skipping SSAS Database Removal"
    }
    else
    {
        "Skipping SSAS Database Deployment"
    }
}

#============================================================================================
# ETL Deployment
#============================================================================================

if (!$Uninstall)
{
    "Deploying ETL Solution"

    switch ($typeETL)
    {
        "informatica"
        {
            INFA-Set-URL -URL $informatica["url"]
            INFA-Set-Organization -OrganizationID $informatica["organization_id"]

            "Logging in to Informatica"

            $sessionID = INFA-Login -Username $informatica["user"] -Password $informatica["password"]
            INFA-Set-Headers -SessionID $sessionID

            $informaticaSourceName = $informaticaConn["source.name"]
            $informaticaTargetName = $informaticaConn["target.name"]

            if ($informaticaSourceName -eq $informaticaTargetName)
            {
                "ERROR: The provided Informatica source and target connection names are the same"
                exit
            }

            "Creating Informatica Connections"

            $idSource = INFA-New-SFConnection -ConnectionName $informaticaSourceName -UserID $informaticaConn["source.user"] -Password $informaticaConn["source.password"] -SecurityToken $informaticaConn["source.token"] -AgentName $informaticaConn["source.agent_name"]
            $idTarget = INFA-New-SQLConnection -ConnectionName $informaticaTargetName -Hostname $informaticaConn["target.hostname"] -Database $informaticaConn["target.database"] -UserID $informaticaConn["target.user"] -Password $informaticaConn["target.password"] -AgentName $informaticaConn["target.agent_name"]

            "Create a new Informatica Task using source $informaticaSourceName and target $informaticaTargetName"

            INFA-Logout

            break
        }
        "scribe"
        {
            $auth = SUGet-AuthHeader -Username $scribe["user"] -Password $scribe["password"]

            "Getting Scribe Online Agent ID"

            $agentID = SUGet-AgentID -AgentName $scribe["agent_name"] -OrganizationID $scribe["organization_id"] -AuthenticationHeader $auth

            $propsSrc = @()
            switch ($typeSource)
            {
                "dynamics"
                {
                    $prop = @{ "Key"="DeploymentType"; "Value"= AES-Encrypt -message $scribeConn["source.deploy"] -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    $prop = @{ "Key"="Url"; "Value"= AES-Encrypt -message $scribeConn["source.url"] -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    $prop = @{ "Key"="UserId"; "Value" = AES-Encrypt -message $scribeConn["source.user"] -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    $prop = @{ "Key"="Password"; "Value" = AES-Encrypt -message $scribeConn["source.password"] -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    $prop = @{ "Key"="Organization"; "Value"= AES-Encrypt -message $scribeConn["source.organization"] -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    $prop = @{ "Key"="DisplayPickListNames"; "Value"= AES-Encrypt -message "true" -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    break
                }
                "salesforce"
                {
                    $prop = @{ "Key"="DeploymentType"; "Value"= AES-Encrypt -message $scribeConn["source.deploy"] -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    $prop = @{ "Key"="Url"; "Value"= AES-Encrypt -message $scribeConn["source.url"] -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    $prop = @{ "Key"="UserId"; "Value" = AES-Encrypt -message $scribeConn["source.user"] -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    $prop = @{ "Key"="Password"; "Value" = AES-Encrypt -message $scribeConn["source.password"] -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    $prop = @{ "Key"="SecurityToken"; "Value"= AES-Encrypt -message $scribeConn["source.token"] -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    $prop = @{ "Key"="UseBulkApiRS"; "Value"= AES-Encrypt -message "true" -key $scribe["key"] -salt $scribe["salt"] }
                    $propsSrc += $prop
                    break
                }
            }

            $propsTarget = @()
            $prop = @{ "Key"="Server"; "Value"= AES-Encrypt -message $scribeConn["target.server"] -key $scribe["key"] -salt $scribe["salt"] }
            $propsTarget += $prop
            $prop = @{ "Key"="Database"; "Value"= AES-Encrypt -message $scribeConn["target.database"] -key $scribe["key"] -salt $scribe["salt"] }
            $propsTarget += $prop
            $prop = @{ "Key"="UserName"; "Value"= AES-Encrypt -message $scribeConn["target.user"] -key $scribe["key"] -salt $scribe["salt"] }
            $propsTarget += $prop
            $prop = @{ "Key"="Password"; "Value"= AES-Encrypt -message $scribeConn["target.password"] -key $scribe["key"] -salt $scribe["salt"] }
            $propsTarget += $prop
            $prop = @{ "Key"="Authentication"; "Value"= AES-Encrypt -message $scribeConn["target.authentication"] -key $scribe["key"] -salt $scribe["salt"] }
            $propsTarget += $prop

            $scribeSourceName = $scribeConn["source.name"]
            $scribeTargetName = $scribeConn["target.name"]

            if ($scribeSourceName -eq $scribeTargetName)
            {
                "ERROR: The provided Scribe source and target connection names are the same"
                exit
            }

            "Creating Scribe Online Connections"

            $connIDSrc = SUNew-Connection -ConnectionType $scribeConn["source.type"] -ConnectionName $scribeSourceName -OrganizationID $scribe["organization_id"] -AgentID $agentID -AuthenticationHeader $auth -Properties $propsSrc
            $connIDTarget = SUNew-Connection -ConnectionType $scribeConn["target.type"] -ConnectionName $scribeTargetName -OrganizationID $scribe["organization_id"] -AgentID $agentID -AuthenticationHeader $auth -Properties $propsTarget

            "Creating Scribe Online Solution"

            $solID = SUNew-ReplicationSolution -SolutionName $scribe["solution_name"] -OrganizationID $scribe["organization_id"] -AgentID $agentID -ConnectionIDForSource $connIDSrc -ConnectionIDForTarget $connIDTarget -AuthenticationHeader $auth

            break
        }
    }
}