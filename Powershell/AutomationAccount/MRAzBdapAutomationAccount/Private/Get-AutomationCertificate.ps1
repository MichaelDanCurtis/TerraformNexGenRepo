function Get-AutomationCertificate {
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$ServicePrincipalName,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateSet("prd", "int", "dev", "sbx", "tt")]
        [Alias("Env")]
        [string] $Environment,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateLength(2, 4)]
        [Alias("MrLoc")]
        [string]$MrLocation = 'WE',

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$Company = 'MR',

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$Application = 'BDAP'
    )

    process {
        $VaultName = Get-MrAzBdapKvltName -Company $Company -Application $Application -Environment $Environment -MrLocation $MrLocation

        # Get password
        $CertPassword = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "$ServicePrincipalName-Password").SecretValueText

        # Get privage key
        $Certificate = Get-AzKeyVaultSecret -VaultName $VaultName -Name "$ServicePrincipalName-pfx"
        $CertificateBytes = [System.Convert]::FromBase64String($Certificate.SecretValueText)
        $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
        $certCollection.Import($CertificateBytes, $null, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
        $ExportedCertificate = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $CertPassword)
        $FilePath = "$Env:Temp\$ServicePrincipalName.pfx"
        [System.IO.File]::WriteAllBytes($FilePath, $ExportedCertificate)

        # Get thumbprint
        $Thumbprint = (Get-AzKeyVaultCertificate -VaultName $VaultName -Name "$ServicePrincipalName-pfx").Thumbprint

        $CertObject = @{
            FilePath   = $FilePath
            Thumbprint = $Thumbprint
            Password   = $CertPassword
        }

        return $CertObject
    }
}
