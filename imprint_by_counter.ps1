#Requires -Version 7
add-type -AssemblyName 'system.drawing'



$data = import-csv $PSScriptRoot\etc\test_zones.csv
$specData = import-csv $PSScriptRoot\etc\zone_specs.csv
$styles = @{
    Regular = [System.Drawing.FontStyle]::Regular
    Bold = [System.Drawing.FontStyle]::Bold
    Italic = [System.Drawing.FontStyle]::Italic
}

$fonts = [System.Collections.Generic.Dictionary[[string],[system.drawing.font]]]::new()
$zones = @{}

foreach ($row in $specData){
    
    $name = '{0}-{1}-{2}' -f $row.font,$row.fontSize,$row.fontStyle
    $st = $styles.Regular
    if ($styles.Containskey($row.fontStyle)){
        $st = $styles[$row.fontStyle]
    }
    <#
    switch ($row.style){
        'Regular' { $st = [System.Drawing.FontStyle]::Regular }
        'Bold' { $st = [System.Drawing.FontStyle]::Bold }
        'Italic' { $st =[System.Drawing.FontStyle]::Italic }
    }#>
    if ($row.font -and -not $fonts.ContainsKey($name)){
        $fonts.Add($name, [system.drawing.font]::new($row.font,[int]$row.fontSize ?? 12, $st,[system.drawing.graphicsunit]::Point))
    }
    $zones[$row.Name] = @{
        x = [int]$row.x
        y = [int]$row.y
        fontSize = [int]$row.fontSize
        font = $row.font
        fontStyle = $row.fontStyle
        alignment = $row.alignment
        vfont = $name
    }
}

$width = 1000
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
            write-host 'saving' $page
            $image.save('r:/page_{0}.png' -f $page)
            $g.dispose()
            $image.dispose()
        }
        $image = [system.drawing.bitmap]::new($width,$height)
        $g = [System.Drawing.Graphics]::FromImage($image) 
        $page = $row.Page
        $print_row = 0
    }
    #write-host $row
    foreach ($k in $cols.Keys){
        #write-host $k $row.$k $print_row

        $zone = $zones[$k]
        $font = $fonts[$zone.vfont]
        $pt = [system.drawing.pointf]::new($zone.x,$zone.y)
        $pt.y += ($font.Height+2)*$print_row
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
    write-host 'saving' $page
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