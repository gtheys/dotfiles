<#
.Synopsis
   Install MiniKube + Kubectl
.DESCRIPTION
   This script downloads the executables for MiniKube, Kubectl, configures Hyper-V as the hypervisor (if not configured already)
   together with configuring a specific network adapter for use with the Minikube virtual machine
.EXAMPLE
   Install-MiniKube
.NOTES
   Version:        1.0
   Author:         James Pettigrove
#>

## Check if running as a Administrator (needed for Hyper-V commands)
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

## Check HyperV status
$HypervState = (Get-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V).State

## If missing, enable HyperV
if ($HypervState -eq "Disabled")
    {
       $EnableHyperV = Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V-Management-Powershell,Microsoft-Hyper-V-All -NoRestart
       
       ## If a restart is needed, add registry entry to continue after reboot
       if ($EnableHyperV.RestartNeeded -eq $true)
          {
            ## Set script to re-run after reboot
            Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "Install-MiniKube" -Value "C:\Windows\system32\WindowsPowerShell\v1.0\Powershell.exe $PSCommandPath"

            ## And reboot
            Restart-Computer
          }
    }

## Get version number of latest stable release of kubectl
$KubectlVersion = (Invoke-WebRequest -uri https://storage.googleapis.com/kubernetes-release/release/stable.txt -UseBasicParsing).content.Trim() 

## Turn off progress bars to speed up incoming download *sigh*
$ProgressPreference = "silentlyContinue"

## Download minikube + kubectl to temp location
$MinikubeUrl = "https://storage.googleapis.com/minikube/releases/latest/minikube-windows-amd64.exe"
$MinikubeDl = "$Env:Temp\minikube.exe"
$KubctlUrl = "https://storage.googleapis.com/kubernetes-release/release/$KubectlVersion/bin/windows/amd64/kubectl.exe"
$KubctlDl = "$Env:Temp\kubectl.exe"

Invoke-WebRequest -uri $MinikubeUrl -OutFile $MinikubeDl
Invoke-WebRequest -uri $KubctlUrl -OutFile $KubctlDl

## Restore progress bars to default
$ProgressPreference = "Continue"

## Create and copy downloads to Minikube directory in Program Files
$MinikubeDst = "$Env:Programfiles\Minikube"

New-Item $MinikubeDst -ItemType Container
Move-Item $MinikubeDl -Destination $MinikubeDst
Move-Item $KubctlDl -Destination $MinikubeDst

## Update PATH environment variable for this session
$env:Path +=";$MinikubeDst"

## Update PATH environment variable permentantly
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$MinikubeDst", [EnvironmentVariableTarget]::Machine)

## Check for and clear out any previous MiniKube configurations
if (Test-Path -Path "$HOME\.minikube") 
    {
      Remove-Item -Path "$HOME\.minikube" -Force -Recurse
    }

## Get Network Adapter of choice for use with MiniKube
$NetworkAdapter = Get-NetAdapter | Out-GridView -OutputMode Single -Title 'Pick your network adapter to use with MiniKube' 

## Configure Hyper-V Virtual Switch with Network Adapter chosen previously
New-VMSwitch -Name "Minikube" -AllowManagementOS $true -NetAdapterName $NetworkAdapter.Name

## Configure Minikube to use Hyper-V driver and Virtual Network Adapter
minikube config set vm-driver hyperv
minikube config set hyperv-virtual-switch Minikube
minikube config set memory 2048
 
## Start MiniKube
minikube start