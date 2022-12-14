using namespace PresentationFramework
Add-Type -AssemblyName PresentationFramework

[console]::BufferWidth = [console]::WindowWidth = 80
[console]::WindowHeight = 25

class DataItem {
    [string]$Filename
    [string]$Meta
    [string]$Type
    [bool]$First
    [bool]$IsSelected
}

[xml]$XAML = Get-Content datagrid-custom.xaml
$Form=[Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($XAML))
$dg = $Form.FindName('Datagrid1')
$items = [System.Collections.ObjectModel.ObservableCollection[DataItem]]::new()
$dg.ItemsSource = $items
#$items.Add([DataItem]::new('r:/test.png'))
#$items.Add([DataItem]@{Filename='r:/test1.png'})
#$items.Add([DataItem]::new('r:/test1.png'))
#$items.Add([DataItem]@{Filename='r:/test1.png';First=$true;Meta='1234';Type='A'})
$l = 30
foreach ($f in (Get-ChildItem C:\Users\lm\Pictures\*.png)){
    $items.Add([DataItem]@{Filename=$f;Meta=$l})
    $l--
    if ($l -le 1){
        break
    }
}
$testb = $Form.FindName('TestButton')
$testb.Add_Click({
    $dg.CancelEdit()
    for ($i=0;$i -lt $items.Count;$i++){
        if ($items[$i].IsSelected){
            write-host $items[$i].Filename $items[$i].Meta $items[$i].First $items[$i].Type
        }
    }
})

$gridmode = $Form.FindName('GridMode')
$gridmode.Add_Click({
    switch ($dg.SelectionUnit){
        "Cell" {
            $dg.SelectionUnit = [System.Windows.Controls.DataGridSelectionUnit]::FullRow
        }
        "FullRow" {
            $dg.SelectionUnit = [System.Windows.Controls.DataGridSelectionUnit]::Cell
        }
    }
    <#
    if ($dg.SelectionUnit -eq [System.Windows.Controls.DataGridSelectionUnit]::Cell){
        $dg.SelectionUnit = [System.Windows.Controls.DataGridSelectionUnit]::FullRow
    } else {
        $dg.SelectionUnit = [System.Windows.Controls.DataGridSelectionUnit]::Cell
    }#>
})
<#
$dg.Add_BeginningEdit({
    $dg.SelectionUnit = [System.Windows.Controls.DataGridSelectionUnit]::Cell
})
$dg.Add_CellEditEnding({
    $dg.SelectionUnit = [System.Windows.Controls.DataGridSelectionUnit]::FullRow
})
#>
$previewimg = $Form.FindName('PreviewImg')
#$dg.Add_CurrentCellChanged({
$dg.Add_CurrentCellChanged({
    #write-host $_
    #write-host $_.CurrentCell.RowNumber;
    $x = $dg.CurrentItem 
    if ($x -and $x.Filename.Length -gt 0 -and (Test-Path $x.Filename)){
        $previewimg.Source = $x.Filename
    }
    
})

$script:indexStack = [system.collections.generic.stack[int]]::new()

Function ItemMove($diff){
    while ($script:indexStack.Count -gt 0){
        $i = $script:indexStack.pop()
        $items.Move($i,$i+$diff)
    }
}

Function ItemMoveDown($dg,$items){
    $dg.IsEnabled = $false
    if ($dg.SelectedItem){
        $l = $items.Count-1
        for ($i=0;$i -lt $l; $i++){
            if ($items[$i].IsSelected){
                $script:indexStack.Push($i)
            }
        }
        $dg.ItemsSource = $null
        ItemMove 1
        $dg.ItemsSource = $items
    }
    $dg.IsEnabled = $true
}
Function ItemMoveUp($dg,$items){
    $dg.IsEnabled = $false
    if ($dg.SelectedItem){
        $dg.ItemsSource = $null
        for ($i=$items.Count-1; $i -gt 0; $i--){
            if ($items[$i].IsSelected){
                $script:indexStack.Push($i)
            }
        }
        ItemMove -1
        $dg.ItemsSource = $items
    }
    $dg.IsEnabled = $true
}


$Form.FindName('MoveDownButton').Add_Click({ItemMoveDown $dg $items})
$Form.FindName('MoveUpButton').Add_Click({ItemMoveUp $dg $items})

$Form.FindName('RmButton').Add_Click({
    if ($dg.SelectedItem){
        $c = $dg.SelectedItems.Count
        $dg.IsEnabled = $false
        $dg.ItemsSource = $null
        for ($i=$items.Count-1; ($c -gt 0 -and $i -ge 0); $i--){
            if ($items[$i].IsSelected){
                $items.RemoveAt($i)
                $c--
            }
        }
        $dg.ItemsSource = $items
        $dg.IsEnabled = $true
    }
})

[void]$Form.ShowDialog()
#pause
