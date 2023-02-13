$header = 'Group','Key','Stat1','Stat2','Stat3'
$data_l = import-csv $PSScriptRoot/etc/keyed_csv.csv -header $header
$data_r = import-csv $PSScriptRoot/etc/keyed_csv_b.csv -header $header

$outcsv = join-path r: difference_csv.txt
if ((test-path $outcsv)){
    write-host 'Output file already exists! (differences will not be written to disk!)' -BackgroundColor DarkRed
    $outcsv = $null
}

'Group,Key,Difference,Left,Right' >> $outcsv

$dictL = [system.collections.generic.dictionary[string,int]]::new()
for ($i=0;$i -lt $data_l.Count;$i++){
    $row = $data_l[$i]
    $key = '{0}-{1}' -f $row.Group,$row.Key
    if (-not $dictL.ContainsKey($key)){
        $dictL.Add($key,$i)
    } else {
        write-host 'Error: key not unique, L row' $i
    }
}
$dictR = [system.collections.generic.dictionary[string,int]]::new()
for ($i=0;$i -lt $data_r.Count;$i++){
    $row = $data_r[$i]
    $key = '{0}-{1}' -f $row.Group,$row.Key
    if (-not $dictR.ContainsKey($key)){
        $dictR.Add($key,$i)
    } else {
        write-host 'Error: key not unique, R row' $i
    }
    if (-not $dictL.ContainsKey($key)){
        write-host 'Missing' $key 'in LEFT' -BackgroundColor Magenta
        '{0},{1},Missing LEFT,,' -f ($row.Group,$row.Key) >> $outcsv
    }
}
$keysL = [System.Collections.Generic.HashSet[string]]::new($dictL.Keys)
$keysR = [System.Collections.Generic.HashSet[string]]::new($dictR.Keys)

foreach ($k in $keysL){
    if (-not $keysR.Contains($k)){
        write-host 'Missing' $k 'in RIGHT' -BackgroundColor Green
        '{0},{1},Missing B,,' -f ($k.Split('-')) >> $outcsv
    }
}


$shared = [System.Collections.Generic.HashSet[string]]::new($keysL)
$shared.IntersectWith($keysR)

$diffCols = 'Stat1','Stat2','Stat3'
Function DiffRow($group,$key,$l,$r){
    $ret = 0
    foreach ($c in $diffCols){
        if ($l.$c -ne $r.$c){
            write-host $group '-' $key '* Mismatch' $c ':' $l.$c '!=' $r.$c -BackgroundColor red
            '{0},{1},{2},{3},{4}' -f ($group,$key,$c,$l.$c,$r.$c) >> $outcsv
            $ret = 1
        }
    }
    return $ret
}

foreach ($k in $shared){
    [int]$group,[int]$key = $k.Split('-')
    DiffRow -group $group -key $key -l $data_l[$dictL[$k]] -r $data_r[$dictR[$k]] | Out-Null
}
Invoke-item $outcsv
