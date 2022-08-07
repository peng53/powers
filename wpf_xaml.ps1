#requires -version 5.1
add-type -assemblyname PresentationFramework
[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="750" Height="500" Title="wpf_xaml.ps1">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition/>
        </Grid.RowDefinitions>
        <ToolBarTray HorizontalAlignment="Left" Height="28" Grid.Row="0" VerticalAlignment="Top">
            <ToolBar HorizontalAlignment="Left" VerticalAlignment="Top">
                <Button Name="TestButton" Content="Button1" />
                <Button Name="TestButton2" Content="Button2" />
                <Label Content="Name" Height="23" VerticalAlignment="Top"/>
                <TextBox Height="23" Margin="0" TextWrapping="Wrap" Text="[namehere]" VerticalAlignment="Top" Width="120"/>
            </ToolBar>
        </ToolBarTray>
        <ListView Name="listv" Grid.Row="1">
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="Ref" Width="120" DisplayMemberBinding="{Binding Path=Id}"/>
                    <GridViewColumn Header="Type" Width="100" DisplayMemberBinding="{Binding Path=Membership}"/>
                    <GridViewColumn Header="Front" Width="250" DisplayMemberBinding="{Binding Path=FirstName}"/>
                    <GridViewColumn Header="Back" Width="250" DisplayMemberBinding="{Binding Path=LastName}"/>
                </GridView>
            </ListView.View>
        </ListView>

    </Grid>
</Window> 
"@

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