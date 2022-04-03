$d1s = '7:11 PM 5/16/2019'
$d2s = '9:50 PM 5/16/2019'

$f = 'h:mm tt M/d/yyyy'

$d1 = [datetime]::parseexact(
    $d1s,
    $f,
    $null
)
$d2 = [datetime]::parseexact(
    $d2s,
    $f,
    $null
)
$tdiff = $d2-$d1

Write-Host $tdiff.TotalHours

$ls = 'thing \ 7:11 PM 5/16/2019 \\ 9:50 PM 5/16/2019'

Write-Host $ls
$ls.split('\\')