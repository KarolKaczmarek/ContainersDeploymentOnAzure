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

    File TestFile
    {
        DestinationPath = "C:\test\test.txt"
        Contents = "test contents"
        Ensure = "Present"
        DependsOn = "[WindowsFeature]ContainersFeature"
    }

    <# TODO uncomment after testing
    Script DownloadImage
    {
        GetScript = { return @{} }
        SetScript = {

                if ($wimPath -ne $null)
                {
                    Write-Verbose "Downloading container image from $wimPath" -Verbose
                    wget -Uri $WimPath -OutFile $localWimPath -UseBasicParsing
                }
                elseif (-not (Test-Path $localWimPath))
                {
                    throw "Path to download wim image was not provided and localWimPath does not exist"
                }

                Write-Verbose "Installing container image $localWimPath" -Verbose
                Install-ContainerOsImage -WimPath $localWimPath -Force

                while ($imageCollection -eq $null)
                {
                    #
                    # Sleeping to ensure VMMS has restarted to workaround TP3 issue
                    #
                    Start-Sleep -Sec 2
                    Write-Verbose "TODO test" -Verbose
                    $imageCollection = Get-ContainerImage $containerImageName
                }
            }
        TestScript = { return ((Get-ContainerImage $containerImageName) -ne $null) }
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
    #>
}

CreateContainer -ContainerName "TestContainer1" -containerImageName "WindowsServerCore" -localWimPath "C:\ContainerBaseImage.wim" -wimPath "https://aka.ms/ContainerOSImage"