#Requires -Version 5.1
using namespace System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms

$form = [form]@{width=800;height=600;text='thumbview.ps1'}
$layout = [tablelayoutpanel]@{dock='fill';columncount=1;rowcount=2}
[void]$form.controls.Add($layout)
$buttons = [toolstrip]::new()
[void]$layout.RowStyles.Add([rowstyle]::new('Absolute',$buttons.Height))
[void]$layout.RowStyles.Add([rowstyle]::new('Percent',100))
[void]$layout.controls.Add($buttons)

[void]$buttons.Items.Add([toolstriplabel]::new('Search'))
[void]$buttons.Items.Add([ToolStriptextbox]::new('1'))
[void]$buttons.Items.Add('-')
$sel = [ToolStripDropDownButton]::new('Select')
[void]$buttons.Items.Add($sel)
[void]$buttons.Items.Add('-')
$numcb = [ToolStripCombobox]::new()
[void]$buttons.Items.Add($numcb)
[void]$buttons.Items.Add('-')
$openImageButton = [ToolStripButton]::new('Open Image')
[void]$buttons.Items.Add($openImageButton)

$split = [splitcontainer]@{Dock='fill'}
[void]$layout.controls.Add($split)
$split.splitterdistance = 220
$listv = [listview]@{view='tile';dock='fill';LargeImageList = [ImageList]@{ImageSize=[system.drawing.size]::new(64,64)}}
[void]$listv.Columns.Add("Item Column", -2)
[void]$split.panel1.controls.Add($listv)
$picbox = [picturebox]@{SizeMode='Zoom';Dock='fill'}
[void]$split.panel2.controls.Add($picbox)

$openfiledialog = [OpenFileDialog]@{Filter='tif File|*.tif;*.tiff'}
$img = $null

Function LoadImg($lv,$pb){
    if ($openfiledialog.ShowDialog() -eq 'OK'){
        $lv.Enabled = $pb.Enabled = $false
        if ($script:img){
            $script:img.Dispose()
            $lv.LargeImageList.Images.Clear()
        }
        $script:img = [drawing.bitmap]::FromFile($openfiledialog.FileName)
        $c = $script:img.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page)-1
        foreach ($i in 0..$c){
            [void]$script:img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $i)
            [void]$listv.LargeImageList.Images.Add($script:img.GetThumbnailImage(64,64,$null,0))
            if ($lv.Items.Count -le $i){
                $t = 'Page {0}' -f $i
                [void]$lv.Items.Add([ListViewItem]::new($t, $i))
            }
        }
        $pb.Image = $script:img
        while ($lv.Items.Count -gt $c+1){
            $lv.Items.RemoveAt($lv.Items.Count-1)
        }
        $lv.Enabled = $pb.Enabled = $true
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
    [void]$form.ShowDialog()
}
catch {
    Write-Error $_
    pause
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