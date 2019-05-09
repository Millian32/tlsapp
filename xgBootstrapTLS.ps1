Write-Host "Import Certificate" ;

$appName = [Environment]::GetEnvironmentVariable("AppName", "Process")
$pfxPassword = [Environment]::GetEnvironmentVariable("PfxPassword", "Process")
#Write-Host $pfxPassword ;

$pfxFile = Get-ChildItem -Path .\ -Filter *.pfx -File -Name| ForEach-Object {[System.IO.Path]::GetFileNameWithoutExtension($_) } ;
#Write-Host $pfxFile ;

$securePfxPassword = ConvertTo-SecureString -String $pfxPassword -AsPlainText -Force ;
$importCertOutput = Import-PfxCertificate -FilePath C:\$pfxFile.pfx -CertStoreLocation Cert:\LocalMachine\My -Password $securePfxPassword ;
#Write-Host $importCertOutput ;

$pfxThumbprint = (Get-PfxData -FilePath c:\tlstest.pfx -Password $securePfxPassword).EndEntityCertificates.Thumbprint
$binding = New-WebBinding -Name $appName -Protocol https -IPAddress * -Port 443;
$binding = Get-WebBinding -Name $appName -Protocol https;
$binding.AddSslCertificate($pfxThumbprint, $appName);

#Write-Host $binding ;

##Cleanup
[Environment]::SetEnvironmentVariable("PfxPassword",$null) ;
#Remove-Item –Path $pfxFile ;
$binding = '';
$securePfxPassword = '';
$importCertOutput = '';
$pfxFile = '';
##End Cleanup

Write-Host "Reset IIS..." ; 
Start-Process iisreset -Wait ;