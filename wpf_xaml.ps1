#requires -version 5.1
add-type -assemblyname PresentationFramework

[xml]$XAML = Get-Content report_make.xaml
$Form=[Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($XAML))
$listv = $Form.FindName('listv')
<#for ($i=0;$i -lt $listv.Items.Count;++$i){
	write-host $listv.Items[$i]
}#>
enum MembershipLevel {
    VIP
    Agent
    IronChef
}
class MyRow {
	[int]$Id
	[MembershipLevel]$Membership
	[string]$FirstName
	[string]$LastName
    [string]ToString(){
        $s = '{0} {1} is member level {2} with ID# {3}' -f $this.FirstName,$this.LastName,$this.Membership,$this.Id
        return $s
    }
}
[void]$listv.Items.Add([MyRow]@{Id=10;Membership=0;FirstName='Jack';LastName='Colby'})
[void]$listv.Items.Add([MyRow]@{Id=55;Membership=2;FirstName='Ismal';LastName='Drino'})
$button = $form.FindName('TestButton')
$button.Add_Click({
    foreach ($item in $listv.Items){
        write-host $item
    }
})
$button2 = $form.FindName('TestButton2')
$button2.Add_Click({
    foreach ($item in $listv.SelectedItems){
        write-host $item
    }
})
$Form.ShowDialog()