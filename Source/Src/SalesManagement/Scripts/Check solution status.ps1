<# Description : Checks the status of a solution
   Date created: Jan. 21, 2016
#>

# Parameters
param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$sqlServer,
      [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$sqlDatabase)

Import-Module SQLPS -WarningAction SilentlyContinue
Import-Module "scribe_utils.psm1" -Force -WarningAction SilentlyContinue
Import-Module "informatica_utils.psm1" -Force -WarningAction SilentlyContinue
Import-Module "pbist_utils.psm1" -Force -WarningAction SilentlyContinue

$settings = $null
$etl = $null
$source = $null

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


if ($etl -eq "Informatica")
{
    try
    {
        # Get settings for Informatica
        $settings = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query "SELECT [Name], [Value] FROM smgt.configuration WHERE configuration_group='informatica' AND configuration_subgroup='connection_info'"

        if ($settings.Count -lt 5)
        {
            Write-Host "ERROR: Informatica settings not configured correctly"
            exit 3
        }


        $user_id = ($settings | where {$_.Name -eq "user_id"}).Value
        $pwd_secured = ($settings | where {$_.Name -eq "password"}).Value
        $org_id = ($settings | where {$_.Name -eq "organization_id"}).Value
        $solution_name = ($settings | where {$_.Name -eq "task"}).Value
        $url = ($settings | where {$_.Name -eq "url"}).Value

        # Decrypt password
        $pwd = ConvertTo-SecureString $pwd_secured

        $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR( $pwd )
        $pwd = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR( $ptr )
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR( $ptr )


        INFA-Set-URL -URL $url
        INFA-Set-Organization -OrganizationID $org_id
        $session_id = INFA-Login -userName $user_id -password $pwd
        INFA-Set-Headers -SessionID $session_id

        # Query status
        $q = "SELECT [Value] FROM smgt.configuration WHERE configuration_group='informatica' AND configuration_subgroup='runtime' AND [name]='last_run_id'"
        $last_run_id = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $q
        $last_run_id = $last_run_id.Value

        do
        {
           Start-Sleep -Seconds 5
           $solution_status = INFA-Get-TaskRunStatus -TaskName $solution_name -RunID $last_run_id
        } until (($solution_status -eq 1) -or ($solution_status -eq 2) -or ($solution_status -eq 3))

        INFA-Logout

        Write-Host ("The solution was found in state " + $solution_status)
    }
    catch
    {
        Write-Host ("ERROR: The provided Informatica settings seem incorrect. " + $_.Exception.Message)
        exit 4
    }
}
elseif ($etl -eq "Scribe")
{
    try
    {
        # Get settings for Scribe
        $settings = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query "SELECT [Name], [Value] FROM smgt.configuration WHERE configuration_group='scribe'"

        if ($settings.Count -ne 4)
        {
            Write-Host "ERROR: Scribe settings not configured correctly"
            exit 5
        }

        $user_id = ($settings | where {$_.Name -eq "user_id"}).Value
        $pwd_secured = ($settings | where {$_.Name -eq "password"}).Value
        $org_id = ($settings | where {$_.Name -eq "organization_id"}).Value
        $solution_name = ($settings | where {$_.Name -eq "solution"}).Value

        # Decrypt password
        $pwd = ConvertTo-SecureString $pwd_secured
        $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR( $pwd )
        $pwd = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR( $ptr )
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR( $ptr )

        # Generate headers
        $headers = SUGet-AuthHeader -userName $user_id -password $pwd

        # Get solution id
        "Requesting solution ID"
        $solution_id = SUGet-SolutionID -organizationID $org_id -authenticationHeader $headers -solutionName $solution_name

        # Query status
        do
        {
           Start-Sleep -Seconds 5
           $solution_status = SUGet-SolutionStatus -solutionID $solution_id -organizationID $org_id -authenticationHeader $headers
        } until (($solution_status -eq "OnDemand") -or ($solution_status -eq "Idle"))

        Write-Host ("The solution was found in state " + $solution_status)
    }
    catch
    {
        Write-Host ("ERROR: The provided Scribe settings seem incorrect. " + $_.Exception.Message)
        exit 6
    }
}

