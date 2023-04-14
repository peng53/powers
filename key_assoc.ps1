using namespace PresentationFramework
Add-Type -AssemblyName PresentationFramework

[console]::BufferWidth = [console]::WindowWidth = 80
[console]::WindowHeight = 25

class DataItem {
    [string]$Field
    [uint]$Len = 1
    [string]$Type='C'
}
class DictionaryItem {
    [char]$key
    [string]$val
}
class WindowVars {
    [string]$site
    [uint]$number = 0
    [uint]$prio = 1234
    [bool[]]$rad = (0,1,0,0)
}


[xml]$XAML = Get-Content xaml/key_assoc.xaml
$Form=[Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($XAML))
$dg = $Form.FindName('Datagrid1')
$items = [System.Collections.ObjectModel.ObservableCollection[DataItem]]::new()
$dg.ItemsSource = $items
$ditems = [System.Collections.ObjectModel.ObservableCollection[DictionaryItem]]::new()
$dim = $Form.FindName('CypherMap')
$dim.ItemsSource = $ditems
$winvars = [WindowVars]::new()
$Form.DataContext = $winvars
$winvars.site = 'amazon'
$winvars.number = 100
$gobutton = $Form.FindName('GoButton')
$gobutton.Add_Click({
    write-host $winvars.site
    write-host $winvars.number
    write-host $winvars.prio
    write-host $winvars.rad
    write-host $ditems
    write-host $items
})
[void]$Form.ShowDialog()
#pause
