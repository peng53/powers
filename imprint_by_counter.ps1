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
        x = 1000
        y = 16
        fontSize = 24
        font = 'Arial'
        fontStyle = 'Bold'
        alignment = 'right'
    }
}
$fonts = [System.Collections.Generic.Dictionary[[string],[system.drawing.font]]]::new()

foreach ($z in $zones.GetEnumerator()){
    $font,$size,$style = $z.value['font','fontSize','fontStyle']
    $name = "$font-$size-$style"
    $st = [System.Drawing.FontStyle]::Regular
    switch ($style){
        'Regular' { $st = [System.Drawing.FontStyle]::Regular }
        'Bold' { $st = [System.Drawing.FontStyle]::Bold }
        'Italic' { [System.Drawing.FontStyle]::Italic }
    }
    if ($font -and -not $fonts.ContainsKey($name)){
        $fonts.Add($name, [system.drawing.font]::new($font,[int]$size ?? 12, $st,[system.drawing.graphicsunit]::Point))
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

$brushBlack = [System.Drawing.SolidBrush]::new('black')
$image = $null
$g = $null

$stringformat = [system.drawing.stringformat]::new()
foreach ($row in $data){
    if ($row.Page -ne $page){
        if ($image){
            $image.save('r:/page_{0}.png' -f $page)
            $g.dispose()
            $image.dispose()
        }
        $image = [system.drawing.bitmap]::new($width,$height)
        $g = [System.Drawing.Graphics]::FromImage($image) 
        $page = $row.Page
        $print_row = 0
    }
    foreach ($k in $cols.Keys){
        #write-host $k $row.$k $print_row

        $zone = $zones[$k]
        $fontName = '{0}-{1}-{2}' -f $zone.font,$zone.fontSize,$zone.fontStyle
        $font = $fonts[$fontName]
        $pt = [system.drawing.pointf]::new($zone.x,$zone.y+(($font.Height+2)*$print_row))
        switch ($zone.alignment){
            'center' { $stringformat.alignment = 'Center' }
            'left' { $stringformat.alignment = 'Near' }
            'right' { $stringformat.alignment = 'Far' }
        }

        $g.DrawString($row.$k,$font,$brushBlack,$pt,$stringformat)
    }
    $print_row++
}
if ($image){
    $image.save('r:/page_{0}.png' -f $page)
    $g.dispose()
    $image.dispose()
}

$brushBlack.dispose()

$stk = [System.Collections.Generic.Stack[string]]::new()
foreach ($k in $fonts.keys){
    [void]$stk.push($k)
}
while ($stk.count -gt 0){
    $x = $stk.pop()
    $fonts[$x].dispose()
    [void]$fonts.Remove($x)
}