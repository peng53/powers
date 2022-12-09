using namespace PresentationFramework
Add-Type -AssemblyName PresentationFramework

[console]::BufferWidth = [console]::WindowWidth = 80
[console]::WindowHeight = 25

class DataItem {
    [string]$Filename
    [string]$Meta
    [bool]$First
}

[xml]$XAML = Get-Content datagrid-custom.xaml
$Form=[Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($XAML))
$dg = $Form.FindName('Datagrid1')
$items = [System.Collections.ObjectModel.ObservableCollection[DataItem]]::new()
$dg.ItemsSource = $items
#$items.Add([DataItem]::new('r:/test.png'))
#$items.Add([DataItem]@{Filename='r:/test1.png'})
#$items.Add([DataItem]::new('r:/test1.png'))
$items.Add([DataItem]@{Filename='r:/test1.png';First=$true;Meta='1234'})
[void]$Form.ShowDialog()
pause