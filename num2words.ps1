﻿# https://support.microsoft.com/en-us/office/convert-numbers-into-words-a0d166fb-e1ea-4090-95c8-69442cd55d98

function GetTens {
    [CmdLetBinding()]
    param(
        [int]$t
    )
    $tensScale = '', '', ' Twenty', ' Thirty', ' Forty', ' Fifty', ' Sixty', ' Seventy', ' Eighty', ' Ninety'
    $smallNum = '', ' One', ' Two', ' Three', ' Four', ' Five', ' Six', ' Seven', ' Eight', ' Nine', ' Ten', ' Eleven', ' Twelve', ' Thirteen', ' Fourteen', ' Fifteen', ' Sixteen', ' Seventeen', ' Eighteen', ' Nineteen'
    if ($t -lt 20){
        return $smallNum[$t]
    } else {
        return $tensScale[[math]::floor($t/10)] + $smallNum[$t%10]
    }
}
function GetHundreds {
    [CmdLetBinding()]
    param(
        [string]$h
    )
    if ([int]$h -eq 0){
        return
    }
    $h = $h.PadLeft(3,'0')
    $result = ''
    if ($h[0] -ne '0'){
        $result = (GetTens([math]::floor([int]$h/100)))+,' Hundred'
    }
    $result = $result + (GetTens($h.Substring(1,2)))
    return $result
}
function Num2Words {
    [CmdLetBinding()]
    param(
        [double]$n
    )
    $places = '', '', ' Thousand', ' Million', ' Billion', ' Trillion'
    $mynum = [string]$n
    $dollar = ''
    $cents = ''
    $decimalPlace = $mynum.LastIndexOf('.')
    if ($decimalPlace -gt 0){
        $cents = GetTens(($mynum.substring($decimalPlace+1).padright(2,'0')))
        $mynum = $mynum.Substring(0,$decimalPlace)
    }
    $l = $mynum.length
    $count = 1
    while ($l -gt 2){
        $temp = GetHundreds($mynum.substring($l-3,3))
        if ($temp.length -gt 0){
            $dollar = $temp+$places[$count]+$dollar
        }   
        $l -= 3
        $count++
    }
    if ($l -gt 0){
        $temp = GetHundreds($mynum.Substring(0,$l))
        if ($temp.length -gt 0){
            $dollar = $temp+$places[$count]+$dollar
        }
    }
    $dollar = switch ($dollar.trim()){
        '' {'No Dollars'}
        'One' {'One Dollar'}
        default { $dollar.trim() + ' Dollars'}
    }
    $cents = switch ($cents.trim()){
        '' {' and No Cents'}
        'One' {' and One Cent'}
        default {' and',$cents.trim()+'Cents'}
    }
    $result = $dollar+$cents
    return $result.trim()
}