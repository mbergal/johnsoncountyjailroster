$psake.use_exit_on_error = $true
$ErrorActionPreference = "Stop"

properties {
    $exportFile = "jailroster.csv";
    $thisDir = (Split-Path -Parent $PSCommandPath)
}

Task default -depends Build

Task Build {
}

Task Scrape -depends Build `
    {
    }

Task Export -depends Build {
    exec { .\bin\Debug\JailRoster.exe export --outputFile=$exportFile }
    BackupDatabase -Server . -Database JailRoster -BackupFile ([IO.Path]::GetFullPath( "jailroster.bak" ))
    }

function BackupDatabase( [Parameter(Mandatory=$true)][string] $Server,
                         [Parameter(Mandatory=$true)][string] $Database,
                         [Parameter(Mandatory=$true)][string] $BackupFile )
    {
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo');
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Management.Sdk.Sfc');
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO');            
    
    Write-Output ("Started at: " + (Get-Date -format yyyy-MM-dd-HH:mm:ss));            
    Write-Output ("Backup file: " + $BackupFile );            

    $s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST" 

    $defaultBackupDirectory = (New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Server).Settings.BackupDirectory
    $tempBackupFile = Join-Path $defaultBackupDirectory ($Database + ".bak")
    $timestamp = Get-Date -format yyyy-MM-dd-HH-mm-ss;            
    $backup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup");            
    $backup.Action = "Database";            
    $backup.Database = $Database;            
    $backup.Devices.AddDevice( $tempBackupFile, "File");            
    $backup.BackupSetDescription = "Full backup of " + $Database + " " + $timestamp;            
    $backup.CopyOnly = $true;            
    $backup.Initialize = $true;
    $backup.Incremental = 0;           
    $backup.SqlBackup($Server);     

    Move-Item -Force $tempBackupFile $BackupFile

    Write-Output ("Finished at: " + (Get-Date -format  yyyy-MM-dd-HH:mm:ss));    Write-Host $Server
    }


