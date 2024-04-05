$assets = (Invoke-RestMethod "https://api.github.com/repos/mvaisakh/wsl-distro-tars/releases/latest").assets

Write-Host @"
wsl-distros

[1] Alpine
[2] Fedora

"@

do {
    $distro = Read-Host "Distro [1/2]"
} until (($distro -eq "1") -or ($distro -eq "2"))

switch ($distro) {
    ("1") { 
        $assets | Where-Object { $_.name -like "alpine.edge-*" } |
        Select-Object -First 1 -ExpandProperty browser_download_url |
        ForEach-Object { Invoke-WebRequest $_ -OutFile "$HOME\Downloads\alpine.tar" }
        
        wsl --import Alpine "$env:LOCALAPPDATA\Packages\wsl-distros.alpine" "$HOME\Downloads\alpine.tar"

        Remove-Item "$HOME\Downloads\alpine.tar"

        do {
            $setup = Read-Host "Perform Setup? [y/n]"
            if ($setup -eq "y") {
                $username = Read-Host "Username"
                do {
                    $password = Read-Host "Password" -MaskInput
                    $rpassword = Read-Host "Retype Password" -MaskInput
                } until ($password -eq $rpassword)
                $timezone = (Invoke-RestMethod "http://ip-api.com/json").timezone
                wsl -d Alpine -e ash -c @"
                    apk upgrade -U &&
                    apk add alpine-base doas &&
                    setup-timezone -z ${timezone} &&
                    adduser -D -G wheel ${username} &&
                    echo '${username}:${password}' | chpasswd &&
                    echo 'root:${password}' | chpasswd &&
                    echo 'permit persist :wheel' > /etc/doas.d/doas.conf &&
                    echo 'iface default inet dhcp' > /etc/network/interfaces &&
                    echo -e '[boot]\ncommand="/sbin/openrc default"\n\n[user]\ndefault=${username}' > /etc/wsl.conf 
"@
                break
            }
        } until ($setup -eq "n")

        wsl -t Alpine

        wsl -d Alpine --cd ~
    }
    ("2") { 
        $assets | Where-Object { $_.name -like "fedora-*" } |
        Select-Object -First 1 -ExpandProperty browser_download_url |
        ForEach-Object { Invoke-WebRequest $_ -OutFile "$HOME\Downloads\fedora.tar" } 

        wsl --import Fedora "$env:LOCALAPPDATA\Packages\wsl-distros.fedora" "$HOME\Downloads\fedora.tar"

        Remove-Item "$HOME\Downloads\fedora.tar"

        do {
            $setup = Read-Host "Perform Setup? [y/n]"
            if ($setup -eq "y") {
                $username = Read-Host "Username"
                do {
                    $password = Read-Host "Password" -MaskInput
                    $rpassword = Read-Host "Retype Password" -MaskInput
                } until ($password -eq $rpassword)
                wsl -d Fedora -e bash -c @"
                    dnf -y update &&
                    dnf -y upgrade &&
                    dnf -y group install "Minimal Install" &&
                    useradd -m -G wheel ${username} &&
                    echo '${username}:${password}' | chpasswd &&
                    echo 'root:${password}' | chpasswd &&
                    echo -e '[boot]\nsystemd=true\n\n[user]\ndefault=${username}' > /etc/wsl.conf 
"@
                break
            }
        } until ($setup -eq "n")

        wsl -t Fedora

        wsl -d Fedora --cd ~
    }
}