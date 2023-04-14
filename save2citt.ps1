[Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”);
#$img = New-Object System.Drawing.Bitmap c:/users/lm/pictures/multi.tif.bmp
$img = New-Object System.Drawing.Bitmap c:/users/lm/pictures/multilzw.tif
$myenc =  [System.Drawing.Imaging.Encoder]::Compression
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myenc, 4)
$myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|where {$_.MimeType -eq 'image/tiff'}
$c = $img.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page)
for ($i = 0; $i -lt $c; $i++){
    $img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $i) | out-null
    $img.Save('r:/lzw_' + $i + '.tif', $myImageCodecInfo, $($encoderParams))
}
#$img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $i) | out-null
#$img.save('R:\testsave.tif',$myImageCodecInfo,$($encoderParams))