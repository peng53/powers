7z x $c index
(Get-Content $f) -replace 'Date="\d{4}-\d\d-\d\d"', 'Date="1970-01-01"' | Set-Content $f
7z u $c index