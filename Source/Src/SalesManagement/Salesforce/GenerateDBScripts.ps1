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
    New-Item -ItemType File $predeploy -Force
    CreateScriptFromFile ($MSBuildProjectDirectory + "\predeploymentscript.sql") $predeploy

    $replicatedTablesFile = $OutDir + '\SalesforceScribeTables.sql'
    New-Item -ItemType File $replicatedTablesFile -Force
    CreateScript ($MSBuildProjectDirectory + "\dbo\tables") $replicatedTablesFile

    $smgtTablesFile = $OutDir + '\SalesforceSmgtTables.sql'
    New-Item -ItemType File $smgtTablesFile -Force
    CreateScript ($MSBuildProjectDirectory + "\smgt") $smgtTablesFile
    CreateScript ($MSBuildProjectDirectory + "\smgt\tables") $smgtTablesFile

    $smgtViewsFile = $OutDir + '\SalesforceSmgtViews.sql'
    New-Item -ItemType File $smgtViewsFile -Force
    CreateScript ($MSBuildProjectDirectory + "\smgt\views") $smgtViewsFile

    $createJob = $OutDir + '\SalesforceCreateJob.sql'
    New-Item -ItemType File $createJob -Force
    CreateScriptFromFile ($MSBuildProjectDirectory + "\postdeployment\create_job.sql") $createJob

    $createSSASUserSecurity = $OutDir + '\SalesforceCreateSSASUserSecurity.sql'
    New-Item -ItemType File $createSSASUserSecurity -Force
    CreateScriptFromFile ($MSBuildProjectDirectory + "\postdeployment\CreateSSASUserSecurity.sql") $createSSASUserSecurity

    $postdeploy = $OutDir + '\SalesforcePostDeploy.sql'
    New-Item -ItemType File $postdeploy -Force
    CreateScriptFromFile ($MSBuildProjectDirectory + "\postdeployment\InsertDates.sql") $postdeploy
    CreateScriptFromFile ($MSBuildProjectDirectory + "\postdeployment\InsertConfiguration.sql") $postdeploy

    switch($Configuration)
    {
        "Debug"
        {
            CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\Postdeploymentdebug.sql") $postdeploy
            break
        }
        "Release"
        {
            CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\Postdeploymentrelease.sql") $postdeploy
            break
        }
        default
        {
            CreateScriptFromFile( $MSBuildProjectDirectory + "\postdeployment\Postdeploymentrelease.sql") $postdeploy
            break
        }
    }
}

CreateScripts $args[0] $args[1] $args[2]