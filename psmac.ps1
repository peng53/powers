[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')


function XTab(){
    [System.Windows.Forms.SendKeys]::SendWait("x{TAB}")
}

[System.Windows.Forms.SendKeys]::SendWait("%{tab}")
for ($i=0;$i -lt 8;$i++){
    XTab
}