#Requires –Version 2.0
Add-Type -AssemblyName system.drawing
$imageFormat = “System.Drawing.Imaging.ImageFormat” -as [type]
$fmts = @('bmp','gif','jpeg','png','tiff')
foreach ($c in $fmts){
	Write-Host $c
}
$outfmt = Read-Host 'Output format'
if ($fmts -contains $outfmt){
	foreach ($a in $args){
		$t = $a+'.'+$outfmt
		Write-Host $a
		if (!($a.EndsWith('.'+$outfmt)) -or !(Test-Path -path $t)){
			$image = [drawing.image]::FromFile($a)
			$image.Save($t, $imageFormat::$outfmt)
			Write-Host "NEW: $t"
		} else{
			Write-Host "ERR: $t"
		}
	}
	Write-Host 'DONE'
} else {
	Write-Host "$outfmt is not valid choice."
}
Read-Host