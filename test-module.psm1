function MyFunc ([string]$x){
    write-host Hello $x !
}
Export-ModuleMember -Function MyFunc

# to use
# Import-Module test-module.psm1