#Requires -Version 5.1
using namespace System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms

$form = [form]@{width=800;height=600;text='imgview.ps1';AllowDrop='true'}
$layout = [tablelayoutpanel]@{dock='fill';columncount=1;rowcount=2}
[void]$form.controls.Add($layout)
$buttons = [toolstrip]::new()
[void]$layout.RowStyles.Add([rowstyle]::new('Absolute',$buttons.Height))
[void]$layout.RowStyles.Add([rowstyle]::new('Percent',100))
[void]$layout.controls.Add($buttons)

$openButton = [ToolStripButton]::new('Open')
[void]$buttons.Items.Add($openButton)

Function PicboxMode($b, $pb){
    $pb.SizeMode = $b
}

$pbmodes = 'Zoom','Stretch','CenterImage','AutoSize'
foreach ($m in $pbmodes){
    $b = [ToolStripButton]::new($m)
    [void]$buttons.Items.Add($b)
    $b.Add_Click({PicboxMode $this.Text $picbox})
}



$picbox = [picturebox]@{SizeMode='Zoom';Dock='fill';AllowDrop='true'}
[void]$layout.controls.Add($picbox)

$openfiledialog = [OpenFileDialog]@{Filter='Image File|*.tif;*.tiff;*.png;*.bmp;*.jpg;*.jpeg'}
$img = $null

Function LoadImg($pb){
    if ($openfiledialog.ShowDialog() -eq 'OK'){
        if ($script:img){
            $script:img.Dispose()
        }
        $script:img = [drawing.bitmap]::FromFile($openfiledialog.FileName)
        $pb.Image = $script:img
        $script:imgframe = 0
        $script:imglast = $script:img.GetFrameCount([System.Drawing.Imaging.FrameDimension]::Page)-1
        $frameIndicator.Text = "0 / $script:imglast"
        $form.Text = 'imgview.ps1 - {0}' -f $openfiledialog.Filename
        $nextButton.Enabled = $prevButton.Enabled = ($script:imglast -gt 0)
    }
}
$openButton.Add_Click({LoadImg $picbox})
$form.Add_DragDrop({LoadImg $picbox})
$script:imgframe = 0
$script:imglast = 0

[void]$buttons.Items.Add('-')
$prevButton = [ToolStripButton]::new('<-')
[void]$buttons.Items.Add($prevButton)
$nextButton = [ToolStripButton]::new('->')
[void]$buttons.Items.Add($nextButton)
[void]$buttons.Items.Add('-')

$frameIndicator = [ToolStripLabel]::new('0 / 0')
[void]$buttons.Items.Add($frameIndicator)
[void]$buttons.Items.Add('-')

Function SetPage($p, $d, $fi){
    if ($script:img){
        $i = $script:imgframe+$d
        if ($i -lt 0){
            $i = $script:imglast
        }
        if ($i -gt $script:imglast){
            $i = 0
        }
        if (($i -lt 0) -or ($i -gt $script:imglast)){
            return
        } else {
            $script:imgframe = $i
            $script:img.SelectActiveFrame([System.Drawing.Imaging.FrameDimension]::Page, $script:imgframe)
            $p.Image = $script:img
        }
        $fi.Text = "$i / $script:imglast"

    }
}
$prevbutton.Add_Click({SetPage $picbox -1 $frameIndicator})
$nextbutton.Add_Click({SetPage $picbox 1 $frameIndicator})


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
    $buttons.Items.Clear()
    $buttons.dispose()
    $picbox.dispose()
    $layout.Dispose()
    $form.Dispose()
    $openfiledialog.Dispose()
    write-host Cleanup!
}