#Requires -Version 7
add-type -AssemblyName 'system.drawing'

$jsonData = convertfrom-json ((Get-Content test_zones.json) -split '`n' -join '') -ashashtable

$fonts = [System.Collections.Generic.Dictionary[[string],[system.drawing.font]]]::new()
foreach ($z in $jsonData.zones.GetEnumerator()){
    $font,$size = $z.value['font','fontSize']
    $name = "$font-$size"
    if ($font -and -not $fonts.ContainsKey($name)){
        $fonts.Add($name, [system.drawing.font]::new($font,$size ?? 12))
    }
}
write-host $fonts
$brushBlack = [System.Drawing.SolidBrush]::new('black')
foreach ($p in $jsonData.pages.GetEnumerator()){
    write-host 'create image of size' $jsonData.width 'x' $jsonData.height
    #$image = [system.drawing.bitmap]::new($jsonData.width,$jsonData.height)
    ## we go zone by zone
    foreach ($z in $p.value.getenumerator()){
        $zname, $zv = $z.name,$z.value
        $zone = $jsonData.zones[$zname]
        $fontName = '{0}-{1}' -f $zone.font,$zone.fontSize
        $font = $fonts[$fontName]
        $rec = [system.drawing.rectanglef]::new($zone.x,$zone.y,$zone.width,$font.Height+10)
        #write-host $rec
        $stringformat = [system.drawing.stringformat]::new()
        switch ($zone.alignment){
            'center' { $stringformat.alignment = 'Center' }
            'left' { $stringformat.alignment = 'Near' }
            'right' { $stringformat.alignment = 'Far' }
        }
        foreach ($v in $zv){
            write-host 'draw string' $v 'with font' $font $brushBlack $rec
            $rec.y += $font.Height+2
        }
    }
}

$brushBlack.dispose()