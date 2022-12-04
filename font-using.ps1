#Requires -Version 5.1
using namespace System.Windows.Forms
Add-Type -AssemblyName 'System.Windows.Forms'
add-type -AssemblyName 'system.drawing'

$pfc = [System.Drawing.Text.PrivateFontCollection]::new()
$pfc.AddFontFile('R:\GnuMICR.ttf')
#$font = [system.drawing.font]::new($pfc.Families[0].Name, 24, "Regular", "Pixel")
$font = [system.drawing.font]::new($pfc.Families[0], 16)


$form = [form]@{width=500;height=400;text='font-using.ps1';AllowDrop='true'}
$layout = [tablelayoutpanel]@{dock='fill';columncount=1;rowcount=2}
$buttons = [toolstrip]::new()
$textbox = [toolstriptextbox]@{font=$font}
[void]$buttons.Items.Add([toolstriplabel]::new('Text'))
[void]$buttons.Items.Add($textbox)
$xposTb = [toolstriptextbox]@{Width=50;AutoSize=$false}
$yposTb = [toolstriptextbox]@{Width=50;AutoSize=$false}

[void]$buttons.Items.Add([toolstriplabel]::new('X'))
[void]$buttons.Items.Add($xposTb)
[void]$buttons.Items.Add([toolstriplabel]::new('Y'))
[void]$buttons.Items.Add($yposTb)


$imprintButton = [toolstripbutton]::new('Imprint')
[void]$buttons.Items.Add($imprintButton)
$saveButton = [toolstripbutton]::new('Save')
[void]$buttons.Items.Add($saveButton)
[void]$form.controls.Add($layout)
[void]$layout.RowStyles.Add([rowstyle]::new('Absolute',$buttons.Height))
[void]$layout.RowStyles.Add([rowstyle]::new('Percent',100))
[void]$layout.controls.Add($buttons)
$picbox = [picturebox]@{SizeMode='Normal';Dock='fill';AllowDrop='true'}
[void]$layout.controls.Add($picbox)


$form.controls.add($layout)
$bmp = [system.drawing.bitmap]::new(400,300)
$picbox.image = $bmp

$g = [system.drawing.graphics]::fromimage($bmp)
$brush = [System.Drawing.SolidBrush]::new('white')
$g.FillRectangle($brush, 0, 0, 400, 300)
$brush.dispose()


Function Imprint($bmp, $t){
    $g = [system.drawing.graphics]::fromimage($bmp)
    $brush = [System.Drawing.SolidBrush]::new('black')
    $x = $y = 5
    if ($xposTb.Text.Length -match '^\d+$'){
        $x = [Math]::Max([Math]::Min([int]$xposTb.Text,400),0)
    }
    if ($yposTb.Text.Length -match '^\d+$'){
        $y = [Math]::Max([Math]::Min([int]$yposTb.Text,300),0)
    }
    $g.drawstring($t,$font,$brush,$x,$y)
    $brush.dispose()
    $picbox.refresh()
}
$imprintButton.Add_Click({Imprint $bmp $textbox.Text})



#$brush = [System.Drawing.SolidBrush]::new('black')
#$g.drawstring("A1234567ACB",$font,$brush,5,5)
#$brush.dispose()

$savefiledialog = [savefiledialog]@{Filter='CCITT T.6 tif|*.tif;*.tiff|png|*.png|jpg|*.jpg;*.jpeg'}

Function SaveAsFile(){
    if ($savefiledialog.ShowDialog() -eq 'OK'){
        $filename = $savefiledialog.filename
        switch ($savefiledialog.filterindex){
            1 {
                $myenc =  [System.Drawing.Imaging.Encoder]::Compression
                $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
                $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myenc, 4)
                $myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|where {$_.MimeType -eq 'image/tiff'}
                $bmp.Save($filename, $myImageCodecInfo, $encoderParams)
            }
            default {
                $bmp.Save($filename)
            }
        }
    }
}

$saveButton.Add_Click({SaveAsFile})

Function SetPosition($ev){
    $xposTb.Text = $ev.X
    $yposTb.Text = $ev.Y
}

$picbox.Add_Click({SetPosition($_)})

[void]$form.showdialog()



$bmp.dispose()
$layout.dispose()
$picbox.dispose()
$buttons.dispose()
$font.dispose()
$form.dispose()
$textbox.dispose()
$savefiledialog.dispose()