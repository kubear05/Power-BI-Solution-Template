<# Description : Encrypts a credential under SQL agent's account
   Date created: Jan. 21, 2016
#>

# Parameters
param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$sqlServer,
      [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$sqlDatabase,
      $password = "")

Import-Module SQLPS -WarningAction Ignore -InformationAction Ignore


try
{
    # Get ETL type
    $settings = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query "SELECT [Name], [Value] FROM smgt.configuration WHERE configuration_group='SolutionTemplate' AND configuration_subgroup='SalesManagement'"

    if ($settings.Count -lt 2)
    {
        Write-Host "ERROR: Solution template settings not configured correctly"
        exit 1
    }
}
catch
{
    Write-Host  ("ERROR: Could not read solution template settings" + $_.Exception.Message)
    exit 2
}

try
{
    $etl = ($settings | where {$_.Name -eq "etl"}).Value
    $source = ($settings | where {$_.Name -eq "source"}).Value

    $payload_secured = ConvertTo-SecureString $password -AsPlainText -Force
    $payload_secured_as_text = $payload_secured | ConvertFrom-SecureString 


    if ($etl -eq "Informatica")
    {
        $q = "DELETE FROM smgt.configuration WHERE configuration_group='informatica' AND configuration_subgroup='connection_info' AND [name]='password'"
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $q
        $q = "INSERT smgt.configuration(configuration_group, configuration_subgroup, [name], [value]) VALUES('informatica', 'connection_info', 'password', '" + $payload_secured_as_text + "')"
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $q
    }
    elseif ($etl -eq "Scribe")
    {
        $q = "DELETE FROM smgt.configuration WHERE configuration_group='scribe' AND configuration_subgroup='connection_info' AND [name]='password'"
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $q
        $q = "INSERT smgt.configuration(configuration_group, configuration_subgroup, [name], [value]) VALUES('scribe', 'connection_info', 'password', '" + $payload_secured_as_text + "')"
        Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $q
    }
}
catch
{
    Write-Host ("ERROR: Could not save encrypted payload." + $_.Exception.Message)
    exit 3
}

Write-Host "Payload succesfully saved"
