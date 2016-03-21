<# Description : invokes a Scribe solution
   Date created: Jan. 21, 2016
#>

# Parameters
$sqlServer   = "raymondb01"
$sqlDatabase = "crm"

$ErrorActionPreference = "Stop"

Import-Module SQLPS -WarningAction SilentlyContinue


# URIs for REST calls
$uri_get_solutions = "https://api.scribesoft.com/v1/orgs/{0}/solutions"
$uri_process_solution = "https://api.scribesoft.com/v1/orgs/{0}/solutions/{1}/start"


# Get settings for Scribe
$settings = Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query "SELECT [Name], [Value] FROM smgt.configuration WHERE configuration_group='scribe' AND configuration_subgroup='connection_info'"

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
$uri = [string]::Format($uri_get_solutions, $org_id)

"Requestion solution ID"
$response = Invoke-RestMethod -Method Get -Headers $headers -Uri $uri

# Get solution id
$solution_id = $response.Where({$_.name -eq $solution_name}).id

# Invoke processing
"Invoking processing for solution id: " + $solution_id
$uri = [string]::Format($uri_process_solution, $org_id, $solution_id)

$response = Invoke-RestMethod -Method Post -Headers $headers -Uri $uri

"Solution status: " + $response.status
