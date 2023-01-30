#Requires -Version 7
add-type -AssemblyName 'system.drawing'

$data = import-csv $PSScriptRoot\etc\test_zones.csv

$zones = @{
    'EmployeeNo' = @{
        x = 50
        y = 16
        fontSize = 24
        font = 'Arial'
        fontStyle = 'Regular'
        alignment = 'left'
    }
    'FirstName' = @{
        x = 250
        y = 16
        fontSize = 24
        font = 'Arial'
        fontStyle = 'Regular'
        alignment = 'left'
    }
    'LastName' = @{
        x = 450
        y = 16
        fontSize = 24
        font = 'Arial'
        fontStyle = 'Regular'
        alignment = 'left'
    }
    'Wage' = @{
        x = 700
        y = 16
        fontSize = 24
        font = 'Arial'
        fontStyle = 'Bold'
        alignment = 'right'
    }
}
$width = 1700
$height = 600

$cols = @{}

foreach ($kv in $data[0].PSObject.properties){
    if ($kv.Name -ne 'Page'){
        $cols[$kv.Name] = $null
    }
}
$page = $null
$print_row = 0

foreach ($row in $data){
    if ($row.Page -ne $page){
        $print_row = 0
        $page = $row.Page
    }
    foreach ($k in $cols.Keys){
        write-host $k $row.$k $print_row
    }
    $print_row++
}