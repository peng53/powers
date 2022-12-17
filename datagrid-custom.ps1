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
})

$previewimg = $Form.FindName('PreviewImg')
$dg.Add_CurrentCellChanged({
    $x = $dg.CurrentItem 
    if ($x -and $x.Filename.Length -gt 0 -and (Test-Path $x.Filename)){
        $previewimg.Source = $x.Filename
    }
    
})

$script:indexStack = [system.collections.generic.stack[int]]::new()


Function ItemsDo($dg, $items, $action){
    $dg.ItemsSource = $null
    while ($script:indexStack.Count -gt 0){
        $i = $script:indexStack.Pop()
        switch ($action){
            SetA { $items[$i].Type = 'A'}
            SetB { $items[$i].Type = 'B'}
            SetC { $items[$i].Type = 'C'}
            CheckFirst { $items[$i].First = -not $items[$i].First}
            ClearMeta { $items[$i].Meta = ''}
            Delete { $items.RemoveAt($i) }
            MoveDown { 
                if ($i -le $items.Count){
                    $items.Move($i,$i+1)
                }
            }
            MoveUp {
                if ($i -gt 0){
                    $items.Move($i,$i-1)
                }
            }
        }
    }
    $dg.ItemsSource = $items
}

Function ReverseSelectedAction($dg, $items, $action){
    if ($dg.SelectedItem){
        $dg.IsEnabled = $false
        for ($i=$items.Count-1; $i -ge 0; $i--){
            if ($items[$i].IsSelected){
                $script:indexStack.Push($i)
            }
        }
        ItemsDo $dg $items $action
        $dg.IsEnabled = $true
    }
}

Function SelectedAction($dg, $items, $action){
    if ($dg.SelectedItem){
        $dg.IsEnabled = $false
        for ($i=0; $i -lt $items.Count; $i++){
            if ($items[$i].IsSelected){
                $script:indexStack.Push($i)
            }
        }
        ItemsDo $dg $items $action
        $dg.IsEnabled = $true
    }
}

$Form.FindName('MoveUpButton').Add_Click({ReverseSelectedAction $dg $items 'MoveUp'})
$Form.FindName('MoveDownButton').Add_Click({SelectedAction $dg $items 'MoveDown'})
$Form.FindName('RmButton').Add_Click({ SelectedAction $dg $items 'Delete'})

[void]$Form.ShowDialog()
#pause
