function CreateScript ($folder, $file)
{
    $files = Get-ChildItem ($folder) | where {!$_.PsIsContainer} 
    for ($i=0; $i -lt $files.Count; $i++)
    {
        $inputfile = Get-Content $files[$i].FullName
        Add-Content $file $inputfile
        Add-Content $file "`r`nGO`r`n"
    }
}

function CreateScriptFromFile ($filePath, $file)
{
    $filename = $filePath
    $inputfile = Get-Content $filename
    Add-Content $file $inputfile
    Add-Content $file "`r`nGO`r`n"
}

function CreateScripts
{
    param([string]$MSBuildProjectDirectory,[string]$OutDir, [string]$Configuration)
    
    $predeploy = $OutDir + '\SalesforcePreDeploy.sql'
    New-Item -ItemType file $predeploy -force
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\PreDeploymentAutomation.sql") $predeploy

    $replicatedTablesFile = $OutDir + '\SalesforceScribeTables.sql'
    New-Item -ItemType file $replicatedTablesFile -force
    CreateScript ($MSBuildProjectDirectory + "\dbo\tables") $replicatedTablesFile

    $smgtTablesFile = $OutDir + '\SalesforceSmgtTables.sql'
    New-Item -ItemType file $smgtTablesFile -force
    CreateScript ($MSBuildProjectDirectory + "\smgt") $smgtTablesFile
    CreateScript ($MSBuildProjectDirectory + "\smgt\tables") $smgtTablesFile

    $smgtViewsFile = $OutDir + '\SalesforceSmgtViews.sql'
    New-Item -ItemType file $smgtViewsFile -force
    CreateScript ($MSBuildProjectDirectory + "\smgt\views") $smgtViewsFile

    $postdeploy = $OutDir + '\SalesforcePostDeploy.sql'
    New-Item -ItemType file $postdeploy -force
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\cleanup.sql") $postdeploy
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\InsertDates.sql") $postdeploy
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\InsertConfiguration.sql") $postdeploy
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\create_job.sql") $postdeploy
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\CreateSSASUserSecurity.sql") $postdeploy

    if($Configuration -eq "Debug")
    {
        CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\Postdeploymentdebug.sql") $postdeploy
    }
    else
    {
        CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\Postdeploymentrelease.sql") $postdeploy
    }
}

CreateScripts $args[0] $args[1] $args[2]