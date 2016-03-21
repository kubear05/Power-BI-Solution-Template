<# Description : Updates domain information from an email address
   Date created: Jan. 21, 2016
#>

# Parameters
param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$sqlServer,
      [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$sqlDatabase)

Import-Module SQLPS -WarningAction SilentlyContinue
Import-Module "pbist_utils.psm1" -Force -WarningAction SilentlyContinue

$settings = $null
$etl = $null
$source = $null
$DBNull = [System.DBNull]::Value
$records = $null

try
{
    # Get ETL type
    $settings = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query "SELECT [Name], [Value] FROM smgt.configuration WHERE configuration_group='SolutionTemplate' AND configuration_subgroup='SalesManagement'"

    if ($settings.Count -lt 2)
    {
        Write-Host "ERROR: Solution template settings not configured correctly"
        exit 1
    }

    $etl = ($settings | where {$_.Name -eq "etl"}).Value
    $source = ($settings | where {$_.Name -eq "source"}).Value
}
catch
{
    Write-Host ("ERROR: Could not read solution template settings. " + $_.Exception.Message)
    exit 2
}


try
{
    switch ($source)
    {
        "salesforce"
        {
            $records = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query "SELECT u.EMAIL, u.ID, um.DomainUser FROM dbo.[USER] u LEFT OUTER JOIN Smgt.userMapping um ON u.EMAIL=um.OwnerId WHERE um.DomainUser IS NULL AND u.EMAIL IS NOT NULL"
            break
        }
        "dynamics"
         {
            $records = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query "SELECT u.[internalemailaddress] as [EMAIL], u.[systemuserid], um.DomainUser FROM dbo.[systemuser] u LEFT OUTER JOIN Smgt.userMapping um ON u.internalemailaddress=um.OwnerId WHERE um.DomainUser IS NULL AND u.internalemailaddress IS NOT NULL"
            break
         }
    }

    foreach ($r in $records)
    {
        $r.DomainUser = Get-DomainAndUser -userEmail $r.EMAIL
        if (! $DBNull.Equals($r.DomainUser) )
        {
            $q = "INSERT INTO Smgt.userMapping(DomainUser, OwnerId) VALUES ('$($r.DomainUser)', '$($r.EMAIL)');"
            Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $q
        }
    }

}
catch
{
    Write-Host ("ERROR: Could not retrieve users. " + $_.Exception.Message)
    exit 10
}

