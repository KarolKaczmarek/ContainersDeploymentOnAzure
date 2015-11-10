# ContainersDeploymentOnAzure
Azure Resource Manager template with DSC configuration deploying Windows Server container on Azure VM

## Deployment
```PowerShell
New-AzureResourceGroup -verbose -ResourceGroupName "containersrg" -Location "East US" -TemplateFile .\WindowsVirtualMachine.json -TemplateParameterFile .\WindowsVirtualMachine.param.dev.json -force
```

After modifying the DSC configuration, you need to regenerate the .zip package
```PowerShell
Publish-AzureVMDscConfiguration -ConfigurationPath .\CreateContainer.ps1 -ConfigurationArchivePath .\CreateContainer.ps1.zip -force
```