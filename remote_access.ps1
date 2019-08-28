# Enabling remote access for PowerShell

# Check TrustedHosts
Get-Item WSMan:\localhost\Client\TrustedHosts

# Set TrustedHosts to allow all if necessary
Set-Item WSMan:\localhost\Client\TrustedHosts -Value *

# Enable remoting
Enable-PSRemoting

# Enter the remote session with IP and credentials. A password prompt window will appear.
Enter-PSSession -ComputerName 172.16.12.20 -Credential "administrator"

# Use Copy-Item to copy items between sessions
$Session = New-PSSession -ComputerName "Server01" -Credential "Contoso\PattiFul"
Copy-Item "D:\Folder001\test.log" -Destination "C:\Folder001_Copy\" -ToSession $Session

# Invoke remote commands
Invoke-Command -Session $sess -ScriptBlock {
    Get-ChildItem -Path C:\Windows\System32 -Recurse -ErrorAction SilentlyContinue -Force |
    Get-FileHash -Algorithm MD5 |
    Export-Csv -Path C:\sys32_hashes.csv
}

# Invoke executable with cmd.exe
Invoke-Command -Session $sess -ScriptBlock {
    cmd.exe /C C:\executable.exe
}
