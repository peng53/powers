#Requires -Version 7
add-type -AssemblyName 'system.drawing'

$width = 1000
$height = 600
$templateImgPath = 'r:/template.png'
$templateImg = $null
#$mainBrush = [system.drawing.brushes]::blue
$mainBrush = [system.drawing.systembrushes]::WindowText

if ($templateImgPath -and (test-path $templateImgPath)){
    $templateImg =[system.drawing.image]::fromfile($templateImgPath)
}

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
    if ($row.font -and -not $fonts.ContainsKey($name)){
        $st = $styles.Regular
        if ($styles.Containskey($row.fontStyle)){
            $st = $styles[$row.fontStyle]
        }
        $fonts.Add($name, [system.drawing.font]::new($row.font,[int]$row.fontSize ?? 12, $st,[system.drawing.graphicsunit]::Point))
    }
    $color = 'black'
    if ($row.color){
        $color = $row.color
        write-host $color $row.color
    }
    $zones[$row.Name] = @{
        x = [int]$row.x
        y = [int]$row.y
        fontSize = [int]$row.fontSize
        font = $row.font
        fontStyle = $row.fontStyle
        alignment = $row.alignment
        vfont = $name
        color = [system.drawing.brushes]::$color
    }
}
## below command will 'zones' section for json
# $zones | ConvertTo-Json

$cols = @{}
foreach ($kv in $data[0].PSObject.properties){
    if ($kv.Name -ne 'Page'){
        $cols[$kv.Name] = $null
    }
}
$page = $null
$print_row = 0

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
        if ($templateImg){
            $image = $templateImg.clone([system.drawing.rectangle]::new(0,0,$templateImg.width,$templateImg.height),[System.Drawing.Imaging.PixelFormat]::Format16bppRgb555)
        } else {
            $image = [system.drawing.bitmap]::new($width,$height)
        }
        $g = [System.Drawing.Graphics]::FromImage($image) 
        $page = $row.Page
        $print_row = 0
    }
    foreach ($k in $cols.Keys){
        $zone = $zones[$k]
        $font = $fonts[$zone.vfont]
        $pt = [system.drawing.pointf]::new($zone.x,$zone.y)
        $pt.y += ($font.Height+2)*$print_row
        switch ($zone.alignment){
            'center' { $stringformat.alignment = 'Center' }
            'left' { $stringformat.alignment = 'Near' }
            'right' { $stringformat.alignment = 'Far' }
        }
        $g.DrawString($row.$k,$font,$zone.color,$pt,$stringformat)
    }
    $print_row++
}
if ($image){
    write-host 'saving' $page
    $image.save('r:/page_{0}.png' -f $page)
    $g.dispose()
    $image.dispose()
}

$t = $fonts.keys
foreach ($k in $t){
    $fonts[$k].Dispose()
}
$fonts.Clear()

if ($templateImg){
    $templateImg.dispose()
}