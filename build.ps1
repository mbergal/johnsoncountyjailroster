param( [string] $Task, $properties  )

$ErrorActionPreference = "Stop"

$thisDir = (Split-Path -Parent $PSCommandPath)
& "$thisDir\.nuget\nuget.exe" Install "$thisDir\packages.config" -o "$thisDir\packages"

Import-Module "$thisDir\packages\psake.4.2.0.1\tools\psake.psm1"

Invoke-psake `
    -buildFile "$thisDir\build.psake.ps1" `
    -taskList $Task `
    -properties $properties

if ( $psake.build_success ) { exit 0; } else { exit 1; }
