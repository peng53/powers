Add-Type -AssemblyName 'System.WIndows.Forms'

$form = New-Object 'system.windows.forms.form' -Property @{width=800;height=600;text='thumbview.ps1'}
$layout = New-Object 'system.windows.forms.tablelayoutpanel' -Property @{dock='fill';columncount=1;rowcount=2;}
$layout.RowStyles.Add((new-object 'system.windows.forms.rowstyle' ('Absolute',30))) | out-null
$layout.RowStyles.Add((new-object 'system.windows.forms.rowstyle' ('Percent',100))) | out-null

$buttons = new-object 'system.windows.forms.toolstrip'
$buttons.Items.Add((new-object 'system.windows.forms.toolstriplabel' ('Search'))) | Out-Null
$tx1 = new-object 'System.Windows.Forms.ToolStriptextbox'
$buttons.Items.Add($tx1) | Out-Null
$buttons.Items.Add((new-object 'system.windows.forms.toolstripseparator')) | Out-Null
$sel = new-object 'System.Windows.Forms.ToolStripDropDownButton' ('Select')
$buttons.Items.Add($sel) | Out-Null
$buttons.Items.Add((new-object 'system.windows.forms.toolstripseparator')) | Out-Null
$numcb = New-Object 'System.Windows.Forms.ToolStripCombobox' ('Select')
$buttons.Items.Add($numcb) | Out-Null
$buttons.Items.Add((new-object 'system.windows.forms.toolstripseparator')) | Out-Null

$split = new-object 'system.windows.forms.splitcontainer' -Property @{Dock='fill'}

$listv = New-Object 'system.windows.forms.listview' -Property @{checkboxes=$true;dock='fill'}
$listv.Columns.Add("Item Column", -2) | out-null
$imglist = new-object 'System.Windows.Forms.ImageList' -Property @{ImageSize=(new-object 'system.drawing.size' (128,128))}

$img = [drawing.bitmap]::FromFile('r:/vlc_multi.tif')
$c = $img.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page)
for ($i=0;$i -lt $c;$i++){
    $img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $i) | out-null
    $tn = $img.GetThumbnailImage(128,128,$null,0)
    $imglist.Images.Add($tn) | out-null
    $t = 'Page {0}' -f $i
    $e = new-object 'system.windows.forms.ListViewItem' ($t, $i)
    $listv.Items.Add($e) | Out-Null
}

$listv.LargeImageList = $imglist

$picbox = new-object 'system.windows.forms.picturebox' -Property @{SizeMode='Zoom';Dock='fill'}
$picbox.Image = $img

$layout.controls.Add($buttons)
$layout.controls.Add($split)
$split.panel1.controls.Add($listv)
$split.panel2.controls.Add($picbox)
$split.splitterdistance = 200

$form.controls.Add($layout)

$listv.Add_selectedindexchanged({
    $img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $listv.SelectedIndices[0])
    $picbox.Image = $img
})

$form.Add_Closed({
    $img.Dispose()
    $imglist.Images | foreach-object {$_.dispose()}
    $imglist.Dispose()
    $listv.dispose()
    $picbox.dispose()
    $layout.Controls | foreach-object {$_.Dispose()}
    $layout.Dispose()
    $form.Dispose()
})

$form.ShowDialog()