function SUGet-AuthHeader
{
    param([Parameter(Mandatory=$true, Position=0)][ValidateNotNullOrEmpty()][string] $Username,
          [Parameter(Mandatory=$true, Position=1)][ValidateNotNullOrEmpty()][string] $Password)

    $auth = $UserName + ":" + $Password
    $auth_payload = "Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($auth))
    $headers = @{}
    $headers.Add("Authorization", $auth_payload)

    # Generate authentication payload

    return $headers
}

function SUGet-SolutionID
{
    param([Parameter(Mandatory=$true, Position=0)][ValidateNotNullOrEmpty()] [string]$SolutionName,
          [Parameter(Mandatory=$true, Position=1)][ValidateNotNullOrEmpty()] [string]$OrganizationID,
          [Parameter(Mandatory=$true, Position=2)][ValidateNotNull()] $AuthenticationHeader)

    $uri_solutions = "https://api.scribesoft.com/v1/orgs/{0}/solutions"
    
    $uri = [string]::Format($uri_solutions, $OrganizationID)
    
    $response = Invoke-RestMethod -Method Get -Headers $AuthenticationHeader -Uri $uri
    $id = ($response | Where-Object {$_.name -eq $SolutionName}).id
    
    return $id
}

function SUGet-SolutionStatus
{
    param([Parameter(Mandatory=$true, Position=0)][ValidateNotNullOrEmpty()][string] $SolutionID,
          [Parameter(Mandatory=$true, Position=1)][ValidateNotNullOrEmpty()][string] $OrganizationID,
          [Parameter(Mandatory=$true, Position=2)][ValidateNotNull()] $AuthenticationHeader)

    $uri_solution_status = "https://api.scribesoft.com/v1/orgs/{0}/solutions/{1}"
    $uri = [string]::Format($uri_solution_status, $organizationID, $solutionID)
    
    $response = Invoke-RestMethod -Method Get -Headers $authenticationHeader -Uri $uri
    
    if ($response -ne $null)
    {
        return $response.status
    }

    return $null
}


function SUGet-AgentID
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$AgentName,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$OrganizationID,
          [Parameter(Mandatory=$true)][ValidateNotNull()] $AuthenticationHeader)

    $uri_agents = "https://api.scribesoft.com/v1/orgs/{0}/agents"
    
    $uri = [string]::Format($uri_agents, $OrganizationID)
    
    $response = Invoke-RestMethod -Method Get -Headers $AuthenticationHeader -Uri $uri
    [string]$id = ($response | Where-Object {$_.name -eq $AgentName}).id

    return $id
}

function SUNew-ReplicationSolution
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$SolutionName,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$OrganizationID,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$AgentID,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$ConnectionIDForSource,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$ConnectionIDForTarget,
          [Parameter(Mandatory=$true)][ValidateNotNull()] $AuthenticationHeader)

    $uri_solution = "https://api.scribesoft.com/v1/orgs/{0}/solutions"
    $template = @"
                    {
                        "Name": "",
                        "AgentId": "",
                        "Description": "",
                        "ConnectionIdForSource": "",
                        "ConnectionIdForTarget": "",
                        "SolutionType": ""
                    }
"@

    $uri = [string]::Format($uri_solution, $OrganizationID)
    $obj = $template | ConvertFrom-Json
    $obj.Name = $SolutionName
    $obj.AgentId = $AgentID
    $obj.ConnectionIdForSource = $ConnectionIDForSource
    $obj.ConnectionIdForTarget = $ConnectionIDForTarget
    $obj.SolutionType = "Replication"
    
    $body = $obj | ConvertTo-Json
    $response = Invoke-RestMethod -Method Post -Headers $AuthenticationHeader -Uri $uri -ContentType "application/json" -Body $body
    $id = $response.id

    return $id
}

# Internal function
function SUGet-ConnectorID()
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$ConnectionType,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$OrganizationID,
          [Parameter(Mandatory=$true)][ValidateNotNull()] $AuthenticationHeader)

    $uri_connectors = "https://api.scribesoft.com/v1/orgs/{0}/connectors"
    $uri = [string]::Format($uri_connectors, $OrganizationID)
    
    $response = Invoke-RestMethod -Method Get -Headers $AuthenticationHeader -Uri $uri
    
    $id = $null
    
    switch ($ConnectionType)
    {
        "CRM"
        {
            $id = ($response | Where-Object {$_.name -eq "Microsoft Dynamics CRM"}).id
            break
        }
        "MSSQL"
        {
            $id = ($response | Where-Object {$_.name -eq "Microsoft SQL Server"}).id
            break
        }
        "Salesforce"
        {
            $id = ($response | Where-Object {$_.name -eq "Salesforce"}).id
            break
        }
    }

    return $id
}


function SUNew-Connection
{
    param([Parameter(Mandatory=$true)][ValidateSet("CRM", "MSSQL", "Salesforce")][ValidateNotNullOrEmpty()] [string]$ConnectionType,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$ConnectionName,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$OrganizationID,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$AgentID,
          [Parameter(Mandatory=$true)][ValidateNotNull()] $AuthenticationHeader,
          [Parameter(Mandatory=$false)] $Properties)

    $uri_connections = "https://api.scribesoft.com/v1/orgs/{0}/connections"
    $uri_connection  = "https://api.scribesoft.com/v1/orgs/{0}/connections/{1}"
    $template = @"
                {
                    "Id": "",
                    "Alias": "",
                    "Color": "",
                    "ConnectorId": "",
                    "Name": "",
                    "Properties": [
                                    {
                                        "Key": "",
                                        "Value": ""
                                    }
                                  ]
                }
"@

    #  Check if connection exists and drop it
    $uri = [string]::Format($uri_connections, $OrganizationID)
    $response = Invoke-RestMethod -Method Get -Headers $AuthenticationHeader -Uri $uri
    $found_connection = ($response | Where-Object {$_.name -eq $ConnectionName})
    if ($found_connection -ne $null)
    {
        $id = $found_connection.id
        $uri = [string]::Format($uri_connection, $OrganizationID, $id)
        $response = Invoke-RestMethod -Method Delete -Headers $AuthenticationHeader -Uri $uri
    }

    #  Obtain ID of the connector
    $connector_id = SUGet-ConnectorID -ConnectionType $ConnectionType -OrganizationID $OrganizationID -AuthenticationHeader $AuthenticationHeader

    #  Fill in required information for the connection
    $obj = $template | ConvertFrom-Json
    $obj.Name = $ConnectionName
    $obj.ConnectorId = $connector_id
    $obj.Color = "#FFEA69A6"
    #  Set properties if any were passed
    if ($Properties -ne $null)
    {
        $obj.Properties = $Properties
    }

    $uri = [string]::Format($uri_connections, $OrganizationID)
    $body = $obj | ConvertTo-Json
    $response = Invoke-RestMethod -Method Post -Headers $AuthenticationHeader -Uri $uri -ContentType "application/json" -Body $body
    $id = $response.id

    return $id
}


function SU-ProcessSolution
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$solutionID,
          [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$OrganizationID,
          [Parameter(Mandatory=$true)][ValidateNotNull()] $AuthenticationHeader)

    $uri_process_solution = "https://api.scribesoft.com/v1/orgs/{0}/solutions/{1}/start"
    $uri = [string]::Format($uri_process_solution, $OrganizationID, $solutionID)
    
    $response = Invoke-RestMethod -Method Post -Headers $headers -Uri $uri
    return $response.status
}

Export-ModuleMember -Function SUGet-AuthHeader
Export-ModuleMember -Function SUGet-SolutionID
Export-ModuleMember -Function SUGet-AgentID
Export-ModuleMember -Function SUGet-SolutionStatus
Export-ModuleMember -Function SUNew-ReplicationSolution
Export-ModuleMember -Function SUNew-Connection
Export-ModuleMember -Function SU-ProcessSolution
# Internal function
# Export-ModuleMember -Function SUGet-ConnectorID

