param ($reinstall = "No",
       $API_Token,
       $Servername,
       $domainUsername,
       $domainPassword)

# Read Server name #

function agent-install {
Param($key, $account)
$ScriptPath = "c:\Scripts\"
  #$Username = 'IDEXCEL\user1'
  #$Password = 'P@ssw0rd@1010'
  $pass = ConvertTo-SecureString -AsPlainText $domainPassword -Force

$SecureString = $pass
# Users you password securly
$MySecureCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domainUsername,$SecureString 
if ($account -ne "") {
  foreach ($machine in $account) {
  if ($reinstall -eq 'Yes' -or ($reinstall -eq 'No' -and (!(Invoke-Command -ComputerName $machine -Credential $MySecureCreds -ScriptBlock {Test-path "c:\Program Files (x86)\CloudEndure\dist\windows_service_wrapper.exe"})))) {
  write-host "--------------------------------------------------------"
  write-host "- Installing CloudEndure for:   $machine -" -BackgroundColor Blue
  write-host "--------------------------------------------------------"
  #$userName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  write-host "Logged In user : $domainUsername"
  if (!(Invoke-Command -ComputerName $machine -Credential $MySecureCreds -ScriptBlock {Test-path "c:\Scripts\"})) {Invoke-Command -ComputerName $machine -Credential $MySecureCreds -ScriptBlock {New-Item -Path "c:\Scripts\" -ItemType directory}}
  Invoke-Command -ComputerName $machine -Credential $MySecureCreds -ScriptBlock {(New-Object System.Net.WebClient).DownloadFile("https://console.cloudendure.com/installer_win.exe","C:\Scripts\installer_win.exe")}
  $fileexist = Invoke-Command -ComputerName $machine -Credential $MySecureCreds -ScriptBlock {Test-path "c:\Scripts\installer_win.exe"}
  if ($fileexist -eq "true") {
    $message = "** Successfully downloaded CloudEndure for: " + $machine + " **"
    Write-Host $message
     }
  $command = $ScriptPath + "installer_win.exe -t " + $key + " --no-prompt" + " --skip-dotnet-check"
  $scriptblock2 = $executioncontext.invokecommand.NewScriptBlock($command)
  Invoke-Command -ComputerName $machine -Credential $MySecureCreds -ScriptBlock $scriptblock2
  write-host
  write-host "** CloudEndure installation finished for : $machine **" 
  write-host
  }
  else {
   $message = "CloudEndure agent already installed for machine: " + $machine + " , please reinstall manually if required"
   write-host $message -BackgroundColor Red
  }
  }
  }
}

agent-install $API_Token $Servername