# MRAzBdapDatabricks
##  MRAzBdapDatabricks 0.1.0
Author:  MR BDAP Automation Team <p0060002256@munichre.com>

PowerShell Module for Azure Infrastructure as Code / automation code for <Component>

## Installing MRAzBdapDatabricks

You can install MRAzBdapDatabricks

```PowerShell
Copy-Item MRAzBdapDatabricks "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\MRAzBdapDatabricks"
Import-Module MRAzBdapDatabricks
```


## Installing MRAzBdapDatabricks

You can install MRAzBdapDatabricks

```PowerShell
git clone  https://apps-munichre.visualstudio.com/DefaultCollection/Big%20Data%20and%20Analytics%20Platform/_git/<repo> --branch master --single-branch [<folder>]

Copy-Item MRAzBdapDatabricks "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\MRAzBdapDatabricks"
Import-Module MRAzBdapDatabricks
```

### Import

You can load MRAzBdapDatabricks

``` PowerShell
Import-Module .\MRAzBdapDatabricks\MRAzBdapDatabricks.psd1
Get-Command -Module MRAzBdapDatabricks
```

### Build and Test

Run individual tests from folder `.\MRAzBdapDatabricks\Test`

```PowerShell
Invoke-Pester .\MRAzBdapDatabricks\Test\
```

### Setup

Edit `config.json` in Setup folder an run in `Setup` the `.\setup.ps1`

```JSON
{
    "Company": "MR",
    "Environment": "SBX",
    "Application": "BDAP",
    "Location": "westeurope",
    ...
}
```
## Release:  MRAzBdapDatabricks 0.1.0

- Adds New-MRAzBdapDatabricksComponent
- Adds Get-MRAzBdapDatabricksName
- Adds Get-MRAzBdapDatabricksArmTemplate
- Adds Get-MRAzBdapDatabricksKeyVaultSecret
## Functions

### Get-MRAzBdapDatabricksArmTemplate

#### SYNOPSIS
Returns the link to the modules ARM template

#### SYNTAX

```
Get-MRAzBdapDatabricksArmTemplate [-Path] <String> [-Source] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### DESCRIPTION
Returns the link to the modules ARM template
Can be configured in Modulemanifest (MRAzBdapDatabricks.psd1)  Attribute FileList = @('./static/azuredeploy.json')

#### EXAMPLES

##### EXAMPLE 1
```
Get-MRAzBdapDatabricksArmTemplate
```

*.\bdap-az-automation-databricks\MRAzBdapDatabricks\static\azuredeploy.json

#### PARAMETERS

##### -Path
Enter path to a template folder or a template file

```yaml
Type: String
Parameter Sets: (All)
Aliases: Loc

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

##### -Source
Select source as a local path or an Azure storage account

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

##### System.String
#### NOTES

#### RELATED LINKS
  ---

### Get-MRAzBdapDatabricksKeyVaultSecret

#### SYNOPSIS
Returns the used KeyVault secrets

#### SYNTAX

```
Get-MRAzBdapDatabricksKeyVaultSecret [<CommonParameters>]
```

#### DESCRIPTION
Returns the used KeyVault secrets
Can be configured in PowerShellfile (KeyVaultSecrets.psd1) in root

#### EXAMPLES

##### EXAMPLE 1
```
Get-MRAzBdapKeyVaulSecret
```

$Secret

#### PARAMETERS

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

#### NOTES

#### RELATED LINKS
  ---

### Get-MRAzBdapDatabricksName

#### SYNOPSIS
Get the name by naming convention \<Company\>-\<Application\>-\<Environment\>-\<MRLocation\>-\<Description and/or Incremental Number\>

#### SYNTAX

```
Get-MRAzBdapDatabricksName [-Company] <String> [-Application] <String> [-Environment] <String>
 -MrLocation <String> -Descriptor <String> [-Delimiter <String>] [-CHARACTER_NAME_LIMIT <Int32>]
 [<CommonParameters>]
```

#### DESCRIPTION
Naming patterns lowercase \<Company\>-\<Application\>-\<Environment\>-\<MRLocation\>-\<Description and/or Incremental Number\>

Examples:
- mr-bdap-prd-we-databricks

#### EXAMPLES

##### EXAMPLE 1
```
Get-MRAzBdapDatabricksName -Company 'MR' -Application 'BDAP' -Environment 'SBX' -MrLocation 'We' -Description 'usecase1'
```

Generates naming conveniton:'mr-bdap-prd-we-databricks'

#### PARAMETERS

##### -Company
Name of Company - e.g.
MR

```yaml
Type: String
Parameter Sets: (All)
Aliases: Co

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -Application
Name of Application - e.g.
BDAP

```yaml
Type: String
Parameter Sets: (All)
Aliases: App

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -Environment
Name of Environment - e.g.
SBX
\[ValidateSet("prd", "int", "dev", "sbx", "tt")\]

```yaml
Type: String
Parameter Sets: (All)
Aliases: Env

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -MrLocation
Name of MrLocation - e.g.
we (Get-MrAzBdapSharedLocation -Loation $Location)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -Descriptor
Descriptor if needed, incremental value or description

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -Delimiter
Delimiter if needed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: -
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -CHARACTER_NAME_LIMIT
Maximum character limit of component = 16

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 30
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

##### System.String
#### NOTES

#### RELATED LINKS
  ---

### New-MRAzBdapDatabricksCluster

#### SYNOPSIS
Returns an object representing defined Azure Databricks clusters.

#### SYNTAX

```
New-MRAzBdapDatabricksCluster [-Connection] <Object> [-config] <PSObject> [[-ClusterID] <String>]
 [<CommonParameters>]
```

#### DESCRIPTION
Returns an object representing defined Azure Databricks clusters.
If a cluster ID is supplied, it will filter for a specific cluster, otherwise it will return an
array of cluster objects.

#### EXAMPLES

##### EXAMPLE 1
```
NEw-MRAzbdapDatabricksCluster -Connection $Connection - config $config
```

Returns an array of Databricks cluster objects defined in the Azure databricks instance defined in $Connection

##### EXAMPLE 2
```

```

#### PARAMETERS

##### -Connection
An object that represents an Azure Databricks API connection where you want to get your clusters from.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -config
{{ Fill config Description }}

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -ClusterID
The cluster ID of the specific databricks cluster you want to return.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

#### NOTES

#### RELATED LINKS
  ---

### New-MRAzBdapDatabricksClusterConnection

#### SYNOPSIS
connection to an Azure Databricks instance by using  PAT and  URL.

#### SYNTAX

```
New-MRAzBdapDatabricksClusterConnection [-BaseURI] <Uri> [-AccessToken] <String> [[-Protocol] <String>]
 [-UseBasicParsing] [<CommonParameters>]
```

#### DESCRIPTION
This function returns a connection object that is required for all other functions in this module, and this function should be the first thing you
call to return a connection object.
Supports PS5 and PSCore 6, and different TLS configurations for HTTPS.

#### EXAMPLES

##### EXAMPLE 1
```
$Connection = New-MrAzBdapDatabricksClusterConnection -BaseURI https://eastus2.azuredatabricks.net -AccessToken x
```

Creates a new connection object in $Connection that contains your base URI and API key for all other functions in the module.

#### PARAMETERS

##### -BaseURI
{{ Fill BaseURI Description }}

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -AccessToken
Your Azure Databricks access token.PAT

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Protocol
If needed you can specify a TLS or SSL protocol, or "All." Use this if you receive certificate and/or HTTPS errors with your current security settings.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -UseBasicParsing
A pass-thru parameter for the underlying Invoke-WebRequest functions these functions rely on.
Use if needed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

#### NOTES

#### RELATED LINKS
  ---

### New-MRAzBdapDatabricksComponent

#### SYNOPSIS
Create the component by naming convention \<Company\>\<Application\>\<Environment\>

#### SYNTAX

##### Default (Default)
```
New-MRAzBdapDatabricksComponent -ResourceGroupName <String> -ManagedResourceGroupName <String>
 -LogAnalyticsResourceGroupName <String> -LogAnalyticsWorkspaceName <String> [-customVirtualNetworkId <String>]
 [-customPrivateSubnetName <String>] [-customPublicSubnetName <String>]
 [-VirtualNetworkResourceGroupName <String>] [-PricingTier <String>] -Location <String>
 [-DeploymentModuleVersion <String>] [-ReleaseIdentifier <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

##### ComponentName
```
New-MRAzBdapDatabricksComponent -ComponentName <String> -ResourceGroupName <String>
 -ManagedResourceGroupName <String> -LogAnalyticsResourceGroupName <String> -LogAnalyticsWorkspaceName <String>
 [-customVirtualNetworkId <String>] [-customPrivateSubnetName <String>] [-customPublicSubnetName <String>]
 [-VirtualNetworkResourceGroupName <String>] [-PricingTier <String>] -Location <String>
 [-DeploymentModuleVersion <String>] [-ReleaseIdentifier <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### DESCRIPTION
\<Company\>\<Application\>\<Environment\>
Naming patterns \<Company\>, \<Application\>, \<Environment\>, .

Examples:
-

#### EXAMPLES

##### EXAMPLE 1
```
New-Component -ComponentName
```

Example of how to use this cmdlet

##### EXAMPLE 2
```
New-Component -Company 'mr' -Application 'bdap' -Environment 'test' -Location 'we' -Component 'test' -Descriptor '666'
```

Example of how to use this cmdlet

#### PARAMETERS

##### -ComponentName
Component Name - e.g.
mr-bdap-sbx-eu-shared001
Can be generated by using Get-MrAzBdap\<Module\>Name
Uses ParameterSet ComponentName

```yaml
Type: String
Parameter Sets: ComponentName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -ResourceGroupName
Resource Group Name - e.g.
\<Company\>-\<Application\>-\<Environment\>-\<Location\>-\<Component\>\[-\<Description or Incremental Number\>\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -ManagedResourceGroupName
DB managed Resource Group Name - e.g.
\<Company\>-\<Application\>-\<Environment\>-\<Location\>-\<Component\>\[-\<Description or Incremental Number\>\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -LogAnalyticsResourceGroupName
LogAnalyticsResourceGroupName - e.g.
\<Company\>-\<Application\>-\<Environment\>-\<Location\>-\<Component\>\[-\<Description or Incremental Number\>\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -LogAnalyticsWorkspaceName
LogAnalyticsWorkspaceName - e.g.
\<Company\>-\<Application\>-\<Environment\>-\<Location\>-\<Component\>\[-\<Description or Incremental Number\>\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -customVirtualNetworkId
Name of the virtual network name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -customPrivateSubnetName
The name of the private subnet in the custom VNet.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -customPublicSubnetName
The name of the public subnet in the custom VNet.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -VirtualNetworkResourceGroupName
The name of the public subnet in the custom VNet.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -PricingTier
The pricing tier of workspace

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Premium
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Location
Name of Azure Location - e.g.
West Europe
\[ValidateScript( { (Get-AzLocation).Location -contains $_ } )\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -DeploymentModuleVersion
The name of deployment Module Version

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -ReleaseIdentifier
The name of deployment Module Version

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -WhatIf
Dry run of script, returns theoretical values

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Confirm
Before impacting system ask to confirm

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

##### System.Management.Automation.PSObject
#### NOTES

#### RELATED LINKS
  ---

### Set-MRAzBdapDatabricksUp

#### SYNOPSIS
{{ Fill in the Synopsis }}

#### SYNTAX

##### Default (Default)
```
Set-MRAzBdapDatabricksUp [-WhatIf] [-Confirm] [<CommonParameters>]
```

##### ConfigPath
```
Set-MRAzBdapDatabricksUp -configPath <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### DESCRIPTION
{{ Fill in the Description }}

#### EXAMPLES

##### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

#### PARAMETERS

##### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -configPath
{{ Fill configPath Description }}

```yaml
Type: String
Parameter Sets: ConfigPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

##### None

#### OUTPUTS

##### System.Management.Automation.PSObject

#### NOTES

#### RELATED LINKS
  ---
