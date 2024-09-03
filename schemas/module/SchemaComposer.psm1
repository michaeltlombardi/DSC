using module ./SchemaComposer.Types.psm1

function Get-KnownKeyword {
    [CmdletBinding()]
    [OutputType('SchemaComposer.Keywords.Known')]
    param(
        [string[]]$Name
    )

    begin {
        $knownKeywords = [SchemaComposer.Keywords.Known].GetEnumValues()
    }

    process {
        if ([string]::IsNullOrEmpty($Name)) {
            return $knownKeywords
        }

        foreach ($kwName in $Name) {
            if ($kwName -in $knownKeywords) {
                $kwName -as [SchemaComposer.Keywords.Known]
            } else {
                Write-Warning "$kwName isn't a known keyword."
            }
        }
    }
}
