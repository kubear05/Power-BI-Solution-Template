Import-Module ActiveDirectory -ErrorAction Stop


function STEncryptText
{
    param([string] $value)

    $sstring = ConvertTo-SecureString $value -AsPlainText -Force
    $sstring_as_text = $sstring | ConvertFrom-SecureString

    return $sstring_as_text
}


function STDecryptText
{
    param([string] $value)

    $sstring = ConvertTo-SecureString $value
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sstring)
    $decrypted_value = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    
    return $decrypted_value
}

function STParseIniFile
{
    param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] [string]$File)

    $ini = @{}

    # create a default section if none exist in the file
    $section = "ROOT"
    $ini[$section] = @{}

    switch -regex -file $File {
        "^\[(.+)\]$" {
            $section = $matches[1].Trim()
            $ini[$section] = @{}
        }
        "^\s*([^#].+?)\s*=\s*(.*)" {
            $name,$value = $matches[1..2]
            # skip comments that start with a semicolon
            if (!($name.StartsWith(";"))) {
                $ini[$section][$name] = $value.Trim()
            }
        }
    }

    return $ini
}

function STGet-RandomIV
{
    param($size)
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
    $randomIv = New-Object Byte[] $size

    $rng.GetBytes($randomIv)
    $rng.Dispose();
        
    return $randomIv
}


function AES-Encrypt
{
    param([Parameter(Mandatory=$true, Position=0)][ValidateNotNullOrEmpty()] $message,
          [Parameter(Mandatory=$true, Position=1)][ValidateNotNullOrEmpty()] $key,
          [Parameter(Mandatory=$true, Position=1)][ValidateNotNullOrEmpty()] $salt
         )

    [string]$result = $null
    
    
    $salt_bytes = [System.Text.Encoding]::UTF8.GetBytes($salt)
    
    # Set-up
    $aes = [System.Security.Cryptography.AesManaged]::new()
    $aes.KeySize = $aes.LegalKeySizes[0].MaxSize
    $aes.BlockSize = $aes.LegalBlockSizes[0].MaxSize
    $aes.IV = STGet-RandomIV -size ($aes.BlockSize / 8)
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

    #  PBKDF2 standard with HMACSHA1 for password-based key generation
    $rfc_derivative = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($key, $salt_bytes)
    $aes.Key = $rfc_derivative.GetBytes($aes.KeySize / 8)
    $rfc_derivative.Dispose()

    $encryptor = $aes.CreateEncryptor()
    
    $memory_stream = [System.IO.MemoryStream]::new()
    $crypto_stream = [System.Security.Cryptography.CryptoStream]::new($memory_stream,  $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)

    # Convert the passed string to UTF8 as a byte array
    $message_as_bytes = [System.Text.Encoding]::UTF8.GetBytes($message)

    #  Write the iv + cipherText array to the crypto stream and flush it
    $crypto_stream.Write($message_as_bytes, 0, $message_as_bytes.Length)
    $crypto_stream.FlushFinalBlock()

    #  Get an array of bytes from the MemoryStream that holds the encrypted data
    $encrypted_bytes = $memory_stream.ToArray();
    $result = [System.Convert]::ToBase64String($aes.IV) + [System.Convert]::ToBase64String($encrypted_bytes)

    $crypto_stream.Close()
    $crypto_stream.Dispose()
    $memory_stream.Close()
    $memory_stream.Dispose()
    $encryptor.Dispose()
    $aes.Dispose()
    
    return $result
}


function AES-Decrypt
{
    param([Parameter(Mandatory=$true, Position=0)][ValidateNotNullOrEmpty()] [string] $message,
          [Parameter(Mandatory=$true, Position=1)][ValidateNotNullOrEmpty()][string] $key,
          [Parameter(Mandatory=$true, Position=1)][ValidateNotNullOrEmpty()][string] $salt
         )

    # Get the IV
    $ivBytes = [System.Convert]::FromBase64String($message.Substring(0, 16 + (16 / 2)));
    #  the last section is the base 64 encoded encrypted message
    $encrypted_bytes = [System.Convert]::FromBase64String($message.Substring(16 + (16 / 2)));

    # Set-up
    $aes = [System.Security.Cryptography.AesManaged]::new()
    $aes.KeySize = $aes.LegalKeySizes[0].MaxSize
    $aes.BlockSize = $aes.LegalBlockSizes[0].MaxSize
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.IV = $ivBytes

    $salt_bytes = [System.Text.Encoding]::UTF8.GetBytes($salt)

    #  PBKDF2 standard with HMACSHA1 for password-based key generation
    $rfc_derivative = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($key, $salt_bytes)
    $aes.Key = $rfc_derivative.GetBytes($aes.KeySize / 8)
    $rfc_derivative.Dispose()

    $decryptor = $aes.CreateDecryptor()
    $memory_stream = [System.IO.MemoryStream]::new($encrypted_bytes)
    $crypto_stream = [System.Security.Cryptography.CryptoStream]::new($memory_stream, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Read)

    $decrypted_bytes = New-Object Byte[] $memory_stream.Length
    #  Write the iv + cipherText array to the crypto stream and flush it
    $crypto_stream.Read($decrypted_bytes, 0, $decrypted_bytes.Length)
    $decryptor.Dispose()

    $result = [System.Text.Encoding]::UTF8.GetString($decrypted_bytes, 0, $decrypted_bytes.Length)

    $crypto_stream.Close()
    $memory_stream.Close()

    $crypto_stream.Dispose()
    $memory_stream.Dispose()
    $aes.Dispose()

    $result = $result.TrimEnd('\0')

    return $result
}


function Get-DomainAndUser
{
    param([Parameter(Mandatory=$true, Position=0)][ValidateNotNullOrEmpty()] [string] $userEmail)
    $result = $null

    try
    {
        $user_info = Get-ADUser -Filter {UserPrincipalName -eq $userEmail} -ErrorAction Stop
    
        if ($user_info -ne $null)
        {
            [string]$sam_account = $user_info.SamAccountName
            [string]$distinguished_name = $user_info.DistinguishedName
            foreach ($s in $distinguished_name.Split(','))
            {
                if ($s.StartsWith("DC="))
                {
                    $result = $s.Substring(3) + "\" + $sam_account
                    break
                }
            }
        }
    }
    catch
    {

    }

    return $result
}


Export-ModuleMember -Function STEncryptText
Export-ModuleMember -Function STDecryptText
Export-ModuleMember -Function STParseIniFile
Export-ModuleMember -Function AES-Encrypt
Export-ModuleMember -Function AES-Decrypt
Export-ModuleMember -Function Get-DomainAndUser