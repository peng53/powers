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
$pb_left.sizemode = $pb_right.sizemode = 'zoom'
$layout.dock = $pb_left.dock = $pb_right.dock= 'fill'

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

$file = 'r:\3layer.tif'
$img = [drawing.image]::FromFile($file)
$imgR = $img.clone()


$img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, 0) | out-null
$pb_left.image = $img
$pb_right.image = $imgR
if ($imgR.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page) -gt 1){
    $imgR.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, 1) | out-null
}

$form.add_Closed({
    $img.dispose()
    $imgR.dispose()
    $layout.dispose()
    $form.dispose()
    write-host Job Done
})

$form.showdialog()