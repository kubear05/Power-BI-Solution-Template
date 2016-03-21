$organization_id = ""

$url = ""
$endpoint_login       = ""
$endpoint_logout      = ""
$endpoint_logout_all  = ""
$endpoint_connection  = ""
$endpoint_runtimeEnvs = ""

$headers = @{}

function INFA-Set-URL
{
    param([string]$URL)
    $Script:url = $URL
    $Script:endpoint_login       = "$Script:url/ma/api/v2/user/login"
    $Script:endpoint_logout      = "$Script:url/saas/api/v2/user/logout"
    $Script:endpoint_logout_all  = "$Script:url/ma/api/v2/user/logoutall"
    $Script:endpoint_connection  = "$Script:url/saas/api/v2/connection"
    $Script:endpoint_runtimeEnvs = "$Script:url/saas/api/v2/runtimeEnvironment"
}


function INFA-Set-Organization
{
    param([string]$OrganizationID)

    $Script:organization_id = $OrganizationID
}


function INFA-Login
{
    param([string]$userName, [string]$password)

    $login_object = "{`"@type`": `"login`", `"username`": `"`", `"password`": `"`" } " | ConvertFrom-Json
    $login_object.username= $userName
    $login_object.password= $password

    $body = $login_object | ConvertTo-Json
    $response = Invoke-RestMethod -Method Post -Uri $Script:endpoint_login -ContentType "application/json" -Body $body

    return $response.icSessionId
}


function INFA-Set-Headers
{
    param([string]$SessionID)
    
    $Script:headers.Clear()
    $Script:headers.Add("icSessionId", $session_id)
}


function INFA-Logout
{
    $response = Invoke-RestMethod -Method Post -Uri $Script:endpoint_logout -Headers $Script:headers
    $Script:headers.Clear()
}

function INFA-LogoutAll
{
    param([string]$userName, [string]$password)

    $login_object = New-Object -TypeName psobject
    Add-Member -InputObject $login_object -MemberType NoteProperty -Name "@type" -Value "logout"
    Add-Member -InputObject $login_object -MemberType NoteProperty -Name "username" -Value $userName
    Add-Member -InputObject $login_object -MemberType NoteProperty -Name "password" -Value $password

    $body = $login_object | ConvertTo-Json
    $response = Invoke-RestMethod -Method Post -Uri $Script:endpoint_logout_all -ContentType "application/json" -Body $body
    $Script:headers.Clear()
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
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "schema" -Value $Schema
    Add-Member -InputObject $connection_object -MemberType NoteProperty -Name "type" -Value "SqlServer2012"
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
        foreach ($agent in $environment)
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

Export-ModuleMember -Function INFA-Set-URL
Export-ModuleMember -Function INFA-Set-Organization
Export-ModuleMember -Function INFA-Set-Headers
Export-ModuleMember -Function INFA-Logout
Export-ModuleMember -Function INFA-Login
Export-ModuleMember -Function INFA-LogoutAll
Export-ModuleMember -Function INFA-Get-Connections
Export-ModuleMember -Function INFA-New-SQLConnection
Export-ModuleMember -Function INFA-New-SFConnection

