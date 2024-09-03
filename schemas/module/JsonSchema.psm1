#region    Enumeration definitions
enum SchemaComposerKnownKeywordName : UInt16 {
    # core keywords
    anchor        = 01
    comment       = 02
    defs          = 03
    dynamicAnchor = 04
    dynamicRef    = 05
    id            = 06
    ref           = 07
    schema        = 08
    vocabulary    = 09
    # applicator keywords
    additionalProperties  = 10
    allOf                 = 11
    anyOf                 = 12
    contains              = 13
    dependentSchemas      = 14
    else                  = 15
    if                    = 16
    items                 = 17
    not                   = 18
    oneOf                 = 19
    patternProperties     = 20
    prefixItems           = 21
    properties            = 22
    propertyNames         = 23
    then                  = 24
    unevaluatedItems      = 25
    unevaluatedProperties = 26
    # content keywords
    contentEncoding  = 27
    contentMediaType = 28
    contentSchema    = 29
    # format  keywords
    format = 30
    # metadata keywords
    default     = 31
    deprecated  = 32
    description = 33
    examples    = 34
    readOnly    = 35
    title       = 36
    writeOnly   = 37
    # validation keywords
    const             = 38
    dependentRequired = 39
    enum              = 40
    exclusiveMaximum  = 41
    exclusiveMinimum  = 42
    maxContains       = 43
    maximum           = 44
    maxItems          = 45
    maxLength         = 46
    maxProperties     = 47
    minContains       = 48
    minimum           = 49
    minItems          = 50
    minLength         = 51
    minProperties     = 52
    multipleOf        = 53
    pattern           = 54
    required          = 55
    type              = 56
    uniqueItems       = 57
    # vscode keywords
    defaultSnippets          = 101
    errorMessage             = 102
    patternErrorMessage      = 103
    deprecationMessage       = 104
    enumDescriptions         = 105
    markdownEnumDescriptions = 106
    markdownDescription      = 107
    doNotSuggest             = 108
    suggestSortText          = 109
    allowComments            = 110
    allowTrailingCommas      = 111
}
enum SchemaComposerKeywordVSCodeName : UInt16 {
    defaultSnippets          = 101
    errorMessage             = 102
    patternErrorMessage      = 103
    deprecationMessage       = 104
    enumDescriptions         = 105
    markdownEnumDescriptions = 106
    markdownDescription      = 107
    doNotSuggest             = 108
    suggestSortText          = 109
    allowComments            = 110
    allowTrailingCommas      = 111
}

enum SchemaComposerKeywordCompatibleName : UInt16 {
    # core keywords
    anchor        = 01
    comment       = 02
    defs          = 03
    dynamicAnchor = 04
    dynamicRef    = 05
    id            = 06
    ref           = 07
    schema        = 08
    vocabulary    = 09
    # applicator keywords
    additionalProperties  = 10
    allOf                 = 11
    anyOf                 = 12
    contains              = 13
    dependentSchemas      = 14
    else                  = 15
    if                    = 16
    items                 = 17
    not                   = 18
    oneOf                 = 19
    patternProperties     = 20
    prefixItems           = 21
    properties            = 22
    propertyNames         = 23
    then                  = 24
    unevaluatedItems      = 25
    unevaluatedProperties = 26
    # content keywords
    contentEncoding  = 27
    contentMediaType = 28
    contentSchema    = 29
    # format  keywords
    format = 30
    # metadata keywords
    default     = 31
    deprecated  = 32
    description = 33
    examples    = 34
    readOnly    = 35
    title       = 36
    writeOnly   = 37
    # validation keywords
    const             = 38
    dependentRequired = 39
    enum              = 40
    exclusiveMaximum  = 41
    exclusiveMinimum  = 42
    maxContains       = 43
    maximum           = 44
    maxItems          = 45
    maxLength         = 46
    maxProperties     = 47
    minContains       = 48
    minimum           = 49
    minItems          = 50
    minLength         = 51
    minProperties     = 52
    multipleOf        = 53
    pattern           = 54
    required          = 55
    type              = 56
    uniqueItems       = 57
}

enum SchemaComposerKeywordCompatibleCoreName : UInt16 {
    anchor        = 01
    comment       = 02
    defs          = 03
    dynamicAnchor = 04
    dynamicRef    = 05
    id            = 06
    ref           = 07
    schema        = 08
    vocabulary    = 09
}

enum SchemaComposerKeywordCompatibleApplicatorName : UInt16 {
    additionalProperties  = 10
    allOf                 = 11
    anyOf                 = 12
    contains              = 13
    dependentSchemas      = 14
    else                  = 15
    if                    = 16
    items                 = 17
    not                   = 18
    oneOf                 = 19
    patternProperties     = 20
    prefixItems           = 21
    properties            = 22
    propertyNames         = 23
    then                  = 24
    unevaluatedItems      = 25
    unevaluatedProperties = 26
}

enum SchemaComposerKeywordCompatibleValidationName : UInt16 {
    const             = 38
    dependentRequired = 39
    enum              = 40
    exclusiveMaximum  = 41
    exclusiveMinimum  = 42
    maxContains       = 43
    maximum           = 44
    maxItems          = 45
    maxLength         = 46
    maxProperties     = 47
    minContains       = 48
    minimum           = 49
    minItems          = 50
    minLength         = 51
    minProperties     = 52
    multipleOf        = 53
    pattern           = 54
    required          = 55
    type              = 56
    uniqueItems       = 57
}

#endregion Enumeration definitions

#region    Class definitions

class SchemaComposerKeyword {
    static [System.Collections.Generic.Dictionary[
        string,
        SchemaComposerKeyword
    ]] $Registry

    static [System.Collections.ObjectModel.ReadOnlyCollection[
        SchemaComposerKeyword
    ]] $CompatibleKeywords

    static [System.Collections.ObjectModel.ReadOnlyCollection[
        SchemaComposerKeyword
    ]] $VSCodeKeywords

    static [System.Collections.Generic.List[
        SchemaComposerKeyword
    ]] $CustomKeywords

    static [System.Collections.Generic.List[
        SchemaComposerKeyword
    ]] $AllKeywords

    static [SchemaComposerKeyword] GetCompatibleKeyword([string]$name) {
        return [SchemaComposerKeyword]::CompatibleKeywords.Find({
            param([SchemaComposerKeyword]$kw)

            return $kw.Name.TrimStart('$') -eq $name.TrimStart('$')
        })
    }

    static [SchemaComposerKeyword] GetVSCodeKeyword([string]$name) {
        return [SchemaComposerKeyword]::VSCodeKeywords.Find({
            param([SchemaComposerKeyword]$kw)

            return $kw.Name -eq $name
        })
    }

    static [SchemaComposerKeyword] GetCustomKeyword([string]$name) {
        return [SchemaComposerKeyword]::CustomKeywords.Find({
            param([SchemaComposerKeyword]$kw)

            return $kw.Name -eq $name
        })
    }

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        <#Category#> 'PSUseDeclaredVarsMoreThanAssignments',
        <#CheckId#>  '',
        Justification = 'TryParse assigns a value to the ref $result without operating on it.'
    )]
    static [bool] TryParse([string]$name, [ref]$result) {
        if ($null -ne [SchemaComposerKeyword]::Registry[$name]) {
            $result = [SchemaComposerKeyword]::Registry[$name]
            return $true
        }
        if ($null -ne [SchemaComposerKeyword]::GetCompatibleKeyword($name)) {
            result = [SchemaComposerKeyword]::GetCompatibleKeyword($name)
            return $true
        }
        if ($null -ne [SchemaComposerKeyword]::GetVSCodeKeyword($name)) {
            result = [SchemaComposerKeyword]::GetVSCodeKeyword($name)
            return $true
        }
        if ($null -ne [SchemaComposerKeyword]::GetCustomKeyword($name)) {
            result = [SchemaComposerKeyword]::GetCustomKeyword($name)
            return $true
        }

        return $false
    }

    static [SchemaComposerKeyword] Parse([string]$name) {
        [ref]$kw = $null
        if ([SchemaComposerKeyword]::TryParse($name)) {
            return $kw
        }

        throw "Unable to parse keyword '$name'"
    }

    hidden static [void] InitializeCompatibleKeywords([bool]$force) {
        [SchemaComposerKeywordCompatibleName]::Initialize($force)
    }
    hidden static [void] InitializeCompatibleKeywords() {
        [SchemaComposerKeywordCompatibleName]::Initialize($false)
    }

    hidden static [void] InitializeVSCodeKeywords([bool]$force) {
        if (-not $force -and $null -ne [SchemaComposerKeyword]::VSCodeKeywords) {
            return
        }
        $keywords = [SchemaComposerUtil]::NewList([SchemaComposerKeyword])
        foreach ($keyword in [SchemaComposerKeywordVSCodeName].GetEnumValues()) {
            $keywords.Add(
                [SchemaComposerKeyword]::new($keyword)
            )
        }
        [SchemaComposerKeyword]::VSCodeKeywords = $keywords.AsReadOnly()
    }
    hidden static [void] InitializeVSCodeKeywords() {
        [SchemaComposerKeyword]::InitializeVSCodeKeywords($false)
    }
    hidden static [void] InitializeCustomKeywords([bool]$force) {
        if (-not $force -and $null -ne [SchemaComposerKeyword]::CustomKeywords) {
            return
        }
        [SchemaComposerKeyword]::CustomKeywords = [SchemaComposerUtil]::NewList(
            [SchemaComposerKeyword]
        )
    }
    hidden static [void] InitializeRegistry([bool]$force) {
        if (-not $force -and $null -ne [SchemaComposerKeyword]::Registry) {
            return
        }
        [SchemaComposerKeyword]::InitializeCompatibleKeywords()
        [SchemaComposerKeyword]::InitializeVSCodeKeywords()
        [SchemaComposerKeyword]::InitializeCustomKeywords()

        [SchemaComposerKeyword]::Registry = [SchemaComposerUtil]::NewDictionary(
            [SchemaComposerKeyword]
        )

        foreach ($keyword in [SchemaComposerKeyword]::CompatibleKeywords) {
            [SchemaComposerKeyword]::Registry.Add(
                $keyword.Name,
                $keyword
            )
        }

        foreach ($keyword in [SchemaComposerKeyword]::VSCodeKeywords) {
            [SchemaComposerKeyword]::Registry.Add(
                $keyword.Name,
                $keyword
            )
        }

        foreach ($keyword in [SchemaComposerKeyword]::CustomKeywords) {
            [SchemaComposerKeyword]::Registry.Add(
                $keyword.Name,
                $keyword
            )
        }
    }

    static [UInt16] GetNextAvailableKeywordValue() {
        [uint16]$v = 1001
        if ([SchemaComposerKeyword]::CustomKeywords.Count -eq 0) {
            return $v
        }
        $highestValue = [SchemaComposerKeyword]::CustomKeywords
        | Sort-Object -Descending -Stable -Property Value
        | Select-Object -ExpandProperty Value -First 1

        return ($highestValue + 1)
    }

    [string]                $Name
    [System.Nullable[uint]] $Value
    [type]                  $JsonSchemaDotNetKeywordType
    [bool]                  $IsReadOnly

    hidden [void] SetAsReadOnly([bool]$quiet) {
        if (
            $this.IsReadOnly() -or
            -not $this.ValidateCanSetAsReadOnly($quiet)
        ) {
            return
        }

        $members = $this | Get-Member

        $scriptProperties = $members
        | Where-Object -FilterScript { $_.MemberType -eq 'ScriptProperty' }
        | Select-Object -ExpandProperty Name

        $scriptMethods = $members
        | Where-Object -FilterScript { $_.MemberType -eq 'ScriptMethod' }
        | Select-Object -ExpandProperty Name

        if ($scriptProperties -notcontains 'Name') {
            $readOnlyName = $this.Name.Clone()
            $memberParams = @{
                Force      = $true
                MemberType = 'ScriptProperty'
                Name       = 'Name'
                Value      = {
                    [OutputType([string])]
                    param()

                    return $readOnlyName
                }.GetNewClosure()
            }
            $this | Add-Member @memberParams

            return
        }

        if ($scriptProperties -notcontains 'Value') {
            $readOnlyValue = $this.Value
            $memberParams = @{
                Force      = $true
                MemberType = 'ScriptProperty'
                Name       = 'Value'
                Value      = {
                    [OutputType([UInt16])]
                    param()

                    return $readOnlyValue
                }.GetNewClosure()
            }
            $this | Add-Member @memberParams
        }

        if ($scriptProperties -notcontains 'JsonSchemaDotNetKeywordType') {
            $readOnlyType = $this.JsonSchemaDotNetKeywordType
            $memberParams = @{
                Force      = $true
                MemberType = 'ScriptProperty'
                Name       = 'JsonSchemaDotNetKeywordType'
                Value      = {
                    [OutputType([type])]
                    param()

                    return $readOnlyType
                }.GetNewClosure()
            }
            $this | Add-Member @memberParams
        }

        if ($scriptMethods -notcontains 'IsCompatible') {
            $readOnlyIsCompatible = $this.IsCompatible()
            $memberParams         = @{
                Force      = $true
                MemberType = 'ScriptMethod'
                Name       = 'IsCompatible'
                Value      = {
                    [OutputType([bool])]
                    param()

                    return $readOnlyIsCompatible
                }.GetNewClosure()
            }
            $this | Add-Member @memberParams
        }

        if ($scriptMethods -notcontains 'IsCompatibleCore') {
            $readOnlyIsCompatibleCore = $this.IsCompatibleCore()
            $memberParams         = @{
                Force      = $true
                MemberType = 'ScriptMethod'
                Name       = 'IsCompatibleCore'
                Value      = {
                    [OutputType([bool])]
                    param()

                    return $readOnlyIsCompatibleCore
                }.GetNewClosure()
            }
            $this | Add-Member @memberParams
        }

        if ($scriptMethods -notcontains 'IsVSCode') {
            $readOnlyIsVSCode = $this.IsVSCode()
            $memberParams         = @{
                Force      = $true
                MemberType = 'ScriptMethod'
                Name       = 'IsVSCode'
                Value      = {
                    [OutputType([bool])]
                    param()

                    return $readOnlyIsVSCode
                }.GetNewClosure()
            }
            $this | Add-Member @memberParams
        }

        if ($scriptMethods -notcontains 'IsCustom') {
            $readOnlyIsCustom = $this.IsCustom()
            $memberParams         = @{
                Force      = $true
                MemberType = 'ScriptMethod'
                Name       = 'IsCustom'
                Value      = {
                    [OutputType([bool])]
                    param()

                    return $readOnlyIsCustom
                }.GetNewClosure()
            }
            $this | Add-Member @memberParams
        }

        if ($scriptProperties -notcontains 'IsReadOnly') {
            $memberParams         = @{
                Force      = $true
                MemberType = 'ScriptProperty'
                Name       = 'IsReadOnly'
                Value      = {
                    [OutputType([bool])]
                    param()

                    return $true
                }
            }
            $this | Add-Member @memberParams
        }
    }

    hidden [void] SetAsReadOnly() {
        $this.SetAsReadOnly($false)
    }

    hidden [bool] ValidateCanSetAsReadOnly([bool]$quiet) {
        $nameNotDefined = -not [string]::IsNullOrWhiteSpace($this.Name)
        if ($quiet -and $nameNotDefined) {
            return $false
        } elseif ($nameNotDefined) {
            $message = @(
                'Keyword is invalid.'
                'The Name property must be defined as'
                'a string containing non-whitespace characters.'
            ) -join ' '
            throw $message
        }

        return $true
    }
    hidden [void] ValidateCanSetAsReadOnly() {
        $this.ValidateCanSetAsReadOnly($false)
    }

    [string] ToString() {
        return $this.Name
    }

    [bool] IsCompatible() {
        return $_.Value -in [SchemaComposerKeywordCompatibleName].GetEnumValues()
    }

    hidden [bool] IsCompatibleCore() {
        return $this.Value -in [SchemaComposerKeywordCompatibleCoreName].GetEnumValues()
    }

    [bool] IsVSCode() {
        return $this.Value -in [SchemaComposerKeywordVSCodeName].GetEnumValues()
    }
    [bool] IsCustom() {
        return $this.Value -eq 0 -or $this -in [SchemaComposerKeyword]::CustomKeywords
    }

    [bool] IsRegistered() {
        return $this.Name -in [SchemaComposerKeyword]::Registry.Keys
    }
    [void] Register() {
        if ($this.IsCompatible() -or $this.IsVSCode()) {
            return
        }
    }

    [SchemaComposerKeyword] Clone() {
        $clone = [SchemaComposerKeyword]::new()
        $clone.Name  = $this.Name.Clone()
        $clone.Value = $this.Value
        $clone.JsonSchemaDotNetKeywordType = $this.JsonSchemaDotNetKeywordType

        return $clone
    }

    SchemaComposerKeyword() {
    }

    SchemaComposerKeyword([SchemaComposerKeywordVSCodeName]$keyword) {
        $this.Name  = $keyword
        $this.Value = $keyword
    }

    SchemaComposerKeyword([string]$name) {
        [SchemaComposerKeyword]$parsed = $null
        if ([SchemaComposerKeyword]::TryParse($name, [ref]$parsed)) {
            $this.Name    = $parsed.Name
            $this.Value   = $parsed.Value
            $this.JsonSchemaDotNetKeywordType = $parsed.JsonSchemaDotNetKeywordType
        } else {
            $this.Name = $name
        }
    }
}

class SchemaComposerKeywordCompatible : SchemaComposerKeyword {
    #region Hide base class collections
    hidden static $CompatibleKeywords
    hidden static $VSCodeKeywords
    hidden static $CustomKeywords
    hidden static $AllKeywords
    #endregion Hide base class collections
    static [System.Collections.ObjectModel.ReadOnlyCollection[
        SchemaComposerKeywordCompatible
    ]] $List

    hidden static [void] Initialize([bool]$force) {
        if (-not $force -and $null -ne [SchemaComposerKeywordCompatible]::List) {
            return
        }
        $keywords = [SchemaComposerUtil]::NewList([SchemaComposerKeywordCompatible])
        foreach ($keyword in [SchemaComposerKeywordCompatibleName].GetEnumValues()) {
            $keywords.Add(
                [SchemaComposerKeywordCompatible]::new($keyword)
            )
        }
        [SchemaComposerKeywordCompatible]::List     = $keywords.AsReadOnly()
        [SchemaComposerKeyword]::CompatibleKeywords = [SchemaComposerKeywordCompatible]::List
        foreach ($keyword in [SchemaComposerKeywordCompatible]::List) {
            [SchemaComposerKeyword]::Registry.Add($keyword.Name, $keyword)
        }
    }
    hidden static [void] Initialize() {
        [SchemaComposerKeywordCompatible]::Initialize($false)
    }

    [ValidateRange(1, 99)][Uint16]$Value

    hidden [void] DefineAsKeyword([SchemaComposerKeywordCompatibleName]$keyword) {
        if ($keyword -in [SchemaComposerKeywordCompatibleCoreName].GetEnumValues()) {
            $this.Name = '${0}' -f $keyword
        } else {
            $this.Name = $keyword
        }
        $this.Value = $keyword
        $this.JsonSchemaDotNetKeywordType = [type]('Json.Schema.${0}Keyword' -f $keyword)
        $this.SetAsReadOnly()
    }

    SchemaComposerKeywordCompatible([SchemaComposerKeywordCompatibleName]$keyword) {
        $this.DefineAsKeyword($keyword)
    }

    SchemaComposerKeywordCompatible([string]$name) {
        [SchemaComposerKeywordCompatibleName]$keyword = $name.TrimStart('$')

        $this.DefineAsKeyword($keyword)
    }
}

class SchemaComposerKeywordVSCode : SchemaComposerKeyword {
    #region    Static properties
    #region Hide base class collections
    hidden static $CompatibleKeywords
    hidden static $VSCodeKeywords
    hidden static $CustomKeywords
    hidden static $AllKeywords
    #endregion Hide base class collections
    static [System.Collections.ObjectModel.ReadOnlyCollection[
        SchemaComposerKeywordVSCode
    ]] $List
    #endregion Static properties
    #region    Static methods
    hidden static [void] Initialize([bool]$force) {
        if (-not $force -and $null -ne [SchemaComposerKeywordVSCode]::List) {
            return
        }
        $keywords = [SchemaComposerUtil]::NewList([SchemaComposerKeywordVSCode])
        foreach ($keyword in [SchemaComposerKeywordVSCodeName].GetEnumValues()) {
            $keywords.Add(
                [SchemaComposerKeywordVSCode]::new($keyword)
            )
        }
        [SchemaComposerKeywordVSCode]::List     = $keywords.AsReadOnly()
        [SchemaComposerKeyword]::VSCodeKeywords = [SchemaComposerKeywordVSCode]::List
        foreach ($keyword in [SchemaComposerKeywordVSCode]::List) {
            [SchemaComposerKeyword]::Registry.Add($keyword.Name, $keyword)
        }
    }
    hidden static [void] Initialize() {
        [SchemaComposerKeywordVSCode]::Initialize($false)
    }
    #endregion Static methods
    [ValidateRange(101, 199)][UInt16]$Value

    hidden [void] DefineAsKeyword([SchemaComposerKeywordVSCode]$keyword) {
        $this.Name  = $keyword
        $this.Value = $keyword
        $this.SetAsReadOnly()
    }

    SchemaComposerKeywordVSCode([SchemaComposerKeywordVSCode]$keyword) {
        $this.DefineAsKeyword($keyword)
    }

    SchemaComposerKeywordVSCode([string]$name) {
        [SchemaComposerKeywordVSCode]$keyword = $name

        $this.DefineAsKeyword($keyword)
    }
}

class SchemaComposerKeywordCustom : SchemaComposerKeyword {
    [ValidateRange(1001, [UInt16]::MaxValue)][Uint16]$Value
}

class SchemaComposerEnumExtensions {
    hidden static [string[]] $CompatibleKeywords
    hidden static [string[]] $DollarPrefixedKeywords = @(
        'anchor'
        'comment'
        'defs'
        'dynamicAnchor'
        'dynamicRef'
        'id'
        'ref'
        'schema'
        'vocabulary'
    )
    static [string] GetCompatibleKeywordJson([SchemaComposerKeywordCompatibleName]$keyword) {
        return ($keyword -in [SchemaComposerEnumExtensions]::DollarPrefixedKeywords)
    }
    static [System.Collections.Generic.List[string]] GetCompatibleKeywords() {
        if ($null -ne [SchemaComposerEnumExtensions]::CompatibleKeywords) {
            $list = [SchemaComposerUtil]::NewList([string])
            $core = [SchemaComposerKeywordCompatibleCoreName].GetEnumNames()
            foreach ($keyword in [SchemaComposerKeywordCompatibleName].GetEnumNames()) {
                $template = $keyword -in $core ? '${0}' : '{0}'
                $list.Add($template -f $keyword)
            }

            [SchemaComposerEnumExtensions]::CompatibleKeywords = $list
        }
        
        return [SchemaComposerEnumExtensions]::CompatibleKeywords
    }
    static [string[]] SchemaComposerKeywordCompatibleNameGetJsonKeywords([psobject]$keyword) {
        return [SchemaComposerEnumExtensions]::GetCompatibleKeywords()
    }

    static [string] SchemaComposerKeywordCompatibleNameGetJsonKeywords([psobject]$keyword) {
        $template = $keyword -in [SchemaComposerEnumExtensions]::DollarPrefixedKeywords ?
                    '${0}' :
                    '{0}'

        return $template -f $keyword
    }

    static [void] DefineSchemaComposerKeywordCompatibleNameExtensions() {
        $typeName = [SchemaComposerKeywordCompatibleName].FullName
        $typeData = $typeName | Get-TypeData
        if ($typeData.Members.Keys -notcontains 'GetJsonKeywords') {
            $memberDefinition = @{
                TypeName   = $typeName
                MemberName = 'GetJsonKeywords'
                MemberType = 'CodeMethod'
                Value      = [SchemaComposerEnumExtensions].GetMethod(
                    'SchemaComposerKeywordCompatibleNameGetJsonKeywords'
                )
            }
            Update-TypeData @memberDefinition
        }
        if ($typeData.Members.Keys -notcontains 'ToJsonKeyword') {
            $memberDefinition = @{
                TypeName   = $typeName
                MemberName = 'ToJsonKeyword'
                MemberType = 'CodeMethod'
                Value      = [SchemaComposerEnumExtensions].GetMethod(
                    'SchemaComposerKeywordCompatibleNameToJsonKeyword'
                )
            }
            Update-TypeData @memberDefinition
        }

        [SchemaComposerEnumExtensions]::SchemaComposerKeywordCompatibleNameGetJsonKeywords()
    }

    static SchemaComposerEnumExtensions() {
    }
}

class SchemaComposerUtil {
    static [System.Collections.IDictionary] NewDictionary([type]$keyType, [type]$valueType) {
        [type]$dictType = 'System.Collections.Generic.Dictionary[{0}, {1}]' -f @(
            $keyType.FullName
            $valueType.FullName
        )
        return $dictType::new([System.OrdinalComparer]::InvariantCultureIgnoreCase)
    }

    static [System.Collections.IDictionary] NewDictionary([type]$valueType) {
        [type]$dictType = 'System.Collections.Generic.Dictionary[string, {0}]' -f @(
            $valueType.FullName
        )
        return $dictType::new([System.OrdinalComparer]::InvariantCultureIgnoreCase)
    }

    static [System.Collections.Specialized.OrderedDictionary] NewOrderedDictionary() {
        return [System.Collections.Specialized.OrderedDictionary]::new(
            [System.OrdinalComparer]::InvariantCultureIgnoreCase
        )
    }

    #region    NewHashSet
    static [System.Collections.IEnumerable] NewHashSet([type]$valueType) {
        [type]$setType = 'System.Collections.Generic.HashSet[{0}]' -f @(
            $valueType.FullName
        )
        return $setType::new([System.OrdinalComparer]::InvariantCultureIgnoreCase)
    }
    static [System.Collections.IEnumerable] NewHashSet() {
        return [System.Collections.Generic.HashSet[string]]::new(
            [System.OrdinalComparer]::InvariantCultureIgnoreCase
        )
    }
    #endregion NewHashSet

    #region    NewList
    static [System.Collections.IList] NewList([type]$itemType) {
        [type]$listType = 'System.Collections.Generic.List[{0}]' -f $itemType.FullName
        return $listType::new()
    }
    static [System.Collections.Generic.Dictionary[string,string]] NewStringDictionary() {
        return [SchemaComposerUtil]::NewDictionary([string])
    }
    static [System.Collections.Generic.List[string]] NewStringList() {
        return [SchemaComposerUtil]::NewList([string])
    }
    #endregion NewList
    static [ordered] ParseYaml([System.IO.FileInfo]$yamlFile) {
        try {
            $data = Get-Content -Raw -Path $yamlFile.FullName
            | yayaml\ConvertFrom-Yaml
        } catch {
            throw [SchemaComposerErrors]::NewRecord('DataFile.ReadFailure', $yamlFile, $_.Exception)
        }

        return $data
    }
    static [ordered] ParseYaml([string]$yamlContent) {
        try {
            $data = $yamlContent | yayaml\ConvertFrom-Yaml
        } catch {
            throw [SchemaComposerErrors]::NewRecord('DataFile.ReadFailure', $yamlContent, $_.Exception)
        }

        return $data
    }
    static [ordered] Parsejson([System.IO.FileInfo]$jsonFile) {
        try {
            $data = Get-Content -Raw -Path $jsonFile.FullName
            | ConvertFrom-Json
            | ConvertTo-OrderedDictionary
        } catch {
            throw [SchemaComposerErrors]::NewRecord('DataFile.ReadFailure', $jsonFile, $_.Exception)
        }

        return $data
    }
    static [ordered] Parsejson([string]$jsonContent) {
        try {
            $data = $jsonContent
            | ConvertFrom-Json
            | ConvertTo-OrderedDictionary
        } catch {
            throw [SchemaComposerErrors]::NewRecord('DataFile.ReadFailure', $jsonContent, $_.Exception)
        }

        return $data
    }
}

class SchemaComposerErrorDefinition {
    [string] $ID
    [type]   $ExceptionType
    [string] $Message
    [System.Management.Automation.ErrorCategory] $Category

    [void] SetID([string]$value) {
        $this.ID = $value -match '^SchemaComposer' ? $value : 'SchemaComposer.{0}' -f $value
    }

    [System.Management.Automation.ErrorRecord] Generate([object]$targetObject) {
        return [System.Management.Automation.ErrorRecord]::new(
            $this.ExceptionType::new($this.Message),
            $this.ID,
            $this.Category,
            $targetObject
        )
    }


    [System.Management.Automation.ErrorRecord] Generate([object]$targetObject, [System.Exception]$innerException) {
        return [System.Management.Automation.ErrorRecord]::new(
            $this.ExceptionType::new($this.Message, $innerException),
            $this.ID,
            $this.Category,
            $targetObject
        )
    }
}
class SchemaComposerErrors {
    static [hashtable] $Table = @{
        Configuration = @{
            FileNotFound = [SchemaComposerErrorDefinition]@{
                ExceptionType = [System.IO.FileNotFoundException]
                Category      = [System.Management.Automation.ErrorCategory]::ObjectNotFound
                Message       = @(
                    "Couldn't find a valid configuration file in the specified path."
                    "Specify the path to a configuration file or to a folder containing one of the following files:"
                ) -join ' '
            }
            PathNotExist = [SchemaComposerErrorDefinition]@{
                ExceptionType = [System.IO.FileNotFoundException]
                Category      = [System.Management.Automation.ErrorCategory]::ObjectNotFound
                Message       = @(
                    "Specified configuration file path doesn't exist."
                ) -join ' '
            }
        }
        DataFile = @{
            InvalidFileExtension = [SchemaComposerErrorDefinition]@{
                ExceptionType = [System.ArgumentException]
                Category      = [System.Management.Automation.ErrorCategory]::InvalidArgument
                Message       = @(
                    "Specified filepath doesn't have a valid JSON or YAML extension."
                    "Data files must have one of the following file extensions:"
                    "'.json', '.jsonc', '.yaml', or '.yml'"
                ) -join ' '
            }
        }
    }

    static [SchemaComposerErrorDefinition] Lookup([string]$dotPath) {
        $segments = $dotPath -split '\.'
        $data     = [SchemaComposerErrors]::Table

        foreach ($segment in $segments) {
            if ($segment -eq 'SchemaComposer') {
                continue
            }

            if (
                $data -isnot [hashtable] -or
                -not $data.ContainsKey($segment)
            ) {
                return $null
            }

            $data = $data[$segment]
        }

        $definition = $data -as [SchemaComposerErrorDefinition]

        if ($null -ne $definition) {
            $definition.SetID($dotPath)
        }

        return $definition
    }

    static [System.Management.Automation.ErrorRecord] NewRecord([string]$id, [object]$targetObject) {
        return [SchemaComposerErrors]::Lookup($id).Generate($targetObject)
    }

    static [System.Management.Automation.ErrorRecord] NewRecord([string]$id, [object]$targetObject, [System.Exception]$innerException) {
        return [SchemaComposerErrors]::Lookup($id).Generate($targetObject, $innerException)
    }
}

class SchemaComposerTemplateVariable {
    [string] $Name
    [regex]  $Pattern
    [string] $Value

    [string] ToString() {
        return '{0} => {1}' -f $this.Pattern, $this.Value
    }

    [regex] GetPatternFromName() {
        return [regex]::new(
            [regex]::Escape('<{0}>' -f $this.Name.ToUpperInvariant()),
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }

    SchemaComposerTemplateVariable() {}
    SchemaComposerTemplateVariable([string]$name, [string] $value) {
        $this.Name    = $name
        $this.Value   = $value
        $this.Pattern = $this.GetPatternFromName()
    }
}

class SchemaComposerConfigurationTemplating {
    static [SchemaComposerConfigurationTemplating] CreateFrom([hashtable]$data) {
        $definition     = [SchemaComposerConfigurationTemplating]::new()

        $variablesData  = $data['variables']
        foreach ($name in $variablesData.Keys) {
            $value = $variablesData[$name]

            $definition.Variables.Add(
                $name,
                [SchemaComposerTemplateVariable]::new($name, $value)
            )
        }

        return $definition
    }

    [System.Collections.Generic.Dictionary[string,SchemaComposerTemplateVariable]]
    $Variables

    [SchemaComposerTemplateVariable] GetVariable([string]$name) {
        return $this.Variables[$name]
    }

    [regex] GetPattern([string]$variableName) {
        return $this.GetVariable($variableName).Pattern
    }
    [string] GetReplacementValue([string]$variableName) {
        return $this.GetVariable($variableName).Value
    }

    [string] Replace([string]$content, [string]$variableName) {
        return $this.GetPattern($variableName).Replace(
            $content,
            $this.GetReplacementValue($variableName)
        )
    }

    [string] Replace([string]$content) {
        $munged = $content.Clone()
        foreach ($variable in $this.Variables.Keys) {
            $munged = $this.Replace($munged, $variable)
        }
        return $munged
    }
    [System.Collections.Specialized.OrderedDictionary] Resolve(
        [System.Collections.Specialized.OrderedDictionary]$data,
        [string]$variableName,
        [bool]$clone
    ) {
        $resolvingParams = @{
            TemplateVariable = $this.GetVariable($variableName)
            Clone            = $clone
        }

        Write-Warning "Replacing variable '$variableName' in data as: $($resolvingParams.TemplateVariable)"

        return ($data | Resolve-TemplateVariable @resolvingParams)
    }

    [System.Collections.Specialized.OrderedDictionary] Resolve(
        [System.Collections.Specialized.OrderedDictionary]$data,
        [string]$variableName
    ) {
        return $this.Resolve($data, $variableName, $false)
    }
    [System.Collections.Specialized.OrderedDictionary] Resolve(
        [System.Collections.Specialized.OrderedDictionary]$data,
        [bool]$clone
    ) {
        Write-Warning "Replacing all variables in data..."
        $resolvingParams = @{
            TemplateVariable = $this.Variables.Values
            Clone            = $clone
        }
        return ($data | Resolve-TemplateVariable @resolvingParams)
    }

    [System.Collections.Specialized.OrderedDictionary] Resolve(
        [System.Collections.Specialized.OrderedDictionary]$data
    ) {
        return $this.Resolve($data, $false)
    }

    [void] Initialize() {
        $this.Variables ??= [SchemaComposerUtil]::NewDictionary([string])
        # [System.Collections.Generic.Dictionary[string,string]]::new()
    }

    [bool] IsEmpty() {
        return ($this.Variables.Keys.Count -lt 1)
    }

    [string] ToString() {
        $names = $this.Variables.Keys

        if ($names.Count -eq 0) {
            return '{}'
        }

        $padTo   = 1
        foreach ($name in $names) {
            if ($name.Length -gt $padTo) {
                $padTo = $name.Length
            }
        }
        $padTo += 2

        $lines  = [SchemaComposerUtil]::NewList([string])
        # [System.Collections.Generic.List[string]]::new()
        foreach ($name in $names) {
            $prefix = ('<{0}>' -f $name.ToUpperInvariant()).PadRight($padTo)
            $suffix = "'{0}'"  -f $this.Variables[$name]
            $line   = '{0} => {1}' -f $prefix, $suffix
            $lines.Add($line)
        }

        return ($lines -join "`n")
    }

    SchemaComposerConfigurationTemplating() {
        $this.Initialize()
    }
}

class SchemaComposerConfigurationDirectories {
    static [SchemaComposerConfigurationDirectories] CreateFrom([hashtable]$data) {
        if ($null -eq $data) {
            return [SchemaComposerConfigurationDirectories]::new()
        }

        return [SchemaComposerConfigurationDirectories]::new(
            $data['root'],
            $data['source'],
            $data['output']
        )
    }

    [string] $Root
    [string] $Source
    [string] $Output
    [string] $Bundles

    [void] Initialize([bool]$force) {
        if ($force -or [string]::IsNullOrWhiteSpace($this.Root)) {
            $this.Root = Get-Location
        }
        if ($force -or [string]::IsNullOrWhiteSpace($this.Source)) {
            $this.Source = [System.IO.Path]::GetFullPath('src', $this.Root)
        }
        if ($force -or [string]::IsNullOrWhiteSpace($this.Output)) {
            $this.Output = [System.IO.Path]::GetFullPath('out', $this.Root)
        }
    }
    [void] Initialize() {
        $this.Initialize($false)
    }

    [string] ResolveRoot() {
        try {
            $resolved = Resolve-Path -Path $this.Root -ErrorAction Stop
            return $resolved
        } catch [System.Management.Automation.ItemNotFoundException] {
            throw $_
        }
    }

    [string] ResolveSource() {
        $resolving = @{
            Path        = $this.Source
            ErrorAction = 'Stop'
        }

        if (-not [System.IO.Path]::IsPathFullyQualified($this.Source)) {
            $resolving.Add('RelativeBasePath', $this.Root)
        }

        try {
            $resolved = Resolve-Path @resolving
            return $resolved
        } catch {
            throw $_
        }
        return $null
    }
    [string] ResolveOutput([bool]$strict) {
        $resolving = @{
            Path        = $this.Output
            ErrorAction = 'Stop'
        }

        if (-not [System.IO.Path]::IsPathFullyQualified($this.Output)) {
            $resolving.Add('RelativeBasePath', $this.Root)
        }

        try {
            $resolved = Resolve-Path @resolving
            return $resolved
        } catch {
            if ($strict) {
                throw $_
            }

            return $_.TargetObject
        }
    }

    [void] Resolve([bool]$strict) {
        $this.Initialize()
        $this.ResolveRoot()
        $this.ResolveSource()
        $this.ResolveOutput($strict)
    }
    [void] Resolve() {
        $this.Resolve($true)
    }

    [void] SetRoot([string]$path) {
        if ([string]::IsNullOrWhiteSpace($path)) {
            $this.Root = Get-Location
            return
        }

        $this.Root = [System.IO.Path]::IsPathFullyQualified($path) ?
                     $path :
                     [System.IO.Path]::GetFullPath($path)
    }
    [void] SetSource([string]$path) {
        if ([string]::IsNullOrWhiteSpace($path)) {
            return
        }

        $this.Initialize()
        $this.Source = [System.IO.Path]::IsPathFullyQualified($path) ?
                       $path :
                       [System.IO.Path]::GetFullPath($path, $this.Root)
    }
    [void] SetOutput([string]$path) {
        if ([string]::IsNullOrWhiteSpace($path)) {
            return
        }

        $this.Initialize()
        $this.Output = [System.IO.Path]::IsPathFullyQualified($path) ?
                       $path :
                       [System.IO.Path]::GetFullPath($path, $this.Root)
    }

    [string] ToString() {
        return @(
            ""
            "Root   : '$($this.Root)'"
            "Source : '$($this.Source)'"
            "Output : '$($this.Output)'"
        ) -join "`n"
    }

    SchemaComposerConfigurationDirectories() {
        $this.Initialize()
    }

    SchemaComposerConfigurationDirectories([string]$rootFolderPath) {
        $this.SetRoot($rootFolderPath)
        $this.Initialize()
    }
    SchemaComposerConfigurationDirectories(
        [string]$rootFolderPath,
        [string]$sourceFolderPath,
        [string]$outputFolderPath
    ) {
        $this.SetRoot($rootFolderPath)
        $this.SetSource($sourceFolderPath)
        $this.SetOutput($outputFolderPath)
        $this.Initialize()
    }
}

class SchemaComposerConfigurationBundleDefinition {
    static [SchemaComposerConfigurationBundleDefinition] CreateFrom([hashtable]$data) {
        $definition = [SchemaComposerConfigurationBundleDefinition]::new()
        if ($data.ContainsKey('source_file_path')) {
            $definition.SourceFilePath = $data['source_file_path']
        }
        if ($data.ContainsKey('output_base_name')) {
            $definition.OutputBaseName = $data['output_base_name']
        }
        if ($data.ContainsKey('output_folder_path')) {
            $definition.OutputFolderPath = $data['output_folder_path']
        }
        if ($data.ContainsKey('formats')) {
            $definition.OutputFormats = $data['formats']
        }

        return $definition
    }

    [string]   $OutputBaseName
    [string]   $SourceFilePath
    [string]   $OutputFolderPath
    [string[]] $OutputFormats
}

class SchemaComposerConfiguration {
    #region    Static properties
    static
    [SchemaComposerConfiguration]
    $Current

    static
    [System.Collections.Generic.List[SchemaComposerConfiguration]]
    $Available

    hidden
    static
    [string[]]
    $FileNames = @(
        '.schemas.config.yaml'
        '.schemas.config.yml'
        '.schemas.config.jsonc'
        '.schemas.config.json'
    )

    #endregion Static properties

    #region    Static methods
    static [string[]] GetConfigurationFileNames([string]$parentFolderPath) {
        if ([string]::IsNullOrWhiteSpace($parentFolderPath)) {
            return [SchemaComposerConfiguration]::FileNames
        }

        return [SchemaComposerConfiguration]::FileNames
        | ForEach-Object -Process { Join-Path -Path $parentFolderPath -ChildPath $_ }
    }
    #region    FindConfigurationFile
    static [System.IO.FileInfo] FindConfigurationFile([string]$path, [bool]$quiet) {
        [string]$searchPath = [string]::IsNullOrWhiteSpace($path) ?
                              (Get-Location) :
                              $path.Clone()

        $info =  try {
            Get-Item -Path $searchPath -ErrorAction Stop
        } catch {
            if ($quiet) {
                return $null
            }

            throw [SchemaComposerErrors]::NewRecord('Configuration.PathNotExist', $path)
        }

        if ($info -is [System.IO.FileInfo]) {
            if ($info.Extension -match '(jsonc?|ya?ml)') {
                return $info
            } elseif ($quiet) {
                return $null
            }
            throw [SchemaComposerErrors]::NewRecord('DataFile.InvalidExtension', $info.FullName)
        }

        foreach ($possiblePath in [SchemaComposerConfiguration]::GetConfigurationFileNames($info.FullName)) {
            try {
                return (Get-Item -Path $possiblePath)
            } catch {
                continue
            }
        }

        if ($quiet) {
            return $null
        }

        throw [SchemaComposerErrors]::NewRecord('Configuration.FileNotFound', $info.FullName)
    }
    static [System.IO.FIleInfo] FindConfigurationFile([string]$path) {
        return [SchemaComposerConfiguration]::FindConfigurationFile($path, $false)
    }
    static [System.IO.FileInfo] FindConfigurationFile([bool]$quiet) {
        return [SchemaComposerConfiguration]::FindConfigurationFile($null, $quiet)
    }
    static [System.IO.FileInfo] FindConfigurationFile() {
        return [SchemaComposerConfiguration]::FindConfigurationFile($null, $false)
    }
    #endregion FindConfigurationFIle
    static [SchemaComposerConfiguration] Get() {
        # Return current config, if set
        if ($null -ne [SchemaComposerConfiguration]::Current) {
            return [SchemaComposerConfiguration]::Current
        }
        # Return null if no configs are available.
        if ([SchemaComposerConfiguration]::Available.Count -lt 1) {
            return $null
        }
        # Return default config, if available
        $default = [SchemaComposerConfiguration]::Available.Find({
            param([SchemaComposerConfiguration]$config)

            return ($config.Name -eq 'default')
        })
        if ($null -ne $default) {
            return $default
        }
        # Return first available config
        return [SchemaComposerConfiguration]::Available[0]
    }
    #endregion Static methods

    #region    Instance properties
    [string]
    $Name

    [uri]
    $BaseUri

    [string]
    $Version

    [SchemaComposerConfigurationDirectories]
    $Directories

    [string]
    $Host

    [SchemaComposerConfigurationTemplating]
    $Templating

    [bool]
    $MungeExtensions

    [System.Collections.Generic.List[
        SchemaComposerConfigurationBundleDefinition
    ]]
    $BundleSchemas

    [Json.Schema.SchemaRegistry]
    $LocalSchemaRegistry

    [System.Collections.Generic.List[
        SchemaComposerSourceFile
    ]]
    $SourceFiles
    #endregion Instance properties

    #region    Instance methods
    [void] Initialize() {
        $this.BundleSchemas ??= [SchemaComposerUtil]::NewList(
            [SchemaComposerConfigurationBundleDefinition]
        )
        # [System.Collections.Generic.List[
        #     SchemaComposerConfigurationBundleDefinition
        # ]]::new()

        $this.Templating  ??= [SchemaComposerConfigurationTemplating]::new()
        $this.Directories ??= [SchemaComposerConfigurationDirectories]::new()
        $this.Name        ??= Split-Path -Path $this.Directories.Root -Leaf
        $this.Version     ??= '0.0.1'
        $this.SourceFiles ??= [SchemaComposerUtil]::NewList([SchemaComposerSourceFile])
        # [System.Collections.Generic.List[
        #     SchemaComposerSourceFile
        # ]]::new()
        $this.LocalSchemaRegistry ??= [Json.Schema.SchemaRegistry]::new()
    }
    [void] Load([hashtable]$data) {
        $this.Initialize()

        if ($null -eq $data) {
            return
        }
        # First, determine a name for the config:
        if ($data.ContainsKey('name')) {
            $this.Name = $data['name'] # Specified in config
        } elseif ('default' -notin [SchemaComposerConfiguration]::Available.Name) {
            $this.Name ??= 'default'   # First config loaded
        } else {
            $this.Name = New-Guid      # New config, not default
        }

        if ($data.ContainsKey('version')) {
            $this.Version = $data['version']
        }
        if ($data.ContainsKey('base_uri')) {
            $this.BaseUri = $data['base_uri']
        }
        if ($data.ContainsKey('munge_extensions')) {
            $this.MungeExtensions = $data['munge_extensions']
        }
        if ($data.ContainsKey('directories')) {
            $directoriesData = $data['directories']
            if (
                $directoriesData.Keys -notcontains 'output' -and
                -not [string]::IsNullOrWhiteSpace($this.Version)
            ) {
                $directoriesData['output'] = './{0}' -f $this.Version
            }

            $this.Directories = [SchemaComposerConfigurationDirectories]::CreateFrom(
                $data['directories']
            )
        }
        if ($data.ContainsKey('templating')) {
            $this.Templating = [SchemaComposerConfigurationTemplating]::CreateFrom(
                $data['templating']
            )
        }
        if ($data.ContainsKey('bundle_schemas')) {
            if ($this.BundleSchemas.Count -gt 0) {
                $this.BundleSchemas.Clear()
            }
            foreach ($definition in $data['bundle_schemas']) {
                $this.BundleSchemas.Add(
                    [SchemaComposerConfigurationBundleDefinition]::CreateFrom($definition)
                )
            }
        }
        # legacy, may remove
        if ($data.ContainsKey('host')) {
            $this.Host = $data['host']
        }
        if ($data.ContainsKey('prefix')) {
            $this.Prefix = $data['prefix']
        }
        if ($data.ContainsKey('docs_base_url')) {
            $this.DocsBaseUrl = $data['docs_base_url']
        }
        if ($data.ContainsKey('docs_version_pin')) {
            $this.DocsVersionPin = $data['docs_version_pin']
        }

        if ([SchemaComposerConfiguration]::Available.Name -notcontains $this.Name) {
            [SchemaComposerConfiguration]::Available.Add($this)
        }
    }
    [void] Load([System.IO.FileInfo]$file) {
        $data = Read-DataFile -FilePath $file.FullName
        if ($data.Keys -notcontains 'name') {
            $data.Insert(0, 'name', $file.FullName)
        }
        if ($data.Keys -notcontains 'directories') {
            $data.Add(
                'directories',
                [ordered]@{
                    root = Split-Path $file.FullName -Parent
                }
            )
        } elseif (
            $data['directories'] -is [System.Collections.Specialized.OrderedDictionary] -and
            $data['directories'].Keys -notcontains 'root'
        ) {
            $data['directories'].Insert(0, 'root', (Split-Path $file.FullName -Parent))
        }

        $this.Load($data)
    }
    [void] Load([string]$filePath) {
        $this.Load((Get-Item -Path $filePath))
    }

    [void] DiscoverSourceFiles([scriptblock]$filter) {
        if ([string]::IsNullOrWhiteSpace($this.Directories.Source)) {
            return
        }

        if (-not (Test-Path -Path $this.Directories.Source)) {
            # error - source dir not found
        }

        $dataFiles = Get-ChildItem -Path $this.Directories.Source -Recurse -File
        | Where-Object { $_ | Test-DataFile }

        if ($null -ne $filter) {
            $dataFiles = $dataFiles | Where-Object -FilterScript $filter
        }

        foreach ($dataFile in $dataFiles) {
            $sourceFile = [SchemaComposerSourceFile]::new($dataFile)
            $this.SourceFiles.Add($sourceFile)
        }
    }

    [void] DiscoverSourceFiles() {
        $this.DiscoverSourceFiles($null)
    }

    [void] ResolveSourceFileTemplateVariables() {
        foreach($sourceFile in $this.SourceFiles) {
            $sourceFile.ResolveTemplateVariables($this.Templating)
        }
    }

    [void] ResolveSourceFileExtensions() {
        foreach ($sourceFile in $this.SourceFiles) {
            $sourceFile.ResolveSchemaExtension($this.BaseUri)
        }
    }

    [void] ValidateBaseUri() {
        if ($null -eq $this.BaseUri) {
            # error, missing URI
        }
        if (
            [string]::IsNullOrEmpty($this.BaseUri.AbsoluteUri) -or
            [string]::IsNullOrEmpty($this.BaseUri.LocalPath)
        ) {
            # error, invalid URI
        }
    }

    [void] ResolveSourceFiles() {
        $this.ResolveSourceFileTemplateVariables()
        $this.ResolveSourceFileExtensions()
    }
    #endregion Instance methods

    static SchemaComposerConfiguration() {
        [SchemaComposerConfiguration]::Available =[SchemaComposerUtil]::NewList([SchemaComposerConfiguration])
        # [System.Collections.Generic.List[
        #     SchemaComposerConfiguration
        # ]]::new()
    }
    SchemaComposerConfiguration() {
        $this.Initialize()
    }

    SchemaComposerConfiguration([string]$configurationFilePath) {
        $this.Load($configurationFilePath)
        [SchemaComposerConfiguration]::Current ??= $this
    }

    SchemaComposerConfiguration([System.IO.FileInfo]$configurationFile)  {
        $this.Load($configurationFile)
        [SchemaComposerConfiguration]::Current ??= $this
    }
}

enum SchemaComposerBuiltinExportVocabularies {
    Compatible
    VSCode
    Extended
}

class SchemaComposerConfigurationExporting {
    [System.Collections.Generic.Dictionary[string, SchemaComposerExportVocabulary]]
    $Vocabularies

    [System.Collections.Generic.Dictionary[string, SchemaComposerExportFormat]]
    $Formats

    [void] Initialize() {
        # $this.Vocabularies ??= [System.Collections.Generic.Dictionary[
        #     string,
        #     SchemaComposerExportVocabulary
        # ]]::new([System.OrdinalComparer]::InvariantCultureIgnoreCase)
        # if ($null -eq $this.Vocabularies.compatible) {
            
        # }
        $this.Vocabularies = [SchemaComposerUtil]::NewDictionary([SchemaComposerExportVocabulary])
    }
}

class SchemaComposerExportFormat {

}

class SchemaComposerExportVocabulary {
    [string]
    $Name
    
    [string]
    $IDSuffix
    
    [System.Collections.Generic.List[string]]
    $KeywordsToRemove

    [JsonSchemaExportOptions] RemoveKeyword([string[]]$keywords) {
        foreach($keyword in $keywords) {
            if ($this.KeywordsToRemove -notcontains $keyword) {
                $this.KeywordsToRemove.Add($keyword)
            }
        }

        return $this
    }

    [JsonSchemaExportOptions] KeepKeyword([string[]]$keywords) {
        foreach($keyword in $keywords) {
            if ($this.KeywordsToRemove -contains $keyword) {
                $this.KeywordsToRemove.Remove($keyword)
            }
        }

        return $this
    }

    [JsonSchemaExportOptions] KeepCompatibleKeywords([bool]$passThru) {
        
        return $this
    }

    [void] Initialize() {
        $this.KeywordsToRemove ??= [SchemaComposerUtil]::NewList([string]) # [System.Collections.Generic.List[string]]::new()
    }

    JsonSchemaExportOptions() {
        $this.Initialize()
    }
}

class SchemaComposerExportVocabularyCompatible : SchemaComposerExportVocabulary {
     [void] Initialize() {
        $this.KeywordsToRemove ??= [SchemaComposerUtil]::NewList([string])
        $this.KeywordsToRemove.Add()
     }
}

class JsonSchemaExportOptions {
    [System.Collections.Generic.List[string]]
    $KeywordsToRemove

    [JsonSchemaExportOptions] RemoveKeyword([string[]]$keywords) {
        foreach($keyword in $keywords) {
            if ($this.KeywordsToRemove -notcontains $keyword) {
                $this.KeywordsToRemove.Add($keyword)
            }
        }

        return $this
    }

    [JsonSchemaExportOptions] KeepKeyword([string[]]$keywords) {
        foreach($keyword in $keywords) {
            if ($this.KeywordsToRemove -contains $keyword) {
                $this.KeywordsToRemove.Remove($keyword)
            }
        }

        return $this
    }

    [void] Initialize() {
        $this.KeywordsToRemove ??= [SchemaComposerUtil]::NewList([string]) # [System.Collections.Generic.List[string]]::new()
    }

    JsonSchemaExportOptions() {
        $this.Initialize()
    }

    JsonSchemaExportOptions([SchemaComposerBuiltinExportVocabularies]$vocabulary) {
        $this.Initialize()
        switch ($vocabulary) {
            Compatible {
                $this.RemoveKeyword([SchemaComposerKeywordVSCodeName].GetEnumNames())
            }
            default {}
        }
    }
}

class SchemaComposerSourceFile {
    static [void] ValidateFileExtension([System.IO.FileInfo]$file) {
        if ($file.Extension -match '(jsonc?|ya?ml)') {
            return
        }
        throw [SchemaComposerErrors]::NewRecord('DataFile.InvalidExtension', $file.FullName)
    }

    [System.IO.FileInfo]
    $FileInfo

    [string]
    $BaseID

    hidden
    [string]
    $_outputFolder

    hidden
    [string]
    $RawContent

    hidden
    [System.Collections.Specialized.OrderedDictionary]
    $RawData

    hidden
    [System.Collections.Specialized.OrderedDictionary]
    $MungedData

    #region    Calculated properties
    [uri] $ID
    [uri] $CompatibleSchemaID
    [uri] $VSCodeSchemaID
    [uri] $ExtendedSchemaID
    [string] $OutputFolder
    [Json.Schema.JsonSchema]$_compatibleSchema
    [Json.Schema.JsonSchema]$CompatibleSchema
    [Json.Schema.JsonSchema]$_vsCodeSchema
    [Json.Schema.JsonSchema]$VSCodeSchema
    [Json.Schema.JsonSchema]$_extendedSchema
    [Json.Schema.JsonSchema]$ExtendedSchema
    #endregion Caclulated properties

    [string] ToJson([JsonSchemaExportOptions]$options) {
        $data = $this.MungedData | Get-DeepClone
        if ($options.KeywordsToRemove.Count -gt 0) {
            $data = $data | Remove-SchemaKeyword -Keyword $options.KeywordsToRemove
        }

        $convertingParams = @{
            InputObject    = $data
            EnumsAsStrings = $true
            Depth          = 99
        }

        return (ConvertTo-Json @convertingParams)
    }
    [string] ToCompatibleJson() {
        $options = $null
        # $options = [JsonSchemaExportOptions]::new([SchemaComposerExportKind]::Compatible)

        return $this.ToJson($options)
    }
    [string] ToVSCodeJson() {
        $options = $null
        # $options = [JsonSchemaExportOptions]::new([SchemaComposerExportKind]::VSCode)

        return $this.ToJson($options)
    }

    [string] ToExtendedJson() {
        $options = $null
        # $options = [JsonSchemaExportOptions]::new([SchemaComposerExportKind]::VSCode)

        return $this.ToJson($options)
    }

    hidden [uri] GetID() {
        return ($this.MungedData['$id'] -as [uri])
    }

    hidden [Json.Schema.JsonSchema] GetCompatibleSchema() {
        try {
            return [Json.Schema.JsonSchema]::FromText($this.ToCompatibleJson())
        } catch {
            return $null
        }
    }

    hidden [Json.Schema.JsonSchema] GetVSCodeSchema() {
        try {
            return [Json.Schema.JsonSchema]::FromText($this.ToVSCodeJson())
        } catch {
            return $null
        }
    }

    hidden [Json.Schema.JsonSchema] GetExtendedSchema() {
        try {
            return [Json.Schema.JsonSchema]::FromText($this.ToExtendedJson())
        } catch {
            return $null
        }
    }

    hidden [string] GetOutputFolder() {
        if (-not [string]::IsNullOrWhiteSpace($this._outputPath)) {
            return $this._outputPath
        }

        $configuration = [SchemaComposerConfiguration]::Get()
        if (
            [string]::IsNullOrEmpty($configuration.Directories.Source) -or
            [string]::IsNullOrEmpty($configuration.Directories.Output)
        ) {
            return [NullString]::Value
        }

        $parentDir = Split-Path -Path $this.FileInfo.FullName -Parent
        $sourceDir = $configuration.Directories.Source
        $outputDir = $configuration.Directories.Output

        return ($parentDir -replace [regex]::Escape($sourceDir), $outputDir)
    }

    [void] Load([System.IO.FileInfo]$file) {
        [SchemaComposerSourceFile]::ValidateFileExtension($file)
        $this.FileInfo      = $file
        $this.BaseID        = $file.BaseName
        $this.RawContent    = $file         | Get-Content -Raw
        $this.RawData       = $file         | Read-DataFile
        $this.MungedData    = $this.RawData | Get-DeepClone
    }
    [void] Load([string]$filePath) {
        $this.Load((Get-Item -Path $filePath))
    }

    [void] ResolveTemplateVariable([string]$variableName, [string]$replacementValue) {
        $resolvingParams = @{
            Name = $variableName
            Value = $replacementValue
            InputObject = $this.MungedData
        }
        $this.MungedData = Resolve-TemplateVariable @resolvingParams
    }
    [void] ResolveTemplateVariables([SchemaComposerConfigurationTemplating]$templating) {
        Write-Warning "Resolving template variables with templating:`n---`n$templating`n---"
        if ($templating.IsEmpty()) {
            Write-Warning "SKipping resolving template variables, templating empty"
            return
        }

        $this.MungedData = $templating.Resolve($this.MungedData, $false)
    }
    [void] ResolveTemplateVariables([SchemaComposerConfiguration]$configuration) {
        Write-Warning "Resolving templating variables from configuration..."
        if ($null -eq $configuration.Templating) {
            Write-Warning "Skipping resolving template variables, config empty"
            return
        }

        $this.ResolveTemplateVariables($configuration.Templating)
    }
    [void] ResolveTemplateVariables() {
        $this.ResolveTemplateVariables(
            [SchemaComposerConfiguration]::Get()
        )
    }
    [void] ResolveSchemaExtension([string[]]$uriPrefixes) {
        $resolvingParams = @{
            InputObject = $this.MungedData
            UriPrefix   = $uriPrefixes
        }

        $this.MungedData = Resolve-SchemaExtension @resolvingParams
    }

    [void] ResolveSchemaExtension([uri]$schemaBaseUri) {
        if ($null -eq $schemaBaseUri) {
            # error
        }
        $this.ResolveSchemaExtension(@(
            $schemaBaseUri.AbsolutePath
            $schemaBaseUri.LocalPath
        ))
    }

    [void] ResolveSchemaExtension() {
        $configuration = [SchemaComposerConfiguration]::Get()
        if ($null -eq $configuration) {
            # Error
        }

        $this.ResolveSchemaExtension($configuration.BaseUri)
    }

    static SchemaComposerSourceFile() {
        $typeName          = [SchemaComposerSourceFile].FullName
        $memberDefinitions = @(
            @{
                MemberName = 'ID'
                MemberType = 'ScriptProperty'
                Value      = {
                    [OutputType([uri])]
                    param()

                    return $this.GetID()
                }
            }
            @{
                MemberName = 'OutputFolder'
                MemberType = 'ScriptProperty'
                Value      = {
                    [OutputType([string])]
                    param()

                    return $this.GetOutputFolder()
                }
            }
            @{
                MemberName = 'CompatibleSchema'
                MemberType = 'ScriptProperty'
                Value      = {
                    [OutputType([Json.Schema.JsonSchema])]
                    param ()

                    $this.GetCompatibleSchema()
                }
            }
            @{
                MemberName = 'VSCodeSchema'
                MemberType = 'ScriptProperty'
                Value      = {
                    [OutputType([Json.Schema.JsonSchema])]
                    param ()

                    $this.GetVSCodeSchema()
                }
            }
            @{
                MemberName = 'ExtendedSchema'
                MemberType = 'ScriptProperty'
                Value      = {
                    [OutputType([Json.Schema.JsonSchema])]
                    param ()

                    $this.GetExtendedSchema()
                }
            }
        )
        foreach ($definition in $memberDefinitions) {
            Update-TypeData -TypeName $TypeName @Definition
        }
    }

    SchemaComposerSourceFile() {}
    SchemaComposerSourceFile([System.IO.FileInfo]$file) {
        $this.Load($file)
    }
    SchemaComposerSourceFile([string]$filePath) {
        $this.Load($filePath)
    }
}

class JsonSchemaSourceRegistry {

}

class JsonSchemaLocalRegistry {
    [SchemaComposerConfiguration]
    $Configuration

    [System.Collections.Specialized.OrderedDictionary]
    $FileMap

    [System.Collections.Specialized.OrderedDictionary]
    $Map

    [System.Collections.Generic.List[System.Collections.Specialized.OrderedDictionary]]
    $List

    [System.Collections.Generic.List[SchemaComposerSourceFile]]
    $SourceFiles

    [string]$SchemaHost
    [string]$SchemaPrefix
    [string]$SchemaVersion
    [string]$DocsBaseUrl
    [string]$DocsVersionPin

    [void] Initialize() {
        $this.FileMap ??= [SchemaComposerUtil]::NewOrderedDictionary() # [System.Collections.Specialized.OrderedDictionary]::new()
        $this.Map     ??= [SchemaComposerUtil]::NewOrderedDictionary() # [System.Collections.Specialized.OrderedDictionary]::new()
        $this.List    ??= [SchemaComposerUtil]::NewList(
            [System.Collections.Specialized.OrderedDictionary]
        ) # [System.Collections.Generic.List[System.Collections.Specialized.OrderedDictionary]]::new()
    }

    JsonSchemaLocalRegistry() {
        $this.Initialize()
    }

    JsonSchemaLocalRegistry(
        [string]$SchemaHost,
        [string]$SchemaPrefix,
        [string]$SchemaVersion,
        [string]$DocsBaseUrl,
        [string]$DocsVersionPin
    ) {
        $this.SchemaHost     = $SchemaHost
        $this.SchemaPrefix   = $SchemaPrefix
        $this.SchemaVersion  = $SchemaVersion
        $this.DocsBaseUrl    = $DocsBaseUrl
        $this.DocsVersionPin = $DocsVersionPin
        $this.Initialize()
    }
}
#endregion Class definitions

#region    Function definitions
    #region    Utility  functions

function Invoke-RecursiveDictionaryFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]
        $InputObject,

        # [Parameter(Mandatory)]
        [System.Management.Automation.FunctionInfo]
        $RecursiveFunction,
        
        [hashtable]
        $RecursiveParameters
    )

    begin {
        # Set recursive parameters to empty hash if not defined
        if ($null -eq $RecursiveParameters) {
            $RecursiveParameters = @{}
        }
        # Set recursive function to calling command if not defined
        if ($null -eq $RecursiveFunction) {
            $RecursiveFunction = Get-PSCallStack
            | Select-Object -First 1 -Skip 1 -ExpandProperty Command
            | Get-Command
        }
    }

    process {
        Write-Verbose "Recursively calling '$RecursiveFunction'..."
        if ($InputObject -is [System.Collections.IDictionary]) {
            $data = [SchemaComposerUtil]::NewOrderedDictionary() # [System.Collections.Specialized.OrderedDictionary]::new()
            foreach ($key in $InputObject.Keys) {
                $value       = $InputObject[$key]
                $valueIsList = $value -is [System.Collections.IList]
                $valueIsDict = $value -is [System.Collections.IDictionary]
                $valueIsNull = $null -eq $value
                Write-Verbose "Converting key '$key' of type [$($InputObject[$key]?.GetType().FullName)]"
                if (
                    $valueIsNull -or
                    ($valueIsList -and $value.Count -eq 0) -or
                    ($valueIsDict -and $value.Keys.Count -eq 0)
                ) {
                    $data[$key] = $value
                    continue
                }

                $value = & $RecursiveFunction -InputObject $value @RecursiveParameters
                # $value = ConvertTo-OrderedDictionary -InputObject $InputObject[$key]

                if ($valueIsList) {
                    $value = $value -as [object[]]
                }

                $data[$key] = $value
            }

            return $data
        }
        if ($InputObject -is [System.Collections.IEnumerable]) {
            if ($InputObject.Count -eq 0) {
                return [object[]]@()
            }

            $converted = @(,($InputObject | & $RecursiveFunction @RecursiveParameters))
            return $converted
        }
    }
}

function ConvertTo-OrderedDictionary {
    [CmdletBinding()]
    # [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        # Always return null input as-is
        if ($null -eq $InputObject) {
            return $null
        }
        # Always return value types as-is
        if ($InputObject -is [System.ValueType]) {
            # Write-Verbose "Returning value type ($InputObject) as-is"
            return $InputObject
        }
        # Handle strings before other enumerables, return as-is
        if ($InputObject -is [string]) {
            # Write-Verbose "Returning string '$InputObject' as-is"
            return $InputObject
        }
        # If it's an unordered dictionary, convert and return
        if ($InputObject -is [System.Collections.IDictionary]) {
            return Invoke-RecursiveDictionaryFunction -InputObject $InputObject
            # Write-Verbose "Converting dictionary [$($InputObject.GetType().FullName)]..."
            # $data = [System.Collections.Specialized.OrderedDictionary]::new()

            # foreach ($key in $InputObject.Keys) {
            #     $value       = $InputObject[$key]
            #     $valueIsList = $value -is [System.Collections.IList]
            #     $valueIsDict = $value -is [System.Collections.IDictionary]
            #     $valueIsNull = $null -eq $value
            #     Write-Verbose "Converting key '$key' of type [$($InputObject[$key]?.GetType().FullName)]"
            #     if (
            #         $valueIsNull -or
            #         ($valueIsList -and $value.Count -eq 0) -or
            #         ($valueIsDict -and $value.Keys.Count -eq 0)
            #     ) {
            #         $data[$key] = $value
            #         continue
            #     }

            #     $value = ConvertTo-OrderedDictionary -InputObject $InputObject[$key]

            #     if ($valueIsList) {
            #         $value = $value -as [object[]]
            #     }

            #     Write-Verbose "Converted key '$key' value as [$(${value}?.GetType().FullName)]: $(ConvertTo-Json -InputObject $value -Depth 99 -EnumsAsStrings)"
            #     $data[$key] = $value
            # }

            # return $data
        }
        # Return the collection of converted enumerables
        if ($InputObject -is [System.Collections.IEnumerable]) {
            return Invoke-RecursiveDictionaryFunction -InputObject $InputObject
        }
        # Handle PowerShell objects last
        if ($InputObject -is [psobject]) {
            $data = [SchemaComposerUtil]::NewOrderedDictionary() #[System.Collections.Specialized.OrderedDictionary]::new()
            Write-Verbose "Converting [pscustomobject]..."
            foreach ($property in $InputObject.psobject.Properties.Name) {
                $propertyIsList = $InputObject.$property -is [System.Collections.IList]
                Write-Verbose "Converting property '$property' of type [$($InputObject.${property}?.GetType().FullName)]"
                $value = ConvertTo-OrderedDictionary -InputObject $InputObject.$property
                if ($propertyIsList) {
                    $value = $value -as [object[]]
                }
                Write-Verbose "Converted property '$property' value as [$(${value}?.GetType().FullName)]: $(ConvertTo-Json -InputObject $value -Depth 99 -EnumsAsStrings)"
                $data[$property] = $value
            }

            return $data
        }
        # If we got here, it wasn't special-cased
        Write-Verbose "Emitting non-converted InputObject to pipeline: $(ConvertTo-Json -InputObject $InputObject -Depth 99 -EnumsAsStrings)"
        $InputObject
    }
}
function Get-DeepClone {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        # Ensure we're working with a fully converted dictionary
        $InputObject = $InputObject | ConvertTo-OrderedDictionary

        # Always return null input as-is
        if ($null -eq $InputObject) {
            return $null
        }
        # Always return value types as-is
        if ($InputObject -is [System.ValueType]) {
            # Write-Verbose "Returning value type ($InputObject) as-is"
            return $InputObject
        }
        # Handle strings before other enumerables, return as-is
        if ($InputObject -is [string]) {
            # Write-Verbose "Returning string '$InputObject' as-is"
            return $InputObject.Clone()
        }
        # If it's an ordered dictionary, recursively clone key-value pairs.
        if ($InputObject -is [System.Collections.Specialized.OrderedDictionary]) {
            return Invoke-RecursiveDictionaryFunction -InputObject $InputObject
            # Write-Verbose "Cloning dictionary..."
            # $clone = [System.Collections.Specialized.OrderedDictionary]::new()
            # foreach ($key in $InputObject.Keys) {
            #     $valueIsList = $InputObject[$key] -is [System.Collections.IList]
            #     Write-Verbose "Cloning key '$key' of type [$($InputObject[$key]?.GetType().FullName)]"
            #     $value = Get-DeepClone -InputObject $InputObject[$key]
            #     if ($valueIsList) {
            #         $value = $value -as [object[]]
            #     }
            #     Write-Verbose "Cloned key '$key' value as [$(${value}?.GetType().FullName)]: $(ConvertTo-Json -InputObject $value -Depth 99 -EnumsAsStrings)"
            #     $clone[$key] = $value
            # }
            # return $clone
        }
        # Return the collection of clones enumerables
        if ($InputObject -is [System.Collections.IEnumerable]) {
            return Invoke-RecursiveDictionaryFunction -InputObject $InputObject
        }
        # If we got here, it wasn't special-cased
        Write-Verbose "Emitting non-cloned InputObject to pipeline: $(ConvertTo-Json -InputObject $InputObject -Depth 99 -EnumsAsStrings)"
        $InputObject
    }
}

function Resolve-ReplacementPatternInDictionary {
    param(
        [Parameter(Mandatory)]
        [regex] $ReplacementPattern,
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $ReplacementValue,
        [Parameter(Mandatory, ValueFromPipeline)]
        [object] $InputObject,
        [switch] $Clone
    )

    begin {
        Write-Warning "Replacing pattern 'ReplacementPattern$' with value '$ReplacementValue'"
    }

    process {
        # Ensure we're working with a fully converted dictionary
        $InputObject = $InputObject | ConvertTo-OrderedDictionary
        if ($Clone) {
            Write-warning "Cloning input object before replacement"
            $InputObject = $InputObject | Get-DeepClone
        }
        $recursingParameters = @{
            InputObject         = $InputObject
            RecursiveFunction   = $PSCmdlet.MyInvocation.MyCommand
            RecursiveParameters = @{
                ReplacementPattern = $ReplacementPattern
                ReplacementValue   = $ReplacementValue
            }
        }

        # Always return null input as-is
        if ($null -eq $InputObject) {
            return $null
        }
        # Always return value types as-is
        if ($InputObject -is [System.ValueType]) {
            return $InputObject
        }
        # Handle strings before other enumerables, replace and return
        if ($InputObject -is [string]) {
            return $InputObject -replace $ReplacementPattern, $ReplacementValue
        }
        # If it's an ordered dictionary, recursively resolve key-value pairs.
        if ($InputObject -is [System.Collections.Specialized.OrderedDictionary]) {
            return Invoke-RecursiveDictionaryFunction @recursingParameters
            # foreach ($key in @($InputObject.Keys)) {
            #     $value       = $InputObject[$key]
            #     $valueIsList = $value -is [System.Collections.IList]
            #     $resolved    = Resolve-ReplacementPatternInDictionary $value @recursingParameters
            #     if ($valueIsList) {
            #         $resolved = $resolved -as [object[]]
            #     }
            #     $InputObject[$key] = $resolved
            # }
            # return $InputObject
        }
        # Return the collection of resolved enumerables
        if ($InputObject -is [System.Collections.IEnumerable]) {
            return Invoke-RecursiveDictionaryFunction @recursingParameters
            # $resolved = @(,($InputObject | Resolve-ReplacementPatternInDictionary @recursingParameters))
            # return $resolved
        }
        # If we got here, it wasn't special-cased
        $InputObject
    }
}

function Resolve-TemplateVariable {
    param(
        [Parameter(Mandatory, ParameterSetName='WithNameAndValue')]
        [string] $Name,
        [Parameter(Mandatory, ParameterSetName='WithNameAndValue')]
        [AllowEmptyString()]
        [string] $Value,
        [Parameter(Mandatory, ParameterSetName='WithVariable')]
        [SchemaComposerTemplateVariable[]]
        $TemplateVariable,
        [Parameter(Mandatory, ValueFromPipeline)]
        [object] $InputObject,
        [switch] $Clone
    )

    begin {
        if ($null -eq $TemplateVariable) {
            Write-Verbose "Creating template variable called '$Name' with value '$Value'"
            $TemplateVariable = [SchemaComposerTemplateVariable]::new($Name, $Value)
        }
    }

    process {
        # Ensure we're working with a fully converted dictionary
        $InputObject = $InputObject | ConvertTo-OrderedDictionary
        if ($Clone) {
            $InputObject = $InputObject | Get-DeepClone
        }
        $recursingParameters = @{
            RecursiveFunction   = Get-Command Resolve-TemplateVariable
            InputObject         = $InputObject
            RecursiveParameters = @{
                TemplateVariable = $TemplateVariable
            }
        }

        # Always return null input as-is
        if ($null -eq $InputObject) {
            return $null
        }
        # Always return value types as-is
        if ($InputObject -is [System.ValueType]) {
            return $InputObject
        }
        # Handle strings before other enumerables, replace and return
        if ($InputObject -is [string]) {
            $munged = $InputObject
            foreach ($variable in $TemplateVariable) {
                Write-Verbose "Replacing $variable in '$munged'"
                $munged = $munged -replace $variable.Pattern, $variable.Value
            }
            return $munged
        }
        # If it's an ordered dictionary, recursively resolve key-value pairs.
        if ($InputObject -is [System.Collections.Specialized.OrderedDictionary]) {
            return Invoke-RecursiveDictionaryFunction @recursingParameters
            # foreach ($key in @($InputObject.Keys)) {
            #     $keyValue       = $InputObject[$key]
            #     $keyValueIsList = $keyValue -is [System.Collections.IList]

            #     $resolved = Resolve-TemplateVariable -InputObject $keyValue @recursingParameters

            #     if ($keyValueIsList) {
            #         $resolved = $resolved -as [object[]]
            #     }

            #     $InputObject[$key] = $resolved
            # }

            # return $InputObject
        }
        # Return the collection of resolved enumerables
        if ($InputObject -is [System.Collections.IEnumerable]) {
            return Invoke-RecursiveDictionaryFunction @recursingParameters
            # $resolved = @(,($InputObject | Resolve-TemplateVariable @recursingParameters))
            # return $resolved
        }
        # If we got here, it wasn't special-cased
        $InputObject
    }
}

function Resolve-SchemaExtension {
    param(
        [Parameter(ValueFromPipeline)]
        [object]   $InputObject,
        [string[]] $UriPrefix,
        [switch]   $Clone
    )

    begin {
        $oldExtension = 'yaml'
        $newExtension = 'json'
        $replacements  = $UriPrefix | ForEach-Object -Process {
            @{
                Pattern = '(?m)({0}\S+\.){1}' -f [regex]::Escape($_), $oldExtension
                Value   = '$1{0}' -f $newExtension
            }
        }
    }

    process {
        # Ensure we're working with a fully converted dictionary
        $InputObject = ConvertTo-OrderedDictionary $InputObject
        # Get a deepl clone if requested
        if ($Clone) {
            $InputObject = Get-DeepClone $InputObject
        }
        # Set recursion params for convenience
        $recursingParameters = @{
            RecursiveFunction = $PSCmdlet.MyInvocation.MyCommand
            InputObject       = $InputObject
            RecursiveParameters = @{
                UriPrefix = $UriPrefix
            }
        }

        # Always return null input as-is
        if ($null -eq $InputObject) {
            return $null
        }
        # Always return value types as-is
        if ($InputObject -is [System.ValueType]) {
            return $InputObject
        }
        # Handle strings before other enumerables, replace and return
        if ($InputObject -is [string]) {
            $munged = $InputObject.Clone()
            foreach ($replacement in $replacements) {
                $munged = $munged -replace $replacement.Pattern, $replacement.Value
            }
            return $munged
        }
        # If it's an ordered dictionary, recursively resolve key-value pairs.
        if ($InputObject -is [System.Collections.Specialized.OrderedDictionary]) {
            return Invoke-RecursiveDictionaryFunction @recursingParameters
            # foreach ($key in @($InputObject.Keys)) {
            #     $keyValue = $InputObject[$key]
            #     $keyValueIsList = $keyValue -is [System.Collections.IList]
            #     $munged = Resolve-SchemaExtension $InputObject[$key] @recursingParameters
            #     if ($keyValueIsList) {
            #         $munged = $munged -as [object[]]
            #     }
            #     $InputObject[$key] = $munged
            # }
            # return $InputObject
        }
        # Return the collection of resolved enumerables
        if ($InputObject -is [System.Collections.IEnumerable]) {
            return Invoke-RecursiveDictionaryFunction @recursingParameters
            # return @(,($InputObject | Resolve-SchemaExtension @recursingParameters))
        }
        # If we got here, it wasn't special-cased
        $InputObject
    }
}

function Remove-SchemaKeyword {
    param(
        [Parameter(ValueFromPipeline)]
        [object]   $InputObject,
        [string[]] $Keyword,
        [switch] $VSCode,
        [switch] $Clone
    )

    begin {
        if ($VSCode) {
            $Keyword = $Keyword + [SchemaComposerKeywordVSCodeName].GetEnumNames()
            | Select-Object -Unique
        }
        [string[]]$keywordsToRemove = $Keyword.Clone()
    }

    process {
        # Ensure we're working with a fully converted dictionary
        $InputObject = ConvertTo-OrderedDictionary $InputObject
        # Get a deepl clone if requested
        if ($Clone) {
            $InputObject = Get-DeepClone $InputObject
        }
        # Set recursion params for convenience
        $recursingParameters = @{
            InputObject         = $InputObject
            RecursiveFunction   = $PSCmdlet.MyInvocation.MyCommand
            RecursiveParameters = {
                Keyword = $Keyword
            }
        }

        # Always return null input as-is
        if ($null -eq $InputObject) {
            return $null
        }
        # Always return value types as-is
        if ($InputObject -is [System.ValueType]) {
            return $InputObject
        }
        # Handle strings before other enumerables, return as-is
        if ($InputObject -is [string]) {
            return $InputObject
        }
        # If it's an ordered dictionary, recursively resolve key-value pairs.
        if ($InputObject -is [System.Collections.Specialized.OrderedDictionary]) {
            # return Invoke-RecursiveDictionaryFunction -InputObject $InputObject $recursingParameters
            foreach ($key in @($InputObject.Keys)) {
                if ($key -in $keywordsToRemove) {
                    $InputObject.Remove($key)
                } else {
                    $recursingParameters.InputObject = $InputObject[$key]
                    $InputObject[$key] = Invoke-RecursiveDictionaryFunction @recursingParameters
                    # $keyValue = $InputObject[$key]
                    # $keyValueIsList = $keyValue -is [System.Collections.IList]
                    # $removed = Remove-SchemaKeyword $keyValue @recursingParameters
                    # if ($keyValueIsList) {
                    #     $removed = $removed -as [object[]]
                    # }
                    # $InputObject[$key] = $removed
                }
            }
            return $InputObject
        }
        # Return the collection of resolved enumerables
        if ($InputObject -is [System.Collections.IEnumerable]) {
            return Invoke-RecursiveDictionaryFunction @recursingParameters
            # return @(,($InputObject | Remove-SchemaKeyword @recursingParameters))
        }
        # If we got here, it wasn't special-cased
        $InputObject
    }
}

function Get-SchemaReference {
    [OutputType([System.Collections.Generic.List[string]])]
    param(
        [Parameter(ValueFromPipeline)]
        [object]   $InputObject
    )

    begin {
        $references = [SchemaComposerUtil]::NewList([string]) # [System.Collections.Generic.List[string]]::new()
    }

    process {
        # Ensure we're working with a fully converted dictionary
        $InputObject = $InputObject | ConvertTo-OrderedDictionary

        # Always return nothing for null input
        if ($null -eq $InputObject) {
            return
        }

        # Handle strings before other enumerables, return immediately
        if ($InputObject -is [string]) {
            return
        }

        # If it's an ordered dictionary, check for the $ref key and add if
        # not already included, then recursively check other keys for nested
        # references.
        if ($InputObject -is [System.Collections.Specialized.OrderedDictionary]) {
            if (
                $InputObject.Keys -contains '$ref' -and
                ($reference = $InputObject['$ref']) -is [string] -and
                -not [string]::IsNullOrWhiteSpace($reference) -and
                -not $references.Contains($reference)
            ) {
                $references.Add($reference )
            }

            foreach ($key in @($InputObject.Keys | Where-Object { $_ -ne '$ref' })) {
                $nestedReferences = $InputObject[$key] | Get-SchemaReference
                if ($nestedReferences.Count -gt 0) {
                    foreach ($reference in $nestedReferences) {
                        if (-not $references.Contains($reference)) {
                            $references.Add($reference)
                        }
                    }
                }
            }
            return
        }
        # Check each item in the collection for nested references,
        # and add if unique
        if ($InputObject -is [System.Collections.IEnumerable]) {
            $nestedReferences = $InputObject | Get-SchemaReference
            foreach ($reference in $nestedReferences) {
                if (-not $references.Contains($reference)) {
                    $references.Add($reference)
                }
            }
        }
        # If we got here, it wasn't special-cased
        return
    }

    end {
        return $references
    }
}

function Read-DataFile {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string[]]
        $FilePath
    )

    begin {
    }

    process {
        foreach ($path in $FilePath) {
            $fileContent = Get-Content -Path $path -Raw

            if ($path -match '\.jsonc?$') {
                $fileContent
                | ConvertFrom-Json
                | ConvertTo-OrderedDictionary
            } elseif ($path -match '\.ya?ml$') {
                $fileContent
                | Yayaml\ConvertFrom-Yaml
            } else {
                $PSCmdlet.WriteError(
                    [SchemaComposerErrors]::NewRecord('DataFile.InvalidExtension', $path)
                )
            }
        }
    }

    end {}
}
function Test-DataFile {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]
        $FilePath
    )

    begin {
    }

    process {
        foreach ($path in $FilePath) {
            # Emit the result for each path
            (
                $path -match '(jsonc?|ya?ml)$' -and
                (Test-Path -Path $path -PathType Leaf)
            )
        }
    }

    end {
    }
}
    #endregion Utility functions
    #region    Configuration functions
    function Import-SchemaComposerConfiguration {}
    function Update-SchemaComposerConfiguration {}
    function New-SchemaComposerConfiguration {}
    function Export-SchemaComposerConfiguration {}
    function Get-SchemaComposerConfiguration {}
    #endregion Configuration functions
    #region    Source file functions
    function Get-SchemaComposerSourceFile {}
    function Export-SchemaComposerSourceFile {}
    #endregion Source file functions
    #region    Local registry functions
    #endregion Local registry functions
#endregion Function definitions

#region    Type exporting
$Exportable = @{
    Types = [type[]]@(
        [SchemaComposerKeywordVSCodeName]
        [JsonSchemaBundledOutputFormat]
        [SchemaComposerErrorDefinition]
        [SchemaComposerErrors]
        [SchemaComposerConfiguration]
        [SchemaComposerConfigurationBundleDefinition]
        [SchemaComposerConfigurationTemplating]
        [SchemaComposerConfigurationDirectories]
        [JsonSchemaLocalRegistry]
    )
}

$TypeAcceleratorsClass = [psobject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)
# Ensure none of the types would clobber an existing type accelerator.
# If a type accelerator with the same name exists, throw an exception.
$ExistingTypeAccelerators = $TypeAcceleratorsClass::Get
foreach ($type in $Exportable.Types) {
    if ($type.FullName -in $ExistingTypeAccelerators.Keys) {
        $message = @(
            "Unable to register type accelerator '$($type.FullName)'"
            'Accelerator already exists.'
        ) -join ' - '

        throw [System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new($message),
            'TypeAcceleratorAlreadyExists',
            [System.Management.Automation.ErrorCategory]::InvalidOperation,
            $type.FullName
        )
    }
}
# Add type accelerators for every exportable type.
foreach ($type in $Exportable.Types) {
    $TypeAcceleratorsClass::Add($type.FullName, $type)
}
# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    foreach($type in $Exportable.Types) {
        $TypeAcceleratorsClass::Remove($type.FullName)
    }
}.GetNewClosure()
#endregion Type exporting

Export-ModuleMember -Function *