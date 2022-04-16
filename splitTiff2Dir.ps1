foreach ($a in $args){
    $f = Get-Item $a
    $od = New-Item -Path $f.Directory -Name $f.BaseName -ItemType Directory
    try { $img = [drawing.image]::FromFile($a) }
    catch {
        Add-Type -AssemblyName system.drawing
        $img = [drawing.image]::FromFile($a)
    }
    $c = $img.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page)
    for ($i = 0; $i -lt $c; $i++){
        $img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $i) | out-null
        $img.Save($od.toString() + '/' + $f.BaseName + '_' + $i + '.tif')
    }
}