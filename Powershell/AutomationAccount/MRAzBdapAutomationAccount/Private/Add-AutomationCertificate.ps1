function Add-AutomationCertificate {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateSet("prd", "int", "dev", "sbx", "tt")]
        [Alias("Env")]
        [string] $Environment,


        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$FilePath,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [SecureString]$Password,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [String]$ServicePrincipalName,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$Company = 'MR',

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$Application = 'BDAP',

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateLength(2, 4)]
        [Alias("MrLoc")]
        [string]$MrLocation = 'WE'
    )

    process {
        $VaultName = Get-MrAzBdapKvltName -Company $Company -Application $Application -Environment $Environment -MrLocation $MrLocation -ErrorAction Stop
        Write-Verbose "Target KeyVault: $VaultName"

        if ($PSCmdlet.ShouldProcess("KeyVault $VaultName", "Upload pfx certificate")) {
            $null = Import-AzKeyVaultCertificate -VaultName $VaultName -Name "$ServicePrincipalName-pfx" -FilePath $FilePath -Password $Password -ErrorAction Stop
            Write-Verbose "Pfx certificate uploaded to KeyVault $VaultName"
        }

        if ($PSCmdlet.ShouldProcess("KeyVault $VaultName", "Add certificate password secret")) {
            $null = Set-AzKeyVaultSecret -VaultName $VaultName -Name "$ServicePrincipalName-Password" -SecretValue $Password -ErrorAction Stop
            Write-Verbose "Certificate password uploaded to KeyVault $VaultName"
        }
    }
}
