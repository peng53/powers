
$mypass = read-host -assecurestring
$enc = ConvertFrom-SecureString $mypass

read-host -AsSecureString | ConvertFrom-SecureString | out-file -FilePath secret.enc

$data = get-content secret.enc

$mypass = read-host -assecurestring

$mysecret = 'secret' | ConvertTo-SecureString -AsPlainText -force
$enc = ConvertTo-SecureString -string $mysecret -key $mykey


$blah = convertto-securestring -string 'x' -key $mykey

##########################

$mybytes = [System.Collections.Generic.List[byte]]::new()
for ($i = 0; $i -lt 16; $i++){
    $mybytes.add($i)
}

[byte[]]$mykey = [byte[]]$mybytes

$mysecret = read-host -AsSecureString
$enc = ConvertFrom-SecureString -SecureString $mysecret -key $mykey

$unlock = get-content enc.txt | ConvertTo-SecureString -Key $mykey
$dec = [pscredential]::new(0,$unlock).GetNetworkCredential().password

###########

#make a key
[byte[]]$mykey = [byte[]]::new(16)
for ($i = 0; $i -lt 16; $i++){
    $mykey[$i] = $i
}

$mysecret2 = "
hello world
telescope
yes
"
# encypt and write, need to set key
$mysecret2_as_ss = ConvertTo-SecureString -string $mysecret2 -AsPlainText -Force
$enc2 = ConvertFrom-SecureString -SecureString $mysecret2_as_ss -key $mykey
set-content -path r:\enc2.txt -value $enc2

# read and decyipt

$enc2_ss = get-content r:\enc2.txt | ConvertTo-SecureString -key $mykey
## if key is wrong, will get error
$mysecret_revealed = [pscredential]::new(0,$enc2_ss).GetNetworkCredential().password


$mycode = @'
    write-host 'testing'
    write-host 'blah'
'@

$mycode = {
    write-host 123
}

Invoke-Expression -Command $mycode


 ConvertFrom-SecureString -SecureString $secret -key $mykey