#Requires –Version 2.0
Add-Type -AssemblyName system.drawing
#$imageFormat = “System.Drawing.Imaging.ImageFormat” -as [type]

Add-Type -AssemblyName System.Windows.Forms
$saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog

#$image.Save($saveFile, $imageFormat::jpeg)
foreach ($a in $args){
    $saveFileDialog.FileName = ''
    $saveFileDialog.title = "Output files for $a"
    $saveFileDialog.initialDirectory = split-path $a
    $saveFileDialog.ShowDialog()
    $outfile_pre = $saveFileDialog.FileName
    if ($outfile_pre -ne ''){
        $image = [drawing.image]::FromFile($a)
        $c = $image.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page);
        for ($i = 0; $i -lt $c; $i++){
            $image.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $i) | out-null
            $image.Save($outfile_pre + '_' + $i + '.tif')
            Write-Host "File write ${outfile_pre}_${i}.tif"
        }
    }
}
