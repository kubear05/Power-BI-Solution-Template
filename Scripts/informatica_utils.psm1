$organization_id = ""

$login_url = ""
$service_url = ""
$endpoint_login       = ""
$endpoint_logout      = ""
$endpoint_logout_all  = ""
$endpoint_connection  = ""
$endpoint_runtimeEnvs = ""
$endpoint_job         = ""
$endpoint_activity    = ""

$headers = @{}

function INFA-ClearSettings
{
    $Script:headers.Clear()
}

function INFA-Set-URL
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$URL)
    $Script:login_url = $URL
    $Script:endpoint_login       = "$Script:login_url/ma/api/v2/user/login"
    $Script:endpoint_logout_all  = "$Script:login_url/ma/api/v2/user/logoutall"
}

function INFA-Set-ServiceURL
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$URL)

    $Script:service_url = $URL
    $Script:endpoint_logout      = "$Script:service_url/api/v2/user/logout"
    $Script:endpoint_connection  = "$Script:service_url/api/v2/connection"
    $Script:endpoint_runtimeEnvs = "$Script:service_url/api/v2/runtimeEnvironment"
    $Script:endpoint_job         = "$Script:service_url/api/v2/job"
    $Script:endpoint_activity    = "$Script:service_url/api/v2/activity/activityLog?rowLimit=100"

}

function INFA-Set-Organization
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$OrganizationID)

    $Script:organization_id = $OrganizationID
}

function INFA-Login
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$Username,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$Password)

    $login_object = New-Object -TypeName psobject
    Add-Member -InputObject $login_object -MemberType NoteProperty -Name "@type" -Value "login"
    Add-Member -InputObject $login_object -MemberType NoteProperty -Name "username" -Value $userName
    Add-Member -InputObject $login_object -MemberType NoteProperty -Name "password" -Value $password

    $body = $login_object | ConvertTo-Json
    $response = Invoke-RestMethod -Method Post -Uri $Script:endpoint_login -ContentType "application/json" -Body $body

    # Set the service URL which might be different than login's
    INFA-Set-ServiceURL $response.serverUrl

    return $response.icSessionId
}

function INFA-Set-Headers
{
    param([string]$SessionID)
    
    INFA-ClearSettings
    $Script:headers.Add("icSessionId", $SessionID)
}

function INFA-Logout
{
    $response = Invoke-RestMethod -Method Post -Uri $Script:endpoint_logout -Headers $Script:headers
    INFA-ClearSettings
}

function INFA-LogoutAll
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$userName, 
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$password)

    $login_object = New-Object -TypeName psobject
    Add-Member -InputObject $login_object -MemberType NoteProperty -Name "@type" -Value "logout"
    Add-Member -InputObject $login_object -MemberType NoteProperty -Name "username" -Value $userName
    Add-Member -InputObject $login_object -MemberType NoteProperty -Name "password" -Value $password

    $body = $login_object | ConvertTo-Json
    $response = Invoke-RestMethod -Method Post -Uri $Script:endpoint_logout_all -ContentType "application/json" -Body $body
    INFA-ClearSettings
}

function INFA-Get-Connections
{
    $response = Invoke-RestMethod -Method Get -Uri $Script:endpoint_connection -Headers $Script:headers
    return $response
}

function INFA-New-SQLConnection
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$ConnectionName,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$Hostname,
          [int]$Port=1433,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$Database,
          [string]$Schema="dbo",
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$UserID,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$Password,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$AgentName)

    $connection_object = New-Object -TypeName psobject
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "@type" -Value "connection"
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "orgId" -Value $Script:organization_id
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "name" -Value $ConnectionName
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "host" -Value $Hostname
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "database" -Value $Database
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "port" -Value $Port
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "schema" -Value $Schema
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "type" -Value "SqlServer2012"
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "username" -Value $UserID
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "password" -Value $Password
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "codepage" -Value "UTF-8"

    $result = $null
    $ids = INFA-Get-RuntimeInfo $AgentName
    if ($ids -ne $null)
    {
        Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "runtimeEnvironmentId" -Value $ids[0]
        Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "agentId" -Value $ids[1]
        $body = $connection_object | ConvertTo-Json
        $response = Invoke-RestMethod -Method Post -Uri $Script:endpoint_connection -Headers $Script:headers -ContentType "application/json" -Body $body
        $result = $response.id
    }

    return $result
}

function INFA-New-SFConnection
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$ConnectionName,
          [string]$ServiceURL="https://login.salesforce.com/services/Soap/u/31.0",
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$UserID,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$Password,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$SecurityToken,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$AgentName)

    $connection_object = New-Object -TypeName psobject
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "@type" -Value "connection"
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "orgId" -Value $Script:organization_id
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "name" -Value $ConnectionName
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "serviceUrl" -Value $ServiceURL
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "type" -Value "Salesforce"
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "securityToken" -Value $SecurityToken
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "username" -Value $UserID
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "password" -Value $Password
    
    $result = $null
    $ids = INFA-Get-RuntimeInfo $AgentName
    if ($ids -ne $null)
    {
        Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "runtimeEnvironmentId" -Value $ids[0]
        Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "agentId" -Value $ids[1]
        $body = $connection_object | ConvertTo-Json
        $response = Invoke-RestMethod -Method Post -Uri $Script:endpoint_connection -Headers $Script:headers -ContentType "application/json" -Body $body
        $result = $response.id
    }

    return $result
}

function INFA-Get-RuntimeInfo
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$AgentName)

    $result = $null
    $response = Invoke-RestMethod -Method Get -Uri $Script:endpoint_runtimeEnvs -Headers $Script:headers
    foreach($environment in $response)
    {
        foreach ($agent in $environment.agents)
        {
            if ($agent.Name -eq $AgentName)
            {
                $result = ($environment.id, $agent.id)
                break
            }
        }
    }

    return $result
}


function INFA-Start-Job
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$TaskName,
          [Parameter(Mandatory=$false)][ValidateSet("DRS", "DSS")] [string]$TaskType = "DRS")

    # $taskID = INFA-Get-TaskID -TaskName $TaskName
    $job_object = New-Object -TypeName psobject
    Add-Member -InputObject $job_object -MemberType NoteProperty -Name "@type" -Value "job"
    Add-Member -InputObject $job_object -MemberType NoteProperty -Name "taskName" -Value $TaskName
    Add-Member -InputObject $job_object -MemberType NoteProperty -Name "taskType" -Value $TaskType

    $body = $job_object | ConvertTo-Json
    $response = Invoke-RestMethod -Method Post -Uri $Script:endpoint_job -Headers $Script:headers -ContentType "application/json" -Body $body

    return $response.runId
}


function INFA-Get-TaskID
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$TaskName,
          [Parameter(Mandatory=$false)][ValidateSet("DRS", "DSS")] [string]$TaskType = "DRS")
    
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $Script:headers

    $result = ($response | where {$_.name -eq $TaskName}).id

    return $result
}


function INFA-Get-TaskRunStatus
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$TaskName,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$RunID,
          [Parameter(Mandatory=$false)][ValidateSet("DRS", "DSS")] [string]$TaskType = "DRS")

    $response = Invoke-RestMethod -Method Get -Uri $Script:endpoint_activity -Headers $Script:headers

    $result = $response | where {$_.objectName -eq $TaskName -and $_.runId -eq $RunID}

    return $result.state
}

Export-ModuleMember -Function INFA-Set-URL
Export-ModuleMember -Function INFA-Set-Organization
Export-ModuleMember -Function INFA-Set-Headers
Export-ModuleMember -Function INFA-Logout
Export-ModuleMember -Function INFA-Login
Export-ModuleMember -Function INFA-LogoutAll
Export-ModuleMember -Function INFA-Get-Connections
Export-ModuleMember -Function INFA-New-SQLConnection
Export-ModuleMember -Function INFA-New-SFConnection
Export-ModuleMember -Function INFA-Start-Job
Export-ModuleMember -Function INFA-Get-TaskID
Export-ModuleMember -Function INFA-Get-TaskRunStatus