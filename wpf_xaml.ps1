#requires -version 5.1
add-type -assemblyname PresentationFramework

enum MembershipLevel {
	ClassF
	VIP
	Agent
	IronChef
}
class MyRow {
	[bool]$IsSelected
	[int]$Id
	[MembershipLevel]$Membership
	[string]$FirstName
	[string]$LastName
	[string]ToString(){
		$s = '{0} {1} is member level {2} with ID# {3} and selected is {4}' -f $this.FirstName,$this.LastName,$this.Membership,$this.Id,$this.IsSelected
		return $s
	}
}

[xml]$XAML = Get-Content report_make.xaml
$Form=[Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($XAML))
$myitems = [system.collections.objectmodel.observablecollection[MyRow]]::new()
$listv = $Form.FindName('listv')
$listv.ItemsSource = $myitems
$tbc = @{}
foreach ($t in 'TbId','TbFirstName','TbLastName','OutputArea'){
	$tbc[$t] =$Form.FindName($t)
}
[void]$myitems.Add([MyRow]@{Id=10;Membership=0;FirstName='Jack';LastName='Colby'})
[void]$myitems.Add([MyRow]@{Id=55;Membership=2;FirstName='Ismal';LastName='Drino'})
[void]$myitems.Add([MyRow]@{Id=81;Membership=1;FirstName='Tiep';LastName='Simia'})
[void]$myitems.Add([MyRow]@{Id=526;Membership=2;FirstName='Zenwalther';LastName='Kooperbanetonopp'})
$removebutton = $form.FindName('RemoveButton')
$removebutton.Add_Click({
	for ($c=$myitems.Count-1;$c -ge 0;$c--){
		if ($myitems[$c].IsSelected){
			write-host 'Removing at position' $c ':' $myitems[$c]
			$tbc.OutputArea.Text += "Removing at position $c : $myitems[$c]"
			$tbc.OutputArea.Text += [System.Environment]::Newline
			$myitems.RemoveAt($c)
		}
	}
})
Function GetTextboxInput {
	$id = $tbc.TbId.Text -replace '[^\d]'
	if ([string]::IsNullOrWhiteSpace($id)){
		return
	}
	return @{Id=[int]$id; FirstName=$tbc.TbFirstName.Text; LastName=$tbc.TbLastName.Text}
}
Function SelectionChanged {
	$item = $listv.SelectedItem
	if ($item){
		$tbc.TbId.Text = $item.Id
		$tbc.TbFirstName.Text = $item.FirstName
		$tbc.TblastName.Text = $item.LastName
	}
}
$listv.Add_SelectionChanged({
	SelectionChanged
})
$createbutton = $form.FindName('CreateRow')
$createbutton.Add_Click({
	$row = GetTextboxInput
	if ($row){
		for ($c=$myitems.Count-1;$c -ge 0;$c--){
			if ($myitems[$c].IsSelected){
				$myitems.Insert($c+1,[MyRow]$row)
			}
		}
	}
})
$Form.ShowDialog()