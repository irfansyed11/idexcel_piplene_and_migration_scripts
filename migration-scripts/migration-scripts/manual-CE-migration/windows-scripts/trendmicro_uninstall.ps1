$app = Get-WmiObject -Class Win32_Product | where-object {$_.Name -match "Trend Micro Deep Security Agent"}

$app.uninstall()
