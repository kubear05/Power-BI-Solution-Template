<# Description : invokes a Scribe solution
   Date created: Jan. 21, 2016
#>

# Sample code about how to use secured strings to store a secret (tied to invoker's account)

# Parameters
$sqlServer   = "server_name"
$sqlDatabase = "database_name"

$ErrorActionPreference="Stop"

Import-Module SQLPS -WarningAction SilentlyContinue

$pwd_plain   = "some_password"
$pwd_secured = ConvertTo-SecureString $pwd_plain -AsPlainText -Force
$pwd_secured_as_text = $pwd_secured | ConvertFrom-SecureString 

$q = "DELETE FROM smgt.configuration WHERE configuration_group='scribe' AND configuration_subgroup='connection_info' AND [name]='password'"
Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $q
$q = "INSERT smgt.configuration(configuration_group, configuration_subgroup, [name], [value]) VALUES('scribe', 'connection_info', 'password', '" + $pwd_secured_as_text + "')"
Invoke-Sqlcmd -ServerInstance $sqlServer -Database $sqlDatabase -Query $q

$z = ConvertTo-SecureString $pwd_secured_as_text

$ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR( $z )
$pwd = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR( $ptr )
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR( $ptr )
$pwd
