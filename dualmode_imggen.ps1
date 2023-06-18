#Requires -Version 7
add-type -AssemblyName 'system.drawing'
add-type -AssemblyName 'system.windows.forms'

#getting specs
# specs should be csv with header
# Name,x0,y0,fontSize,font,fontStyle,alignment,color,dx,dy
$allSpecs = import-csv $psscriptroot/etc/zone_specs_dual.csv
#getting specs end

$data = import-csv $psscriptroot/etc/test_zones_dual.csv
# data should have Filename column and all other columns should be in the spec to be captured on file
# getting cols start
$ignoreCols = 'Filename,Width,Height'
$dataCols = $data[0].psobject.Properties.Name | Where-Object {$ignoreCols -notcontains $_}
$drawCols = [System.Collections.Generic.Dictionary[string,pscustomobject]]::new()
$fonts = [System.Collections.Generic.Dictionary[[string],[system.drawing.font]]]::new()
$styles = @{
    Regular = [System.Drawing.FontStyle]::Regular
    Bold = [System.Drawing.FontStyle]::Bold
    Italic = [System.Drawing.FontStyle]::Italic
}
foreach ($row in $allSpecs){
    if ($dataCols.Contains($row.Name)){
        $drawCols.Add($row.Name, $row)
        $font = '{0}|{1}|{2}' -f $row.font,$row.fontSize,$row.fontStyle
        if (-not $fonts.containskey($font)){
            $st = [System.Drawing.FontStyle]::Regular
            if ($styles.Containskey($row.fontStyle)){
                $st = [System.Drawing.FontStyle]$row.fontStyle
            }
            $fonts.Add($font, [system.drawing.font]::new($row.Font,[int]$row.fontSize, $st,[system.drawing.graphicsunit]::Point))
        }
    }
}
#getting cols end
$width = 1700
$height = 600
$templateFile = 'templateImg.png'
$template = $null
if ((Test-Path $templateFile)){
    $template = [system.drawing.image]::fromfile($templateFile)
    $width = $template.Width
    $height = $template.Height
}
$folderSelector = [System.Windows.Forms.FolderBrowserDialog]::new()
$outpath = $null
$noClobber = $false
write-host 'Safe mode: ' $noClobber
if ($folderSelector.ShowDialog() -eq 'OK'){
    $outpath = $folderSelector.SelectedPath
} else {
    exit
}
$folderSelector.dispose()
#drawing core
$align = [system.drawing.stringformat]::new()
foreach ($row in $data){
    if ($row.Filename.length -le 0){
        write-host 'Filename column empty'
        continue
    }
    $fn = join-path $outpath $row.Filename
    if ((Test-path $fn) -and $noClobber){
        write-host 'File already exists'
        continue
    }
    $frame = $null
    $g = $null
    if ($template -eq $null){
        if ($row.width -and $row.height){
            $width = [int]$row.width
            $height = [int]$row.height
        }
        if ($width -gt 0 -and $height -gt 0){
            $frame = [system.drawing.bitmap]::new($width,$height)
            # create blank (white) canvas
            $g = [system.drawing.graphics]::FromImage($frame)
            $g.FillRectangle([System.Drawing.Brushes]::White,[system.drawing.rectangle]::new(0,0,$width,$height))
        }
    } else {
        $frame = $template.clone([system.drawing.rectangle]::new(0,0,$width,$height),[System.Drawing.Imaging.PixelFormat]::Format16bppRgb555)
        $g = [system.drawing.graphics]::FromImage($frame)
    }
    if ($frame -eq $null -or $g -eq $null){
        write-host 'Failed to create image or graphic'
        break
    }
    foreach ($col in $drawCols.GetEnumerator()){
        if (($row.($col.Key)).Length -lt 1){
            continue
        }
        $vals = ($row.($col.Key)).split('|')
        $pos = [system.drawing.pointf]::new(($col.value).x0, ($col.value).y0)
        switch (($col.value).alignment){
            'center' {$align.alignment = 'Center'}
            'left' {$align.alignment = 'Near'}
            'right' {$align.alignment = 'Far'} 
        }
        $font = '{0}|{1}|{2}' -f $col.Value.font,$col.Value.fontSize,$col.Value.fontStyle
        foreach ($v in $vals){
            $g.drawstring(
                $v,
                $fonts[$font],
                [system.drawing.brushes]::($col.Value.Color),
                $pos,
                $align
            )
            $pos.x += ($col.Value).dx
            $pos.y += ($col.Value).dy
        }
    }
    $frame.save($fn)
    $g.Dispose()
    $frame.Dispose()
}
if ($template){
    $template.Dispose()
}
foreach ($f in $fonts.Values){
    $f.dispose()
}
$fonts.Clear()