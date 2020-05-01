@{
    "KeyVaultPermissions"       = @{
        "Key"         = @(
            "get"
            "list"
            "decrypt"
            "unwrapkey"
            "verify"
        )
        "Secret"      = @(
            "get"
            "list"
        )
        "Certificate" = @(
            "get"
            "list"
            "getissuers"
            "listissuers"
        )
    }
    "StorageAccountName"        = @{
        TT  = 'mrbdapsbxweauto'
        SBP = 'mrbdapsbxweauto'
        SBX = 'mrbdapsbxweauto'
        DEP = 'mrbdapdevweauto'
        DEV = 'mrbdapdevweauto'
        INP = 'mrbdapintweauto'
        INT = 'mrbdapintweauto'
        PRP = 'mrbdapprdweauto'
        PRD = 'mrbdapprdweauto'
    }
    "AutomationModuleContainer" = "modules"
}