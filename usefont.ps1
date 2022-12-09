$x = new-object System.Drawing.Text.PrivateFontCollection
$x.AddFontFile('R:\GnuMICR.ttf')

$ff = $x.Families[0]

$f = new-object system.drawing.font $ff, 16

$drawing = new-object system.drawing.bitmap 300,300
$g = [System.Drawing.Graphics]::FromImage($drawing)

$b = new-object System.Drawing.SolidBrush 'black'
#$g.DrawString('123',$x.Families[0].Name,$b,(new-object system.drawing.rectanglef 0,0,300,300))

$g.DrawString('A1234567890BCD',$f,$b,(new-object system.drawing.rectanglef 0,0,300,300))

$drawing.save('r:/test.png')
pause