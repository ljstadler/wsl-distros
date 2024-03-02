(Invoke-WebRequest -Uri "https://www.alpinelinux.org/downloads/").Links | 
    Where-Object { ($_.href -like "*alpine-minirootfs*") -and ($_.href -like "*x86_64.tar.gz") } | 
    Select-Object -First 1 -ExpandProperty href | 
    ForEach-Object { Invoke-WebRequest $_.Replace("&#x2F;", "/") -OutFile "$HOME\Downloads\alpine.tar.gz" };

New-Item -Path "$env:LOCALAPPDATA\Packages\alpine-wsl" -ItemType "directory";

wsl --import Alpine "$env:LOCALAPPDATA\Packages\alpine-wsl" "$HOME\Downloads\alpine.tar.gz";

Remove-Item "$HOME\Downloads\alpine.tar.gz";

do {
    $setup = Read-Host "Perform Setup? [y/n]"
    if ($setup -eq "y") {
        $username = Read-Host "Username"
        do {
            $password = Read-Host "Password" -MaskInput
            $rpassword = Read-Host "Retype Password" -MaskInput
        } until ($password -eq $rpassword)
        wsl -d Alpine -e ash -c @"
            apk upgrade -U &&
            apk add alpine-base doas &&
            adduser -D -G wheel ${username} &&
            echo '${username}:${password}' | chpasswd &&
            echo 'permit persist :wheel' > /etc/doas.d/doas.conf &&
            echo 'iface default inet dhcp' > /etc/network/interfaces &&
            echo -e '[boot]\ncommand="/sbin/openrc default"\n\n[user]\ndefault=${username}' > /etc/wsl.conf 
"@;
        break
    }
} until ($setup -eq "n")

wsl -t Alpine;

wsl -d Alpine --cd ~;