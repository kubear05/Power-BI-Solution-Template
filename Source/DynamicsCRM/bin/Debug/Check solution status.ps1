<# Description : invokes a Scribe solution
   Date created: Jan. 21, 2016
#>

# Parameters
$sqlServer   = "server_name"
$sqlDatabase = "database_name"


$ErrorActionPreference = "Stop"

Import-Module SQLPS -WarningAction SilentlyContinue


# URIs for REST calls
$uri_solutions = "https://api.scribesoft.com/v1/orgs/{0}/solutions"
$uri_solution_status = "https://api.scribesoft.com/v1/orgs/{0}/solutions/{1}"


# Get settings for Scribe
$settings = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query "SELECT [Name], [Value] FROM smgt.configuration WHERE configuration_group='scribe'"

if ($settings.Count -ne 4)
{
    throw "ERROR: Scribe settings not configured correctly"
}


$user_id = $settings.Where({$_.Name -eq "user_id"}).Value
$pwd_secured = $settings.Where({$_.Name -eq "password"}).Value
$org_id = $settings.Where({$_.Name -eq "org_id"}).Value
$solution_name = $settings.Where({$_.Name -eq "solution"}).Value

# Decrypt password
$pwd = ConvertTo-SecureString $pwd_secured
$ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR( $pwd )
$pwd = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR( $ptr )
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR( $ptr )


# Generate authentication payload
$authInfo = $user_id + ":" + $pwd;
$authInfo = "Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($authInfo));

# Generate headers
$headers = @{}
$headers.Add("Authorization", $authInfo)
$uri = [string]::Format($uri_solutions, $org_id)

$response = Invoke-RestMethod -Method Get -Headers $headers -Uri $uri


# Get solution id
"Requestion solution ID"
$solution_id = $response.Where({$_.name -eq $solution_name}).id

# Query status
$uri = [string]::Format($uri_solution_status, $org_id, $solution_id)
"Request status for solution id: " + $solution_id
$response = Invoke-RestMethod -Method Get -Headers $headers -Uri $uri

$solution_status = $response.status

if (($solution_status -eq "OnDemand") -or ($solution_status -eq "Idle") )
{
    "Solution in processed state. " 
}
else
{
    # The Scribe solution is not in a completed state
    throw "Solution was not (yet) processed, the current status is: " + $response.status
}

