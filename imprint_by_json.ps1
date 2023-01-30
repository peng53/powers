#Requires -Version 7
add-type -AssemblyName 'system.drawing'

$jsonData = convertfrom-json ((Get-Content $PSScriptroot\etc\test_zones.json) -split '`n' -join '') -ashashtable

$fonts = [System.Collections.Generic.Dictionary[[string],[system.drawing.font]]]::new()
foreach ($z in $jsonData.zones.GetEnumerator()){
    $font,$size,$style = $z.value['font','fontSize','fontStyle']
    $name = "$font-$size-$style"
    write-host $font
    $st = [System.Drawing.FontStyle]::Regular
    switch ($style){
        'Regular' { $st = [System.Drawing.FontStyle]::Regular }
        'Bold' { $st = [System.Drawing.FontStyle]::Bold }
        'Italic' { $st = [System.Drawing.FontStyle]::Italic }
    }
    if ($font -and -not $fonts.ContainsKey($name)){
        $fonts.Add($name, [system.drawing.font]::new($font,[int]$size ?? 12, $st,[system.drawing.graphicsunit]::Point))
    }
}
write-host $fonts
$brushBlack = [System.Drawing.SolidBrush]::new('black')
foreach ($p in $jsonData.pages.GetEnumerator()){
    write-host 'create image of size' $jsonData.width 'x' $jsonData.height
    $image = [system.drawing.bitmap]::new([int]$jsonData.width,[int]$jsonData.height)
    $g = [System.Drawing.Graphics]::FromImage($image)
    ## we go zone by zone
    foreach ($z in $p.value.getenumerator()){
        $zname, $zv = $z.name,$z.value
        $zone = $jsonData.zones[$zname]
        $fontName = '{0}-{1}-{2}' -f $zone.font,$zone.fontSize,$zone.fontStyle
        $font = $fonts[$fontName]
        $pt = [system.drawing.pointf]::new($zone.x,$zone.y)
        $stringformat = [system.drawing.stringformat]::new()
        switch ($zone.alignment){
            'center' { $stringformat.alignment = 'Center' }
            'left' { $stringformat.alignment = 'Near' }
            'right' { $stringformat.alignment = 'Far' }
        }
        foreach ($v in $zv){
            $g.DrawString($v,$font,$brushBlack,$pt,$stringformat)
            write-host 'draw string' $v 'with font' $font $brushBlack $rec
            $pt.y += $font.Height+2

        }
    }
    $image.save('r:/{0}.png' -f $p.name)
    $g.dispose()
    $image.dispose()
}

$brushBlack.dispose()
