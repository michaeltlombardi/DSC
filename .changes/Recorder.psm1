enum ChronistCategory {
    Undefined
    Security
    Removed
    Deprecated
    Changed
    Added
    Fixed
}

[Json.Schema.SchemaSpecVersionAttribute()]
class DscTestResource {

}

class ChronistUtil {
    #region    Static properties
    hidden static [System.Collections.Generic.List[String]] $_ValidCategories
    hidden static [bool] $_YayamlAvailable
    hidden static [bool] $_CheckedYayamlAvailable
    #endregion Static properties
    static [hashtable] ReadFileData([System.IO.FileInfo]$file) {
        [hashtable] $fileData    = @{}
        [string]    $fileContent = Get-Content -Path $file.FullName -Raw
        if ($file.FullName -match '\.jsonc?$') {
            $fileData = $fileContent
            | ConvertFrom-Json -AsHashtable
        } elseif ($file.FullName -match '\.ya?ml$') {
            if (-not [ChronistUtil]::TestYayamlAvailable()) {
                # error can't read yaml
            }
            $fileData = $fileContent
            | Yayaml\ConvertFrom-Yaml
        } else {
            # error invalid extension
        }

        return $fileData
    }

    #region    Static methods
    static [string] GetRegexGroupValue(
        [System.Text.RegularExpressions.Match]$match,
        [string]$groupName
    ) {
        return $match.Groups.Where(
            { $_.Name -eq $groupName },
            'First'
        )[0].Value ?? [NullString]::Value
    }
    static [System.Collections.Generic.List[string]] GetValidCategories() {
        if ($null -eq [ChronistUtil]::_ValidCategories) {
            $categories = [ChronistCategory].GetEnumNames()
            [ChronistUtil]::_ValidCategories = [System.Collections.Generic.List[string]]::new(
                $categories.Count - 1
            )
            $categories.Where({
                $_ -ne [ChronistCategory]::Undefined.ToString()
            }).ForEach({
                [ChronistUtil]::_ValidCategories.Add($_)
            })
        }

        return [ChronistUtil]::_ValidCategories
    }

    static [regex] GetValidCategoriesPattern() {
        $pattern = @(
            '(?<category>'
            [ChronistUtil]::GetValidCategories() -join '|'
            ')'
        ) -join ''

        return [regex]::new(
            $pattern,
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }
    static [regex] GetValidPriorityPattern() {
        return [regex]::new(
            '(?<priority>\d+)',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }
    static [regex] GetValidIDPattern() {
        return [regex]::new(
            '(?<id>(?:\w|-)+?)',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }
    static [regex] GetValidFileExtensionPattern() {
        return [regex]::new(
            '(\.chronist)?\.(?<extension>jsonc?|ya?ml)$',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }

    static [bool] TestYayamlAvailable() {
        return [ChronistUtil]::TestYayamlAvailable($false)
    }
    static [bool] TestYayamlAvailable([bool]$refresh) {
        if ($refresh -or -not [ChronistUtil]::_CheckedYayamlAvailable) {
            try {
                Get-Module -ListAvailable -Name Yayaml -ErrorAction Stop
                [ChronistUtil]::_YayamlAvailable = $true
            } catch {
                [ChronistUtil]::_YayamlAvailable = $false
            }
            [ChronistUtil]::_CheckedYayamlAvailable = $true
        }

        return [ChronistUtil]::_YayamlAvailable
    }

    static [void] ValidateYayamlAvailable([bool]$refresh, [string]$message) {
        if ([ChronistUtil]::TestYayamlAvailable($refresh)) {
            return
        }
        if ([string]::IsNullOrWhiteSpace($message)) {
            $message = @() -join ' '
        }

        throw [System.InvalidOperationException]::new($message)
    }
    static [void] ValidateYayamlAvailable([bool]$refresh) {
        [ChronistUtil]::ValidateYayamlAvailable($refresh, $null)
    }
    static [void] ValidateYayamlAvailable([string]$message) {
        [ChronistUtil]::ValidateYayamlAvailable($false, $message)
    }
    static [void] ValidateYayamlAvailable() {
        [ChronistUtil]::ValidateYayamlAvailable($false, $null)
    }

    static [bool] TestRegexMatchHasGroup(
        [System.Text.RegularExpressions.Match]$match,
        [string]$groupName
    ) {
        return $match.Groups.Name -contains $groupName
    }

    static [System.Management.Automation.Language.ParameterAst[]] GetParameterAsts(
        [scriptblock]$scriptblock
    ) {
        return $scriptblock.Ast.Find(
            {
                param($Item)
                return ($Item -is [System.Management.Automation.Language.ParamBlockAst])
            },
            $false
        )?.Parameters
    }
    static [System.Management.Automation.OutputTypeAttribute[]] GetOutputTypes(
        [scriptblock]$scriptblock
    ) {
        return $scriptblock.Attributes.Where({
            $_.TypeId -eq [OutputType]
        })
    }
    static [bool] HasOutputType(
        [scriptblock]$scriptblock,
        [System.Management.Automation.PSTypeName]$outputTypeName,
        [string]$parameterSetName
    ) {
        [OutputType[]]$outputTypes = [ChronistUtil]::GetOutputType($scriptblock)

        if ($null -eq $outputTypes -or $outputTypes.Count -eq 0) {
            return $false
        }

        if (-not [string]::IsNullOrWhiteSpace($parameterSetName)) {
            $outputTypes - $outputTypes.Where({
                $_.ParameterSetName -contains $parameterSetName
            })
            if ($outputTypes.Count -eq 0) {
                return $false
            }
        }

        return $outputTypes.Type -contains $outputTypeName
    }

    static [string] PrettyConcatValues([string[]]$values) {
        $builder = [System.Text.StringBuilder]::new()

        for ($i = 0; $i -lt $values.Count; $i++) {
            $json = $values[$i] | ConvertTo-Json -EnumsAsStrings
            $template = ', {0}'
            if ($i -eq 0) {
                $template = '{0}'
            } elseif ($i -eq ($values.Count - 1)) {
                $template = ', and {0}'
            }

            $builder.Append($template -f $json)
        }
        $output = $builder.ToString()

        if ($output -match '\\') {
            return $output
        }

        return ($output -replace '"', "'")
    }
    #endregion Static mathods
}

class ChronistErrors {
    static [System.NotImplementedException] NewChronistItemNotImplementedError([
        System.Reflection.MethodInfo]$method,
        [string[]]$paragraphs
    ) {
        $signature  = [ChronistErrors]::GetMethodSignature($method)
        $preamble   = "Types derived from [ChronistItem] must implement a method with the following signature:"
        $paragraphs = @($preamble, $signature) + $paragraphs
        $message    = ($paragraphs -join "`n`n").Trim()

        return [System.NotImplementedException]::new($message)
    }

    static [string] GetMethodSignature([System.Reflection.MethodInfo]$method) {
        $signature = ''
        if ($method.CustomAttributes.AttributeType -contains [System.Management.Automation.HiddenAttribute]) {
            $signature += 'hidden '
        }
        if ($method.IsStatic) {
            $signature += 'static '
        }
        $signature += '[{0}] ' -f $method.ReturnType.FullName
        $signature += '{0} (' -f $method.Name
        $parameters = $method.GetParameters()

        if ($null -eq $parameters -or $parameters.Count -eq 0) {
            return "$signature)"
        }
        for ($i = 0; $i -lt $parameters.Count; $i++) {
            $parameter = $parameters[$i]
            $signature += "`n`t[{0}] `${1}" -f $parameter.ParameterType.FullName, $parameter.Name
            if ($i -lt ($parameters.Count - 1)) {
                $signature += ','
            }
        }
        return "$signature`n)"
    }
}

class ChronistDatum {
    #region Static methods
    static [ChronistDatum] From([hashtable]$definition) {
        return [ChronistDatum]::new($definition)
    }
    #endregion Static methods
    #region Instance properties
    [string] $PropertyName
    [string] $KeyName
    [type]   $ValueType
    [bool]   $Required
    [bool]   $Nullable
    #endregion Instance properties

    #region Exception generators
    hidden [void] MissingRequiredException(
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        $message = "Missing required key '{0}' of type [{1}]" -f @(
            $this.KeyName
            $this.ValueType.FullName
        )
        $exception = [System.IO.InvalidDataException]::new($message)

        if ($null -eq $exceptionsList) {
            throw $exception
        }

        $exceptionsList.Add($exception)
    }
    hidden [void] InvalidTypeException(
        [object]$value,
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        $message = "Defined key '{0}' as [{1}] instead of [string]" -f @(
            $this.KeyName
            $value.GetType().FullName
        )
        $exception = [System.IO.InvalidDataException]::new($message)

        if ($null -eq $exceptionsList) {
            throw $exception
        }

        $exceptionsList.Add($exception)
    }
    hidden [void] StringEmptyException(
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        $message = "Key '{0}' must be a string that isn't null, empty, or only includes whitespace." -f @(
            $this.KeyName
        )
        $exception = [System.IO.InvalidDataException]::new($message)

        if ($null -eq $exceptionsList) {
            throw $exception
        }

        $exceptionsList.Add($exception)
    }
    hidden [void] InvalidEnumValueException(
        [string]$value,
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        $message = "Defined key '{0}' as invalid value '{1}'. Valid values are [{2}] enumerations: {3}" -f @(
            $this.KeyName
            $value,
            [ChronistUtil]::PrettyConcatValues($this.ValueType.GetEnumNames())
        )
        $exception = [System.IO.InvalidDataException]::new($message)

        if ($null -eq $exceptionsList) {
            throw $exception
        }

        $exceptionsList.Add($exception)
    }
    hidden static [System.ArgumentException] UndefinedPropertyNameException() {
        $message = @(
                'The specified property name is null, empty, or consists of only white-space characters.'
                'Provide a value for property name that contains non white-space characters.'
            ) -join ' '
            return [System.ArgumentException]::new($message)
    }
    hidden static [System.ArgumentException] UndefinedValueTypeException() {
        $message = @(
            'The specified value type is null. Provide a type for the datum.'
            'If the datum can be of any type, specify the type as [object].'
        ) -join ' '
        return [System.ArgumentException]::new($message)
    }
    #endregion Exception generators

    #region Validate* methods
    hidden [void] ValidateNotEmpty(
        [hashtable]$data,
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        if ([string]::IsNullOrWhiteSpace($data[$this.KeyName])) {
            $this.StringEmptyException($exceptionsList)
        }
    }

    hidden [void] ValidateString(
        [hashtable]$data,
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        $value = $data[$this.KeyName]

        if (
            $data.ContainsKey($this.KeyName) -and
            $null -ne $data[$this.KeyName] -and
            $data[$this.KeyName] -isnot [string]
        ) {
            $this.InvalidType($value, $exceptionsList)
        }
    }
    hidden [void] ValidateEnum(
        [hashtable]$data,
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        $value = $data[$this.KeyName]

        if (
            $data.ContainsKey($this.KeyName) -and
            $this.ValueType.GetEnumNames() -notcontains $value
        ) {
            $this.InvalidEnumValueException($value, $exceptionsList)
        }
    }

    hidden [void] ValidateNullableScalarType(
        [hashtable]$data,
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        $value = $data[$this.KeyName]

        if (
            $data.ContainsKey($this.KeyName) -and
            $null -ne $value -and
            $value -isnot $this.ValueType
        ) {
            $this.InvalidTypeException($value, $exceptionsList)
        }
    }

    hidden [void] ValidateScalarType(
        [hashtable]$data,
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        $value = $data[$this.KeyName]

        if (
            $data.ContainsKey($this.KeyName) -and
            $value -isnot $this.ValueType
        ) {
            $this.InvalidTypeException($value, $exceptionsList)
        }
    }

    hidden [void] ValidateCollectionType(
        [hashtable]$data,
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        $value = $data[$this.KeyName]

        if (
            $data.ContainsKey($this.KeyName) -and
            $null -ne $value -and
            $null -eq ($value -as $this.ValueType)
        ) {
            $this.InvalidTypeException($value, $exceptionsList)
        }
    }

    hidden [void] ValidateRequired(
        [hashtable]$data,
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        if (-not $data.ContainsKey($this.KeyName)) {
            $this.MissingRequiredException($exceptionsList)
        }
    }

    [void] Validate(
        [hashtable]$data,
        [System.Collections.Generic.List[System.Exception]]$exceptionsList
    ) {
        if ($this.Required) {
            $this.ValidateRequired()
        }

        if ($this.ValueType -eq [string] -and $this.Nullable) {
            $this.ValidateString($data, $exceptionsList)
        } elseif ($this.ValueType -eq [string]) {
            $this.ValidateNotEmpty($data, $exceptionsList)
        } elseif ($this.ValueType.IsSubclassOf([System.Enum])) {
            $this.ValidateEnum($data)
        } elseif ($this.ValueType.IsSubclassOf([System.Array])) {
            $this.ValidateCollectionType($data, $exceptionsList)
        } elseif ($this.Nullable) {
            $this.ValidateNullableScalarType($data, $exceptionsList)
        } else {
            $this.ValidateScalarType($data, $exceptionsList)
        }
    }

    [void] Validate([hashtable]$data) {
        $this.Validate($data, $null)
    }
    #endregion Validate* methods

    static [string] InferKeyName([string]$propertyName) {''
        $pattern = @(
            '(?<=.)'    #
            '(?=[A-Z])' #
        ) -join ''

        return [regex]::replace(
            $propertyName,
            $pattern,
            '_'
        ).ToLower()
    }
    [void] InferKeyName() {
        if ([string]::IsNullOrWhiteSpace($this.KeyName)) {
            $this.KeyName = [ChronistDatum]::InferKeyName($this.PropertyName)
        }
    }
    ChronistDatum() {}

    ChronistDatum(
        [string]$propertyName,
        [string]$keyName,
        [type]$valueType,
        [bool]$required,
        [bool]$nullable
    ) {
        if ([string]::IsNullOrWhiteSpace($propertyName)) {
            throw [ChronistDatum]::UndefinedPropertyNameException()
        }
        if ($null -eq $valueType) {
            throw [ChronistDatum]::UndefinedValueTypeException()
        }
        $this.PropertyName = $propertyName
        $this.KeyName      = $keyName
        $this.ValueType    = $valueType
        $this.Required     = $required
        $this.Nullable     = $nullable

        $this.InferKeyName()
    }

    ChronistDatum(
        [string]$propertyName,
        [string]$keyName,
        [type]$valueType
    ) {
        if ([string]::IsNullOrWhiteSpace($propertyName)) {
            throw [ChronistDatum]::UndefinedPropertyNameException()
        }
        if ($null -eq $valueType) {
            throw [ChronistDatum]::UndefinedValueTypeException()
        }

        $this.PropertyName = $propertyName
        $this.KeyName      = $keyName
        $this.ValueType    = $valueType

        $this.InferKeyName()
    }

    ChronistDatum(
        [string]$propertyName,
        [type]$valueType
    ) {
        if ([string]::IsNullOrWhiteSpace($propertyName)) {
            throw [ChronistDatum]::UndefinedPropertyNameException()
        }
        if ($null -eq $valueType) {
            throw [ChronistDatum]::UndefinedValueTypeException()
        }

        $this.PropertyName = $propertyName
        $this.ValueType    = $valueType

        $this.InferKeyName()
    }

    ChronistDatum([hashtable]$definition) {
        $definitionPropertyName = $definition['PropertyName']
        $definitionKeyName      = $definition['KeyName']
        $definitionValueType    = $definition['ValueType']
        $definitionRequired     = $definition['Required']
        $definitionNullable     = $definition['Nullable']

        if ([string]::IsNullOrWhiteSpace($definitionPropertyName)) {
            throw [ChronistDatum]::UndefinedPropertyNameException()
        }
        if ($null -eq $definitionValueType) {
            throw [ChronistDatum]::UndefinedValueTypeException()
        }

        $this.PropertyName = $definitionPropertyName
        $this.KeyName      = $definitionKeyName
        $this.ValueType    = $definitionValueType

        if ($null -ne $definitionRequired){
            $this.Required = $definitionRequired
        }
        if ($null -ne $definitionNullable){
            $this.Nullable = $definitionNullable
        }

        $this.InferKeyName()
    }
}

class ChronistData {
    static [ChronistData] From(
        [System.Collections.Specialized.OrderedDictionary]$propertyDefinitions
    ) {
        $data = [ChronistData]::new()
        foreach ($propertyName in $propertyDefinitions.Keys) {
            $definition                 = $propertyDefinitions[$propertyName]
            $definition['PropertyName'] = $propertyName

            $data.AddProperty([ChronistDatum]::From($definition))
        }

        return $data
    }
    [System.Collections.Generic.List[ChronistDatum]]$Properties

    [void] Initialize() {
        $this.Properties ??= [System.Collections.Generic.List[ChronistDatum]]::new()
    }
    #region    Add* methods
    [void] AddProperty([ChronistDatum]$propertyDatum) {
        $this.Properties.Add($propertyDatum)
    }
    [void] AddProperty(
        [string]$propertyName,
        [string]$keyName,
        [type]$valueType,
        [bool]$required,
        [bool]$nullable
    ) {
        if ($propertyName -in $this.Properties.PropertyName) {
            return
        }

        $this.Properties.Add([ChronistDatum]::new(
            $propertyName,
            $keyName,
            $valueType,
            $required,
            $nullable
        ))
    }
    [void] AddProperty(
        [string]$propertyName,
        [string]$keyName,
        [type]$valueType
    ) {
        $this.AddProperty($propertyName, $keyName, $valueType, $false, $false)
    }
    [void] AddProperty(
        [string]$propertyName,
        [type]$valueType
    ) {
        $this.AddProperty($propertyName, $null, $valueType, $false, $false)
    }
    [void] AddRequiredProperty(
        [string]$propertyName,
        [string]$keyName,
        [type]$valueType,
        [bool]$nullable
    ) {
        $this.AddProperty($propertyName, $keyName, $valueType, $true, $nullable)
    }
    [void] AddRequiredProperty(
        [string]$propertyName,
        [type]$valueType,
        [bool]$nullable
    ) {
        $this.AddProperty($propertyName, $null, $valueType, $true, $nullable)
    }
    [void] AddRequiredProperty(
        [string]$propertyName,
        [string]$keyName,
        [type]$valueType
    ) {
        $this.AddProperty($propertyName, $keyName, $valueType, $true, $false)
    }
    [void] AddRequiredProperty(
        [string]$propertyName,
        [type]$valueType
    ) {
        $this.AddProperty($propertyName, $null, $valueType, $true, $false)
    }
    [void] AddOptionalProperty(
        [string]$propertyName,
        [string]$keyName,
        [type]$valueType,
        [bool]$nullable
    ) {
        $this.AddProperty($propertyName, $keyName, $valueType, $false, $nullable)
    }
    [void] AddOptionalProperty(
        [string]$propertyName,
        [type]$valueType,
        [bool]$nullable
    ) {
        $this.AddProperty($propertyName, $null, $valueType, $false, $nullable)
    }
    [void] AddOptionalProperty(
        [string]$propertyName,
        [string]$keyName,
        [type]$valueType
    ) {
        $this.AddProperty($propertyName, $keyName, $valueType, $false, $false)
    }
    [void] AddOptionalProperty(
        [string]$propertyName,
        [type]$valueType
    ) {
        $this.AddProperty($propertyName, $null, $valueType, $false, $false)
    }
    [void] AddNullableProperty(
        [string]$propertyName,
        [string]$keyName,
        [type]$valueType,
        [bool]$required
    ) {
        $this.AddProperty($propertyName, $keyName, $valueType, $required, $true)
    }
    [void] AddNullableProperty(
        [string]$propertyName,
        [type]$valueType,
        [bool]$required
    ) {
        $this.AddProperty($propertyName, $null, $valueType, $required, $true)
    }
    [void] AddNullableProperty(
        [string]$propertyName,
        [string]$keyName,
        [type]$valueType
    ) {
        $this.AddProperty($propertyName, $keyName, $valueType, $false, $true)
    }
    [void] AddNullableProperty(
        [string]$propertyName,
        [type]$valueType
    ) {
        $this.AddProperty($propertyName, $null, $valueType, $false, $true)
    }
    #endregion Add* methods

    [System.Collections.Specialized.OrderedDictionary] Convert([object]$item) {
        $data           = [System.Collections.Specialized.OrderedDictionary]::new()
        $itemProperties = Get-Member -InputObject $item -MemberType Properties
        | Select-Object -ExpandProperty Name

        foreach ($datum in $this.Properties) {
            $propertyName = $datum.PropertyName
            if ($propertyName -in $itemProperties) {
                $data.Add($datum.KeyName, $item.$propertyName)
            }
        }

        return $data
    }

    [void] Validate([hashtable]$data) {
        $exceptions = [System.Collections.Generic.List[System.Exception]]::new()
        foreach ($datum in $this.Properties) {
            $datum.Validate($data, $exceptions)
        }

        if ($exceptions.Count -ge 1) {
            throw [System.AggregateException]::(
                "Data failed one or more property validations.",
                $exceptions
            )
        }
    }

    ChronistData() {
        $this.Initialize()
    }
}

enum ChronistFormat {
    #region    Definitions
    G = 0 # General, Short - for terminal/synopsis
    M = 1 # Markdown - for export or pretty terminal
    Y = 2 # YAML - for export
    J = 3 # JSON - for export
    #endregion Definitions
    #region    Aliases
    S        = 0
    General  = 0
    Short    = 0
    Markdown = 1
    YAML     = 2
    JSON     = 3
    #endregion Aliases
}

class ChronistConfiguration {
    #region    Static properties
    #endregion Static properties
    #region    Static methods
    static [void] ValidateFileData([hashtable]$fileData) {
        $definesProjectName = $fileData.ContainsKey('project_name')
        if ($definesProjectName -and $fileData['project_name'] -isnot [string]) {
            # Invalid type
        } elseif ($definesProjectName -and [string]::IsNullOrWhiteSpace($fileData['project_name'])) {
            # Must have value
        }

        $definesOverview = $fileData.ContainsKey('overview')
        if ($definesOverview -and $fileData['overview'] -isnot [string]) {
            # Invalid type
        } elseif ($definesOverview -and [string]::IsNullOrWhiteSpace($fileData['overview'])) {
            # Must have value
        }

        $definesGitHubUrl = $fileData.ContainsKey('github_url')
        if ($definesGitHubUrl -and $fileData['github_url'] -isnot [string]) {
            # Invalid type
        } elseif ($definesGitHubUrl -and [string]::IsNullOrWhiteSpace($fileData['github_url'])) {
            # Must have value
        }

    }
    static [void] ValidateFileData([System.IO.FileInfo]$file) {
        [ChronistConfiguration]::ValidateFileData(
            [ChronistUtil]::ReadFileData($file)
        )
    }
    #endregion Static methods
    #region    Instance properties
    [string] $ProjectName
    [string] $Overview
    [uri]    $GitHubUrl
    #endregion Instance properties
    #region    Instance methods
    #endregion Instance methods
    #region    Constructors
    #endregion Constructors
}

class ChronistMarkdownFormatter {
    [System.Func[
        System.Collections.Specialized.OrderedDictionary, # Chronist item data
        hashtable,                                        # Configuration
        string
    ]] $Function

    [string] Format(
        [ChronistItem]$item,
        [hashtable]$configuration
    ) {
        return $this.Format($item.ToData(), $configuration)
    }

    [string] Format(
        [System.Collections.Specialized.OrderedDictionary]$itemData,
        [hashtable]$configuration
    ) {
        if ($null -eq $this.Function) {
            # error?
        }

        if ($null -eq $configuration) {
            # get default config?
        }

        return $this.Function.Invoke($itemData, $configuration)
    }

    [string] Format([ChronistItem]$item) {
        return $this.Format($item, $null)
    }

    static [System.Func[
        System.Collections.Specialized.OrderedDictionary, # Chronist item data
        hashtable,                                        # Configuration
        string
    ]] GetBuiltInEntryFunction() {
        return [System.Func[
            System.Collections.Specialized.OrderedDictionary, # Chronist item data
            hashtable,                                        # Configuration
            string
        ]]{
            [OutputType([string])]
            param(
                [System.Collections.Specialized.OrderedDictionary]
                $EntryData,

                [hashtable]
                $Configuration
            )

            $builder    = [System.Text.StringBuilder]::new()
            $hasID      = -not [string]::IsNullOrWhiteSpace($entryData['id'])
            $hasDetails = -not [string]::IsNullOrWhiteSpace($entryData['details'])

            if ($hasID) {
                $null = $builder.Append('- <a id="{0}"></a>' -f $entryData['ID'])
                $null = $builder.Append("`n`n").Append('  ')
            } else {
                $null = $builder.Append('- ')
            }

            # Select the content to display - details if available, otherwise synopsis.
            $content = $hasDetails ? $entry.Details : $entry.Synopsis

            # Write the content line by line with a two-space prefix.
            $lines   = $content -split '\r?\n'
            for ($i = 0 ; $i -lt $lines.Count ; $i++) {
                if ($i -eq 0) {
                    $null = $builder.Append($lines[$i]).Append("`n")
                } elseif ([string]::IsNullOrWhiteSpace($lines[$i])) {
                    $null = $builder.Append("`n")
                } else {
                    $null = $builder.Append("  $($lines[$i])").Append("`n")
                }
            }

            return $builder.ToString()
        }
    }
    #region    Constructors
    ChronistMarkdownFormatter() {}
    ChronistMarkdownFormatter([scriptblock]$scriptblock) {
        $this.Function = $scriptblock
    }
    ChronistMarkdownFormatter(
        [System.Func[
            System.Collections.Specialized.OrderedDictionary, # Chronist item data
            hashtable,                                        # Configuration
            string
        ]]$formatFunction
    ) {
        $this.Function = $formatFunction
    }

    ChronistMarkdownFormatter([type]$chronistType) {
        switch ($chronistType) {
            {$_ -eq [ChronistEntry] }      { $this.Function = [ChronistMarkdownFormatter]::GetBuiltInEntryFunction }
            # {$_ -eq [ChronistUnreleased] } { }
            # {$_ -eq [ChronistRelease] }    { }
            # {$_ -eq [ChronistChangelog] }  { }
            default {
                # error, invalid type
            }
        }
    }
    #endregion Constructors
}
class ChronistFormatProvider : IFormatProvider, ICustomFormatter {
    #region    IFormatProvider methods
    [object] GetFormat([type]$formatType) {
        if ($formatType -is [System.ICustomFormatter]) {
            return $this
        }

        return $null
    }
    #endregion IFormatProvider methods
    #region    ICustomFormatter methods
    [string] Format([string]$format, [object]$arg, [System.IFormatProvider]$formatProvider) {
        # Short circuit if formatted argument isn't a chronist item.
        if ($arg -isnot [ChronistItem]) {
            try {
                return $this.HandleOtherFormats($format, $arg)
            } catch [System.FormatException] {
                throw [System.FormatException]::new(
                    ("The format of '{0}' is invalid." -f $format), # Message
                    $_                                              # Inner exception
                )
            }
        }

        if ([string]::IsNullOrWhiteSpace($format)) {
            $format = 'G'
        }
        # Try to convert specified value to valid format
        $validFormat = $format -as [ChronistFormat]

        if ($null -eq $validFormat) {
            try {
                return $this.HandleOtherFormats($format, $arg)
            } catch [System.FormatException] {
                throw [System.FormatException]::new(
                    ("The format of '{0}' is invalid." -f $format), # Message
                    $_                                              # Inner exception
                )
            }
        }

        switch ($validFormat) {
            M { return $this.FormatMarkdown($arg) }
            J { return $this.FormatJson($arg) }
            Y { return $this.FormatYaml($arg) }
        }

        return $arg.ToString()
    }

    [string] HandleOtherFormats([string]$format, [object]$arg) {
        if ($arg -is [System.IFormattable]) {
            return ([System.IFormattable]$arg).ToString($format, [cultureinfo]::CurrentCulture)
        }
        if ($null -ne $arg) {
            return $arg.ToString()
        }

        return [string]::Empty
    }
    #endregion ICustomFormatter methods
    #region    Static default properties
    static [ChronistMarkdownFormatter] $DefaultEntryFormatter = [ChronistMarkdownFormatter]::new([ChronistEntry])
    # static [ChronistMarkdownFormatter] $DefaultUnreleasedFormatter
    # static [ChronistMarkdownFormatter] $DefaultReleaseFormatter
    # static [ChronistMarkdownFormatter] $DefaultChangelogFormatter
    #endregion Static default properties

    #region    Instance properties
    [ChronistMarkdownFormatter] $EntryFormatter
    # [ChronistMarkdownFormatter] $UnreleasedFormatter
    # [ChronistMarkdownFormatter] $ReleaseFormatter
    # [ChronistMarkdownFormatter] $ChangelogFormatter
    #endregion Instance properties

    #region Custom format methods
    #endregion Custom format methods

    [void] Initialize() {
        $this.EntryFormatter ??= [ChronistFormatProvider]::DefaultEntryFormatter ??
                                 [ChronistMarkdownFormatter]::new([ChronistEntry])
    }

    [void] Validate() {
        # Validate each formatter.
    }

    ChronistFormatProvider() {
        $this.Initialize()
        $this.Validate()
    }
}

class ChronistItem : System.IFormattable {
    static [regex] GetFileNameParsingPattern() {
        $method = [ChronistItem].GetMethod(
            'GetFileNameParsingPattern', # Name
            [type[]]@()                  # Parameter types
        )
        $paragraphs = @(
            'The method must return a regular expression that can parse relevant information about the item'
            "from the item file's **FullName**."
        ) -join ' '

        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, $paragraphs)
    }
    static [hashtable] ParseFileName([string]$fileName) {
        $method = [ChronistItem].GetMethod(
            'ParseFileName',    # Name
            [type[]]@([string]) # Parameter types
        )
        $returnParagraph = @(
            "The method must return a hashtable representing the data parsed from the item files **FullName**."
            'Chronist uses this data to inifer information about the item. Data in the item file overrides'
            'information inferred from the name, if present in both.'
        ) -join ' '
        $parameterParagraph = @(
            "The method must take a single string parameter called 'fileName'."
            'Chronist always calls this method with the **FullName** of a file.'
        ) -join ' '
        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, @($returnParagraph, $parameterParagraph))
    }
    static [hashtable] ParseFileName ([System.IO.FileInfo]$file) {
        $method = [ChronistItem].GetMethod(
            'ParseFileName',    # Name
            [type[]]@([string]) # Parameter types
        )
        $returnParagraph = @(
            "The method must return a hashtable representing the data parsed from the item files **FullName**."
            'Chronist uses this data to inifer information about the item. Data in the item file overrides'
            'information inferred from the name, if present in both.'
        ) -join ' '
        $implementationParagraph = @(
            'The simplest implementation for this overload is to return the output of the same static method for the'
            'class, passing the **FullName** as the string parameter. For example, this method overload is'
            'implemented in [ChronistEntry] as:'
        ) -join ' '
        $exampleParagraph = @(
            "`tstatic [hashtable] ParseFileName ([System.IO.FileInfo]`$file) {"
            "`t`treturn [ChronistEntry]::ParseFileName(`$file.FullName)"
            "`t}"
        ) -join "`n"
        $paragraphs = @($returnParagraph, $implementationParagraph, $exampleParagraph)

        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, $paragraphs)
    }
    static [void] ValidateFileData([hashtable]$fileData) {
        $method = [ChronistItem].GetMethod(
            'ValidateFileData',    # Name
            [type[]]@([hashtable]) # Parameter types
        )
        $returnParagraph = @(
            "The method must validate a hashtable representing the data parsed from an item's file."
            'This validation helps to ensure that the data in the file can be correctly assigned to'
            "the item's properties."
        ) -join ' '
        $paragraphs = @($returnParagraph)

        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, $paragraphs)
    }
    static [void] ValidateFileData([System.IO.FileInfo]$file) {
        $method = [ChronistItem].GetMethod(
            'ValidateFileData',             # Name
            [type[]]@([System.IO.FileInfo]) # Parameter types
        )
        $returnParagraph = @(
            "The method must validate a hashtable representing the data parsed from an item's file."
            'This validation helps to ensure that the data in the file can be correctly assigned to'
            "the item's properties."
        ) -join ' '
        $implementationParagraph = @(
            'The simplest implementation for this overload is to return the output of the same static method for the'
            'class, first using [ChronistUtil]::ReadFileData() method to retrieve the data.'
            'For example, this method overload is implemented in [ChronistEntry] as:'
        ) -join ' '
        $exampleParagraph = @(
            "`tstatic [void] ValidateFileData([System.IO.FileInfo]`$file) {"
            "`t`t[ChronistEntry]::ValidateFileData("
            "`t`t`t[ChronistUtil]::ReadFileData(`$file)"
            "`t`t)"
            "`t}"
        ) -join "`n"
        $paragraphs = @($returnParagraph, $implementationParagraph, $exampleParagraph)

        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, $paragraphs)
    }
    hidden static [void] ValidateImplementation([type]$derivedType) {
        # Check that it implements all methods etc
    }

    #region    Interface methods
    [string] ToString(
        [string]$format,
        [System.IFormatProvider]$formatProvider
    ) {
        <#
            .SYNOPSIS
            Implements IFormattable
        #>
        return ''

        if ([string]::IsNullOrWhiteSpace($format)) {
            $format = 'G'
        }
        if ($null -eq $formatProvider) {
            $formatProvider = [ChronistFormatProvider]::new()
        }
    }

    [string] ToString() {
        return $this.ToString($null, $null)
    }
    [string] ToString([string]$format) {
        return $this.ToString($format, $null)
    }
    [string] ToString([System.IFormatProvider]$formatProvider) {
        return $this.ToString('G', $formatProvider)
    }
    #endregion Interface methods

    #region    To* methods
    [ordered] ToData() {
        $method = [ChronistItem].GetMethod(
            'ToData',    # Name
            [type[]]@() # Parameter types
        )
        $returnParagraph = @(
            "The method must return an ordered dictionary representing the properties of the item"
            "for serialization to JSON or YAML. This is primarily used for exporting to item files."
            "Due to the way ConvertTo-Json serializes hidden properties and null values, this method"
            "provides definitive control over how the item data is represented when serialized."
        ) -join ' '
        $paragraphs = @($returnParagraph)

        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, $paragraphs)
    }
    [string] ToShortString() {
        $method = [ChronistItem].GetMethod(
            'ToShortString', # Name
            [type[]]@()      # Parameter types
        )
        $returnParagraph = @(
            "The method must return a short string for the item, which can be displayed in the terminal"
            "or in an overview list. This method is called when using ToString() and when formatting with"
            "the 'G' (General) or 'S' (Short) formats."
        ) -join ' '
        $paragraphs = @($returnParagraph)
        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, $paragraphs)
    }
    [string] ToMarkdown() {
        $method = [ChronistItem].GetMethod(
            'ToMarkdown', # Name
            [type[]]@()   # Parameter types
        )
        $returnParagraph = @(
            "The method must return a block of Markdown text as a single string."
            "This method is called when formatting with the 'M' (Markdown) format."
        ) -join ' '
        $implementationParagraph = @(
            'This method operates without any parameters and should be used to select the'
            'appropriate [ChronistMarkdownTemplate] or [ChronistMarkdownFormatter] to handle'
            'the conversion of the item into Markdown.'
        ) -join ' '
        $paragraphs = @($returnParagraph, $implementationParagraph)
        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, $paragraphs)
    }
    [string] ToMarkdown([ChronistMarkdownFormatter]$formatter) {
        return $formatter.Format($this)
    }
    [string] ToJson() {
        return $this.ToData()
        | ConvertTo-Json -Depth 99 -EnumsAsStrings
    }
    [string] ToYaml() {
        [ChronistUtil]::ValidateYayamlAvailable()

        return $this.ToData()
        | Yayaml\ConvertTo-Yaml -Depth 99
    }
    #endregion To* methods

    #region    Validate instance methods
    [bool] Validate([bool]$quiet, [bool]$strict) {
        $method = [ChronistItem].GetMethod(
            'Validate',               # Name
            [type[]]@([bool], [bool]) # Parameter types
        )
        $returnParagraph = @(
            "The method must return true if the instance is a valid representation of the item."
            "If the instance is invalid and the `$quiet parameter is true, it must return false."
            "If the instance is incalid and the `$quiet parameter is false, it must throw an error."
            "The `$strict parameter enables the method to handle leniency in the validation."
        ) -join ' '
        $usageParagraph = @(
            "This method is called by the other Validate() methods and the Test() methods available"
            "on all classes derived from [ChronistItem]. "
        ) -join ' '
        $parametersParagraph = @(
            "This method must take two [bool] parameters, `$quiet and `$strict, in that order."
            "The first parameter, `$quiet, determines whether the method should return a boolean"
            "value (when `$quiet is true) or throw an error if the instance is invalid (when `$quiet"
            "is false). The second parameter, `$strict, determines whether the method should apply"
            "tighter validation to the instance. If there is no strict validation for an item,"
            "you can ignore this parameter in the implementation, but it *must* be in the method"
            "signature to support the other overloads."
        ) -join ' '
        $paragraphs = @($returnParagraph, $usageParagraph, $parametersParagraph)
        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, $paragraphs)
    }
    [void] Validate([bool]$strict) {
        $this.Validate($false, $strict)
    }
    [void] Validate() {
        $this.Validate($false, $true)
    }
    [bool] Test([bool]$strict) {
        return $this.Validate($true, $strict)
    }
    [bool] Test() {
        return $this.Validate($true, $true)
    }
    #endregion Validate instance methods

    #region    Load instance methods
    [void] Load([System.IO.FileInfo]$file) {
        $this.LoadFileName($file.FullName)
        $this.LoadFileData($file)
    }

    [void] LoadFileData([System.IO.FileInfo]$file) {
        $this.LoadFileData(
            [ChronistUtil]::ReadFileData($file)
        )
    }
    [void] LoadFileData([hashtable]$fileData) {
        $method = [ChronistItem].GetMethod(
            'LoadFileData',        # Name
            [type[]]@([hashtable]) # Parameter types
        )
        $implementationParagraph = @(
            "This method must operate on the data from one of the item's files to"
            "set the properties of the item from that data. It should leverage the"
            "derived class's static ValidateFileData() method before setting any"
            "properties."
        ) -join ' '
        $parameterParagraph = @(
            "This method must take one [hashtable] parameter called `$fileData,"
            "which represents the output of the [ChronistUtil]::ReadFileData method"
            "called against an item file."
        ) -join ' '
        $paragraphs = @($implementationParagraph, $parameterParagraph)
        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, $paragraphs)
    }

    [void] LoadFileName([string]$fileFullName) {
        $method = [ChronistItem].GetMethod(
            'LoadFileName',        # Name
            [type[]]@([string]) # Parameter types
        )
        $implementationParagraph = @(
            "This method must parse one of the item file's **FullName** to"
            "set the properties of the item from the parsed data. It should leverage the"
            "derived class's static ParseFileName() method to get the parsed data and then"
            "apply it as needed."
        ) -join ' '
        $parameterParagraph = @(
            'This method takes one [string] parameter called `$fileFullName,'
            'which represents the **FullName** of an item file.'
        ) -join ' '
        $paragraphs = @($implementationParagraph, $parameterParagraph)
        throw [ChronistErrors]::NewChronistItemNotImplementedError($method, $paragraphs)
    }
    [void] LoadFileName([System.IO.FileInfo]$file) {
        $this.LoadFileName($file.FullName)
    }
    #endregion Load instance methods
}

Class ChronistEntry : ChronistItem, System.IComparable, System.IEquatable[Object] {
    #region    Static methods
    static [ChronistData] DataDefinition() {
        return [ChronistData]::From([ordered]@{
            ID = @{
                KeyName   = 'id'
                ValueType = [string]
                Required  = $false
                Nullable  = $true
            }
            Priority = @{
                KeyName   = 'priority'
                ValueType = [int]
                Required  = $false
                Nullable  = $true
            }
            Breaking = @{
                KeyName   = 'breaking'
                ValueType = [bool]
                Required  = $false
                Nullable  = $true
            }
            Category = @{
                KeyName   = 'category'
                ValueType = [ChronistCategory]
                Required  = $false
                Nullable  = $false
            }
            Synopsis = @{
                KeyName   = 'synopsis'
                ValueType = [string]
                Required  = $true
                Nullable  = $false
            }
            Details = @{
                KeyName   = 'details'
                ValueType = [string]
                Required  = $false
                Nullable  = $true
            }
            PullRequests = @{
                KeyName   = 'pull_requests'
                ValueType = [int[]]
                Required  = $false
                Nullable  = $true
            }
            Issues = @{
                KeyName   = 'issues'
                ValueType = [int[]]
                Required  = $false
                Nullable  = $true
            }
            MergedAt = @{
                KeyName   = 'merged_at'
                ValueType = [datetime]
                Required  = $false
                Nullable  = $true
            }
        })
    }
    #endregion Data definition
    #region    File name parsing pattern
    static [regex] GetFileNameParsingPattern() {
        $pattern = @(
            '^'
            "(?:$([ChronistUtil]::GetValidCategoriesPattern())\.)?"
            "(?:$([ChronistUtil]::GetValidPriorityPattern())\.)?"
            "(?:$([ChronistUtil]::GetValidIDPattern()))?"
            [ChronistUtil]::GetValidFileExtensionPattern().ToString()
        ) -join ''

        return [regex]::new(
            $pattern,
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }
    static [hashtable] ParseFileName ([string]$fileName) {
        $fileName = Split-Path -Path $fileName -Leaf

        $pattern = [ChronistEntry]::GetFileNameParsingPattern()
        $parsed  = @{}

        if ($fileName -match $pattern) {
            if ($null -ne $Matches.category) {
                $parsed.Category = $Matches.category
            }
            if ($null -ne $Matches.priority) {
                $parsed.Priority = $Matches.priority
            }
            if ($null -ne $Matches.id) {
                $parsed.ID = $Matches.id
            }
            if ($null -ne $Matches.extension) {
                $parsed.Extension = $Matches.extension
            }
        }

        return $parsed
    }
    static [hashtable] ParseFileName ([System.IO.FileInfo]$file) {
        return [ChronistEntry]::ParseFileName($file.FullName)
    }

    static [void] ValidateFileData([hashtable]$fileData) {
        $exceptions = [System.Collections.Generic.List[System.Exception]]::new()
        [ChronistData]::ValidateMandatoryString('synopsis', $fileData, $exceptions)
        [ChronistData]::ValidateOptionalString('details', $fileData, $exceptions)
        [ChronistData]::ValidateCategory('category', $fileData, $exceptions)
        [ChronistData]::ValidateOptionalString('id', $fileData, $exceptions)
        [ChronistData]::ValidateOptionalNullableScalarType('priority', [int], $fileData, $exceptions)
        [ChronistData]::ValidateOptionalScalarType('breaking', [bool], $fileData, $exceptions)
        [ChronistData]::ValidateOptionalCollectionType('pull_requests', [int[]], $fileData, $exceptions)
        [ChronistData]::ValidateOptionalCollectionType('issues', [int[]], $fileData, $exceptions)
        [ChronistData]::ValidateOptionalNullableScalarType('merged_at', [datetime], $fileData, $exceptions)
        #todo: link references, related changes

        if ($exceptions.Count -ge 1) {
            throw [System.AggregateException]::new(
                "Data for [ChronistEntry] has one or more validation failures.",
                $exceptions
            )
        }

        # if (-not $fileData.ContainsKey('synopsis')) {
        #     # missing synopsis
        # } elseif ($fileData.synopsis -isnot [string]) {
        #     # invalid type
        # } elseif ([string]::IsNullOrWhiteSpace($fileData.synopsis)) {
        #     # empty
        # }
        # $hasDetails        = $fileData.ContainsKey('details')
        # $hasCategory       = $fileData.ContainsKey('category')
        # $hasID             = $fileData.ContainsKey('id')
        # $hasPriority       = $fileData.ContainsKey('priority')
        # $hasBreaking       = $fileData.ContainsKey('breaking')
        # $hasPullRequests   = $fileData.ContainsKey('pull_requests')
        # $hasIssues         = $fileData.ContainsKey('issues')
        # $hasMergedAt       = $filedata.ContainsKey('merged_at')
        # $hasLinkReferences = $fileData.ContainsKey('link_references')
        # $hasRelatedChanges = $fileData.ContainsKey('related_changes')

        # if (
        #     $hasDetails -and
        #     $null -ne $fileData['details'] -and
        #     $fileData['details'] -isnot [string]
        # ) {
        #     # invalid type
        # }
        # if (
        #     $hasCategory -and
        #     [ChronistCategory].GetEnumNames() -notcontains $fileData.category
        # ) {
        #     # invalid category
        # }
        # if (
        #     $hasID -and
        #     $null -ne $fileData.id -and
        #     $fileData.id -isnot [string]
        # ) {
        #     # invalid ID
        # }
        # if (
        #     $hasPriority -and
        #     $null -ne $fileData.priority -and
        #     $fileData.priority -isnot [int]
        # ) {
        #     # invalid type
        # }
        # if (
        #     $hasBreaking -and
        #     $fileData.breaking -isnot [bool]
        # ) {
        #     # invalid type
        # }
        # if (
        #     $hasPullRequests -and
        #     $null -ne $fileData.pull_requests -and
        #     $null -eq ($fileData.pull_requests -as [int[]])
        # ) {
        #     # invalid type
        # }
        # if (
        #     $hasIssues -and
        #     $null -ne $fileData.issues -and
        #     $null -eq ($fileData.issues -as [int[]])
        # ) {
        #     # invalid type
        # }
        # if (
        #     $hasMergedAt -and
        #     $null -ne $fileData.merged_at -and
        #     $null -eq ($fileData.merged_at -as [datetime])
        # ) {
        #     # invalid type
        # }
        # if (
        #     $hasLinkReferences
        # ) {
        #     # todo
        # }
        # if (
        #     $hasRelatedChanges
        # ) {
        #     # todo
        # }
    }
    static [void] ValidateFileData([System.IO.FileInfo]$file) {
        [ChronistEntry]::ValidateFileData(
            [ChronistUtil]::ReadFileData($file)
        )
    }
    #endregion Static methods

    #region    Instance properties
    [string]                               $ID
    [System.Nullable[datetime]]            $MergedAt
    [System.Nullable[int]]                 $Priority
    [bool]                                 $Breaking
    [ChronistCategory]                     $Category
    [string]                               $Synopsis
    [string]                               $Details
    [System.Collections.Generic.List[int]] $PullRequests
    [System.Collections.Generic.List[int]] $Issues
    # [ChronistLinkReferences] $LinkReferences
    [string[]]               $RelatedChanges
    #endregion Instance properties

    #region    System.IEquatable methods
    [bool] Equals([object]$other) {
        <#
            .SYNOPSIS
            Implements IEquatable
        #>

        # If the other object is null, we can't compare it.
        if ($null -eq $other) {
            return $false
        }

        # If the other object isn't a temperature, we can't compare it.
        [ChronistEntry]$otherEntry = $other -as [ChronistEntry]
        if ($null -eq $otherEntry) {
            return $false
        }
        if ($this.Category -ne $otherEntry.Category)             { return $false }
        if ($this.Synopsis -ne $otherEntry.Synopsis)             { return $false }
        if ($this.Priority -ne $otherEntry.Priority)             { return $false }
        if ($this.MergedAt -ne $otherEntry.MergedAt)             { return $false }
        if ($this.ID -ne $otherEntry.ID)                         { return $false }
        if ($this.Details -ne $otherEntry.Details)               { return $false }
        if ($this.PullRequests -ne $otherEntry.PullRequests)     { return $false }
        if ($this.Issues -ne $otherEntry.Issues)                 { return $false }
        if ($this.LinkReferences -ne $otherEntry.LinkReferences) { return $false }
        if ($this.RelatedChanges -ne $otherEntry.RelatedChanges) { return $false }

        return $true
    }
    #endregion System.IEquatable methods

    #region    System.IComparable methods
    [int] CompareTo([Object]$other) {
        <#
            .SYNOPSIS
            Implements IComparable
        #>

        # If the other object's null, consider this instance "greater than" it
        if ($null -eq $other) {
            return 1
        }
        # If the other object isn't an entry, we can't compare it.
        [ChronistEntry]$otherEntry = $Other -as [ChronistEntry]
        if ($null -eq $otherEntry) {
            # error
        }

        # If the categories aren't the same, sort on category
        if ($this.Category -ne $otherEntry.Category) {
            return $this.Category.CompareTo($otherEntry.Category)
        }
        # If both define a priority, compare them - otherwise a defined priority
        # sorts higher than an undefined priority
        $thisDefinesPriority  = $null -ne $this.Priority
        $otherDefinesPriority = $null -ne $otherEntry.Priority
        if ($thisDefinesPriority -and $otherDefinesPriority) {
            return $this.Priority.CompareTo($otherEntry.Priority)
        } elseif ($thisDefinesPriority) {
            return -1
        } elseif ($otherDefinesPriority) {
            return 1
        }
        # If both define a merged date, compare them - otherwise a defined merged
        # date sorts higher than an undefined one.
        $thisDefinesMergedAt  = $null -ne $this.MergedAt
        $otherDefinesMergedAt = $null -ne $otherEntry.MergedAt
        if ($thisDefinesMergedAt -and $otherDefinesMergedAt) {
            return $this.MergedAt.CompareTo($otherDefinesMergedAt)
        } elseif ($thisDefinesMergedAt) {
            return -1
        } elseif ($otherDefinesMergedAt) {
            return 1
        }

        # If both define PRs, compare oldest PR - otherwise a defined PR list
        # sorts higher than an undefined one.
        $thisDefinesPRs  = $this.PullRequests.Count -ge 1
        $otherdefinesPRs = $otherEntry.PullRequests.Count -ge 1
        if ($thisDefinesPRs -and $otherdefinesPRs) {
            # compare first pr for both
        } elseif ($thisDefinesPRs) {
            return -1
        } elseif ($otherdefinesPRs) {
            return 1
        }
        # If the entries are in the same category without priority, merged at,
        # or pull requests defined, they're equivalent for sorting.
        return 0
    }
    #endregion System.IComparable methods

    #region    Load methods
    [void] LoadFileData([hashtable]$fileData) {
        [ChronistEntry]::ValidateFileData($fileData)
        # Always load the synopsis, which is mandatory
        $this.Synopsis = $fileData['synopsis']
        # Load remaining optional values
        if (-not [string]::IsNullOrWhiteSpace($fileData['category'])) {
            $this.Category = $fileData['category']
        }
        if (-not [string]::IsNullOrWhiteSpace($fileData['id'])) {
            $this.ID = $fileData['id']
        }
        if ($fileData.ContainsKey('priority')) {
            $this.Priority = $fileData['priority']
        }
        if ($fileData.ContainsKey('breaking')) {
            $this.Breaking = $fileData['breaking']
        } elseif (
            $this.Category -in @(
                [ChronistCategory]::Removed,
                [ChronistCategory]::Changed
            )
        ) {
            $this.Breaking = $false
        }
        if (-not [string]::IsNullOrWhiteSpace($fileData['details'])) {
            $this.Details = $fileData['details']
        }
        if ($fileData.ContainsKey('pull_requests')) {
            $this.PullRequests = $fileData['pull_requests']
        }
        if ($fileData.ContainsKey('issues')) {
            $this.Issues = $fileData['issues']
        }
        if ($fileData.ContainsKey('link_references')) {
            # add link references
        }
        if ($fileData.ContainsKey('related_changes')) {
            # Add related change IDs
        }
    }
    [void] LoadFileName([string]$fileFullName) {
        $parsed = [ChronistEntry]::ParseFileName($fileFullName)
        if (-not $parsed.ContainsKey('Extension')) {
            # error
        }
        if ($parsed.ContainsKey('Category')) {
            $this.Category = $parsed['Category']
        }
        if ($parsed.ContainsKey('ID')) {
            $this.ID = $parsed['ID']
        }
        if ($parsed.ContainsKey('Priority')) {
            $this.Priority = $parsed['Priority']
        }
    }
    #endregion Load methods

    #region    To* methods
    [ordered] ToData() {
        $data = [ordered]@{}
        if (-not [string]::IsNullOrWhiteSpace($this.ID)) {
            $data.Add('id', $this.ID)
        }
        if ($null -ne $this.Priority) {
            $data.Add('priority', $this.Priority)
        }
        if ($this.Category -ne [ChronistCategory]::Undefined) {
            $data.Add('breaking', $this.Breaking)
            $data.Add('category', $this.Category)
        }
        if (-not [string]::IsNullOrWhiteSpace($this.Synopsis)) {
            $data.Add('synopsis', $this.Synopsis)
        }
        if (-not [string]::IsNullOrWhiteSpace($this.Details)) {
            $data.Add('details', $this.Details)
        }
        if ($null -ne $this.PullRequests) {
            $data.Add('pull_requests', $this.PullRequests)
        }
        if ($null -ne $this.Issues) {
            $data.Add('issues', $this.Issues)
        }
        # ToDo: Implement link references and related changes
        # if ($null -ne $this.LinkReferences) {
        #     $data.Add('link_references', $this.LinkReferences)
        # }
        # if ($null -ne $this.RelatedChangeIDs) {
        #     $data.Add('related_changes', $this.RelatedChangeIDs)
        # }

        return $data
    }

    [string] ToShortString() {
        return $this.Synopsis
    }

    [string] ToMarkdown() {
        return ''
    }
    #endregion To* methods

    #region    Validate methods
    [bool] Validate([bool]$quiet, [bool]$strict) {
        if ([string]::IsNullOrWhiteSpace($this.Synopsis)) {
            # error missing synopsis
            if ($quiet) { return $false}
        }
        if ($this.Category -eq [ChronistCategory]::Undefined) {
            # error no category
            if ($quiet) { return $false }
        }
        if ($strict -and $this.PullRequests.Count -eq 0) {
            # error no related PRs
            if ($quiet) { return $false}
        }

        return $true
    }
    #endregion Validate methods

    #region    Instance methods
    [void] Initialize() {
        $this.PullRequests = [System.Collections.Generic.List[int]]::new()
        $this.Issues       = [System.Collections.Generic.List[int]]::new()
    }
    #endregion Instance methods
    #region    Constructors
    static ChronistEntry() {}

    ChronistEntry() {
        $this.Initialize()
    }

    ChronistEntry(
        [string]$synopsis,
        [ChronistCategory]$category
    ) {
        $this.Initialize()
        $this.Synopsis = $synopsis
        $this.Category = $category
    }

    ChronistEntry(
        [System.IO.FileInfo]$file
    ) {
        $this.Initialize()
        $this.Load($file)
    }
    #endregion Constructors
}

Class ChronistUnreleased : ChronistItem, System.IEquatable[Object] {
    #region    Static methods
    static [regex] GetFileNameParsingPattern() {
        return $null
        # $pattern = @(
        #     '^'
        #     "unreleased\."
        #     [ChronistUtil]::GetValidFileExtensionPattern().ToString()
        # ) -join ''

        # return [regex]::new(
        #     $pattern,
        #     [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        # )
    }
    static [hashtable] ParseFileName ([string]$fileName) {
        return $null
        # $fileName = Split-Path -Path $fileName -Leaf

        # $pattern = [ChronistUnreleased]::GetFileNameParsingPattern()
        # $parsed  = @{}

        # if ($fileName -match $pattern) {
        # }

        # return $parsed
    }
    static [hashtable] ParseFileName ([System.IO.FileInfo]$file) {
        return [ChronistUnreleased]::ParseFileName($file.FullName)
    }

    static [void] ValidateFileData([hashtable]$fileData) {
        if (
            $fileData.ContainsKey('breaking') -and
            $fileData['breaking'] -isnot [bool]
        ) {
            # invalid type
        }

        if (
            $fileData.ContainsKey('synopsis') -and
            $null -ne $fileData['synopsis'] -and
            $fileData['synopsis'] -isnot [string]
        ) {
            # invalid type
        }

        if (
            $fileData.ContainsKey('details') -and
            $null -ne $fileData['details'] -and
            $fileData['details'] -isnot [string]
        ) {
            # invalid type
        }

        $categories = [ChronistCategory].GetEnumNames().ToLower()

        foreach ($category in $categories) {
            if (-not $fileData.ContainsKey($category)) {
                continue
            }
            if ($null -eq $fileData[$category]) {
                continue
            }
            if ($fileData[$category] -isnot [object[]]) {
                # invalid, must be array.
            }
            foreach ($entry in $fileData[$category]) {
                [ChronistEntry]::ValidateFileData($entry)
            }
        }
    }
    static [void] ValidateFileData([System.IO.FileInfo]$file) {
        [ChronistEntry]::ValidateFileData(
            [ChronistUtil]::ReadFileData($file)
        )
    }
    #endregion Static methods

    #region    Instance properties
    [bool]                                           $Breaking
    [string]                                         $DiffUrl
    [string]                                         $Synopsis
    [string]                                         $Details
    [System.Collections.Generic.List[ChronistEntry]] $UndefinedEntries
    [System.Collections.Generic.List[ChronistEntry]] $Security
    [System.Collections.Generic.List[ChronistEntry]] $Removed
    [System.Collections.Generic.List[ChronistEntry]] $Deprecated
    [System.Collections.Generic.List[ChronistEntry]] $Changed
    [System.Collections.Generic.List[ChronistEntry]] $Added
    [System.Collections.Generic.List[ChronistEntry]] $Fixed
    #endregion Instance properties

    #region    System.IEquatable methods
    [bool] Equals([object]$other) {
        <#
            .SYNOPSIS
            Implements IEquatable
        #>

        # If the other object is null, we can't compare it.
        if ($null -eq $other) {
            return $false
        }

        # If the other object isn't a temperature, we can't compare it.
        [ChronistUnreleased]$otherUnreleased = $other -as [ChronistUnreleased]
        if ($null -eq $otherUnreleased) {
            return $false
        }
        # if ($this.Category -ne $otherEntry.Category)             { return $false }
        # if ($this.Synopsis -ne $otherEntry.Synopsis)             { return $false }
        # if ($this.Priority -ne $otherEntry.Priority)             { return $false }
        # if ($this.MergedAt -ne $otherEntry.MergedAt)             { return $false }
        # if ($this.ID -ne $otherEntry.ID)                         { return $false }
        # if ($this.Details -ne $otherEntry.Details)               { return $false }
        # if ($this.PullRequests -ne $otherEntry.PullRequests)     { return $false }
        # if ($this.Issues -ne $otherEntry.Issues)                 { return $false }
        # if ($this.LinkReferences -ne $otherEntry.LinkReferences) { return $false }
        # if ($this.RelatedChanges -ne $otherEntry.RelatedChanges) { return $false }

        return $true
    }
    #endregion System.IEquatable methods

    #region    System.IComparable methods
    [int] CompareTo([Object]$other) {
        <#
            .SYNOPSIS
            Implements IComparable
        #>

        # If the other object's null, consider this instance "greater than" it
        if ($null -eq $other) {
            return 1
        }
        # If the other object isn't an entry, we can't compare it.
        [ChronistUnreleased]$otherUnreleased = $other -as [ChronistUnreleased]
        if ($null -eq $otherUnreleased) {
            # error
        }

        return 0
    }
    #endregion System.IComparable methods

    #region    Load methods
    [void] LoadFileData([hashtable]$fileData) {
    }
    [void] LoadFileName([string]$fileFullName) {
    }
    #endregion Load methods

    #region    To* methods
    [ordered] ToData() {
        return [ordered]@{
        }
    }

    [string] ToShortString() {
        return ''
    }

    [string] ToMarkdown() {
        return ''
    }
    #endregion To* methods

    #region    Validate methods
    [bool] Validate([bool]$quiet, [bool]$strict) {
        return $true
    }
    #endregion Validate methods
}

Class ChronistRelease : ChronistItem, System.IComparable, System.IEquatable[Object] {
    #region    Static methods
    static [regex] GetFileNameParsingPattern() {
        $pattern = @(
            '^'
            "(?:$([ChronistUtil]::GetValidDatePattern())\.)?"
            "(?:$([ChronistUtil]::GetValidVersionPattern())\.)?"
            [ChronistUtil]::GetValidFileExtensionPattern().ToString()
        ) -join ''

        return [regex]::new(
            $pattern,
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }
    static [hashtable] ParseFileName ([string]$fileName) {
        $fileName = Split-Path -Path $fileName -Leaf

        $pattern = [ChronistRelease]::GetFileNameParsingPattern()
        $parsed  = @{}

        if ($fileName -match $pattern) {
        }

        return $parsed
    }
    static [hashtable] ParseFileName ([System.IO.FileInfo]$file) {
        return [ChronistRelease]::ParseFileName($file.FullName)
    }

    static [void] ValidateFileData([hashtable]$fileData) {
        
    }
    static [void] ValidateFileData([System.IO.FileInfo]$file) {
        [ChronistEntry]::ValidateFileData(
            [ChronistUtil]::ReadFileData($file)
        )
    }
    #endregion Static methods

    #region    Instance properties
    #endregion Instance properties

    #region    System.IEquatable methods
    [bool] Equals([object]$other) {
        <#
            .SYNOPSIS
            Implements IEquatable
        #>

        # If the other object is null, we can't compare it.
        if ($null -eq $other) {
            return $false
        }

        # If the other object isn't a temperature, we can't compare it.
        [ChronistRelease]$otherRelease = $other -as [ChronistRelease]
        if ($null -eq $otherRelease) {
            return $false
        }
        # if ($this.Category -ne $otherEntry.Category)             { return $false }
        # if ($this.Synopsis -ne $otherEntry.Synopsis)             { return $false }
        # if ($this.Priority -ne $otherEntry.Priority)             { return $false }
        # if ($this.MergedAt -ne $otherEntry.MergedAt)             { return $false }
        # if ($this.ID -ne $otherEntry.ID)                         { return $false }
        # if ($this.Details -ne $otherEntry.Details)               { return $false }
        # if ($this.PullRequests -ne $otherEntry.PullRequests)     { return $false }
        # if ($this.Issues -ne $otherEntry.Issues)                 { return $false }
        # if ($this.LinkReferences -ne $otherEntry.LinkReferences) { return $false }
        # if ($this.RelatedChanges -ne $otherEntry.RelatedChanges) { return $false }

        return $true
    }
    #endregion System.IEquatable methods

    #region    System.IComparable methods
    [int] CompareTo([Object]$other) {
        <#
            .SYNOPSIS
            Implements IComparable
        #>

        # If the other object's null, consider this instance "greater than" it
        if ($null -eq $other) {
            return 1
        }
        # If the other object isn't an entry, we can't compare it.
        [ChronistRelease]$otherRelease = $other -as [ChronistRelease]
        if ($null -eq $otherRelease) {
            # error
        }

        return 0
    }
    #endregion System.IComparable methods

    #region    Load methods
    [void] LoadFileData([hashtable]$fileData) {
    }
    [void] LoadFileName([string]$fileFullName) {
    }
    #endregion Load methods

    #region    To* methods
    [ordered] ToData() {
        return [ordered]@{
        }
    }

    [string] ToShortString() {
        return ''
    }

    [string] ToMarkdown() {
        return ''
    }
    #endregion To* methods

    #region    Validate methods
    [bool] Validate([bool]$quiet, [bool]$strict) {
        return $true
    }
    #endregion Validate methods
}

Class ChronistChangelog : ChronistItem, System.IEquatable[Object] {
    #region    Static methods
    static [regex] GetFileNameParsingPattern() {
        $pattern = @(
            '^'
            "(?:$([ChronistUtil]::GetValidDatePattern())\.)?"
            "(?:$([ChronistUtil]::GetValidVersionPattern())\.)?"
            [ChronistUtil]::GetValidFileExtensionPattern().ToString()
        ) -join ''

        return [regex]::new(
            $pattern,
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }
    static [hashtable] ParseFileName ([string]$fileName) {
        $fileName = Split-Path -Path $fileName -Leaf

        $pattern = [ChronistRelease]::GetFileNameParsingPattern()
        $parsed  = @{}

        if ($fileName -match $pattern) {
        }

        return $parsed
    }
    static [hashtable] ParseFileName ([System.IO.FileInfo]$file) {
        return [ChronistRelease]::ParseFileName($file.FullName)
    }

    static [void] ValidateFileData([hashtable]$fileData) {
        
    }
    static [void] ValidateFileData([System.IO.FileInfo]$file) {
        [ChronistEntry]::ValidateFileData(
            [ChronistUtil]::ReadFileData($file)
        )
    }
    #endregion Static methods

    #region    Instance properties
    #endregion Instance properties

    #region    System.IEquatable methods
    [bool] Equals([object]$other) {
        <#
            .SYNOPSIS
            Implements IEquatable
        #>

        # If the other object is null, we can't compare it.
        if ($null -eq $other) {
            return $false
        }

        # If the other object isn't a temperature, we can't compare it.
        [ChronistChangelog]$otherChangelog = $other -as [ChronistChangelog]
        if ($null -eq $otherChangelog) {
            return $false
        }
        # if ($this.Category -ne $otherEntry.Category)             { return $false }
        # if ($this.Synopsis -ne $otherEntry.Synopsis)             { return $false }
        # if ($this.Priority -ne $otherEntry.Priority)             { return $false }
        # if ($this.MergedAt -ne $otherEntry.MergedAt)             { return $false }
        # if ($this.ID -ne $otherEntry.ID)                         { return $false }
        # if ($this.Details -ne $otherEntry.Details)               { return $false }
        # if ($this.PullRequests -ne $otherEntry.PullRequests)     { return $false }
        # if ($this.Issues -ne $otherEntry.Issues)                 { return $false }
        # if ($this.LinkReferences -ne $otherEntry.LinkReferences) { return $false }
        # if ($this.RelatedChanges -ne $otherEntry.RelatedChanges) { return $false }

        return $true
    }
    #endregion System.IEquatable methods

    #region    System.IComparable methods
    [int] CompareTo([Object]$other) {
        <#
            .SYNOPSIS
            Implements IComparable
        #>

        # If the other object's null, consider this instance "greater than" it
        if ($null -eq $other) {
            return 1
        }
        # If the other object isn't an entry, we can't compare it.
        [ChronistChangelog]$otherChangelog = $other -as [ChronistChangelog]
        if ($null -eq $otherChangelog) {
            # error
        }

        return 0
    }
    #endregion System.IComparable methods

    #region    Load methods
    [void] LoadFileData([hashtable]$fileData) {
    }
    [void] LoadFileName([string]$fileFullName) {
    }
    #endregion Load methods

    #region    To* methods
    [ordered] ToData() {
        return [ordered]@{
        }
    }

    [string] ToShortString() {
        return ''
    }

    [string] ToMarkdown() {
        return ''
    }
    #endregion To* methods

    #region    Validate methods
    [bool] Validate([bool]$quiet, [bool]$strict) {
        return $true
    }
    #endregion Validate methods
}
