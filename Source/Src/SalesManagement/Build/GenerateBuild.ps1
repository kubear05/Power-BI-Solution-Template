function Build
{
    param([string]$MSBuildProjectDirectory,[string]$OutDir, [string]$Configuration)

    C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe $MSBuildProjectDirectory\..\DynamicsCRM\DynamicsCRM.sqlproj /p:OutDir=$OutDir /p:MSBuildExtensionsPath='C:\Program Files (x86)\MSBuild' /p:VisualStudioVersion='14.0' /p:Configuration=$Configuration
    C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe $MSBuildProjectDirectory\..\Salesforce\Salesforce.sqlproj /p:OutDir=$OutDir /p:MSBuildExtensionsPath='C:\Program Files (x86)\MSBuild' /p:VisualStudioVersion='14.0' /p:Configuration=$Configuration
    C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe $MSBuildProjectDirectory\..\SalesManagementTabularModel\SalesManagementTabularModel.smproj /p:OutDir=$OutDir /p:MSBuildExtensionsPath='C:\Program Files (x86)\MSBuild' /p:VisualStudioVersion='14.0' /p:Configuration=$Configuration

    #============================================================================================
    # Versioning
    #============================================================================================

    $verMajor = 1
    $verMinor = 0
    $verBuild = get-date -Format yyyyMMdd
    $verRevision = get-date -Format HHmm
    
    #============================================================================================
    # Create Directories
    #============================================================================================

    $dirBuild = "$MSBuildProjectDirectory\..\..\..\Release\BuildOutput\"
    Remove-Item -Force -Recurse "$dirBuild"
    $dirBuildOutput = "$dirBuild$verMajor.$verMinor.$verBuild.$verRevision"
    $dirs = @("\", "\DBScripts", "\Model", "\Scripts", "\Documents", "\PowerBIReport")
    foreach($dir in $dirs)
    {
        New-Item -ItemType Directory -Force -Path "$dirBuildOutput$dir"
    }

    #============================================================================================
    # Copy SQL Scripts
    #============================================================================================

    $dirDBScripts = "$dirBuildOutput\DBScripts"
    $sqlScriptsDynamics = @("DynamicsPreDeploy.SQL", "DynamicsScribeTables.SQL", "DynamicsSmgtTables.SQL", "DynamicsSmgtViews.SQL", "DynamicsCreateJob.SQL", "DynamicsCreateSSASUserSecurity.SQL", "DynamicsPostDeploy.SQL")
    $sqlScriptsSalesforce = @("SalesforcePreDeploy.SQL", "SalesforceScribeTables.SQL", "SalesforceSmgtTables.SQL", "SalesforceSmgtViews.SQL", "SalesforceCreateJob.SQL", "SalesforceCreateSSASUserSecurity.SQL", "SalesforcePostDeploy.SQL")
    foreach ($sqlScript in $sqlScriptsDynamics)
    {
        Copy-Item "$OutDir\$sqlScript" $dirDBScripts
    }
    foreach ($sqlScript in $sqlScriptsSalesforce)
    {
        Copy-Item "$OutDir\$sqlScript" $dirDBScripts
    }

    #============================================================================================
    # Copy SSAS Model Files
    #============================================================================================

    $dirModel = "$dirBuildOutput\Model"
    $modelFiles = @("Model.asdatabase", "Model.deploymentoptions", "Model.deploymenttargets")
    foreach ($modelFile in $modelFiles)
    {
        Copy-Item "$OutDir\$modelFile" $dirModel
    }

    #============================================================================================
    # Copy Scripts, Reports, and Documents
    #============================================================================================

    Copy-Item "$MSBuildProjectDirectory\..\scripts\*" "$dirBuildOutput\scripts"
    Move-Item "$dirBuildOutput\scripts\setup.ps1" "$dirBuildOutput\"

    Copy-Item "$MSBuildProjectDirectory\..\..\..\reports\*" "$dirBuildOutput\PowerBIReport"
    Copy-Item "$MSBuildProjectDirectory\..\..\..\docs\*.docx" "$dirBuildOutput\Documents"
}

Build $args[0] $args[1] $args[2]