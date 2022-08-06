#Requires -Version 4.0
Add-Type -AssemblyName System.Windows.Forms

$form = New-Object system.windows.forms.form -Property @{width=800;height=600;text='thumbview.ps1'}
$layout = New-Object system.windows.forms.tablelayoutpanel -Property @{dock='fill';columncount=1;rowcount=2;}
$form.controls.Add($layout)
$buttons = new-object system.windows.forms.toolstrip
$layout.RowStyles.Add((new-object system.windows.forms.rowstyle ('Absolute',$buttons.Height))) | out-null
$layout.RowStyles.Add((new-object system.windows.forms.rowstyle ('Percent',100))) | out-null
$layout.controls.Add($buttons)

$buttons.Items.Add((new-object system.windows.forms.toolstriplabel ('Search'))) | Out-Null
$buttons.Items.Add((new-object System.Windows.Forms.ToolStriptextbox ('1'))) | Out-Null
$buttons.Items.Add((new-object 'system.windows.forms.toolstripseparator')) | Out-Null
$sel = new-object 'System.Windows.Forms.ToolStripDropDownButton' ('Select')
$buttons.Items.Add($sel) | Out-Null
$buttons.Items.Add((new-object 'system.windows.forms.toolstripseparator')) | Out-Null
$numcb = New-Object 'System.Windows.Forms.ToolStripCombobox' ('Select')
$buttons.Items.Add($numcb) | Out-Null
$buttons.Items.Add((new-object 'system.windows.forms.toolstripseparator')) | Out-Null
$openImageButton = New-Object System.Windows.Forms.ToolStripButton ('Open Image')
$buttons.Items.Add($openImageButton) | Out-Null

$split = new-object 'system.windows.forms.splitcontainer' -Property @{Dock='fill';}
$layout.controls.Add($split)
$split.splitterdistance = 220
$listv = New-Object 'system.windows.forms.listview' -Property @{view='tile';dock='fill'}
$listv.Columns.Add("Item Column", -2) | out-null
$listv.LargeImageList = new-object System.Windows.Forms.ImageList -Property @{ImageSize=(new-object system.drawing.size (64,64))}
$split.panel1.controls.Add($listv)
$picbox = new-object 'system.windows.forms.picturebox' -Property @{SizeMode='Zoom';Dock='fill'}
$split.panel2.controls.Add($picbox)

$openfiledialog = new-object System.Windows.Forms.OpenFileDialog -Property @{Filter='tif File|*.tif;*.tiff'}
$img = $null

Function LoadImg($lv,$pb){
    if ($openfiledialog.ShowDialog() -eq 'OK'){
        $lv.Enabled = $false
        if ($script:img){
            $script:img.Dispose()
            $lv.LargeImageList.Images.Clear()
        }
        $script:img = [drawing.bitmap]::FromFile($openfiledialog.FileName)
        $c = $script:img.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page)-1
        foreach ($i in 0..$c){
            $script:img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $i) | out-null
            $listv.LargeImageList.Images.Add($script:img.GetThumbnailImage(64,64,$null,0)) | out-null
            if ($lv.Items.Count -le $i){
                $t = 'Page {0}' -f $i
                $lv.Items.Add((new-object 'system.windows.forms.ListViewItem' ($t, $i))) | Out-Null
            }
        }
        $pb.Image = $script:img
        while ($lv.Items.Count -gt $c+1){
            $lv.Items.RemoveAt($lv.Items.Count-1)
        }
        $lv.Enabled = $true
    }
}
$openImageButton.Add_Click({LoadImg $listv $picbox})

Function LV_RowClick($s,$p){
    if ($s.SelectedIndices.Count -gt 0){
        $script:img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $s.SelectedIndices[0])
        $p.Image = $script:img
    }
}
$listv.Add_selectedindexchanged({LV_RowClick $this $picbox})

try {
    $form.ShowDialog() | Out-Null
}
catch {
    Write-Error $_
}
finally {
    if ($img){
        $img.Dispose()
    }
    $listv.LargeImageList.Images.Clear()
    $buttons.Items.Clear()
    $buttons.dispose()
    $listv.dispose()
    $picbox.dispose()
    $split.dispose()
    $layout.Dispose()
    $form.Dispose()
    $openfiledialog.Dispose()
    write-host Cleanup!
}
pause