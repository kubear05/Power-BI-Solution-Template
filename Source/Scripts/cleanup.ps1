#============================================================================================
# Remove SQL Database
#============================================================================================


if ($server.Databases.Contains($sqlDatabase))
{
    $queryDelete = "DROP DATABASE $sqlDatabase"
    if ($isSQLBasicAuth)
    {
        Invoke-Sqlcmd -ServerInstance $sqlServer -Query $queryDelete -Username $sqlUserID -Password $sqlPassword
    }
    else
    {
        Invoke-Sqlcmd -ServerInstance $sqlServer -Query $queryDelete
    }
}

# Delete SQLSERVERAGENT jobs

#============================================================================================
# Remove SSAS Database
#============================================================================================

if ($useSSAS -eq "true" -or $useSSAS -eq "1")
{
    "Removing SSAS Database"

    if ([string]::IsNullOrEmpty($ssasServer))
    {
        $ssasServer = $sqlServer
    }

    if ([string]::IsNullOrEmpty($ssasDatabase))
    {
        "ERROR: SSAS Database Name not provided in INI file"
        exit
    }

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
    "Skipping SSAS Database Removal"
}

#============================================================================================
# ETL Cleanup
#============================================================================================

<#

"Cleaning up ETL Solution"

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

        "Deleting Informatica Connections"

        # Delete Source
        # Delete Target

        INFA-Logout

        break
    }
    "scribe"
    {
        $auth = SUGet-AuthHeader -Username $scribe["user"] -Password $scribe["password"]

        "Getting Scribe Online Agent ID"

        $agentID = SUGet-AgentID -AgentName $scribe["agent_name"] -OrganizationID $scribe["organization_id"] -AuthenticationHeader $auth

        $scribeSourceName = $scribeConn["source.name"]
        $scribeTargetName = $scribeConn["target.name"]

        if ($scribeSourceName -eq $scribeTargetName)
        {
            "ERROR: The provided Scribe source and target connection names are the same"
            exit
        }

        "Deleting Scribe Online Solution"

        # Delete Solution

        "Deleting Scribe Online Connections"

        # Delete Source
        # Delete Target

        break
    }
    default
    {
        "ERROR: Invalid ETL type provided in INI file"
        exit
    }
}

#>