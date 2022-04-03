#Requires –Version 2.0
Add-Type -AssemblyName system.drawing
#$imageFormat = “System.Drawing.Imaging.ImageFormat” -as [type]
$outdir = "r:/outd"
$outpre = "page"
#$image.Save($saveFile, $imageFormat::jpeg)
foreach ($a in $args){
    if (-not $a.EndsWith('.tif')){ continue }
    $image = [drawing.image]::FromFile($a)
    $c = $image.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page);
    for ($i = 0; $i -lt $c; $i++){
        $image.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $i)
        $image.Save('{0}/{1}_{2}.tif' -f ($outdir,$outpre,$i))
    }
}