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
$items.Add([DataItem]@{Filename='r:/test1.png';First=$true;Meta='1234';Type='A'})
$testb = $Form.FindName('TestButton')
$testb.Add_Click({
    for ($i=0;$i -lt $items.Count;$i++){
        if ($items[$i].IsSelected){
            write-host $items[$i].Filename $items[$i].Meta $items[$i].First $items[$i].Type
        }
    }
})
$previewimg = $Form.FindName('PreviewImg')
$dg.Add_CurrentCellChanged({
    #write-host $_
    #write-host $_.CurrentCell.RowNumber;
    $x = $dg.CurrentItem 
    if ($x -and $x.Filename.Length -gt 0 -and (Test-Path $x.Filename)){
        $previewimg.Source = $x.Filename
    }
    
})

[void]$Form.ShowDialog()
#pause
