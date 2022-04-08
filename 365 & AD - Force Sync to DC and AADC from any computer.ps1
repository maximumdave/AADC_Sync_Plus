#Sync Domain Controllers
if ($env:LOGONSERVER -eq $env:COMPUTERNAME)
{
    repadmin /syncall /force /APed
}
elseif ($env:LOGONSERVER -ne $env:COMPUTERNAME)
{
    Invoke-Command -ComputerName $env:LOGONSERVER.split("\\")[2] -ScriptBlock {repadmin /syncall /force /APed}
}

#Initiate Full Sync on AADC server
$aadcs = ((get-aduser -filter * -Properties Description | Where-Object {$_.Name -like "MSOL*" -and $_.Enabled -eq "True"}).description).split(" ")[15]
foreach ($aadc in $aadcs)
{
    if ($env:COMPUTERNAME -eq $aadc)
    {
        Start-ADSyncSyncCycle -policytype initial
    }
    elseif ($env:COMPUTERNAME -ne $aadc)
    {
        Invoke-Command -ComputerName $aadc -ScriptBlock {Start-ADSyncSyncCycle -policytype initial}
    }
}