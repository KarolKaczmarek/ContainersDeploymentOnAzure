configuration CreateContainer
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string]
        $containerName,
        
        [Parameter(Mandatory=$true)]
        [string]
        $containerImageName,

        [Parameter(Mandatory=$true)]
        [string]
        $localWimPath,
        
        [string]
        $wimPath
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration -Name WindowsFeature
    Import-DscResource -ModuleName nContainer
    
    LocalConfigurationManager
    {
        RebootNodeIfNeeded = $true
    }

    WindowsFeature ContainersFeature
    {
        Name =   'Containers'
        Ensure = 'Present'
    }

    Script DownloadImage
    {
        GetScript = { return @{} }
        SetScript = {

                if ($using:wimPath -ne $null)
                {
                    Write-Verbose "Downloading container image from $using:wimPath" -Verbose
                    wget -Uri $using:WimPath -OutFile $using:localWimPath -UseBasicParsing
                }
                elseif (-not (Test-Path $using:localWimPath))
                {
                    throw "Path to download wim image was not provided and localWimPath does not exist"
                }

                Write-Verbose "Installing container image $using:localWimPath" -Verbose
                Install-ContainerOsImage -WimPath $using:localWimPath -Force

                while ($imageCollection -eq $null)
                {
                    
                    #
                    # Sleeping to ensure VMMS has restarted to workaround TP3 issue
                    #
                    
                    Start-Sleep -Sec 2
                    Write-Verbose "TODO test" -Verbose
                    $imageCollection = Get-ContainerImage $using:containerImageName
                }
            }
        TestScript = { return ((Get-ContainerImage $using:containerImageName) -ne $null) }
        DependsOn = "[WindowsFeature]ContainersFeature"
    }

    nContainer Container
    {
        Name      = $containerName
        ImageName = $containerImageName
        Ensure    = 'Present'
        State     = 'Off'
        VirtualSwitchName = 'Virtual Switch'
        DependsOn = "[Script]DownloadImage"
    }

}

#
# Compilation sample:
#
#CreateContainer -ContainerName "TestContainer1" -containerImageName "WindowsServerCore" -localWimPath "C:\ContainerBaseImage.wim" -wimPath "https://aka.ms/ContainerOSImage"
