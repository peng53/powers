$reader = [System.IO.File]::OpenText("C:\users\lm\ps\test_data.txt")
$f = 'h:mm tt M/d/yyyy'
$codes = @{}

try {
    for() {
        $t1s = $reader.ReadLine()
        if ($t1s -eq $null){
            break;
        }
        $code = $reader.ReadLine()
        $t2s = $reader.ReadLine()
        if ($code -eq $null -or $t2s -eq $null){
            Write-Host No t2/code
            break;
        }
        $d1 = [datetime]::parseexact(
            $t1s,
            $f,
            $null
        )
        $d2 = [datetime]::parseexact(
            $t2s,
            $f,
            $null
        )
        $tdiff_m = ($d2-$d1).TotalMinutes
        
        if ($codes.ContainsKey($code)){
            $codes[$code] += $tdiff_m
        } else {
            $codes[$code] = $tdiff_m
        }
        #Write-Host $code $tdiff_m
        $blank = $reader.ReadLine()
        if ($blank -eq $null){
            break;
        }        
    }
}
finally {
    $reader.Close()
}

foreach ($k in $codes.Keys){
    $t = "{0} : {1} m ({2:f2} hrs)" -f $k, $codes[$k].ToString().PadLeft(3), ($codes[$k]/60)
    Write-Host $t
}