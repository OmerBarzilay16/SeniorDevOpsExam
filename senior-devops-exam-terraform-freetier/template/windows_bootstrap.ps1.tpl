<powershell>
# Password that Terraform generated and injected
$password = "${admin_password}"

# Set local Administrator password
$securePass = ConvertTo-SecureString -String $password -AsPlainText -Force
$admin = [ADSI]"WinNT://./Administrator,user"
$admin.SetPassword($password)
Write-Output "Administrator password set from Terraform user_data"

# --- Configure WinRM ---

# Basic WinRM config
winrm quickconfig -q

# Enable Basic auth for WinRM service (required for Ansible winrm_transport=basic)
winrm set winrm/config/service/auth '@{Basic="true"}'

# For HTTPS we keep AllowUnencrypted = false (more secure)
winrm set winrm/config/service '@{AllowUnencrypted="false"}'

# Create self-signed cert for WinRM HTTPS
$cert = New-SelfSignedCertificate -DnsName "winrm-local" -CertStoreLocation "cert:\LocalMachine\My"
$thumb = $cert.Thumbprint

# Remove any existing listeners
Remove-Item -Path WSMan:\Localhost\Listener\* -Recurse -ErrorAction SilentlyContinue

# Create HTTPS listener on 5986
New-Item -Path WSMan:\Localhost\Listener `
  -Transport HTTPS `
  -Address * `
  -CertificateThumbprint $thumb `
  -Port 5986 `
  -Force

# Firewall rule for WinRM HTTPS
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986

# Firewall rule for HTTP (IIS)
netsh advfirewall firewall add rule name="HTTP" dir=in action=allow protocol=TCP localport=80

# Ensure WinRM service is running
Set-Service -Name WinRM -StartupType Automatic
Start-Service WinRM

Write-Output "WinRM HTTPS (5986) configured."
</powershell>
