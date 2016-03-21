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
    
    $predeploy = $OutDir + '\DynamicsPreDeploy.sql'
    New-Item -ItemType file $predeploy -force
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\PreDeploymentAutomation.sql") $predeploy

    $replicatedTablesFile = $OutDir + '\DynamicsScribeTables.sql'
    New-Item -ItemType file $replicatedTablesFile -force
    CreateScript ($MSBuildProjectDirectory + "\dbo\tables") $replicatedTablesFile

    $smgtTablesFile = $OutDir + '\DynamicsSmgtTables.sql'
    New-Item -ItemType file $smgtTablesFile -force
    CreateScript ($MSBuildProjectDirectory + "\smgt") $smgtTablesFile
    CreateScript ($MSBuildProjectDirectory + "\smgt\tables") $smgtTablesFile

    $smgtViewsFile = $OutDir + '\DynamicsSmgtViews.sql'
    New-Item -ItemType file $smgtViewsFile -force
    CreateScript ($MSBuildProjectDirectory + "\smgt\views") $smgtViewsFile

    $postdeploy = $OutDir + '\DynamicsPostDeploy.sql'
    New-Item -ItemType file $postdeploy -force
    
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\cleanup.sql") $postdeploy
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\InsertDates.sql") $postdeploy
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\InsertConfiguration.sql") $postdeploy
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\create_job.sql") $postdeploy
    CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\CreateSSASUserSecurity.sql") $postdeploy

    if($Configuration -eq "Debug")
    {
        CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\InsertCRMSampleData.sql") $postdeploy
        CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\InsertActualsAndTargets.sql") $postdeploy
    }
    else
    {
        CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\postdeploymentRelease.sql") $postdeploy
    }
    
}

CreateScripts $args[0] $args[1] $args[2]