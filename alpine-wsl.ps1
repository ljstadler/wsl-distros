(Invoke-WebRequest -Uri "https://www.alpinelinux.org/downloads/").Links | 
    Where-Object { ($_.href -like "*alpine-minirootfs*") -and ($_.href -like "*x86_64.tar.gz") } | 
    Select-Object -First 1 -ExpandProperty href | 
    ForEach-Object { Invoke-WebRequest $_.Replace("&#x2F;", "/") -OutFile "$HOME\Downloads\alpine.tar.gz" };

New-Item -Path "$env:LOCALAPPDATA\Packages\alpine-wsl" -ItemType "directory";

wsl --import Alpine "$env:LOCALAPPDATA\Packages\alpine-wsl" "$HOME\Downloads\alpine.tar.gz";

Remove-Item "$HOME\Downloads\alpine.tar.gz";