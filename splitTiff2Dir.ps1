foreach ($a in $args){
    if ($a.EndsWith('.tif')){
        $f = Get-Item $a
        $od = '{0}\{1}' -f ($f.Directory,$f.BaseName)
        if (!(Test-Path $od)){
            New-Item -Path $od -ItemType Directory | out-null
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
        } else {
            Write-Host 'Folder' $od 'already exists'
        }
    } else {
        Write-Host 'Skipping non-tif' $a
    }
}