. ${PSScriptRoot}\..\..\SystemConfiguration\Register-AutoStartService.ps1

class Register-AutoStartService-JenkinsAgent-Exception : Exception {
	$ScriptLocation

	Register-AutoStartService-JenkinsAgent-Exception([string] $scriptLocation) : base("Register-AutoStartService-JenkinsAgent must be called with the location of an existing script file; ${scriptLocation} does not exist") { $this.ScriptLocation = $scriptLocation }
}

function Register-AutoStartService-JenkinsAgent {

	<#
		.SYNOPSIS
		Installs a service, that is autostarting, and runs a PowerShell script under the name "JenkinsAgent"
	#>

	param (
		[Parameter(Mandatory)] [string] $ScriptLocation
	)

	if (!(Test-Path $ScriptLocation)) {
		throw [Register-AutoStartService-JenkinsAgentException]::new($ScriptLocation)
	}

    Register-AutoStartService -ServiceName "JenkinsAgent" -Program "powershell" -ArgumentList @($ScriptLocation)
}
