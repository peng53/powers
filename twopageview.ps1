Add-Type -AssemblyName 'System.WIndows.Forms'

$form = New-Object 'system.windows.forms.form'
$form.Size = New-Object 'System.Drawing.Size' (800,600)
$layout = new-object 'System.Windows.Forms.TableLayoutPanel'
$layout.ColumnCount = $layout.RowCount = 2
$layout.ColumnStyles.Add((new-object 'System.Windows.Forms.ColumnStyle' ('Percent', 50)))
$layout.ColumnStyles.Add((new-object 'System.Windows.Forms.ColumnStyle' ('Percent', 50)))
$layout.RowStyles.Add((new-object 'System.Windows.Forms.RowStyle' ('Percent', 100)))
$layout.RowStyles.Add((new-object 'System.Windows.Forms.RowStyle' ('Absolute', 26)))

$pb_left = New-Object 'system.windows.forms.picturebox'
$pb_right = New-Object 'system.windows.forms.picturebox'

$layout.dock = $pb_left.dock = $pb_right.dock= 'fill'

$file = 'r:\multilzw.tif'

function FormKeyDown {
  [CmdletBinding()] 
  param ( 
    [parameter(Mandatory=$True)][system.windows.forms.form]$Sender, 
    [parameter(Mandatory=$True)][system.windows.forms.keyeventargs]$e
  )
  write-host $e.KeyCode
}

$form.add_Keydown({FormKeyDown -Sender $form -E $_ })

$layout.controls.add($pb_left)
$layout.controls.add($pb_right)
$form.controls.add($layout)

$img = [drawing.image]::FromFile($file)

$leftI = 0
$pb_left.image = $img.GetThumbnailImage($pb_left.width,$pb_left.Width,$null,0)
if ($img.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page) -gt 1){
    $img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, 1) | out-null
    $pb_right.image = $img.GetThumbnailImage($pb_right.width,$pb_right.Width,$null,0)
}


$form.add_Closed({
    $img.dispose()
    $pb_left.image.dispose()
    $pb_right.image.dispose()
    $layout.dispose()
    $form.dispose()
    write-host Job Done
})

$form.add_Resize({
$pb_left.image.dispose()
$pb_right.image.dispose()
$img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, 0) | out-null
$pb_left.image = $img.GetThumbnailImage($pb_left.width,$pb_left.Width,$null,0)
if ($img.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page) -gt 1){
    $img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, 1) | out-null
    $pb_right.image = $img.GetThumbnailImage($pb_right.width,$pb_right.Width,$null,0)
}
})

$form.showdialog()