using namespace PresentationFramework
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Drawing

[console]::BufferWidth = [console]::WindowWidth = 80
[console]::WindowHeight = 25

class ListViewItemsData {
    [string]$Thumbnail
    [string]$Filename
    [string]$Type
    [bool]$First
}

[xml]$XAML = Get-Content thumbnail-grid.xaml
$Form=[Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($XAML))
$items = [System.Collections.ObjectModel.ObservableCollection[ListViewItemsData]]::new()
$lv = $Form.FindName('Listview1')

$lv.ItemsSource = $items
$items.Add([ListViewItemsData]@{Thumbnail='R:\speedauto.PNG';Filename='speedauto.png';First=$true})
$items.Add([ListViewItemsData]@{Thumbnail='R:\test1.PNG';Filename='test1.png';Type="B"})
#$items.Add([ListViewItemsData]@{Thumbnail='R:\test.PNG';Filename='test.png'})

#$bmi = [System.Windows.Media.Imaging.BitmapImage]::

$items[0].Type = "C"

$bd = [System.Windows.Media.Imaging.BitmapDecoder]::Create('r:\test.png',2,2)
$items.Add([ListViewItemsData]@{Thumbnail=$bd.Frames;Filename='test.png';Type="B"})

[void]$Form.ShowDialog()
pause