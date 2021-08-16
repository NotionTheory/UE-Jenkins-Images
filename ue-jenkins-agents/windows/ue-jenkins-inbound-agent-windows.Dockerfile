# escape=`

FROM jenkins/inbound-agent:4.7-1-jdk11-windowsservercore-ltsc2019@sha256:9059353c2f70278e11d6a3ed7c258b24c299939de54885e6319f229c35cee23f

# Include shared installation scripts
COPY Scripts\Windows\* C:\Workspace\

# Include specific installation scripts
COPY ue-jenkins-agents\windows\Container\* C:\Workspace\

RUN try { C:\Workspace\InstallSoftware.ps1 } catch { Write-Error $_ } `
    Remove-Item C:\Workspace -Recurse -Force
