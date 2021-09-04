# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
Start-Transcript -LiteralPath "C:\Logs\GCEService-DockerInboundAgent-$(Get-Date -Format "yyyyMMdd-HHmmss" -ErrorAction Stop).txt" -ErrorAction Stop

try {

    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
    . ${PSScriptRoot}\..\..\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
    . ${PSScriptRoot}\..\Run\Run-DockerInboundAgent.ps1

    $VMSettings = Import-PowerShellDataFile -Path "${PSScriptRoot}\..\..\VMSettings.psd1" -ErrorAction Stop

    $AgentName = (Get-GCEInstanceHostname).Split(".")[0]

    Write-Host "Waiting for required settings to be available in Secrets Manager / Instance Metadata..."

    $RequiredSettingsSpec = @{
        JenkinsURL = @{ Name = "jenkins-url"; Source = [GCESettingSource]::Secret }
        AgentKey = @{ Name = "agent-key-file"; Source = [GCESettingSource]::Secret }
        AgentImageURL = @{ Name = "inbound-agent-image-url-windows"; Source = [GCESettingSource]::Secret }
        JenkinsSecret = @{ Name = "inbound-agent-secret-${AgentName}"; Source = [GCESettingSource]::Secret }
    }

    $RequiredSettings = Get-GCESettings $RequiredSettingsSpec -Wait -PrintProgress

    # Extract region from docker image URL
    # Example: europe-west1-docker.pkg.dev/<projectname>/<reponame>/<imagename>:<tag> => europe-west1
    $Region = ($RequiredSettings.AgentImageURL -Split "-docker.pkg.dev")[0]

    Write-Host "Authenticating Docker for Google Artifact Registry..."

    Authenticate-DockerForGoogleArtifactRegistry -AgentKey $RequiredSettings.AgentKey -Region $Region

    Write-Host "Waiting for SSH Server to start..."

    (Get-Service -Name "sshd").WaitForStatus("Running")

    Write-Host "Running Jenkins Agent..."

    $ServiceParams = @{
        JenkinsAgentFolder = $VMSettings.JenkinsAgentFolder
        JenkinsWorkspaceFolder = $VMSettings.JenkinsWorkspaceFolder
        PlasticConfigFolder = $VMSettings.PlasticConfigFolder
        JenkinsURL = $RequiredSettings.JenkinsURL
        JenkinsSecret = $RequiredSettings.JenkinsSecret
        AgentImageURL = $RequiredSettings.AgentImageURL
        AgentName = $AgentName
    }

    Run-DockerInboundAgent @ServiceParams

    Write-Host "Done."

} finally {

    Stop-Transcript

}