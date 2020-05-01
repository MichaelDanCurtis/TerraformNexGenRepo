# Setup

Setup Folder contains

- Setup: [`Setup.ps1`](.\Setup.ps1)
  - Config `config.local.tests.json`
- Module [`UploadModule.ps1`](.\UploadModule.ps1)
- Runbook [`UploadRunbook.ps1`](.\UploadRunbook.ps1)

Upload functions are implemented in [Upload AutomationAccount Assets](https://apps-munichre.visualstudio.com/Big%20Data%20and%20Analytics%20Platform/_release?_a=releases&view=mine&definitionId=66)

- [Setup](#setup)
  - [setup.ps1](#setupps1)
  - [UploadModule.ps1](#uploadmoduleps1)
  - [UploadRunbook.ps1](#uploadrunbookps1)

## setup.ps1

```yaml
// .config.local.test.json


// Convertfrom-json (Get-Content -Path .\Setup\config.local.test.json -raw) | convertto-yaml


// Company for the naming
Company: MR

// Application for the naming
Application: BDAP

// Environment for the naming, indicating subscription
Environment: SBX

// Log Analytics Workspace name to connect to
LogAnalyticsWorkspace: mr-bdap-sbx-eu

// Names of modules that gets installed on the automation account after it got provisioned
// the modules need to be from the PSGallery
ModuleNames:
- - Az
  - 2.1.0
- - AzureAD
  - 2.0.2.16
```

## UploadModule.ps1

Uploads given modules by `-ModuleNames`, this is an array of module names that can be installed on a given Automation Account.
Modules can be from a private nuget feed or from PSGallery.
Modules will be also be uploaded to the given StorageAccount.
Using a convention of  `$($ModuleName + '\' + $Version + '\' + $Package.BaseName + '.zip')` where ModuleName is the parent Module and the `Package.BaseName` the dependent modules. E.g. DSVM consist of different internal Modules that need to be present on the automation account too.

// TODO: Currently it will only upload to an automation worker - not a hybrid worker!

## UploadRunbook.ps1

Uploads and publishes local runbooks to the automation accounts and enables logging and tracing.
The runbooks must be present in a specific Path e.g. `$env:System_DefaultWorkingDirectory` on the build agent.
Thus the user can specifiy multiple repositories to upload runbooks from.

On the build agent the script will search each artifact (repository) for a `runbook` folder.

For each runbook folder found it will upload all contained `*.ps1` files to the given automation account.

See [Set-Runbook](../MRAzBdapAutomationAccount/Public/Set-Runbook.ps1)