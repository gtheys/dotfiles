# Excellent gist: https://gist.github.com/timbophillips/d31a38efc7c29add955198550c7554d0#file-generate-github-ssh-key-ps1
#

Write-Host "

This script performs the steps from 
https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

1. generate a ssh key
2. start the ssh-agent service
3. add the key to the agent
4. copy the public key signaturecopy it to the clipboard

"
$email = Read-Host -Prompt "enter your GitHub email address"

ssh-keygen -t rsa -b 4096 -C $email
Start-Process -filepath powershell.exe -Verb Runas -ArgumentList @('Set-Service -StartupType Manual ssh-agent')
Start-Service ssh-agent
ssh-add $HOME\.ssh\id_rsa
Get-Content $HOME\.ssh\id_rsa.pub | clip.exe
Write-Host "

now head to https://github.com/settings/ssh/new to paste the key in to Github

"
