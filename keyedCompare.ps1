$header = 'Group','Key','Stat1','Stat2','Stat3'
$a = import-csv 'keyed_csv.csv' -header $header
$b = import-csv 'keyed_csv_b.csv' -header $header

$outcsv = join-path r: difference_csv.txt
if ((test-path $outcsv)){
    write-host 'Output file already exists! (differences will not be written to disk!)' -BackgroundColor DarkRed
    $outcsv = $null
}

'Group,Key,Difference' >> $outcsv

$a_keyed = @{}
$a_keys = [System.Collections.Generic.HashSet[string]]::new()
for ($i=0; $i -lt $a.Count; $i++){
    $row = $a[$i]
    if (-not $a_keyed.ContainsKey([int]$row.Group)){
        $a_keyed[[int]$row.Group] = @{}
    }
    $a_keyed[[int]$row.Group][[int]$row.Key] = $row
    # group or key can be a string, just remove [int] casting
    [void]$a_keys.Add('{0}-{1}' -f ($row.Group,$row.Key))
}

$b_keyed = @{}
$b_keys = [System.Collections.Generic.HashSet[string]]::new()
for ($i=0; $i -lt $b.Count; $i++){
    $row = $b[$i]
    if (-not $b_keyed.ContainsKey([int]$row.Group)){
        $b_keyed[[int]$row.Group] = @{}
    }
    $b_keyed[[int]$row.Group][[int]$row.Key] = $row
    # group or key can be a string, just remove [int] casting
    $k = '{0}-{1}' -f ($row.Group,$row.Key)
    [void]$b_keys.Add($k)
    if (-not $a_keys.Contains($k)){
        write-host 'Missing' $k 'in A' -BackgroundColor Magenta
        '{0},{1},Missing A' -f ($row.Group,$row.Key) >> $outcsv
    }
}

foreach ($k in $a_keys){
    if (-not $b_keys.Contains($k)){
        write-host 'Missing' $k 'in B' -BackgroundColor Green
        '{0},{1},Missing B' -f ($k.Split('-')) >> $outcsv
    }
}
$shared = [System.Collections.Generic.HashSet[string]]::new($a_keys)
$shared.IntersectWith($b_keys)

$diffCols = 'Stat1','Stat2','Stat3'
Function DiffRow($group,$key,$l,$r){
    $ret = 0
    foreach ($c in $diffCols){
        if ($l.$c -ne $r.$c){
            write-host $group '-' $key '* Mismatch' $c ':' $l.$c '!=' $r.$c -BackgroundColor red
            '{0},{1},{2}' -f ($group,$key,$c) >> $outcsv
            $ret = 1
        }
    }
    return $ret
}

foreach ($k in $shared){
    [int]$group,[int]$key = $k.Split('-')
    DiffRow -group $group -key $key -l $a_keyed[$group][$key] -r $b_keyed[$group][$key] | Out-Null
}
Invoke-item $outcsv