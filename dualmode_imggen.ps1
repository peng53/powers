#Requires -Version 7
add-type -AssemblyName 'system.drawing'
add-type -AssemblyName 'system.windows.forms'

Function ImgGen([string]$specfile
    ,[string]$datafile
    ,[string]$outpath
    ,[bool]$clobber=$false
    ,[int]$width=1700
    ,[int]$height=600
    ,[string]$templateFile = 'template.png'
){
    # specs should be csv with header
    # Name,x0,y0,fontSize,font,fontStyle,alignment,color,dx,dy
    $allSpecs = import-csv $specfile
    $data = import-csv $datafile
    # data should have Filename column and all other columns should be in the spec to be captured on file
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

    $template = $null
    if ((Test-Path $templateFile)){
        $template = [system.drawing.image]::fromfile($templateFile)
        $width = $template.Width
        $height = $template.Height
    }
    #drawing core
    $align = [system.drawing.stringformat]::new()
    $frame = $null
    $g = $null
    $t = 1
    $pos = [system.drawing.pointf]::new(0,0)
    foreach ($row in $data){
        if ($row.Filename.length -le 0){
            write-error "Filename column empty at line # $t" -Category ParserError
            continue
        }
        $fn = join-path $outpath $row.Filename
        if (-not $clobber -and (Test-path $fn)){
            write-error "File already exists: $fn" -Category WriteError
            continue
        }
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
            } else {
                Write-Error "Invalid size dimensions (width/height) $width $height" -Category InvalidData
                continue
            }
        } else {
            $frame = $template.clone([system.drawing.rectangle]::new(0,0,$width,$height),[System.Drawing.Imaging.PixelFormat]::Format16bppRgb555)
            $g = [system.drawing.graphics]::FromImage($frame)
        }
        if ($frame -eq $null -or $g -eq $null){
            write-error 'Failed to create image or graphic' -Category NotSpecified
            break
        }
        $drawn = $false
        foreach ($col in $drawCols.GetEnumerator()){
            if (($row.($col.Key)).Length -lt 1){
                continue
            }
            $drawn = $true
            $vals = ($row.($col.Key)).split('|')
            $pos.x = [int]($col.value).x0
            $pos.y = [int]($col.value).y0
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
        if ($drawn){
            $frame.save($fn)
        } else {
            write-error "No data to draw for line $t" -Category InvalidData
        }
        $g.Dispose()
        $frame.Dispose()
        $t++
    }
    if ($template){
        $template.Dispose()
    }
    foreach ($f in $fonts.Values){
        $f.dispose()
    }
    $fonts.Clear()
}

ImgGen -specfile "$PSScriptRoot/etc/zone_specs_dual.csv" -datafile "$PSScriptRoot/etc/test_zones_dual.csv" -outpath 'R:/' -clobber $true