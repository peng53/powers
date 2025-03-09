add-type -AssemblyName 'system.drawing'

function Get-Header-Cols(
    [Parameter(Mandatory)][PSCustomObject]$Header
){
    $cols = [System.Collections.Generic.List[String]]::new()
    foreach ($x in $Header.psobject.properties){
        $cols.Add($x.Name)
    }
    return $cols
}

function Create-Imprint(
    [Parameter(Mandatory)][Object[]]$Specs
    ,[Parameter(Mandatory)][System.Collections.Generic.Dictionary[string,int]]$SpecIx
    ,[Parameter(Mandatory)][System.Collections.Generic.Dictionary[[string],[system.drawing.font]]]$Fonts
    ,[Parameter(Mandatory)][system.drawing.bitmap]$Template
    ,[Parameter(Mandatory)][string]$Outfile
    ,[Parameter(Mandatory)][System.Collections.Generic.List[string]]$HeaderCols
    ,[Parameter(Mandatory)][PSCustomObject]$Row
){
    $strFmt = [System.Drawing.StringFormat]@{alignment='Near'}
    $styles = @('Regular','Bold','Italic','Underline','Strikeout')
    $img = $Template.Clone()
    $g = [System.Drawing.Graphics]::FromImage($img)
    foreach ($col in $HeaderCols){
        $S = $Specs[$SpecIx[$col]]
        $fontName = '{0}-{1}-{2}' -f $S.Font,$S.Size,$S.Style
        if (-not $Fonts.ContainsKey($fontName)){
            $style = if ($styles.Contains($S.Style)){
                [System.Drawing.FontStyle]$S.Style
            } else {
                [System.Drawing.FontStyle]::Regular
            }   
            $Fonts.Add($fontName,[system.drawing.font]::new($S.Font,[int]$S.Size,$style,[System.Drawing.GraphicsUnit]::Point))
        }
        $font = $fonts[$fontName]
        $strFmt.Alignment = switch -Wildcard ($S.Align){
            'L*' {'Near'}
            'R*' {'Far'}
            'C*' {'Center'}
            default {'Near'}
        }
        $Color = $S.Color
        $vals = ($Row.$col).Split('|')
        $x = [int]$S.x
        $y = [int]$S.y
        foreach ($v in $vals){
            $vf = switch -Wildcard ($S.Format){
                'c*' {([float]$v).ToString($S.Format)}
                'f*' {([float]$v).ToString($S.Format)}
                'd*' {([int]$v).ToString($S.Format)}
                default {$v}
            }
            $g.DrawString($vf, $font, [System.Drawing.Brushes]::$Color, $x, $y, $strFmt)
            $x += [int]$S.dx
            $y += [int]$S.dy
        }
    }
    $g.Dispose()
    $img.Save($Outfile)
}

function Get-Index-Spec(
    [Parameter(Mandatory)][Object[]]$Specs
){
    $index = [System.Collections.Generic.Dictionary[string,int]]::new()
    for ($i=0;$i -lt $Specs.Count; $i++){
        $index.Add($Specs[$i].Name,$i)
    }
    return $index
}

function Create-Imprints(
    [Parameter(Mandatory)][string]$SpecFile
    ,[string]$Template
    ,[int]$Height
    ,[int]$Width
    ,[string]$BgCol
    ,[Parameter(Mandatory)][string]$Infile
){
    $data = Import-Csv -Path $Infile
    if ($data.Count -lt 1){
        Write-Host 'No data!'
        return
    }
    $spec = Import-Csv -Path $SpecFile
    $specIndex = Get-Index-Spec -Specs ([ref]$spec)
    $cols = Get-Header-Cols -Header ([ref]$data[0])
    $fonts = [System.Collections.Generic.Dictionary[[string],[system.drawing.font]]]::new()
    if ($Template.length -gt 0){
        $t = [system.drawing.image]::fromfile($template)
        $templateImg = $t.clone([system.drawing.rectangle]::new(0,0,$t.width,$t.height),[System.Drawing.Imaging.PixelFormat]::Format16bppRgb555)
        $t.dispose()
    } else {
        $templateImg = [system.drawing.bitmap]::new($Width,$Height)
        $g = [System.Drawing.Graphics]::FromImage($templateImg)
        $g.FillRectangle([System.Drawing.Brushes]::$BgCol,0,0,$Width,$Height)
        $g.Dispose()
    }
    foreach ($row in $data){
        $out = (join-path r:/ $row.Row)+'.jpg'
        Create-Imprint -Specs ([ref]$spec) -SpecIx ([ref]$specIndex) -Template ([ref]$templateImg) -Fonts ([ref]$fonts) -Outfile $out -Row ([ref]$row) -HeaderCols ([ref]$cols)
    }
    $templateImg.Dispose()
    write-host $fonts.Count
    foreach ($font in $fonts.GetEnumerator()){
        $font.Value.Dispose()
    }
}



$fileSelector = [Microsoft.Win32.OpenFileDialog]@{filter='CSV|*.csv'}

if ($fileSelector.ShowDialog()){
    Create-Imprints -SpecFile C:\users\engpe\ps1\etc\imprint_by_counter_specfile.csv -Infile $fileSelector.FileName -Width 800 -Height 400 -BgCol White
}