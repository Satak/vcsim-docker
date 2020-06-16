$password = "xxx" | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential('test', $password)
$r = Invoke-RestMethod -Uri 'https://localhost/rest/com/vmware/cis/session' -SkipCertificateCheck -Authentication Basic -Credential $credential -Method Post
Invoke-WebRequest -Uri 'https://localhost/rest/vcenter/vm' -Headers @{'vmware-api-session-id' = $r.value } -SkipCertificateCheck
