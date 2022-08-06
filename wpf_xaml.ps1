#requires -version 5.1
add-type -assemblyname PresentationFramework
[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
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
                <Button Content="Button1" />
                <Button Content="Button2" />
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
class MyRow {
	[int]$Id
	[string]$Membership
	[string]$FirstName
	[string]$LastName
}
$listv.Items.Add([MyRow]@{Id=10;Membership='Agent';FirstName='Jack';LastName='Colby'})
$Form.ShowDialog()