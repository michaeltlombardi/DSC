$TypeDefinitions = Get-Content -Path $PSScriptRoot/SchemaComposer.Types.cs -Raw
Add-Type -TypeDefinition $TypeDefinitions
