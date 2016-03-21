<# Description : Configures Sales Management Solution Template
   Date created: February 16th, 2016
#>

$ErrorActionPreference = "Stop"

##########################################
# Install PBIST Modules
##########################################

$module_install_path = $env:ProgramFiles + "\PBIST\SM\PowerShell"
$st_modules = Get-ChildItem -Filter *.psm1 | % {$_.BaseName}

foreach ($m in $st_modules)
{
    $d = "$module_install_path\$m"
    if ( !(Test-Path -Path $d) )
    {
        New-Item $d -ItemType Directory | Out-Null
    }
    "Copying module " + $m.ToUpper()
    Copy-Item ".\$m.psm1" $d -Force
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

Import-Module .\pbist_utils.psm1 -DisableNameChecking

$ini = STParseIniFile -File .\sample.ini
$ini_root = "ROOT"

$sql_server = $ini[$ini_root].sql_server
$sql_db = $ini[$ini_root].sql_db
$ssas_db = $ini[$ini_root].ssas_db

##########################################
# Deploy SQL Database
##########################################

$location = Get-Location
Import-Module SQLPS -DisableNameChecking -ErrorAction Stop
Set-Location -Path $location

$server = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Server -ArgumentList $sql_server
$database = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Database -ArgumentList $server, $sql_db
$database.Create()
$schema = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Schema -ArgumentList $database, "Smgt"
$schema.Owner = "dbo"
$schema.Create()

$sql_scripts = Get-ChildItem -Filter *.sql | % {$_.Name}

foreach ($sql_script in $sql_scripts)
{
    Invoke-Sqlcmd -ServerInstance $sql_server -Database $sql_db -InputFile .\$sql_script
}

##########################################
# Deploy SSAS Database
##########################################

#Import-Module SQLAS -ErrorAction Stop

##########################################
# Process SSAS Database
##########################################

##########################################
# ETL (Scribe/Informatica)
##########################################