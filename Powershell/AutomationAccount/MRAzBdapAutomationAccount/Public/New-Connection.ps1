function  New-Connection {
    <#
.SYNOPSIS
Creates an Azure Automation connection

.DESCRIPTION
Creates an Azure Automation connection of type AzureServicePrincipal, named 'AzureRunAsConnection', with Contributor role on the subscription.

.PARAMETER Environment
Name of Environment - e.g. SBX
[ValidateSet("prd", "int", "dev", "sbx", "tt")]

.PARAMETER MrLocation
Name of MunichRe location - e.g. we

.PARAMETER AutomationAccountName
Name of the Automation Account where the connection will be used.

.PARAMETER ResourceGroupName
Name of the Resource Group where the Automation Account was created

.PARAMETER ConnectionName
Name of the connection. It is recommended to use the default value.

.PARAMETER Company
Name of the company - e.g. MR

.PARAMETER Application
Name of the application - e.g. BDAP

.PARAMETER Confirm
Will promt user to confirm the action to create invasible commands

.PARAMETER WhatIf
Dry run of the script

.PARAMETER CertificateSubject
Subject of the Certificate. It is recommended to use the default value.

.EXAMPLE
New-MRAzBdapAutomationAccount -Environment 'tt' -MrLocation 'we' -AutomationAccountName 'mr-bdap-tt' -ResourceGroupName 'MR-BDAP-WE-TT-AUTO'

Creates a Connection for the Automation Account  'mr-bdap-tt'

#>
    [CmdletBinding(
        SupportsShouldProcess = $True,
        PositionalBinding = $True,
        DefaultParameterSetName = "Default"
    )]
    [OutputType('Microsoft.Azure.Commands.Automation.Model.Connection')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Justification = "The secret retrieved from the keyvault can't be decrypted by PS, so it has to be retrieved as plain text and then reconverted in secure string")]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("prd", "int", "dev", "sbx", "tt")]
        [Alias("Env")]
        [string] $Environment,

        [Parameter(Mandatory = $false)]
        [ValidateLength(2, 4)]
        [Alias("MrLoc")]
        [string]
        $MrLocation = 'WE',

        [Parameter(Mandatory = $True)]
        [Alias("AaName")]
        [string]$AutomationAccountName,

        [Parameter(Mandatory = $True)]
        [Alias("Rg")]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $false)]
        [Alias("Name")]
        [string]$ConnectionName = 'AzureRunAsConnection',

        [Parameter(Mandatory = $false)]
        [Alias("Subject")]
        [string]$CertificateSubject = 'CN=MRAzBdapAutomationConnection',

        [Parameter(Mandatory = $false)]
        [Alias("Co")]
        [string]$Company = 'MR',

        [Parameter(Mandatory = $false)]
        [Alias("App")]
        [string]$Application = 'BDAP'
    )

    begin { }

    process {
        $Subscription = (Get-AzContext).Subscription
        Write-Verbose "Subscription properties were collected"

        $SpName = Get-MRAzBdapServicePrincipalName -MrLocation $MrLocation -Environment $Environment -Suffix '-connection'
        Write-Verbose "Service Principal name: $SpName"

        $Sp = Get-AzADServicePrincipal -DisplayName $SpName -ErrorAction SilentlyContinue
        if ($Sp) {
            # Get certificate pfx
            Try {
                $CertObject = Get-AutomationCertificate -Environment $Environment -ServicePrincipalName $SpName
                Write-Verbose "Certificate for $($Sp.DisplayName) was found in key vault"
            }
            Catch {
                Throw "Certificate for $($Sp.DisplayName) not found. Exception: $($_.Exception)"
            }
            $FilePath = $CertObject.FilePath
            $Thumbprint = $CertObject.Thumbprint
            $CertPassword = $CertObject.Password | ConvertTo-SecureString -AsPlainText -Force
        }
        else {
            if ($PSCmdlet.ShouldProcess("CurrentUser certificate store", "Create Certificate")) {
                $Cert = New-MRAzBdapServicePrincipalCertificate -Subject $CertificateSubject -Store CurrentUser
                $Thumbprint = $Cert.Thumbprint
                Write-Verbose "Self-signed certificate was generated."
            }

            if ($PSCmdlet.ShouldProcess("Azure Active Directory", "Create Service Principal")) {
                $Sp = New-MRAzBdapServicePrincipalComponent -ComponentName $SpName -Certificate $Cert
                Write-Verbose "Service Principal $($Sp.DisplayName) with ApplicationID $($Sp.ApplicationId.Guid) was created."
                Start-Sleep -Seconds 30
                $retry = 0
                while ((-not (Get-AzADServicePrincipal -ObjectId $Sp.Id)) -and ($retry -lt 10)) {
                    Write-Verbose ("$retry : Wait for SP {0} to be created" -f $sp.id)
                    Start-Sleep -Seconds 10
                    $retry++
                }
            }

            if ($PSCmdlet.ShouldProcess("Temp folder", "Export pfx certificate")) {
                $CertPassword = ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | Sort-Object { Get-Random })[0..8] -join '' | ConvertTo-SecureString -AsPlainText -Force
                $FilePath = "$Env:Temp\$SpName.pfx"
                $null = Export-PfxCertificate -Cert $Cert.PSPath -FilePath $FilePath -Password $CertPassword
                Write-Verbose "Pfx certificate was exported."
            }

            if ($PSCmdlet.ShouldProcess("KeyVault", "Export pfx certificate")) {
                Add-AutomationCertificate -FilePath $FilePath -Password $CertPassword -Environment $Environment -ServicePrincipalName $SpName
            }
        }


        if ($PSCmdlet.ShouldProcess("Service Principal $($sp.DisplayName)", "Assign Contributor Role at subscription level")) {
            [string]$ApplicationId = $Sp.ApplicationId.Guid
            $InputObject = @{
                ApplicationId      = $ApplicationId
                RoleDefinitionName = 'Contributor'
                Scope              = "/subscriptions/$($Subscription.Id)"
            }

            # If a new Service Principal was created, AAD needs some time to propagate the change.
            $Assignment = Get-AzRoleAssignment -ObjectId $sp.Id -Scope ("/subscriptions/{0}" -f $Subscription.Id) -RoleDefinitionName "Contributor"
            if (-not $Assignment) {
                $Assignment = New-AzRoleAssignment @InputObject -Verbose -ErrorAction SilentlyContinue
                $retry = 0
                while ((!$Assignment) -and ($retry -lt 10)) {
                    Start-Sleep -Seconds 10
                    $Assignment = New-AzRoleAssignment @InputObject -Verbose -ErrorAction SilentlyContinue
                    $retry++
                }
            }
            if (!$Assignment) {
                Throw ("Role Assignment for Service Principal with ApplicationId: {0} and ObjectId: {1} failed. Deployment has stopped" -f $sp.ApplicationId.Guid, $sp.Id.Guid)
            }
        }
        Write-Verbose "Service Principal $($sp.DisplayName) was assigned Contributor role at subscription level"

        # Assigne keyvault reader permissions
        if ($PSCmdlet.ShouldProcess("Service Principal $($sp.DisplayName)", "Assign reader role on every key vault")) {
            $null = Set-MrAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName $Sp.DisplayName -Application $Application -Company $Company
            Write-Verbose "Access permissions set for all key vaults"
        }

        $InputObject = @{
            Name                  = $ConnectionName
            AutomationAccountName = $AutomationAccountName
            ResourceGroupName     = $ResourceGroupName
        }
        $Connection = Get-AzAutomationConnection @InputObject -ErrorAction SilentlyContinue
        if ($Connection) {
            $null = Remove-AzAutomationConnection @InputObject -Force
            Write-Verbose "Existing connection has been removed and will be replaced"
        }

        $FieldValues = @{"ApplicationId" = $sp.ApplicationId.Guid; "TenantId" = $Subscription.TenantId; "CertificateThumbprint" = $Thumbprint; "SubscriptionId" = $Subscription.Id }

        if ($PSCmdlet.ShouldProcess("Automation account $ComponentName", "Create Connection $ConnectionName")) {
            $Connection = New-AzAutomationConnection @InputObject -ConnectionTypeName 'AzureServicePrincipal' -ConnectionFieldValues $FieldValues
        }
        else {
            Write-Verbose "Name = $ConnectionName, AutomationAccountName = $AutomationAccountName, ResourceGroupName = $ResourceGroupName, ConnectionTypeName = 'AzureServicePrincipal'"
        }

        $InputObject.Name = 'AzureRunAsCertificate'
        $Certificate = Get-AzAutomationCertificate @InputObject -ErrorAction SilentlyContinue
        if ($Certificate) {
            $null = Remove-AzAutomationCertificate @InputObject
        }

        if ($PSCmdlet.ShouldProcess("Automation account $ComponentName", "Import certificate")) {
            $null = New-AzAutomationCertificate -Name 'AzureRunAsCertificate' -Password $CertPassword -Path $FilePath -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName
        }

        return $Connection
    }

    end { }

}