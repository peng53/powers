Add-Type -AssemblyName 'System.WIndows.Forms'

$form = New-Object 'system.windows.forms.form' -Property @{width=1200;height=600;text='thumbview.ps1'}
$layout = New-Object 'system.windows.forms.tablelayoutpanel' -Property @{dock='fill';columncount=2;rowcount=2;}
$layout.ColumnStyles.Add((new-object 'system.windows.forms.columnstyle' ('Percent',100))) | out-null
$layout.ColumnStyles.Add((new-object 'system.windows.forms.columnstyle' ('Absolute',400))) | out-null
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
$layoutMode = New-Object 'System.Windows.Forms.ToolStripButton' ('Expand Preview') -Property @{CheckOnClick=$true}
$buttons.Items.Add($layoutMode) | Out-Null


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
$layout.setcolumnspan($buttons,2)
$layout.controls.Add($listv)
$layout.controls.Add($picbox)

$form.controls.Add($layout)

$layoutMode.Add_Click({
    if ($layoutMode.Checked){
        $layout.ColumnStyles[0] = new-object 'system.windows.forms.columnstyle' ('Absolute',200)
        $layout.ColumnStyles[1] = new-object 'system.windows.forms.columnstyle' ('Percent',100)
    } else {
        $layout.ColumnStyles[0] = new-object 'system.windows.forms.columnstyle' ('Percent',100)
        $layout.ColumnStyles[1] = new-object 'system.windows.forms.columnstyle' ('Absolute',400)
    }
})

$listv.Add_selectedindexchanged({
    $img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $listv.SelectedIndices[0])
    $picbox.Image = $img
})

$form.Add_Closed({
    #$buttons.Items | foreach-object {$_.dispose()}
    #$listv.Items | foreach-object {$_.dispose()}
    $img.Dispose()
    $imglist.Images | foreach-object {$_.dispose()}
    $imglist.Dispose()
    $layout.Controls | foreach-object {$_.Dispose()}
    $layout.Dispose()
    $form.Dispose()
})

$form.ShowDialog()