<#

#>

# using namespace System.Collections.Generic

enum ChronistCategory {
    Undefined
    Security
    Removed
    Deprecated
    Changed
    Added
    Fixed
}

class ChronistUtil {
    #region    Static properties
    hidden static [System.Collections.Generic.List[String]] $_ValidCategories
    hidden static [System.Nullable[bool]] $_YayamlAvailable
    #endregion Static properties
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
        if ($refresh -or $null -eq [ChronistUtil]::_YayamlAvailable) {
            try {
                Get-Module -ListAvailable -Name Yayaml -ErrorAction Stop
                [ChronistUtil]::_YayamlAvailable = $true
            } catch {
                [ChronistUtil]::_YayamlAvailable = $false
            }
        }

        return [ChronistUtil]::_YayamlAvailable
    }

    static [bool] TestRegexMatchHasGroup(
        [System.Text.RegularExpressions.Match]$match,
        [string]$groupName
    ) {
        return $match.Groups.Name -contains $groupName
    }

    static [Markdig.Syntax.MarkdownDocument] ParseAsMarkdown([string]$text) {
        return [Markdig.Markdown]::Parse($text, $true)
    }
    static [Markdig.Syntax.LinkReferenceDefinition[]] GetMarkdownLinkReferenceDefinitions(
        [Markdig.Syntax.MarkdownDocument]$markdownDocument
    ) {
        $listType = [System.Collections.Generic.List[Markdig.Syntax.LinkReferenceDefinition]]
        $arrayType = [Markdig.Syntax.LinkReferenceDefinition[]]
        return [Markdig.Syntax.MarkdownObjectExtensions]::Descendants[Markdig.Syntax.LinkReferenceDefinition](
            $markdownDocument
        ) -as $listType -as $arrayType
    }

    static [Markdig.Syntax.LinkReferenceDefinition[]] GetMarkdownLinkReferenceDefinitions(
        [string]$markdownText
    ) {
        return [ChronistUtil]::GetMarkdownLinkReferenceDefinitions(
            [ChronistUtil]::ParseAsMarkdown($markdownText)
        )
    }

    static [Markdig.Syntax.Inlines.LinkInline[]] GetMarkdownLinkInline(
        [Markdig.Syntax.MarkdownDocument]$markdownDocument
    ) {
        $listType = [System.Collections.Generic.List[Markdig.Syntax.Inlines.LinkInline]]
        $arrayType = [Markdig.Syntax.Inlines.LinkInline[]]
        return [Markdig.Syntax.MarkdownObjectExtensions]::Descendants[Markdig.Syntax.Inlines.LinkInline](
            $markdownDocument
        ) -as $listType -as $arrayType
    }

    static [Markdig.Syntax.Inlines.LinkInline[]] GetMarkdownLinkInline(
        [string]$markdownText
    ) {
        return [ChronistUtil]::GetMarkdownLinkInline(
            [ChronistUtil]::ParseAsMarkdown($markdownText)
        )
    }

    static [string] ToMarkdownText([Markdig.Syntax.MarkdownDocument]$markdownDocument) {
        $writer   = [System.IO.StringWriter]::new()
        $renderer = [Markdig.Renderers.Roundtrip.RoundtripRenderer]::new($writer)
        $renderer.Write($markdownDocument)
        return $writer.ToString()
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
}

class ChronistMarkdownPatterns {
    hidden static [System.Collections.Generic.Dictionary[string,[regex]]] $Dictionary
    static [System.Collections.Generic.Dictionary[string,[regex]]] Get([bool]$forceRefresh) {
        [ChronistMarkdownPatterns]::InitializePatterns()
        if ($forceRefresh -or $null -eq [ChronistMarkdownPatterns]::Dictionary) {
            $patterns = [System.Collections.Generic.Dictionary[string, regex]]::new()
            $patternProperties = [ChronistMarkdownPatterns].GetProperties().Where({
                $_.PropertyType -eq [regex]
            }) -as [System.Reflection.PropertyInfo[]]
            foreach ($patternProperty in $patternProperties) {
                $name  = $patternProperty.Name
                $value = $patternProperty.GetGetMethod().Invoke($null,$null)
                $patterns.Add(
                    $name,
                    $value
                )
            }
            [ChronistMarkdownPatterns]::Dictionary = $patterns
        }

        return [ChronistMarkdownPatterns]::Dictionary
    }
    static [System.Collections.Generic.Dictionary[string,[regex]]] Get() {
        return [ChronistMarkdownPatterns]::Get($false)
    }
    #region    Line leading
    static [regex] $LineLeading
    #region    Methods
    #region    Default
    static [regex] DefaultLineLeadingPattern() {
        return [ChronistMarkdownPatterns]::NewLineLeadingPattern($null, $null, $null, $null)
    }
    #endregion Default
    #region    Get
    static [regex] GetLineLeadingPattern() {
        return [ChronistMarkdownPatterns]::LineLeading ??
                [ChronistMarkdownPatterns]::DefaultLineLeadingPattern()
    }
    #endregion Get
    #region    IsValid
    static [bool] IsValidLineLeadingPattern([regex]$pattern, [bool]$throw) {
        $isValid = $true
        $missingGroup = $pattern.GetGroupNames() -notcontains 'LineLead'
        if ($missingGroup) {
            $isValid = $false
        }
        return $isValid
    }
    static [bool] IsValidLineLeadingPattern([regex]$pattern) {
        return [ChronistMarkdownPatterns]::IsValidLineLeadingPattern($pattern, $false)
    }
    #endregion IsValid
    #region    New
    static [regex] NewLineLeadingPattern() {
        return [ChronistMarkdownPatterns]::NewLineLeadingPattern($null, $null, $null, $null)
    }
    static [regex] NewLineLeadingPattern(
        [string[]]$blockQuoteOptions,
        [string[]]$orderedListOptions,
        [string[]]$unorderedListOptions
    ) {
        return [ChronistMarkdownPatterns]::NewLineLeadingPattern($blockQuoteOptions, $orderedListOptions, $unorderedListOptions, $null)
    }
    static [regex] NewLineLeadingPattern(
        [string[]]$extraOptions
    ) {
        return [ChronistMarkdownPatterns]::NewLineLeadingPattern($null, $null, $null, $extraOptions)
    }
    static [regex] NewLineLeadingPattern(
        [string[]]$blockQuoteOptions,
        [string[]]$orderedListOptions,
        [string[]]$unorderedListOptions,
        [string[]]$extraOptions
    ) {
        $blockQuoteOptions    ??= [string[]]@('>')
        $orderedListOptions   ??= [string[]]@('\d+\.')
        $unorderedListOptions ??= [string[]]@('-','\*', '\+')
        $extraOptions         ??= [string[]]@()

        [string[]]$validOptions = $blockQuoteOptions + $orderedListOptions + $unorderedListOptions + $extraOptions

        return @(
            '^'                              # Start of line
            '(?<LineLead>'                   # Open capture group for line leading text
            '\s*'                            # Any amount of whitespace
            '(?:'                            # Open non-capturing group for each instance of valid leading syntax
            "(?:$($validOptions -join '|'))" # Non-capture group for valid leading syntax
            '\s+'                            # All leading syntax must be followed by one or more spaces
            ')*'                             # Close of non-capturing group for an instance, allow any number of times
            '\s*'                            # Any amount of whitespace
            ')'                              # Close leading text capture group.
        ) -join ''
    }
    #endregion New
    #region    Reset
    static [regex] ResetLineLeadingPattern([bool]$passThru) {
        [ChronistMarkdownPatterns]::LineLeading = [ChronistMarkdownPatterns]::DefaultLineLeadingPattern()

        return $passThru ? [ChronistMarkdownPatterns]::LineLeading : $null
    }
    static [void] ResetLineLeadingPattern() {
        [ChronistMarkdownPatterns]::ResetLineLeadingPattern($false)
    }
    #endregion Reset
    #region    Set
    static [regex] SetLineLeadingPattern([regex]$pattern, [bool]$passThru, [bool]$throw) {
        $thisClass = [ChronistMarkdownPatterns]
        if ($thisClass::IsValidLineLeadingPattern($pattern, $throw)) {
            $thisClass::LineLeading = $pattern
        }

        return $passThru ? $pattern : $null
    }
    static [regex] SetLineLeadingPattern([regex]$pattern, [bool]$passThru) {
        return [ChronistMarkdownPatterns]::SetLineLeadingPattern($pattern, $passThru, $false)
    }
    static SetLineLeadingPattern([regex]$pattern) {
        [ChronistMarkdownPatterns]::SetLineLeadingPattern($pattern, $false, $true)
    }
    #endregion Set
    #endregion Methods
    #endregion Line leading

    #region    Link definition
    static [regex] $LinkDefinition
    #region    Methods
    #region    Default
    static [regex] DefaultLinkDefinitionPattern() {
        return @(
            '\s*'                # Any amount of whitespace before URL
            '(?<Url>\S+)'        # Capture group for URL, one or more non-whitespace characters
            '\s*'                # Any amount of whitespace after URL
            '(?<Title>"[^"]+")?' # Capture group for optional title, all text between double quotes
            '\s*'                # Any amount of whitespace after title
        ) -join ''
    }
    #endregion Default
    #region    Get
    static [regex] GetLinkDefinitionPattern() {
        return [ChronistMarkdownPatterns]::LinkDefinition ??
                [ChronistMarkdownPatterns]::DefaultLinkDefinitionPattern()
    }
    #endregion Get
    #region    IsValid
    static [bool] IsValidLinkDefinitionPattern([regex]$pattern, [bool]$throw) {
        $isValid = $true

        $groups            = $pattern.GetGroupNames()
        $missingUrlGroup   = $groups -notcontains 'Url'
        $missingTitleGroup = $groups -notcontains 'Title'

        if ($missingUrlGroup) {
            $isValid = $false
        }

        if ($missingTitleGroup) {
            $isValid = $false
        }

        return $isValid
    }
    static [bool] IsValidLinkDefinitionPattern([regex]$pattern) {
        return [ChronistMarkdownPatterns]::IsValidLinkDefinitionPattern($pattern, $false)
    }
    #endregion IsValid
    #region    New
    static [regex] NewLinkDefinitionPattern() {
        return [ChronistMarkdownPatterns]::NewLinkDefinitionPattern($null, $null)
    }
    static [regex] NewLinkDefinitionPattern([regex]$urlPattern, [regex]$titlePattern) {
        $urlPattern   ??= '\S+'
        $titlePattern ??= '"[^"]+"'

        return @(
            '\s*'                        # Any amount of whitespace before URL
            "(?<Url>${urlPattern})"      # Capture group for URL
            '\s*'                        # Any amount of whitespace after URL
            "(?<Title>${titlePattern})?" # Capture group for optional title
            '\s*'                        # Any amount of whitespace after title
        ) -join ''
    }
    #endregion New
    #region    Reset
    static [regex] ResetLinkDefinitionPattern([bool]$passThru) {
        [ChronistMarkdownPatterns]::LinkDefinition = [ChronistMarkdownPatterns]::DefaultLinkDefinitionPattern()

        return $passThru ? [ChronistMarkdownPatterns]::LinkDefinition : $null
    }
    static [void] ResetLinkDefinitionPattern() {
        [ChronistMarkdownPatterns]::ResetLinkDefinitionPattern($false)
    }
    #endregion Reset
    #region    Set
    static [bool] SetLinkDefinitionPattern([regex]$pattern, [bool]$passThru, [bool]$throw) {
        if ([ChronistMarkdownPatterns]::IsValidLinkDefinitionPattern($pattern, $throw)) {
            [ChronistMarkdownPatterns]::LinkDefinition = $pattern
        }

        return $passThru ? [ChronistMarkdownPatterns]::LinkDefinition : $null
    }
    static [regex] SetLinkDefinitionPattern([regex]$pattern, [bool]$passThru) {
        return [ChronistMarkdownPatterns]::SetLinkDefinitionPattern($pattern, $passThru, $false)
    }
    static SetLinkDefinitionPattern([regex]$pattern) {
        [ChronistMarkdownPatterns]::SetLinkDefinitionPattern($pattern, $false, $true)
    }
    #endregion Set
    #endregion Methods
    #endregion Link definition

    #region    Link text
    static [regex] $LinkText
    #region    Methods
    #region    Default
    static [regex] DefaultLinkTextPattern() {
        return [ChronistMarkdownPatterns]::NewLinkTextPattern($null)
    }
    #endregion Default
    #region    Get
    static [regex] GetLinkTextPattern() {
        return [ChronistMarkdownPatterns]::LinkText ??
                [ChronistMarkdownPatterns]::DefaultLinkTextPattern()
    }
    #endregion Get
    #region    New
    static [regex] NewLinkTextPattern() {
        return [ChronistMarkdownPatterns]::NewLinkTextPattern($null)
    }
    static [regex] NewLinkTextPattern([regex]$innerPattern) {
        $innerPattern ??= '[^\]]+'
        return @(
            '\['                         # Opening for link text
            "(?<Text>${innerPattern})"   # Capture group for link text
            '\]'                         # Closing for link text
        ) -join ''
    }
    #endregion New
    #region    IsValid
    static [bool] IsValidlinkTextPattern([regex]$pattern, [bool]$throw) {
        $isValid = $true
        $missingGroup = $pattern.GetGroupNames() -notcontains 'Text'
        if ($missingGroup) {
            $isValid = $false
        }

        return $isValid
    }
    static [bool] IsValidLinkTextPattern([regex]$pattern) {
        return [ChronistMarkdownPatterns]::IsValidlinkTextPattern($pattern, $false)
    }
    #endregion IsValid
    #region    Reset
    #endregion Reset
    #region Set
    static [regex] SetLinkTextPattern([regex]$pattern, [bool]$passThru, [bool]$throw) {
        $thisClass = [ChronistMarkdownPatterns]
        if ($thisClass::IsValidLinkTextPattern($pattern, $throw)) {
            $thisClass::LinkText = $pattern
        }

        return $passThru ? $pattern : $null
    }
    static [regex] SetLinkTextPattern([regex]$pattern, [bool]$passThru) {
        return [ChronistMarkdownPatterns]::SetLinkTextPattern($pattern, $passThru, $false)
    }
    static SetLinkTextPattern([regex]$pattern) {
        [ChronistMarkdownPatterns]::SetLinkTextPattern($pattern, $false, $true)
    }
    #endregion Set
    #endregion Methods
    #endregion Link text

    #region    Inline link definition
    static [regex] $InlineLinkDefinition
    #region    Methods
    #region    Default
    static [regex] DefaultInlineLinkDefinitionPattern() {
        return [ChronistMarkdownPatterns]::NewInlineLinkDefinitionPattern($null)
    }
    #endregion Default
    #region    Get
    static [regex] GetInlineLinkDefinitionPattern() {
        return [ChronistMarkdownPatterns]::InlineLinkDefinition ??
                [ChronistMarkdownPatterns]::DefaultInlineLinkDefinitionPattern()
    }
    #endregion Get
    #region    IsValid
    static [bool] IsValidInlineLinkDefinitionPattern([regex]$pattern, [bool]$throw) {
        $isValid = $true

        $missingDefinitionGroup = $pattern.GetGroupNames() -contains 'Definition'

        if ($missingDefinitionGroup) {
            $isValid = $false
        }

        return $isValid
    }
    static [bool] IsValidInlineLinkDefinitionPattern([regex]$pattern) {
        return [ChronistMarkdownPatterns]::IsValidInlineLinkDefinitionPattern($pattern, $false)
    }
    #endregion IsValid
    #region    New
    static [regex] NewInlineLinkDefinitionPattern(
        [regex]$innerPattern
    ) {
        $innerPattern ??= '.*'

        return "(?<Definition>${innerPattern})"
    }
    static [regex] NewInlineLinkDefinitionPattern() {
        return [ChronistMarkdownPatterns]::NewInlineLinkDefinitionPattern($null)
    }
    #endregion New
    #region    Reset
    #endregion Reset
    #region    Set
    static [regex] SetInlineLinkDefinitionPattern([regex]$pattern, [bool]$passThru, [bool]$throw) {
        $thisClass = [ChronistMarkdownPatterns]
        if ($thisClass::IsValidInlineLinkDefinitionPattern($pattern, $throw)) {
            $thisClass::InlineLinkDefinition = $pattern
        }

        return $passThru ? $pattern : $null
    }
    static [regex] SetInlineLinkDefinitionPattern([regex]$pattern, [bool]$passThru) {
        return [ChronistMarkdownPatterns]::SetInlineLinkDefinitionPattern($pattern, $passThru, $false)
    }
    static SetInlineLinkDefinitionPattern([regex]$pattern) {
        [ChronistMarkdownPatterns]::SetInlineLinkDefinitionPattern($pattern, $false, $true)
    }
    #endregion Set
    #endregion Methods
    #endregion Inline link definition

    #region    Inline links
    static [regex] $InlineLinks
    #region    Methods
    #region    Default
    static [regex] DefaultInlineLinksPattern() {
        # return @(
        #     '(?m)'                                          # Multiline
        #     '(?<InlineLink>'                                # Capture group for full link syntax
        #     [ChronistMarkdownPatterns]::LinkText.ToString() # Capture link text
        #     '\('                                            # Opening for link definition
        #     '(?<Definition>.*)'                             # Capture group for link definition
        #     '\)'                                            # Closing for link definition
        #     ')'                                             # Closing for full link syntax capture group
        # ) -join ''

        return [ChronistMarkdownPatterns]::NewInlineLinksPattern($null, $null)
    }
    #endregion Default
    #region    Get
    static [regex] GetInlineLinksPattern() {
        return [ChronistMarkdownPatterns]::InlineLinks ??
                [ChronistMarkdownPatterns]::DefaultInlineLinksPattern()
    }
    #endregion Get
    #region    IsValid
    static [bool] IsValidInlineLinksPattern([regex]$pattern, [bool]$throw) {
        $isValid = $true

        return $isValid
    }
    static [bool] IsValidInlineLinksPattern([regex]$pattern) {
        return [ChronistMarkdownPatterns]::IsValidInlineLinksPattern($pattern, $false)
    }
    #endregion IsValid
    #region    New
    static [regex] NewInlineLinksPattern() {
        return [ChronistMarkdownPatterns]::NewInlineLinksPattern($null, $null)
    }
    static [regex] NewInlineLinksPattern(
        [regex]$linkTextPattern,
        [regex]$inlineLinkDefinitionPattern
    ) {
        $thisClass = [ChronistMarkdownPatterns]
        if ($null -eq $linkTextPattern) {
            $linkTextPattern = $thisClass::GetLinkTextPattern()
        }
        if ($null -eq $inlineLinkDefinitionPattern) {
            $inlineLinkDefinitionPattern = $thisClass::GetInlineLinkDefinitionPattern()
        }
        return [string[]]@(
            '(?m)'                       # Multiline
            '(?<InlineLink>'             # Capture group for full link syntax
            $linkTextPattern             # Capture link text
            '\('                         # Opening for link definition
            $inlineLinkDefinitionPattern # Capture group for inline link definition
            '\)'                         # Closing for link definition
            ')'                          # Closing for full link syntax capture group
        ) -join ''
    }
    #endregion New
    #region    Reset
    #endregion Reset
    #region    Set
    #endregion Set
    #endregion Methods
    #endregion Inline link

    #region    Link reference
    static [regex] $LinkReference
    #region    Methods
    #region    Default
    static [regex] DefaultLinkReferencePattern() {
        return [ChronistMarkdownPatterns]::NewLinkReferencePattern($null)
    }
    #endregion Default
    #region    Get
    static [regex] GetLinkReferencePattern() {
        return [ChronistMarkdownPatterns]::LinkReference ??
                [ChronistMarkdownPatterns]::DefaultLinkReferencePattern()
    }
    #endregion Get
    #region    IsValid
    static [bool] IsValidLinkReferencePattern([regex]$pattern, [bool]$throw) {
        $isValid = $true

        return $isValid
    }
    static [bool] IsValidLinkReferencePattern([regex]$pattern) {
        return [ChronistMarkdownPatterns]::IsValidLinkReferencePattern($pattern, $false)
    }
    #endregion IsValid
    #region    New
    static [regex] NewLinkReferencePattern() {
        return [ChronistMarkdownPatterns]::NewLinkReferencePattern($null)
    }
    static [regex] NewLinkReferencePattern([regex]$innerPattern) {
        $innerPattern ??= '[^\]]+'

        return @(
            '\['
            "(?<ReferenceID>${innerPattern})"
            '\]'
        ) -join ''
    }
    #endregion New
    #region    Reset
    #endregion Reset
    #region    Set
    #endregion Set
    #endregion Method
    #endregion Link reference

    #region    Referencing links
    static [regex] $ReferencingLinks
    #region    Methods
    #region    Default
    static [regex] DefaultReferencingLinksPattern() {
        return [ChronistMarkdownPatterns]::NewReferencingLinksPattern($null, $null)
    }
    #endregion Default
    #region    Get
    static [regex] GetReferencingLinksPattern() {
        return [ChronistMarkdownPatterns]::ReferencingLinks ??
                [ChronistMarkdownPatterns]::DefaultReferencingLinksPattern()
    }
    #endregion Get
    #region    IsValid
    static [bool] IsValidReferencingLinksPattern([regex]$pattern, [bool]$throw) {
        $isValid = $true

        return $isValid
    }
    static [bool] IsValidReferencingLinksPattern([regex]$pattern) {
        return [ChronistMarkdownPatterns]::IsValidReferencingLinksPattern($pattern, $false)
    }
    #endregion IsValid
    #region    New
    static [regex] NewReferencingLinksPattern() {
        return [ChronistMarkdownPatterns]::NewReferencingLinksPattern($null, $null)
    }
    static [regex] NewReferencingLinksPattern([regex]$linkTextPattern, [regex]$linkReferencePattern) {
        $linkTextPattern      ??= [ChronistMarkdownPatterns]::GetLinkTextPattern()
        $linkReferencePattern ??= [ChronistMarkdownPatterns]::GetLinkReferencePattern()

        return [string[]]@(
            '(?m)'
            '(?<ReferencingLink>'
            $linkTextPattern
            $linkReferencePattern
            ')'
        ) -join ''
    }
    #endregion New
    #region    Reset
    #endregion Reset
    #region    Set
    #endregion Set
    #endregion Methods
    #endregion Referencing links

    #region    All links
    static [regex] $AllLinks
    #region    Methods
    #region    Default
    static [regex] DefaultAllLinksPattern() {
        return [ChronistMarkdownPatterns]::NewAllLinksPattern($null, $null)
    }
    #endregion Default
    #region    Get
    static [regex] GetAllLinksPattern() {
        return [ChronistMarkdownPatterns]::AllLinks ??
                [ChronistMarkdownPatterns]::DefaultAllLinksPattern()
    }
    #endregion Get
    #region    IsValid
    static [bool] IsValidAllLinksPattern([regex]$pattern, [bool]$throw) {
        $isValid = $true

        return $isValid
    }
    static [bool] IsValidAllLinksPattern([regex]$pattern) {
        return [ChronistMarkdownPatterns]::IsValidAllLinksPattern($pattern, $false)
    }
    #endregion IsValid
    #region    New
    static [regex] NewAllLinksPattern() {
        return [ChronistMarkdownPatterns]::NewAllLinksPattern($null, $null)
    }
    static [regex] NewAllLinksPattern(
        [regex]$inlineLinksPattern,
        [regex]$referencingLinksPattern
    ) {
        $inlineLinksPattern      ??= [ChronistMarkdownPatterns]::GetInlineLinksPattern()
        $referencingLinksPattern ??= [ChronistMarkdownPatterns]::GetReferencingLinksPattern()

        return [string[]]@(
            '(?m)'
            '(?<Link>'
            "(?:${inlineLinksPattern}|${referencingLinksPattern})"
            ')'
        ) -join ''
    }
    #endregion New
    #region    Reset
    #endregion Reset
    #region    Set
    #endregion Set
    #endregion Methods
    #endregion All Links

    #region    Link reference definitions
    static [regex] $LinkReferenceDefinitions
    #region    Methods
    #region    Default
    static [regex] DefaultLinkReferenceDefinitionsPattern() {
        return [ChronistMarkdownPatterns]::NewLinkReferenceDefinitionsPattern($null, $null, $null)
    }
    #endregion Default
    #region    Get
    static [regex] GetLinkReferenceDefinitionsPattern() {
        return [ChronistMarkdownPatterns]::LinkReferenceDefinitions ??
               [ChronistMarkdownPatterns]::DefaultLinkReferenceDefinitionsPattern()
    }
    #endregion Get
    #region    IsValid
    static [bool] IsValidLinkReferenceDefinitionPattern([regex]$pattern, [bool]$throw) {
        $isValid = $true

        return $isValid
    }
    static [bool] IsValidLinkReferenceDefinitionPattern([regex]$pattern) {
        return [ChronistMarkdownPatterns]::IsValidLinkReferenceDefinitionPattern($pattern, $false)
    }
    #endregion IsValid
    #region    New
    static [regex] NewLinkReferenceDefinitionsPattern() {
        return [ChronistMarkdownPatterns]::NewLinkReferenceDefinitionsPattern($null, $null, $null)
    }
    static [regex] NewLinkReferenceDefinitionsPattern(
        [regex]$lineLeadingPattern,
        [regex]$linkReferencePattern,
        [regex]$linkDefinitionPattern
    ) {

        $lineLeadingPattern    ??= [ChronistMarkdownPatterns]::GetLineLeadingPattern()
        $linkReferencePattern  ??= [ChronistMarkdownPatterns]::GetLinkReferencePattern()
        $linkDefinitionPattern ??= [ChronistMarkdownPatterns]::GetLinkDefinitionPattern()

        [ChronistMarkdownPatterns]::IsValidLineLeadingPattern($lineLeadingPattern, $true)
        [ChronistMarkdownPatterns]::IsValidLinkReferencePattern($linkReferencePattern, $true)
        [ChronistMarkdownPatterns]::IsValidLinkDefinitionPattern($linkDefinitionPattern, $true)

        return [string[]]@(
            '(?m)'
            $lineLeadingPattern
            '(?<ReferenceDefinition>'
            $linkReferencePattern
            ':\s+'
            $linkDefinitionPattern
            ')'
        ) -join ''
    }
    #endregion New
    #region    Reset
    #endregion Reset
    #region    Set
    #endregion Set
    #endregion Method
    #endregion Link reference definitions

    static InitializePatterns([bool]$force) {
        if ($force) {
            [ChronistMarkdownPatterns]::LineLeading              = $null
            [ChronistMarkdownPatterns]::InlineLinkDefinition     = $null
            [ChronistMarkdownPatterns]::LinkDefinition           = $null
            [ChronistMarkdownPatterns]::LinkReference            = $null
            [ChronistMarkdownPatterns]::LinkText                 = $null
            [ChronistMarkdownPatterns]::InlineLinks              = $null
            [ChronistMarkdownPatterns]::ReferencingLinks         = $null
            [ChronistMarkdownPatterns]::LinkReferenceDefinitions = $null
            [ChronistMarkdownPatterns]::AllLinks                 = $null
        }

        [ChronistMarkdownPatterns]::LineLeading              ??= [ChronistMarkdownPatterns]::DefaultLineLeadingPattern()
        [ChronistMarkdownPatterns]::InlineLinkDefinition     ??= [ChronistMarkdownPatterns]::DefaultInlineLinkDefinitionPattern()
        [ChronistMarkdownPatterns]::LinkDefinition           ??= [ChronistMarkdownPatterns]::DefaultLinkDefinitionPattern()
        [ChronistMarkdownPatterns]::LinkReference            ??= [ChronistMarkdownPatterns]::DefaultLinkReferencePattern()
        [ChronistMarkdownPatterns]::LinkText                 ??= [ChronistMarkdownPatterns]::DefaultLinkTextPattern()
        [ChronistMarkdownPatterns]::InlineLinks              ??= [ChronistMarkdownPatterns]::DefaultInlineLinksPattern()
        [ChronistMarkdownPatterns]::ReferencingLinks         ??= [ChronistMarkdownPatterns]::DefaultReferencingLinksPattern()
        [ChronistMarkdownPatterns]::LinkReferenceDefinitions ??= [ChronistMarkdownPatterns]::DefaultLinkReferenceDefinitionsPattern()
        [ChronistMarkdownPatterns]::AllLinks                 ??= [ChronistMarkdownPatterns]::DefaultAllLinksPattern()
    }
    static[void] InitializePatterns() {
        [ChronistMarkdownPatterns]::InitializePatterns($false)
    }
    static ChronistMarkdownPatterns() {
        [ChronistMarkdownPatterns]::InitializePatterns()
    }
}

enum ChronistLinkReferenceIDAlgorithm {
    IncrementingAlphabetical
    IncrementingNumerical
    Named
}

class ChronistLink : System.IEquatable[object] {
    #region    Static methods
    static [System.Collections.Generic.List[ChronistLink]] NewList() {
        return [System.Collections.Generic.List[ChronistLink]]::new()
    }
    static [System.Collections.Generic.List[ChronistLink]] NewList([ChronistLink[]]$links) {
        $list = [ChronistLink]::NewList()
        foreach ($link in $links) {
            $list.Add($link)
        }
        return $list
    }
    static [System.Collections.Generic.Dictionary[string, ChronistLink]] NewLookupDictionaryByID() {
        return [System.Collections.Generic.Dictionary[string, ChronistLink]]::new()
    }
    static [System.Collections.Generic.Dictionary[string, ChronistLink]] NewLookupDictionaryByID([System.Collections.Generic.List[ChronistLink]]$links) {
        $dictionary = [ChronistLink]::NewLookupDictionaryByID()
        foreach ($link in $links) {
            if ([string]::IsNullOrWhiteSpace($link.ID) -or $null -ne $dictionary[$link.ID]) {
                continue
            }
            $dictionary.Add($link.ID, $link)
        }
        return $dictionary
    }
    static [System.Collections.Generic.Dictionary[System.Tuple[string,string], [ChronistLink]]] NewLookupDictionaryByUrlAndTitle() {
        return [System.Collections.Generic.Dictionary[System.Tuple[string,string], [ChronistLink]]]::new()
    }
    static [System.Collections.Generic.Dictionary[System.Tuple[string,string], [ChronistLink]]] NewLookupDictionaryByUrlAndTitle(
        [System.Collections.Generic.List[ChronistLink]]$links
    ) {
        $dictionary = [ChronistLink]::NewLookupDictionaryByUrlAndTitle()
        foreach ($link in $links) {
            $urlAndTitle = $link.GetUrlAndTitleTuple()
            if ($null -ne $dictionary[$urlAndTitle]) {
                # already in dictionary
                continue
            }

            $dictionary.Add($urlAndTitle, $link)
        }

        return $dictionary
    }

    static [System.Collections.Generic.List[ChronistLink]] ParseFromMarkdownDocument(
        [string]$markdown,
        [bool]$includeReferenceDefinitions
    ) {
        $links                  = [System.Collections.Generic.List[ChronistLink]]::new()
        $patterns               = [ChronistMarkdownPatterns]
        [regex]$allLinksPattern = $patterns::GetAllLinksPattern()
        [regex]$refDefsPattern  = $patterns::GetLinkReferenceDefinitionsPattern()

        $allLinksPattern.Matches($markdown).ForEach({
            $isInline = -not [string]::IsNullOrWhiteSpace(
                [ChronistUtil]::GetRegexGroupValue($_, 'InlineLink')
            )
            $isReferencing = -not [string]::IsNullOrWhiteSpace(
                [ChronistUtil]::GetRegexGroupValue($_, 'ReferencingLink')
            )
            if ($isInline) {
                $link = [ChronistLinkInlineLiteral]::ParseFromPatternMatch($_)
                if ($null -ne $link) {
                    $links.Add($link)
                }
            } elseif ($isReferencing) {
                $link = [ChronistLinkInlineReferencing]::ParseFromPatternMatch($_)
                if ($null -ne $link) {
                    $links.Add($link)
                }
            } else {
                $full = [ChronistUtil]::GetRegexGroupValue($_, 'Link')
                $text = [ChronistUtil]::GetRegexGroupValue($_, 'Text')
                $link = [ChronistLink]@{
                    LiteralMarkdown    = $full
                    Text               = $text
                    ParsedFromMarkdown = $true
                }
                $links.Add($link)
            }
        })

        $refDefsPattern.Matches($markdown).ForEach({
            $definition = [ChronistLinkReferenceDefinition]::ParseFromPatternMatch($_)
            if ($null -ne $definition) {
                $definition.UpdateReferencingLinks($links)
                if ($includeReferenceDefinitions) {
                    $links.Add($definition)
                }
            }
        })

        return $links
    }
    static [System.Collections.Generic.List[ChronistLink]] ParseFromMarkdownDocument(
        [string]$markdown
    ) {
        return [ChronistLink]::ParseFromMarkdownDocument($markdown, $false)
    }
    #endregion Static methods
    #region    Interface methods
    [bool] Equals([object]$other) {
        # If the other object is null, we can't compare it.
        if ($null -eq $other) {
            return $false
        }

        # If the other object isn't a temperature, we can't compare it.
        $otherLink = $other -as [ChronistLink]
        if ($null -eq $otherLink) {
            return $false
        }

        # Compare only ID, URL, and Title
        return (
            $this.Text  -eq $otherLink.Text -and
            $this.ID    -eq $otherLink.ID   -and
            $this.Url   -eq $otherLink.Url  -and
            $this.Title -eq $otherLink.Title
        )
    }
    #endregion Interface methods
    #region    Instance properties
    [string] $Url
    [string] $Title
    [string] $ID
    [string] $Text
    [string] $LiteralMarkdown
    [bool]   $ParsedFromMarkdown
    #endregion Instance properties
    #region    Instance methods
    [System.Tuple[string,string]] GetUrlAndTitleTuple() {
        return [System.Tuple[string,string]]::new($this.Url, $this.Title)
    }
    [bool] IsInlineLink() {
        return [string]::IsNullOrWhiteSpace($this.ID)
    }
    [bool] IsReferencingLink() {
        return (-not [string]::IsNullOrWhiteSpace($this.ID))
    }

    [string] ToString() {
        if ($this.IsInlineLink()) {
            return $this.ToInlineLink()
        }

        return $this.ToReferenceLink()
    }

    [string] ToInlineLink([bool]$validate) {
        if ($validate -and [string]::IsNullOrWhiteSpace($this.Text)) {
            throw [System.InvalidOperationException]::new("Links require text")
        }
        if ($validate -and [string]::IsNullOrWhiteSpace($this.Url)) {
            throw [System.InvalidOperationException]::new("Inline links require a URL")
        }

        $template = [string]::IsNullOrEmpty($this.Title) ? '[{0}]({1})' : '[{0}]({1} "{2}")'
        return $template -f $this.Text, $this.Url, $this.Title
    }
    [string] ToInlineLink() {
        return $this.ToInlineLink($false)
    }

    [string] ToReferenceLink([bool]$validate) {
        if ($validate -and [string]::IsNullOrWhiteSpace($this.Text)) {
            throw [System.InvalidOperationException]::new("Links require text")
        }
        if ($validate -and [string]::IsNullOrWhiteSpace($this.ID)) {
            throw [System.InvalidOperationException]::new("Reference links require an ID")
        }

        $template = '[{0}][{1}]'
        return $template -f $this.Text, $this.ID
    }
    [string] ToReferenceLink() {
        return $this.ToReferenceLink($false)
    }

    [string] ToReferenceDefinition([bool]$validate) {
        if ($validate -and [string]::IsNullOrWhiteSpace($this.ID)) {
            throw [System.InvalidOperationException]::new("Reference link definitions require an ID")
        }
        if ($validate -and [string]::IsNullOrWhiteSpace($this.Url)) {
            throw [System.InvalidOperationException]::new("Reference link definitions require a URL")
        }

        $template = [string]::IsNullOrEmpty($this.Title) ? '[{0}]: {1}' : '[{0}]: {1} "{2}"'
        return $template -f $this.ID, $this.Url, $this.Title
    }
    [string] ToReferenceDefinition() {
        return $this.ToReferenceDefinition($false)
    }
    [string] ReplaceInMarkdown([string]$markdown) {
        $message = @(
            "The ReplaceInMarkdown([string]`$markdown) method isn't defined on the base class, ChronistLink."
            "Every class derived from ChronistLink must implement this method overload."
        ) -join ' '
        throw [System.NotImplementedException]::new($message)
    }
    [string] ReplaceInMarkdown([string]$markdown, [type]$asLinkType) {
        if ($null -eq $asLinkType -or -not $asLinkType.IsSubclassOf([ChronistLink])) {
            throw [System.ArgumentException]::new("Type $asLinkType isn't derived from $([ChronistLink].FullName).")
        }

        $link = $this -as $asLinkType
        return $link.ReplaceInMarkdown($markdown)
    }
    #endregion Instance methods
    #region    Constructors
    static ChronistLink() {
        $typeDataParams = @{
            TypeName = [ChronistLink].FullName
            DefaultDisplayPropertySet = @(
                'LiteralMarkdown'
                'Text'
                'ID'
                'Url'
                'Title'
            )
            DefaultDisplayProperty = 'LiteralMarkdown'
            DefaultKeyPropertySet  = @('ID', 'Url')
        }
        Update-TypeData @typeDataParams
    }
    ChronistLink() {}
    #endregion Constructors
}

class ChronistLinkUrlAndTitle : System.Tuple[string, string] {
    ChronistLinkUrlAndTitle() : base() {}
    
    ChronistLinkUrlAndTitle(
        [ChronistLink]
        $link
    ) : base($link.Url, $link.Title) {}

    ChronistLinkUrlAndTitle(
        [string]
        $url,
        
        [string]
        $title
    ) : base($url, $title) {}
}

class ChronistLinkInlineLiteral : ChronistLink {
    #region Static methods
    static [System.Collections.Generic.List[ChronistLinkInlineLiteral]] NewList() {
        return [System.Collections.Generic.List[ChronistLinkInlineLiteral]]::new()
    }
    static [System.Collections.Generic.List[ChronistLinkInlineLiteral]] NewList([ChronistLinkInlineLiteral[]]$links) {
        $list = [ChronistLinkInlineLiteral]::NewList()
        foreach ($link in $links) {
            $list.Add($link)
        }
        return $list
    }
    static [System.Collections.Generic.Dictionary[string, ChronistLinkInlineLiteral]] NewLookupDictionaryByID() {
        return [System.Collections.Generic.Dictionary[string, ChronistLinkInlineLiteral]]::new()
    }
    static [System.Collections.Generic.Dictionary[string, ChronistLinkInlineLiteral]] NewLookupDictionaryByID([System.Collections.Generic.List[ChronistLinkInlineLiteral]]$links) {
        $dictionary = [ChronistLinkInlineLiteral]::NewLookupDictionaryByID()
        foreach ($link in $links) {
            if ([string]::IsNullOrWhiteSpace($link.ID) -or $null -ne $dictionary[$link.ID]) {
                continue
            }
            $dictionary.Add($link.ID, $link)
        }
        return $dictionary
    }
    static [System.Collections.Generic.Dictionary[System.Tuple[string,string], [ChronistLinkInlineLiteral]]] NewLookupDictionaryByUrlAndTitle() {
        return [System.Collections.Generic.Dictionary[System.Tuple[string,string], [ChronistLinkInlineLiteral]]]::new()
    }
    static [System.Collections.Generic.Dictionary[System.Tuple[string,string], [ChronistLinkInlineLiteral]]] NewLookupDictionaryByUrlAndTitle(
        [System.Collections.Generic.List[ChronistLinkInlineLiteral]]$links
    ) {
        $dictionary = [ChronistLinkInlineLiteral]::NewLookupDictionaryByUrlAndTitle()
        foreach ($link in $links) {
            $urlAndTitle = $link.GetUrlAndTitleTuple()
            if ($null -ne $dictionary[$urlAndTitle]) {
                # already in dictionary
                continue
            }

            $dictionary.Add($urlAndTitle, $link)
        }

        return $dictionary
    }
    static [System.Collections.Generic.List[ChronistLinkInlineLiteral]] ParseFromMarkdownDocument(
        [string]$markdown
    ) {
        $links   = [System.Collections.Generic.List[ChronistLinkInlineLiteral]]::new()
        $pattern = [ChronistMarkdownPatterns]::GetInlineLinksPattern()

        $pattern.Matches($markdown).ForEach({
            $link = [ChronistLinkInlineLiteral]::ParseFromPatternMatch($_)
            if ($null -ne $link) {
                $links.Add($link)
            }
        })
        return $links
    }

    static [ChronistLinkInlineLiteral] ParseFromPatternMatch([System.Text.RegularExpressions.Match]$match) {
        [regex]$linkDefPattern  = [ChronistMarkdownPatterns]::GetLinkDefinitionPattern()
        $inline                 = [ChronistUtil]::GetRegexGroupValue($match, 'InlineLink')
        if ([string]::IsNullOrEmpty($inline)) {
            return $null
        }

        $text              = [ChronistUtil]::GetRegexGroupValue($match, 'Text')
        $definition        = [ChronistUtil]::GetRegexGroupValue($match, 'Definition')
        $url               = [ChronistUtil]::GetRegexGroupValue($match, 'Url')
        $title             = [ChronistUtil]::GetRegexGroupValue($match, 'Title')
        $definitionDefined = -not [string]::IsNullOrWhiteSpace($definition)
        $urlParsed         = -not [string]::IsNullOrWhiteSpace($url)

        # If the definition captures everything and doesn't require a URL, try to parse the value.
        if (-not $urlParsed -and $definitionDefined) {
            if ($definition -match $linkDefPattern) {
                $url       = $Matches.Url
                $title     = $Matches.Title
                $urlParsed = -not [string]::IsNullOrWhiteSpace($url)
            } else {
                Write-Warning "Couldn't parse definition:`n`tDefinition: ``$definition```n`tPattern: ``$linkDefPattern``"
            }
        }
        if (-not $urlParsed) {
            # Couldn't parse URL, warn, ignore, or error?
            return $null
        }

        $link = [ChronistLinkInlineLiteral]@{
            Text            = $text
            Url             = $url
            LiteralMarkdown = $inline
        }
        if (-not [string]::IsNullOrWhiteSpace($title)) {
            $link.Title = $title
        }
        return $link
    }
    #endregion Static methods
    #region    Interface methods
    [bool] Equals([object]$other) {
        # If the other object is null, we can't compare it.
        if ($null -eq $other) {
            return $false
        }

        # If the other object isn't a temperature, we can't compare it.
        $otherLink = $other -as [ChronistLink]
        if ($null -eq $otherLink) {
            return $false
        }

        # Compare only ID, URL, and Title
        return (
            $this.Text  -eq $otherLink.Text -and
            $this.Url   -eq $otherLink.Url  -and
            $this.Title -eq $otherLink.Title
        )
    }
    #endregion Interface methods
    #region    Instance methods
    [string] ToString() {
        return $this.ToInlineLink()
    }
    [string] ReplaceInMarkdown([string]$markdown) {
        $newMarkdownDefinition = $this.ToString()
        # If there's nothing to change, don't try to replace
        if ($this.LiteralMarkdown -ieq $newMarkdownDefinition) {
            return $markdown
        }
        # Munge the Markdown, replace the old literal with the new one.
        $munged = $markdown -replace [regex]::Escape($this.LiteralMarkdown), $newMarkdownDefinition

        # Set the literal to the new value before returning.
        $this.LiteralMarkdown = $newMarkdownDefinition

        return $munged
    }

    #endregion Instance methods
    #region Constructors
    static ChronistLinkInlineLiteral() {}
    ChronistLinkInlineLiteral() {}
    #endregion Constructors

}

class ChronistLinkInlineReferencing : ChronistLink {
    #region    Static methods
    static [System.Collections.Generic.List[ChronistLinkInlineReferencing]] NewList() {
        return [System.Collections.Generic.List[ChronistLinkInlineReferencing]]::new()
    }
    static [System.Collections.Generic.List[ChronistLinkInlineReferencing]] NewList([ChronistLinkInlineReferencing[]]$links) {
        $list = [ChronistLinkInlineReferencing]::NewList()
        foreach ($link in $links) {
            $list.Add($link)
        }
        return $list
    }
    static [System.Collections.Generic.Dictionary[string, ChronistLinkInlineReferencing]] NewLookupDictionaryByID() {
        return [System.Collections.Generic.Dictionary[string, ChronistLinkInlineReferencing]]::new()
    }
    static [System.Collections.Generic.Dictionary[string, ChronistLinkInlineReferencing]] NewLookupDictionaryByID([System.Collections.Generic.List[ChronistLinkInlineReferencing]]$links) {
        $dictionary = [ChronistLinkInlineReferencing]::NewLookupDictionaryByID()
        foreach ($link in $links) {
            if ([string]::IsNullOrWhiteSpace($link.ID) -or $null -ne $dictionary[$link.ID]) {
                continue
            }
            $dictionary.Add($link.ID, $link)
        }
        return $dictionary
    }
    static [System.Collections.Generic.Dictionary[System.Tuple[string,string], ChronistLinkInlineReferencing]] NewLookupDictionaryByUrlAndTitle() {
        return [System.Collections.Generic.Dictionary[System.Tuple[string,string], ChronistLinkInlineReferencing]]::new()
    }
    static [System.Collections.Generic.Dictionary[System.Tuple[string,string], ChronistLinkInlineReferencing]] NewLookupDictionaryByUrlAndTitle(
        [System.Collections.Generic.List[ChronistLinkInlineReferencing]]$links
    ) {
        $dictionary = [ChronistLinkInlineReferencing]::NewLookupDictionaryByUrlAndTitle()
        foreach ($link in $links) {
            $urlAndTitle = $link.GetUrlAndTitleTuple()
            if ($null -ne $dictionary[$urlAndTitle]) {
                # already in dictionary
                continue
            }

            $dictionary.Add($urlAndTitle, $link)
        }

        return $dictionary
    }

    static [System.Collections.Generic.List[ChronistLinkInlineReferencing]] ParseFromMarkdownDocument(
        [string]$markdown
    ) {
        $links   = [System.Collections.Generic.List[ChronistLinkInlineReferencing]]::new()
        $pattern = [ChronistMarkdownPatterns]::GetReferencingLinksPattern()

        $pattern.Matches($markdown).ForEach({
            $link = [ChronistLinkInlineReferencing]::ParseFromPatternMatch($_)
            if ($null -ne $link) {
                $links.Add($link)
            }
        })

        return $links
    }
    static [ChronistLinkInlineReferencing] ParseFromPatternMatch(
        [System.Text.RegularExpressions.Match]$match
    ) {
        $referencing = [ChronistUtil]::GetRegexGroupValue($match, 'ReferencingLink')
        $text        = [ChronistUtil]::GetRegexGroupValue($match, 'Text')
        $refID       = [ChronistUtil]::GetRegexGroupValue($match, 'ReferenceID')
        if ([string]::IsNullOrWhiteSpace($referencing) -or [string]::IsNullOrWhiteSpace($refID)) {
            return $null
        }

        return [ChronistLinkInlineReferencing]@{
            Text            = $text
            ID              = $refID
            LiteralMarkdown = $referencing
        }
    }
    #endregion Static methods
    #region    Interface methods
    [bool] Equals([object]$other) {
        # If the other object is null, we can't compare it.
        if ($null -eq $other) {
            return $false
        }

        # If the other object isn't a temperature, we can't compare it.
        $otherLink = $other -as [ChronistLink]
        if ($null -eq $otherLink) {
            return $false
        }

        # Compare only ID, URL, and Title
        return (
            $this.Text -eq $otherLink.Text -and
            $this.ID   -eq $otherLink.ID
        )
    }
    #endregion Interface methods
    #region    Instance methods
    [string] ToString() {
        return $this.ToReferenceLink()
    }
    [string] ReplaceInMarkdown([string]$markdown) {
        $newMarkdownDefinition = $this.ToString()
        # If there's nothing to change, don't try to replace
        if ($this.LiteralMarkdown -ieq $newMarkdownDefinition) {
            return $markdown
        }
        # Munge the Markdown, replace the old literal with the new one.
        $munged = $markdown -replace [regex]::Escape($this.LiteralMarkdown), $newMarkdownDefinition

        # Set the literal to the new value before returning.
        $this.LiteralMarkdown = $newMarkdownDefinition

        return $munged
    }
    #endregion Instance methods
    #region    Constructors
    static ChronistLinkInlineReferencing() {}
    ChronistLinkInlineReferencing() {}
    #endregion Constructors
}

class ChronistLinkReferenceDefinition : ChronistLink {
    #region    Static methods
    static [ChronistLinkReferenceDefinition] From([object]$link) {
        if ($null -eq $link -or $link -isnot [ChronistLink]) {
            return $null
        }

        $missingUrl = [string]::IsNullOrWhiteSpace($link.Url)
        $missingID  = [string]::IsNullOrWhiteSpace($link.ID)
        if ($missingUrl -and $missingID) {
            Write-Warning "Can't use as reference definition, missing URL and ID: $link"
            return $null
        }

        return [ChronistLinkReferenceDefinition]@{
            ID    = $link.ID
            Url   = $link.Url
            Title = $link.Title
        }
    }
    static [System.Collections.Generic.List[ChronistLinkReferenceDefinition]] From([System.Collections.Generic.List[ChronistLink]]$links) {
        $definitions = [System.Collections.Generic.List[ChronistLinkReferenceDefinition]]::new()

        foreach($link in $links) {
            $definition = [ChronistLinkReferenceDefinition]::From($link)
            if ($null -eq $definition) {
                continue
            }
            if ($definitions.Contains($definition)) {
                continue
            }
            $definitions.Add($definition)
        }

        return $definitions
    }
    static [System.Collections.Generic.List[ChronistLinkReferenceDefinition]] NewList() {
        return [System.Collections.Generic.List[ChronistLinkReferenceDefinition]]::new()
    }
    static [System.Collections.Generic.List[ChronistLinkReferenceDefinition]] NewList([ChronistLinkReferenceDefinition[]]$links) {
        $list = [ChronistLinkReferenceDefinition]::NewList()
        foreach ($link in $links) {
            $list.Add($link)
        }
        return $list
    }
    static [System.Collections.Generic.Dictionary[string, ChronistLinkReferenceDefinition]] NewLookupDictionaryByID() {
        return [System.Collections.Generic.Dictionary[string, ChronistLinkReferenceDefinition]]::new()
    }
    static [System.Collections.Generic.Dictionary[string, ChronistLinkReferenceDefinition]] NewLookupDictionaryByID([System.Collections.Generic.List[ChronistLinkReferenceDefinition]]$links) {
        $dictionary = [ChronistLinkReferenceDefinition]::NewLookupDictionaryByID()
        foreach ($link in $links) {
            if ([string]::IsNullOrWhiteSpace($link.ID) -or $null -ne $dictionary[$link.ID]) {
                continue
            }
            $dictionary.Add($link.ID, $link)
        }
        return $dictionary
    }
    static [System.Collections.Generic.Dictionary[System.Tuple[string,string], ChronistLinkReferenceDefinition]] NewLookupDictionaryByUrlAndTitle() {
        return [System.Collections.Generic.Dictionary[System.Tuple[string,string], ChronistLinkReferenceDefinition]]::new()
    }
    static [System.Collections.Generic.Dictionary[System.Tuple[string,string], ChronistLinkReferenceDefinition]] NewLookupDictionaryByUrlAndTitle(
        [System.Collections.Generic.List[ChronistLinkReferenceDefinition]]$links
    ) {
        $dictionary = [ChronistLinkReferenceDefinition]::NewLookupDictionaryByUrlAndTitle()
        foreach ($link in $links) {
            $urlAndTitle = $link.GetUrlAndTitleTuple()
            if ($null -ne $dictionary[$urlAndTitle]) {
                # already in dictionary
                continue
            }

            $dictionary.Add($urlAndTitle, $link)
        }

        return $dictionary
    }
    static [System.Collections.Generic.List[ChronistLinkReferenceDefinition]] ParseFromMarkdownDocument(
        [string]$markdown
    ) {
        $defs    = [System.Collections.Generic.List[ChronistLinkReferenceDefinition]]::new()
        $pattern = [ChronistMarkdownPatterns]::GetLinkReferenceDefinitionsPattern()

        $pattern.Matches($markdown).ForEach({
            $definition = [ChronistLinkReferenceDefinition]::ParseFromPatternMatch($_)
            if ($null -ne $definition) {
                $defs.Add($definition)
            }
        })

        return $defs
    }
    static [ChronistLinkReferenceDefinition] ParseFromPatternMatch(
        [System.Text.RegularExpressions.Match]$match
    ) {
        $full  = [ChronistUtil]::GetRegexGroupValue($match, 'ReferenceDefinition')
        $id    = [ChronistUtil]::GetRegexGroupValue($match, 'ReferenceID')
        $url   = [ChronistUtil]::GetRegexGroupValue($match, 'Url')
        $title = [ChronistUtil]::GetRegexGroupValue($match, 'Title')

        if (
            [string]::IsNullOrEmpty($full) -or
            [string]::IsNullOrWhiteSpace($id) -or
            [string]::IsNullOrWhiteSpace($url)
        ) {
            # Not a link reference definition
            return $null
        }

        $definition = [ChronistLinkReferenceDefinition]@{
            ID                 = $id
            Url                = $url
            LiteralMarkdown    = $full
            ParsedFromMarkdown = $true
        }

        if (-not [string]::IsNullOrWhiteSpace($title)) {
            $definition.Title = $title
        }

        return $definition
    }

    static [void] ResolveInlineLinks([System.Collections.Generic.List[ChronistLink]]$links) {
        [ChronistLinkReferenceDefinition[]]$definitions = $links.Where({ $_ -is [ChronistLinkReferenceDefinition] })

        foreach ($definition in $definitions) {
            $definition.UpdateReferencingLinkIDs($links)
        }
    }

    static [void] ResolveReferencingLinks([System.Collections.Generic.List[ChronistLink]]$links) {
        [ChronistLinkReferenceDefinition[]]$definitions = $links.Where({ $_ -is [ChronistLinkReferenceDefinition] })

        foreach ($definition in $definitions) {
            $definition.UpdateReferencingLinks($links)
        }
    }

    static [void] ResolveLinks ([System.Collections.Generic.List[ChronistLink]]$links) {
        [ChronistLinkReferenceDefinition]::ResolveInlineLinks($links)
        [ChronistLinkReferenceDefinition]::ResolveReferencingLinks($links)
    }

    static [void] UpdateLinkReferences(
        [System.Collections.Generic.List[ChronistLink]]$links,
        [ChronistLinkReferenceDefinition]$definition
    ) {
        $definition.UpdateReferencingLinks($links)
    }
    #endregion Static methods
    #region    Interface methods
    [bool] Equals([object]$other) {
        # If the other object is null, we can't compare it.
        if ($null -eq $other) {
            return $false
        }

        # If the other object isn't a temperature, we can't compare it.
        $otherDefinition = [ChronistLinkReferenceDefinition]::From($other)
        if ($null -eq $otherDefinition) {
            return $false
        }

        # Compare only ID, URL, and Title
        return (
            $this.ID -eq $otherDefinition.ID -and
            $this.Url -eq $otherDefinition.Url -and
            $this.Title -eq $otherDefinition.Title
        )
    }
    #endregion Interface methods
    #region    Instance methods
    [System.Collections.Generic.List[ChronistLink]] GetReferenceableLinks([System.Collections.Generic.List[ChronistLink]]$links) {
        $referenceableLinks = [System.Collections.Generic.List[ChronistLink]]::new()

        $links.Where({
            $_       -isnot [ChronistLinkReferenceDefinition] -and
            $_.Url   -eq     $this.Url -and
            $_.Title -eq     $this.Title
        }).ForEach({ $referenceableLinks.Add($_) })

        return $referenceableLinks
    }

    [System.Collections.Generic.List[ChronistLink]] GetReferencingLinks([System.Collections.Generic.List[ChronistLink]]$links) {
        $referencingLinks = [System.Collections.Generic.List[ChronistLink]]::new()

        $links.Where({
            $_    -isnot [ChronistLinkReferenceDefinition] -and
            $_.ID -eq    $this.ID
        }).ForEach({ $referencingLinks.Add($_) })

        return $referencingLinks
    }

    [void] UpdateReferencingLinks([System.Collections.Generic.List[ChronistLink]]$links) {
        # Before changing anything but ID, update links with matching URL/tItle to current ID
        $this.UpdateReferencingLinkIDs($links)
        # Enforce the referenced URL and title
        $this.UpdateReferencingLinkUrlsAndTitles($links)
    }

    [void] UpdateReferencingLinkIDs ([System.Collections.Generic.List[ChronistLink]]$links) {
        $refLinks = $this.GetReferenceableLinks($links)
        foreach ($refLink in $refLinks) {
            $refLink.ID = $this.ID
        }
    }
    [void] UpdateReferencingLinkUrlsAndTitles ([System.Collections.Generic.List[ChronistLink]]$links) {
        $refLinks = $this.GetReferencingLinks($links)

        foreach ($refLink in $refLinks) {
            $refLink.Url   = $this.Url
            $refLink.Title = $this.Title
        }
    }

    [string] ToString() {
        return $this.ToReferenceDefinition()
    }

    [string] ReplaceInMarkdown([string]$markdown) {
        $newMarkdownDefinition = $this.ToString()
        # If there's nothing to change, don't try to replace
        if ($this.LiteralMarkdown -ieq $newMarkdownDefinition) {
            return $markdown
        }
        # Munge the Markdown, replace the old literal with the new one.
        $munged = $markdown -replace [regex]::Escape($this.LiteralMarkdown), $newMarkdownDefinition

        # Set the literal to the new value before returning.
        $this.LiteralMarkdown = $newMarkdownDefinition

        return $munged
    }
    #endregion Instance methods
    #region    Constructors
    static ChronistLinkReferenceDefinition() {
        $typeDataParams = @{
            TypeName = [ChronistLinkReferenceDefinition].FullName
            DefaultDisplayPropertySet = @(
                'ID'
                'Url'
                'Title'
                'LiteralMarkdown'
            )
            DefaultDisplayProperty = 'ID'
            DefaultKeyPropertySet  = @('ID', 'Url')
        }
        Update-TypeData @typeDataParams
    }
    ChronistLinkReferenceDefinition() {}
    #endregion Constructors
}

class ChronistLinkReferenceDefinitionIndexedCollection {
    #region    Instance properties
    [System.Collections.Generic.List[ChronistLinkReferenceDefinition]]
    $List

    hidden
    [System.Collections.Generic.Dictionary[string, ChronistLinkReferenceDefinition]]
    $LookupByID
    
    hidden
    [System.Collections.Generic.Dictionary[ChronistLinkUrlAndTitle, ChronistLinkReferenceDefinition]]
    $LookupByUrlAndTitle
    #endregion Instance properties
    #region    Instance methods
    #region    Initialize overloads
    [void] Initialize([bool]$force) {
        if ($force -or $null -eq $this.List) {
            $this.List = [ChronistLinkReferenceDefinition]::NewList()
        }
        if ($force -or $null -eq $this.LookupByID) {
            $this.List = [ChronistLinkReferenceDefinition]::NewLookupDictionaryByID()
        }
        if ($force -or $null -eq $this.LookupByUrlAndTitle) {
            $this.LookupByUrlAndTitle = [ChronistLinkReferenceDefinition]::NewLookupDictionaryByUrlAndTitle()
        }
    }
    [void] Initialize() {
        $this.Initialize($false)
    }
    #endregion Initialize overloads
    #region    Add overloads
    [void] AddDefinition([ChronistLinkReferenceDefinition]$definition) {
        $this.Initialize()

        if ($this.ExistsWithUrlAndTitle($definition)) {
            # error
        }

        if ($this.ExistsWithID($definition)) {
            # error
        }

        $this.List.Add($definition)
        $this.LookupByID.Add($definition.ID, $definition)
        $this.LookupByUrlAndTitle.Add(
            [ChronistLinkUrlAndTitle]::new($definition),
            $definition
        )
    }
    [bool] TryAddDefinition([ChronistLinkReferenceDefinition]$definition) {
        if ($this.Exists($definition)) {
            return $false
        }

        $this.List.Add($definition)
        $this.LookupByID.Add($definition.ID, $definition)
        $this.LookupByUrlAndTitle.Add(
            [ChronistLinkUrlAndTitle]::new($definition),
            $definition
        )

        return $true
    }
    #endregion Add overloads
    #region    Remove overloads
    [void] RemoveDefinition([ChronistLinkReferenceDefinition]$definition) {
        $found = $this.Find($definition)
        
        if ($null -eq $found) {
            return
        }
        $this.List.Remove($found)
        $this.LookupByID.Remove($found.ID)
        $this.LookupByUrlAndTitle.Remove(
            [ChronistLinkUrlAndTitle]::new($found)
        )
    }
    #endregion Remove overloads
    #region    Update overloads
    [void] UpdateDefinitionID([string]$oldID, [string]$newID) {
        $foundByID          = $this.FindByID($oldID)
        $foundByUrlAndTitle = $this.FindByUrlAndTitle($foundByID)
        $indexed            = $this.List[$this.List.IndexOf($foundByID)]

        # Update the ID for the index and title/url lookup collections
        $foundByUrlAndTitle.ID = $newID
        $indexed.ID            = $newID

        # Remove the old entry for the removed ID
        $this.LookupByID.Remove($oldID)
        $this.LookupByID.Add($newID, $indexed)
    }
    #endregion Update overloads
    #region    Exists overloads
    [bool] ExistsWithID([string]$id) {
        return $null -ne $this.FindByID($id)
    }
    [bool] ExistsWithID([ChronistLinkReferenceDefinition]$definition) {
        return $this.ExistsWithID($definition.ID)
    }
    [bool] ExistsWithID([ChronistLink]$link) {
        return $this.ExistsWithID($link.ID)
    }
    [bool] ExistsWithUrlAndTitle([ChronistLinkUrlAndTitle]$urlAndTitle) {
        return $null -ne $this.FindByUrlAndTitle($urlAndTitle)
    }
    [bool] ExistsWithUrlAndTitle([string]$url, [string]$title) {
        return $this.ExistsWithUrlAndTitle(
            [ChronistLinkUrlAndTitle]::new($url, $title)
        )
    }
    [bool] ExistsWithUrlAndTitle([ChronistLinkReferenceDefinition]$definition) {
        return $this.ExistsWithUrlAndTitle(
            [ChronistLinkUrlAndTitle]::new($definition.Url, $definition.Title)
        )
    }
    [bool] ExistsWithUrlAndTitle([ChronistLink]$link) {
        return $this.ExistsWithUrlAndTitle(
            [ChronistLinkUrlAndTitle]::new($link.Url, $link.Title)
        )
    }
    [bool] Exists([ChronistLinkReferenceDefinition]$definition) {
        $exists = $this.ExistsWithUrlAndTitle($definition)
        if ($exists) {
            return $true
        }

        return $this.ExistsWithID($definition)
    }
    [bool] Exists([ChronistLink]$link) {
        $exists = $this.ExistsWithUrlAndTitle($link)
        if ($exists) {
            return $true
        }

        return $this.ExistsWithID($link)
    }
    #endregion Exists overloads

    #region    Find overloads
    [ChronistLinkReferenceDefinition] FindByID([string]$id) {
        $this.Initialize()

        return $this.LookupByID[$id]
    }
    [ChronistLinkReferenceDefinition] FindByID([ChronistLinkReferenceDefinition]$definition) {
        return $this.FindByID($definition.ID)
    }
    [ChronistLinkReferenceDefinition] FindByID([ChronistLink]$link) {
        return $this.FindByID($link.ID)
    }
    [ChronistLinkReferenceDefinition] FindByUrlAndTitle([ChronistLinkUrlAndTitle]$urlAndTitle) {
        $this.Initialize()

        return $this.LookupByUrlAndTitle[$urlAndTitle]
    }
    [ChronistLinkReferenceDefinition] FindByUrlAndTitle([string]$url, [string]$title) {
        return $this.FindByUrlAndTitle(
            [ChronistLinkUrlAndTitle]::new($url, $title)
        )
    }
    [ChronistLinkReferenceDefinition] FindByUrlAndTitle([ChronistLinkReferenceDefinition]$definition) {
        return $this.FindByUrlAndTitle(
            [ChronistLinkUrlAndTitle]::new($definition.Url, $definition.Title)
        )
    }
    [ChronistLinkReferenceDefinition] FindByUrlAndTitle([ChronistLink]$link) {
        return $this.FindByUrlAndTitle(
            [ChronistLinkUrlAndTitle]::new($link.Url, $link.Title)
        )
    }
    [ChronistLinkReferenceDefinition] Find([ChronistLinkReferenceDefinition]$definition) {
        $found = $this.FindByUrlAndTitle($definition)
        if ($null -ne $found) {
            return $found
        }

        return $this.FindByID($definition)
    }
    [ChronistLinkReferenceDefinition] Find([ChronistLink]$link) {
        $found = $this.FindByUrlAndTitle($link)
        if ($null -ne $found) {
            return $found
        }

        return $this.FindByID($link)
    }

    #endregion Find overloads
    #endregion Instance methods
    #region    Constructors
    static ChronistLinkReferenceDefinitionIndexedCollection() {

    }
    ChronistLinkReferenceDefinitionIndexedCollection() {
        $this.Initialize()
    }
    #endregion Constructors
}

class ChronistLinkLibrary {
    #region Static properties
    static [ChronistLinkReferenceIDAlgorithm] $DefaultIDAlgorithm      = 'IncrementingAlphabetical'
    static [ValidateRange(1,5)] [int]         $DefaultIDNumeralCount   = 3
    static [ValidateRange(1,5)] [int]         $DefaultIDCharacterCount = 3
    #endregion Static properties
    #region    Static methods
    static [bool] DefinesID([string]$id, [string]$markdown) {
        $defs = [ChronistLinkReferenceDefinition]::ParseFromMarkdownDocument($markdown)
        return $defs.ID -contains $id
    }
    #region    Get*ID overloads
    static [string] GetNumericalID([int]$index, [int]$numeralCount) {
        if ($numeralCount -le 0 -or $numeralCount -gt 5) {
            $numeralCount = 3
        }

        if ($index -ge (10 * $numeralCount)) {
            # error
        }

        return "{0:D${numeralCount}}" -f $index
    }
    static [string] GetNumericalID([int]$index) {
        return [ChronistLinkLibrary]::GetNumericalID(
            $index,
            [ChronistLinkLibrary]::DefaultIDNumeralCount
        )
    }

    static [string] GetAlphabeticalID([int]$index, [int]$characterCount) {
        if ($characterCount -le 0 -or $characterCount -gt 3) {
            # warning
            $characterCount = 3
        }

        if ($characterCount -eq 1 -and $index -gt 26) {
            # error
        }

        if ($characterCount -eq 2 -and $index -gt 676) {
            # error
        }

        if ($characterCount -eq 3 -and $index -gt 17576) {
            # error
        }

        $chars  = 'a'..'z'

        $id = $chars[($index % 26) - 1]

        if ($characterCount -ge 2) {
            $characterIndex = 0
            if ($index -gt 26 -and $index -le 676) {
                # Get quotient and remainder - use quotient as index. When the remainder
                # is zero, subtract 1 to account for the last letter in the group.
                # If the index is greater than 676, use that modulo first - otherwise,
                # the character index will be out of range.
                $divRem = [math]::Divrem(
                    ($index -le 676 ? $index : $index % 676),
                    26
                )
                $characterIndex = $divRem.Item1
                if ($divRem.Item2 -eq 0) {
                    $characterIndex -= 1
                }
            }

            $id = $chars[$characterIndex] + $id
        }

        if ($characterCount -ge 3) {
            $characterIndex = 0
            if ($index -gt 676) {
                # Get quotient and remainder - use quotient as index. When the remainder
                # is zero, subtract 1 to account for the last letter in the group.
                $divRem = [math]::Divrem($index, 676)
                $characterIndex = $divRem.Item1
                if ($divRem.Item2 -eq 0) {
                    $characterIndex -= 1
                }
            }
            Write-Warning "Lead character index: $characterIndex $($chars[$characterIndex])"
            $id = $chars[$characterIndex] + $id
            Write-Warning "Three-character ID: $id"
        }

        return $id
    }

    static [string] GetAlphabeticalID([int]$index) {
        return [ChronistLinkLibrary]::GetAlphabeticalID(
            $index,
            [ChronistLinkLibrary]::DefaultIDCharacterCount
        )
    }
    #endregion Get*ID overloads
    #endregion Static methods
    #region    Instance properties
    [System.Collections.Generic.List[ChronistLink]]
    $Links

    [ChronistLinkReferenceDefinitionIndexedCollection]
    $IndexedDefinitions

    [ChronistLinkReferenceDefinitionIndexedCollection]
    $NamedDefinitions
    #endregion Instance properties
    #region    Instance methods
    [void] AddLink([ChronistLink]$link) {
        if ($link -is [ChronistLinkInlineLiteral]) {

        } elseif ($link -is [ChronistLinkInlineLiteral]) {

        } elseif ($link -is [ChronistLinkReferenceDefinition]) {

        }
    }
    [void] AddInlineLink([ChronistLinkInlineLiteral]$link) {
        $this.Links.Add($link)
    }
    [void] AddReferencingLink([ChronistLinkInlineReferencing]$link) {
        $this.Links.Add($link)
    }
    [void] AddDefinition([ChronistLinkReferenceDefinition]$definition) {

    }

    [bool] DefinitionIsIndexed([ChronistLinkReferenceDefinition]$definition) {
        if (
            $null -eq $definition -or
            $null -eq $this.IndexedDefinitions -or
            $this.IndexedDefinitions.Count -eq 0
        ) {
            return $false
        }

        return $this.IndexedDefinitions.Exists($definition)
    }
    [bool] DefinitionIsNamed([ChronistLinkInlineReferencing]$link) {
        if (
            $null -eq $link -or
            $null -eq $this.NamedDefinitions -or
            $this.NamedDefinitions.Count -eq 0
        ) {
            return $false
        }

        return $this.NamedDefinitions.ExistsWithID($link.ID)
    }
    [bool] DefinitionIsNamed([ChronistLinkInlineLiteral]$link) {
        if (
            $null -eq $link -or
            $null -eq $this.NamedDefinitions -or
            $this.NamedDefinitions.Count -eq 0
        ) {
            return $false
        }

        return $this.NamedDefinitions.ExistsWithUrlAndTitle($link.Url, $link.Title)
    }
    [bool] DefinitionIsNamed([ChronistLink]$link) {
        if (
            $null -eq $link -or
            $null -eq $this.NamedDefinitions -or
            $this.NamedDefinitions.Count -eq 0
        ) {
            return $false
        }
        return $this.NamedDefinitions.Exists($link)
    }

    [ChronistLinkReferenceDefinition] GetNamedDefinition([string]$name) {
        if (
            [string]::IsNullOrWhiteSpace($name) -or
            $null -eq $this.NamedDefinitions -or
            $this.NamedDefinitions.Count -eq 0
        ) {
            return $null
        }

        return $this.NamedDefinitions.FindByID($name)
    }
    [void] Initialize([bool]$force) {
        if ($force -or $null -eq $this.Links) {
            $this.Links = [System.Collections.Generic.List[ChronistLink]]::new()
        }
        if ($force -or $null -eq $this.IndexedDefinitions) {
            $this.IndexedDefinitions = [ChronistLinkReferenceDefinitionIndexedCollection]::new()
        }
        if ($force -or $null -eq $this.NamedDefinitions) {
            $this.NamedDefinitions = [ChronistLinkReferenceDefinitionIndexedCollection]::new()
        }
    }
    [void] Initialize() {
        $this.Initialize($false)
    }
    #endregion Instance methods
    #region    Constructors
    static ChronistLinkLibrary() {

    }

    ChronistLinkLibrary() {
        $this.Initialize()

    }
    #endregion Constructors
}

class ChronistLinkReferences {
    #region    Static properties
    static [ChronistLinkReferenceIDAlgorithm] $DefaultIDAlgorithm = 'IncrementingAlphabetical'
    static [ValidateRange(1,5)] [int] $DefaultIDNumeralCount = 3
    static [ValidateRange(1,5)] [int] $DefaultIDCharacterCount = 3
    #endregion Static properties
    #region    Static methods
    static[bool] DefinesID([string]$id, [string]$markdown) {
        $defs = [ChronistLinkReferenceDefinition]::ParseFromMarkdownDocument($markdown)
        return $defs.ID -contains $id
    }

    static [string] GetNumericalID([int]$index, [int]$numeralCount) {
        if ($numeralCount -le 0 -or $numeralCount -gt 5) {
            $numeralCount = 3
        }

        if ($index -ge (10 * $numeralCount)) {
            # error
        }

        return "{0:D${numeralCount}}" -f $index
    }
    static [string] GetNumericalID([int]$index) {
        return [ChronistLinkReferences]::GetNumericalID(
            $index,
            [ChronistLinkReferences]::DefaultIDNumeralCount
        )
    }

    static [string] GetAlphabeticalID([int]$index, [int]$characterCount) {
        if ($characterCount -le 0 -or $characterCount -gt 3) {
            # warning
            $characterCount = 3
        }

        if ($characterCount -eq 1 -and $index -gt 26) {
            # error
        }

        if ($characterCount -eq 2 -and $index -gt 676) {
            # error
        }

        if ($characterCount -eq 3 -and $index -gt 17576) {
            # error
        }

        $chars  = 'a'..'z'

        $id = $chars[($index % 26) - 1]

        if ($characterCount -ge 2) {
            $characterIndex = 0
            if ($index -gt 26 -and $index -le 676) {
                # Get quotient and remainder - use quotient as index. When the remainder
                # is zero, subtract 1 to account for the last letter in the group.
                # If the index is greater than 676, use that modulo first - otherwise,
                # the character index will be out of range.
                $divRem = [math]::Divrem(
                    ($index -le 676 ? $index : $index % 676),
                    26
                )
                $characterIndex = $divRem.Item1
                if ($divRem.Item2 -eq 0) {
                    $characterIndex -= 1
                }
            }

            $id = $chars[$characterIndex] + $id
        }

        if ($characterCount -ge 3) {
            $characterIndex = 0
            if ($index -gt 676) {
                # Get quotient and remainder - use quotient as index. When the remainder
                # is zero, subtract 1 to account for the last letter in the group.
                $divRem = [math]::Divrem($index, 676)
                $characterIndex = $divRem.Item1
                if ($divRem.Item2 -eq 0) {
                    $characterIndex -= 1
                }
            }
            Write-Warning "Lead character index: $characterIndex $($chars[$characterIndex])"
            $id = $chars[$characterIndex] + $id
            Write-Warning "Three-character ID: $id"
        }

        return $id
    }

    static [string] GetAlphabeticalID([int]$index) {
        return [ChronistLinkReferences]::GetAlphabeticalID(
            $index,
            [ChronistLinkReferences]::DefaultIDCharacterCount
        )
    }

    static [string[]] GetReferencedIDs([string]$markdownText) {
        return [ChronistLinkReferences]::GetLinkReferences($markdownText).Item2
    }

    static [System.Collections.Generic.List[System.Tuple[string,string]]] GetLinkReferences([string]$markdownText) {
        [regex]$pattern = '\[[^\]]+?\]\[(?<ReferencedID>(?:\w|-|\.)+)\]'
        $linkReferences = [System.Collections.Generic.List[System.Tuple[string,string]]]::new()
        foreach ($matchResult in $pattern.Matches($markdownText)) {
            $fullText = $matchResult.Value
            $refID    = $matchResult.Groups.Where({$_.Name -eq 'ReferencedID'}, 'First')[0].Value
            $linkReferences.Add([System.Tuple[string,string]]::new($fullText, $refID))
        }
        return $linkReferences
    }

    static [bool] ReferencesID([string]$id, [string]$markdownText) {
        <#
            .SYNOPSIS
            Simple match for [foo][bar] reference link usage.
            Not robust, might find apparent links in code spans.
            Doesn't find links that use the text as the label, like [foo].
        #>
        $pattern = "\[[^\]]+?\]\[$id\]"

        return ($markdownText -match $pattern)
    }

    static [string] ReplaceReferenceID([string]$replacingID, [string]$newID, [string]$markdownText) {
        $linkReferences = [ChronistLinkReferences]::GetLinkReferences($markdownText)
        $literalsToReplace = $linkReferences.Where({$_.Item2 -eq $replacingID}).Item1
        $escapedID = [regex]::Escape($replacingID)
        foreach ($linkReference in $literalsToReplace) {
            $newText      = $linkReference -replace "\[${escapedID}\]", "[$newid]"
            $markdownText = $markdownText -replace [regex]::Escape($linkReference), $newText
        }

        if ($markdownText -match "(?m)^\s*\[${escapedID}\]:\s*.+$") {
            $oldText      = $matches.0
            $newText      = $oldText -replace "\[${replacingID}\]", "[$newid]"
            $markdownText = $markdownText -replace [regex]::Escape($oldText), $newText
        }

        return $markdownText
    }

    #endregion Static methods
    #region    Instance properties
    [ChronistLinkReferenceIDAlgorithm]     $IDAlgorithm
    [System.Collections.Generic.List[ChronistLinkReferenceDefinition]] $Deffies
    [System.Collections.Generic.HashSet[System.Tuple[string,string]]] $ReferencedValues
    [ordered]                              $Definitions
    #endregion Instance properties
    #region    Instance methods
    [void] Add([string]$id, [string]$url, [string]$title) {
        $urlAndTitle = [System.Tuple[string,string]]::new($url, $title)
        if ($this.ReferencedValues.Contains($urlAndTitle)) {
            return
        }

        if ($this.IDAlgorithm -eq [ChronistLinkReferenceIDAlgorithm]::IncrementingAlphabetical) {
            $id = $this.GetNextAlphabeticalID()
        } elseif ($this.IDAlgorithm -eq [ChronistLinkReferenceIDAlgorithm]::IncrementingNumerical) {
            $id = $this.GetNextNumericalID()
        }

        if ($this.Definitions.Keys -contains $id) {
            # error
        }

        $this.Definitions.Add($id, $urlAndTitle)
        $this.ReferencedValues.Add($urlAndTitle)
    }

    [void] Add([Markdig.Syntax.LinkReferenceDefinition]$definition) {
        $this.Add($definition.Label, $definition.Url, $definition.Title)
    }

    [void] Add([Markdig.Syntax.Inlines.LinkInline]$inline) {
        $this.add($inline.Label, $inline.Url, $inline.Title)
    }

    [void] Add([Markdig.Syntax.MarkdownDocument]$markdownDocument) {
        foreach ($inline in [ChronistUtil]::GetMarkdownLinkInline($markdownDocument)) {
            $this.Add($inline)
        }
        foreach ($refdef in [ChronistUtil]::GetMarkdownLinkReferenceDefinitions($markdownDocument)) {
            $this.Add($refdef)
        }
    }

    [Markdig.Syntax.LinkReferenceDefinition] GetReferenceDefinition([string]$id) {
        if ($this.Definitions.Keys -notcontains $id) {
            # error, id not defined
        }

        $definitionData = $this.Definitions[$id]
        $url, $title = $definitionData.Item1, $definitionData.Item2

        return [ChronistLinkReferences]::NewReferenceDefinition($id, $url, $title)
    }

    [string] GetNextNumericalID() {
        [int]$index = $this.Definitions.Keys.Count + 1

        return [ChronistLinkReferences]::GetNumericalID($index)
    }

    [string] GetNextAlphabeticalID() {
        [int]$index = $this.Definitions.Keys.Count + 1

        return [ChronistLinkReferences]::GetAlphabeticalID($index)
    }

    [void] Resolve([ChronistEntry]$entry) {

    }

    [void] Resolve([string]$markdownText) {
        $markdownDocument  = [ChronistUtil]::ParseAsMarkdown($markdownText)

        $initialInlines = [ChronistUtil]::GetMarkdownLinkInline($markdownDocument)
        $initialRefDefs = [ChronistUtil]::GetMarkdownLinkReferenceDefinitions($markdownDocument)

        foreach ($definedID in $this.Definitions.Keys) {
            # Get the definition info as a canonical reference definition
            $canonical = $this.GetReferenceDefinition($definedID)
            # Get the markdown info
            $mdDefinition = $initialRefDefs.Where({
                $_.Url -eq $canonical.Url -and $_.Title -eq $canonical.Title
            }, 'First')[0] -as [Markdig.Syntax.LinkReferenceDefinition]
            $mdInlines = $initialInlines.Where({
                $_.Url -eq $canonical.Url -and $_.Title -eq $canonical.Title
            }) -as [Markdig.Syntax.Inlines.LinkInline[]]
            # Helpers for booleans
            $definesID    = $null -ne $mdDefinition
            $hasInlines   = $mdInlines.Count -gt 0

            if ($definesID) {
                if ($mdDefinition.Label -ne $definedID) {
                    $markdownText = [ChronistLinkReferences]::ReplaceReferenceID($mdDefinition.Label, $canonical.Label, $markdownText)
                }
                continue
            }
            if ($hasInlines -and -not $definesID) {
                [ChronistLinkReferences]::AddReferenceDefinition($canonical)
                foreach ($inline in $mdInlines) {
                    [ChronistLinkReferences]::SetLinkInline($inline, $canonical)
                }

            }

        }
    }

    [void] Resolve([Markdig.Syntax.MarkdownDocument]$markdownDocument) {
    }
    #endregion Instance methods
    #region    Constructors
    ChronistLinkReferences() {
        $this.Definitions = [ordered]@{}
        $this.ReferencedValues = [System.Collections.Generic.HashSet[System.Tuple[string,string]]]::new()
    }
    #endregion Constructors
}

class ChronistFormattingScriptblocks : System.Collections.Generic.Dictionary[type, System.Collections.Generic.Dictionary[string, scriptblock]] {
    #region    Static properties
    #endregion Static properties
    #region    Static methods
    static hidden [System.Collections.Generic.Dictionary[string, scriptblock]] NewScriptblockDictionary() {
        return [System.Collections.Generic.Dictionary[string, scriptblock]]::new(
            [System.OrdinalComparer]::InvariantCultureIgnoreCase
        )
    }

    static hidden [string] MungeTemplateSpacing([string]$template) {
        [string]$munged   = $template.Clone()
        [string[]]$lines  = $template -split '\r?\n'
        [regex]$leadRegex = $null
        foreach ($line in $lines) {
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }
            if ($line -match '^(?<LeadingSpaces>\s+)\S') {
                $leadRegex = "(?m)^$($Matches.LeadingSpaces)"
                break
            }
            if ($line -match '^\S') {
                break
            }
        }

        if ($null -ne $leadRegex) {
            $munged = $template -replace $leadRegex, ''
        }

        return $munged.Trim("`r", "`n")
    }

    static [string] GetEntryFormatterTemplate() {
        $template = {
            {
                [CmdletBinding()]
                [OutputType([string])]
                param(
                    [Parameter(Mandatory, Position=0)]
                    [ChronistEntry]$entry,
                    [Parameter(Mandatory, Position=1)]
                    [ChronistConfiguration]$configuration
                )

                begin {
                    $builder    = [System.Text.StringBuilder]::new()
                }

                process {
                    # Logic
                }

                end {
                    $builder.ToString()
                }
            }
        }.ToString()

        return [ChronistFormattingScriptblocks]::MungeTemplateSpacing($template)
    }

    static [scriptblock] GetDefaultEntryFormatter() {
        return {
            [CmdletBinding()]
            [OutputType([string])]
            param(
                [Parameter(Mandatory, Position=0)]
                [ChronistEntry]$entry,
                [Parameter(Mandatory, Position=1)]
                [ChronistConfiguration]$configuration
            )

            $builder    = [System.Text.StringBuilder]::new()
            $hasID      = -not [string]::IsNullOrWhiteSpace($entry.ID)
            $hasDetails = -not [string]::IsNullOrWhiteSpace($entry.Details)

            if ($hasID) {
                $null = $builder.Append('- <a id="{0}"></a>' -f $entry.ID)
                $null = $builder.Append("`n`n").Append('  ')
            } else {
                $null = $builder.Append('- ')
            }

            $content = $hasDetails ? $entry.Details : $entry.Synopsis
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

    static [scriptblock] GetDefaultUnreleasedFormatter() {
        return {
            [CmdletBinding()]
            [OutputType([string])]
            param(
                [Parameter(Mandatory, Position=0)]
                [ChronistUnreleased]$unreleased,
                [Parameter(Mandatory, Position=1)]
                [ChronistConfiguration]$configuration
            )

            $builder = [System.Text.StringBuilder]::new()

            return $builder.ToString()
        }
    }

    static [scriptblock] GetDefaultReleaseFormatter() {
        return {
            [CmdletBinding()]
            [OutputType([string])]
            param(
                [Parameter(Mandatory, Position=0)]
                [ChronistRelease]$release,
                [Parameter(Mandatory, Position=1)]
                [ChronistConfiguration]$configuration
            )

            $builder = [System.Text.StringBuilder]::new()

            return $builder.ToString()
        }
    }

    static [scriptblock] GetDefaultChangelogFormatter() {
        return {
            [CmdletBinding()]
            [OutputType([string])]
            param(
                [Parameter(Mandatory, Position=0)]
                [ChronistChangelog]$changelog,
                [Parameter(Mandatory, Position=1)]
                [ChronistConfiguration]$configuration
            )

            $builder = [System.Text.StringBuilder]::new()

            return $builder.ToString()
        }
    }

    hidden static [System.Nullable[int]] GetParameterPosition(
        [System.Management.Automation.Language.ParameterAst]$parameter
    ) {
        $attribute = $parameter.Attributes.Where({
            $_.TypeName.Name -eq 'Parameter'
        }, 'First') -as [System.Management.Automation.Language.AttributeAst]
        if ($null -eq $attribute) {
            return $null
        }

        $positionArgument = $attribute.NamedArguments.Where({
            $_.ArgumentName -eq 'Position'
        }, 'First') -as [System.Management.Automation.Language.NamedAttributeArgumentAst]

        return $positionArgument.Argument.Value
    }

    hidden static [System.Nullable[bool]] GetParameterMandatory(
        [System.Management.Automation.Language.ParameterAst]$parameter
    ) {
        $attribute = $parameter.Attributes.Where({
            $_.TypeName.Name -eq 'Parameter'
        }, 'First') -as [System.Management.Automation.Language.AttributeAst]
        if ($null -eq $attribute) {
            return $null
        }

        $mandatoryArgument = $attribute.NamedArguments.Where({
            $_.ArgumentName -eq 'Mandatory'
        }, 'First') -as [System.Management.Automation.Language.NamedAttributeArgumentAst]

        return $mandatoryArgument.Argument.Value
    }

    static [void] ValidateFormatter([type]$chronistType, [scriptblock]$formatter) {
        $parameters = [ChronistUtil]::GetParameterAsts($formatter)
        if ($null -eq $parameters -or $parameters.Count -eq 0) {
            # error, must define parameters
        }

        $configParameter = $parameters.Where({
            $_.Name -eq 'Configuration' -and
            $_.StaticType -eq [ChronistConfiguration]
        }, 'First') -as [System.Management.Automation.Language.ParameterAst]
        if ($null -eq $configParameter) {
            # error missing parameter
        }
        
        $instanceParameterName = switch ($chronistType) {
            [ChronistEntry]      { 'entry' }
            [ChronistUnreleased] { 'unreleased' }
            [ChronistRelease]    { 'release' }
            [ChronistChangelog]  { 'changelog' }
        }
        $instanceParameter = $parameters.Where({
            $_.Name -eq $instanceParameterName -and
            $_.StaticType -eq $chronistType
        }, 'First')  -as [System.Management.Automation.Language.ParameterAst]
        if ($null -eq $instanceParameter) {
            # error missing parameter
        }
        $instanceMandatory = [ChronistFormattingScriptblocks]::GetParameterMandatory($instanceParameter)
        if ($null -eq $instanceMandatory) {
            # error, not defined at all
        } elseif ($instanceMandatory -eq $false) {
            # error, specifically defined as not mandatory
        }
        $instancePosition = [ChronistFormattingScriptblocks]::GetParameterPosition($instanceParameter)
        if ($null -eq $instancePosition) {
            # error, not defined at all
        } elseif ($instancePosition -ne 0) {
            # error, incorrect position
        }

        $outputTypes = [ChronistUtil]::GetOutputTypes($formatter)
        if ($null -eq $outputTypes -or $outputTypes.Count -eq 0) {
            # error, must define output type
        }
        $outputTypeValues = $outputTypes.Type | Select-Object -Unique
        if ($outputTypeValues -ne [System.Management.Automation.PSTypeName][string]) {
            # error, must only and always return strings
        }
        
    }

    static [type[]] GetValidFormattableChronistTypes() {
        return @(
            [ChronistEntry]
            [ChronistUnreleased]
            [ChronistRelease]
            [ChronistChangelog]
        )
    }

    static [bool] IsValidFormattableChronistType([type]$chronistType) {
        $validTypes = [ChronistFormattingScriptblocks]::GetValidFormattableChronistTypes()
        
        return $chronistType -in $validTypes
    }
    static [bool] IsNotValidFormattableChronistType([type]$chronistType) {
        $validTypes = [ChronistFormattingScriptblocks]::GetValidFormattableChronistTypes()
        
        return $chronistType -notin $validTypes
    }
    #endregion Static methods
    #region    Instance properties
    #endregion Instance properties
    #region    Instance methods
    [ChronistFormattingScriptblocks] Clone() {
        $clone = [ChronistFormattingScriptblocks]::new($false)

        foreach ($chronistType in $this.Keys) {
            $thisType = $this[$chronistType]

            if ($chronistType -notin $clone.Keys) {
                $clone.InitializeTypeDictionaryWithoutDefaults($chronistType)
            }

            foreach ($name in $thisType.Keys) {
                $formatScriptblock = $thisType[$name]
                $clonedScriptblock = [scriptblock]::Create($formatScriptblock)

                $clone[$chronistType].Add($clonedScriptblock)
            }
        }

        return $clone
    }
    #region    Get overloads
    [System.Collections.Generic.Dictionary[string, scriptblock]] Get([type]$chronistType) {
        $this.ValidateChronistType($chronistType)
        
        return $this[$chronistType]
    }
    [scriptblock] Get([type]$chronistType, [string]$name) {
        return $this.Get($chronistType)[$name]
    }
    #endregion Get overloads
    #region    Add overloads
    [void] AddScriptblock([type]$chronistType, [string]$name, [scriptblock]$formatter) {
        $this.Get($chronistType).Add($name, $formatter)
    }
    [void] AddEntryScriptblock([string]$name, [scriptblock]$formatter) {
        $this.AddScriptblock([ChronistEntry], $name, $formatter)
    }
    [void] AddUnreleasedScriptblock([string]$name, [scriptblock]$formatter) {
        $this.AddScriptblock([ChronistUnreleased], $name, $formatter)
    }
    [void] AddReleaseScriptblock([string]$name, [scriptblock]$formatter) {
        $this.AddScriptblock([ChronistRelease], $name, $formatter)
    }
    [void] AddChangelogScriptblock([string]$name, [scriptblock]$formatter) {
        $this.AddScriptblock([ChronistChangelog], $name, $formatter)
    }
    [bool] TryAddScriptblock([type]$chronistType, [string]$name, [scriptblock]$formatter) {
        $dict = $this.Get($chronistType)

        if ($null -eq $dict) {
            return $false
        }

        return $dict.TryAdd($name, $formatter)
    }
    [bool] TryAddEntryScriptblock([string]$name, [scriptblock]$formatter) {
        return $this.TryAddScriptblock([ChronistEntry], $name, $formatter)
    }
    [bool] TryAddUnreleasedScriptblock([string]$name, [scriptblock]$formatter) {
        return $this.TryAddScriptblock([ChronistUnreleased], $name, $formatter)
    }
    [bool] TryAddReleaseScriptblock([string]$name, [scriptblock]$formatter) {
        return $this.TryAddScriptblock([ChronistRelease], $name, $formatter)
    }
    [bool] TryAddChangelogScriptblock([string]$name, [scriptblock]$formatter) {
        return $this.TryAddScriptblock([ChronistChangelog], $name, $formatter)
    }
    #endregion Add overloads
    #region    Set overloads

    #endregion Set overloads
    #region    Initialize overloads
    [void] Initialize([bool]$force) {
        $this.InitializeTypeDictionary([ChronistEntry], $force)
        $this.InitializeTypeDictionary([ChronistUnreleased], $force)
        $this.InitializeTypeDictionary([ChronistRelease], $force)
        $this.InitializeTypeDictionary([ChronistChangelog], $force)
    }
    [void] Initialize() {
        $this.Initialize($false)
    }
    [void] InitializeWithoutDefaults([bool]$force) {
        $this.InitializeTypeDictionaryWithoutDefaults([ChronistEntry], $force)
        $this.InitializeTypeDictionaryWithoutDefaults([ChronistUnreleased], $force)
        $this.InitializeTypeDictionaryWithoutDefaults([ChronistRelease], $force)
        $this.InitializeTypeDictionaryWithoutDefaults([ChronistChangelog], $force)
    }
    [void] InitializeWithoutDefaults() {
        $this.InitializeWithoutDefaults($false)
    }
    [void] InitializeTypeDictionary([type]$chronistType, [bool]$force) {
        $this.ValidateChronistType()

        if (-not $force -or $this.ContainsKey($chronistType)) {
            return
        }
        $dict = [ChronistFormattingScriptblocks]::NewScriptblockDictionary()
        [scriptblock]$default = {}
        switch ($chronistType) {
            [ChronistEntry] {
                $default = [ChronistFormattingScriptblocks]::GetDefaultEntryFormatter()
            }
            [ChronistUnreleased] {
                $default = [ChronistFormattingScriptblocks]::GetDefaultUnreleasedFormatter()
            }
            [ChronistRelease] {
                $default = [ChronistFormattingScriptblocks]::GetDefaultReleaseFormatter()
            }
            [ChronistChangelog] {
                $default = [ChronistFormattingScriptblocks]::GetDefaultChangelogFormatter()
            }
        }
        $dict.Add('Default', $default)

        if ($this.ContainsKey($chronistType)) {
            $this[$chronistType] = $dict
        } else {
            $this.Add($chronistType, $dict)
        }
    }
    [void] InitializeTypeDictionary([type]$chronistType) {
        $this.InitializeTypeDictionary($chronistType, $false)
    }
    [void] InitializeTypeDictionaryWithoutDefaults([type]$chronistType, [bool]$force) {
        if (
            $chronistType -notin @(
                [ChronistEntry]
                [ChronistUnreleased]
                [ChronistRelease]
                [ChronistChangelog]
            )
        ) {
            # error
        }

        if (-not $force -or $this.ContainsKey($chronistType)) {
            return
        }

        $dict = [ChronistFormattingScriptblocks]::NewScriptblockDictionary()

        if ($this.ContainsKey($chronistType)) {
            $this[$chronistType] = $dict
        } else {
            $this.Add($chronistType, $dict)
        }
    }
    [void] InitializeTypeDictionaryWithoutDefaults([type]$chronistType) {
        $this.InitializeTypeDictionaryWithoutDefaults($chronistType, $false)
    }
    #endregion Initialize overloads
    #region    Validate overloads
    [void] ValidateChronistType([type]$chronistType) {
        if (
            [ChronistFormattingScriptblocks]::IsNotValidFormattableChronistType($chronistType)
        ) {
            # error
        }
    }
    #endregion Validate overloads
    #endregion Instance methods
    #region    Constructors
    static ChronistFormattingScriptblocks() {}

    ChronistFormattingScriptblocks() {
        $this.Initialize()
    }

    ChronistFormattingScriptblocks([bool]$addDefaults) {
        if ($addDefaults) {
            $this.Initialize()
        } else {
            $this.InitializeWithoutDefaults()
        }
    }
    #endregion Constructors
}

enum ChronistFormattingID {
    S        = 0
    Short    = 0
    M        = 1
    Markdown = 1
    Y        = 2
    YAML     = 2
    J        = 3
    JSON     = 3
}

class ChronistFormatInfo : System.IFormatProvider, System.ICustomFormatter {
    #region    Static properties
    static [ChronistFormattingScriptblocks] $DefaultFormattingScriptblocks
    static [string[]] GetSupportedFormats() {
        return [ChronistFormattingID].GetEnumNames()
    }
    #endregion Static properties
    #region    Static methods
    #endregion Static methods
    #region    Instance properties
    [ChronistFormattingScriptblocks] $FormattingScriptblocks
    #endregion Instance properties
    #region    Interface methods
    [object] GetFormat([type]$formatType) {
        if ($formatType -is [System.ICustomFormatter]) {
            return $this
        }
        return $null
    }

    [string] Format(
        [string]$format,
        [object]$argument,
        [System.IFormatProvider]$formatProvider
    ) {
        if ([ChronistFormattingScriptblocks]::IsNotValidFormattableChronistType($argument)) {
            # Handle other formats in try/catch
        }

        if ($format -notin [ChronistFormatInfo]::GetSupportedFormats()) {
            # handle other formats in try/catch
        }

        switch (([ChronistFormattingID]$format)) {
            M {
                return $this.FormatMarkdown($argument)
            }
            J {
                return $argument.ToJson()
            }
            Y {
                return $argument.ToYaml()
            }
            default {
                return $argument.ToShort()
            }
        }

        return ''
    }
    #endregion Interface methods
    #region    Instance methods
    #region    Get for given type
    [System.Collections.Generic.Dictionary[string, scriptblock]] GetFormatters([type]$chronistType) {
        $defaults   = [ChronistFormatInfo]::DefaultFormattingScriptblocks.Get($chronistType)
        $formatters = $this.FormattingScriptblocks.Get($chronistType)
        if ($null -eq $defaults) {
            $defaults = [ChronistFormattingScriptblocks]::n
        }
        if ($null -eq $formatters) {
            return $defaults
        }
        foreach ($defaultName in $defaults.Keys) {
            if (-not $formatters.ContainsKey($defaultName)) {
                $formatters.Add($defaultName, $defaults[$defaultName])
            }
        }

        return $formatters
    }
    [scriptblock] GetFormatter([type]$chronistType, [string]$name, [bool]$quiet) {
        $formatters = $this.GetFormatters($chronistType)
        $notDefined = -not $formatters.ContainsKey($name)

        if ($notDefined -and $quiet) {
            return $null
        } elseif ($notDefined) {
            # error
        }

        return $formatters[$name]
    }
    [scriptblock] GetFormatter([type]$chronistType, [string]$name) {
        return $this.GetFormatter($chronistType, $name, $false)
    }
    #endregion Get for given type
    #region    Get for entry
    [System.Collections.Generic.Dictionary[string, scriptblock]] GetEntryFormatters() {
        return $this.GetFormatters([ChronistEntry])
    }
    [scriptblock] GetEntryFormatter([string]$name, [bool]$quiet) {
        return $this.GetFormatter([ChronistEntry], $name, $quiet)
    }
    [scriptblock] GetEntryFormatter([string]$name) {
        return $this.GetFormatter([ChronistEntry], $name, $false)
    }
    [scriptblock] GetDefaultEntryFormatter() {
        return $this.GetFormatter([ChronistEntry], 'Default', $false)
    }
    #endregion Get for entry
    #region    Get for unreleased
    [System.Collections.Generic.Dictionary[string, scriptblock]] GetUnreleasedFormatters() {
        return $this.GetFormatters([ChronistUnreleased])
    }
    [scriptblock] GetUnreleasedFormatter([string]$name, [bool]$quiet) {
        return $this.GetFormatter([ChronistUnreleased], $name, $quiet)
    }
    [scriptblock] GetUnreleasedFormatter([string]$name) {
        return $this.GetFormatter([ChronistUnreleased], $name, $false)
    }
    [scriptblock] GetDefaultUnreleasedFormatter() {
        return $this.GetFormatter([ChronistUnreleased], 'Default', $false)
    }
    #endregion Get for unreleased
    #region    Get for release
    [System.Collections.Generic.Dictionary[string, scriptblock]] GetReleaseFormatters() {
        return $this.GetFormatters([ChronistRelease])
    }
    [scriptblock] GetReleaseFormatter([string]$name, [bool]$quiet) {
        return $this.GetFormatter([ChronistRelease], $name, $quiet)
    }
    [scriptblock] GetReleaseFormatter([string]$name) {
        return $this.GetFormatter([ChronistRelease], $name, $false)
    }
    [scriptblock] GetDefaultReleaseFormatter() {
        return $this.GetFormatter([ChronistRelease], 'Default', $false)
    }
    #endregion Get for release
    #region    Get for changelog
    [System.Collections.Generic.Dictionary[string, scriptblock]] GetChangelogFormatters() {
        return $this.GetFormatters([ChronistChangelog])
    }
    [scriptblock] GetChangelogFormatter([string]$name, [bool]$quiet) {
        return $this.GetFormatter([ChronistChangelog], $name, $quiet)
    }
    [scriptblock] GetChangelogFormatter([string]$name) {
        return $this.GetFormatter([ChronistChangelog], $name, $false)
    }
    [scriptblock] GetDefaultChangelogFormatter() {
        return $this.GetFormatter([ChronistChangelog], 'Default', $false)
    }
    #endregion Get for changelog

    
    [string] FormatMarkdown([ChronistEntry]$entry) {
        return ''
    }
    [string] FormatMarkdown([ChronistUnreleased]$unreleased) {
        return ''
    }
    [string] FormatMarkdown([ChronistRelease]$release) {
        return ''
    }
    [string] FormatMarkdown([ChronistChangelog]$changelog) {
        return ''
    }
    #endregion Instance methods
    #region    Constructors
    static ChronistFormatInfo() {
        [ChronistFormatInfo]::DefaultFormattingScriptblocks = [ChronistFormattingScriptblocks]::new()
    }
    ChronistFormatInfo() {
        $this.FormattingScriptblocks = [ChronistFormattingScriptblocks]::new($false)
    }
    #endregion Constructors
}

class ChronistEntry : System.IFormattable, System.IComparable, System.IEquatable[Object] {
    #region    Static properties
    static
    [regex]
    $FileNameParsingPattern = [ChronistEntry]::GetFileNameParsingPattern()
    #endregion Static properties
    #region    Static methods
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
    static [hashtable] ParseEntryFileName ([string]$fileName) {
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

    static [hashtable] ParseEntryFileName ([System.IO.FileInfo]$file) {
        return [ChronistEntry]::ParseEntryFileName($file.FullName)
    }

    #endregion Static methods
    #region    Instance properties
    [string]                 $ID
    [datetime]               $MergedAt
    [System.Nullable[int]]   $Priority
    [bool]                   $Breaking
    [ChronistCategory]       $Category
    [string]                 $Synopsis
    [string]                 $Details
    [System.Collections.Generic.List[int]]              $PullRequests
    [System.Collections.Generic.List[int]]              $Issues
    [ChronistLinkReferences] $LinkReferences
    [string[]]               $RelatedChanges
    #endregion Instance properties
    #region    Instance methods
    #region    Interface methods
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

    [string] ToString(
        [string]$Format,
        [System.IFormatProvider]$FormatProvider
    ) {
        <#
            .SYNOPSIS
            Implements IFormattable
        #>
        return ''
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
        $thisDefinesMergedAt  = [datetime]::MinValue -ne $this.MergedAt
        $otherDefinesMergedAt = [datetime]::MinValue -ne $otherEntry.MergedAt
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
        }
        # If the entries are in the same category without priority, merged at,
        # or pull requests defined, they're equivalent for sorting.
        return 0
    }
    #endregion Interface methods

    [void] Initialize() {
        $this.LinkReferences ??= [ChronistLinkReferences]::new()
    }

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
        $parsed = [ChronistEntry]::ParseEntryFileName($file.FullName)
        if (-not $parsed.ContainsKey('Extension')) {
            # error
        }
        if ($parsed.ContainsKey('Category')) {
            $this.Category = $parsed.Category
        }
        if ($parsed.ContainsKey('ID')) {
            $this.ID = $parsed.ID
        }
        if ($parsed.ContainsKey('Priority')) {
            $this.Priority = $parsed.Priority
        }

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
        # Merge data from file
        if (-not [string]::IsNullOrWhiteSpace($fileData.synopsis)) {
            $this.Synopsis = $fileData.Synopsis
        } else {
            # error, missing synopsis
        }
        if (-not [string]::IsNullOrWhiteSpace($fileData.details)) {
            $this.Details = $fileData.details
        }
        if (-not [string]::IsNullOrWhiteSpace($fileData.category)) {
            $this.Category = $fileData.Category
        }
        if (-not [string]::IsNullOrWhiteSpace($fileData.id)) {
            $this.ID = $fileData.id
        }
        if ($fileData.ContainsKey('priority')) {
            $this.Priority = $fileData.priority
        }
        if ($fileData.ContainsKey('breaking')) {
            $this.Breaking = $fileData.breaking
        } elseif (
            $this.Category -in @(
                [ChronistCategory]::Removed,
                [ChronistCategory]::Changed
            )
        ) {
            $this.Breaking = $false
        }
        if ($fileData.ContainsKey('pull_requests')) {
            $this.PullRequests = $fileData.pull_requests
        }
        if ($fileData.ContainsKey('issues')) {
            $this.Issues = $fileData.issues
        }
        if ($fileData.ContainsKey('link_references')) {
            # add link references
        }
        if ($fileData.ContainsKey('related_changes')) {
            $this.RelatedChanges = $fileData.related_changes
        }
    }
    #endregion Constructors
}

class ChronistUnreleased {
    #region    Static properties
    #endregion Static properties
    #region    Static methods
    #endregion Static methods
    #region    Instance properties
    [bool]                   $Breaking
    [string]                 $DiffUrl
    [string]                 $Synopsis
    [string]                 $Details
    [System.Collections.Generic.List[ChronistEntry]]    $UndefinedEntries
    [System.Collections.Generic.List[ChronistEntry]]    $Security
    [System.Collections.Generic.List[ChronistEntry]]    $Removed
    [System.Collections.Generic.List[ChronistEntry]]    $Deprecated
    [System.Collections.Generic.List[ChronistEntry]]    $Changed
    [System.Collections.Generic.List[ChronistEntry]]    $Added
    [System.Collections.Generic.List[ChronistEntry]]    $Fixed
    [ChronistLinkReferences] $LinkReferences
    #endregion Instance properties
    #region    Instance methods
    [void] Initialize() {
        $this.Security       ??= [System.Collections.Generic.List[ChronistEntry]]::new(10)
        $this.Removed        ??= [System.Collections.Generic.List[ChronistEntry]]::new(10)
        $this.Deprecated     ??= [System.Collections.Generic.List[ChronistEntry]]::new(10)
        $this.Changed        ??= [System.Collections.Generic.List[ChronistEntry]]::new(10)
        $this.Added          ??= [System.Collections.Generic.List[ChronistEntry]]::new(10)
        $this.Fixed          ??= [System.Collections.Generic.List[ChronistEntry]]::new(10)
        $this.LinkReferences ??= [ChronistLinkReferences]::new()
    }

    [void] AddEntry([ChronistEntry]$entry, [bool]$sort) {
        switch ($entry.Category) {
            Undefined {
                $this.UndefinedEntries.Add($entry)
                if ($sort) { $this.UndefinedEntries.Sort() }
            }
            Security {
                $this.Security.Add($entry)
                if ($sort) { $this.Security.Sort() }
            }
            Removed {
                $this.Removed.Add($entry)
                if ($sort) { $this.Removed.Sort() }
            }
            Deprecated {
                $this.Deprecated.Add($entry)
                if ($sort) { $this.Deprecated.Sort() }
            }
            Changed {
                $this.Changed.Add($entry)
                if ($sort) { $this.Changed.Sort() }
            }
            Added {
                $this.Added.Add($entry)
                if ($sort) { $this.Added.Sort() }
            }
            Fixed {
                $this.Fixed.Add($entry)
                if ($sort) { $this.Fixed.Sort() }
            }
        }
    }
    [void] AddEntry([ChronistEntry]$entry) {
        $this.AddEntry($entry, $false)
    }

    [void] AddEntries([ChronistEntry[]]$entries) {
        foreach ($entry in $entries) {
            $this.AddEntry($entry)
        }
        if ($entries.Where({$_.Category -eq [ChronistCategory]::Undefined}).Count -ge 1) {
            $this.UndefinedEntries.Sort()
        }
        if ($entries.Where({$_.Category -eq [ChronistCategory]::Security}).Count -ge 1) {
            $this.Security.Sort()
        }
        if ($entries.Where({$_.Category -eq [ChronistCategory]::Removed}).Count -ge 1) {
            $this.Removed.Sort()
        }
        if ($entries.Where({$_.Category -eq [ChronistCategory]::Deprecated}).Count -ge 1) {
            $this.Deprecated.Sort()
        }
        if ($entries.Where({$_.Category -eq [ChronistCategory]::Changed}).Count -ge 1) {
            $this.Changed.Sort()
        }
        if ($entries.Where({$_.Category -eq [ChronistCategory]::Added}).Count -ge 1) {
            $this.Added.Sort()
        }
        if ($entries.Where({$_.Category -eq [ChronistCategory]::Fixed}).Count -ge 1) {
            $this.Fixed.Sort()
        }
    }
    #endregion Instance methods
    #region    Constructors
    ChronistUnreleased() {
        $this.Initialize()
    }

    ChronistUnreleased([System.IO.DirectoryInfo]$unreleasedFolder) {
        $this.Initialize()
    }
    #endregion Constructors
}

class ChronistRelease {
    #region    Static properties
    #endregion Static properties
    #region    Static methods
    #endregion Static methods
    #region    Instance properties
    [string]                 $Tag
    [datetime]               $Date
    [bool]                   $Breaking
    [string]                 $DiffUrl
    [string]                 $Synopsis
    [string]                 $Details
    [System.Collections.Generic.List[ChronistEntry]]    $Security
    [System.Collections.Generic.List[ChronistEntry]]    $Removed
    [System.Collections.Generic.List[ChronistEntry]]    $Deprecated
    [System.Collections.Generic.List[ChronistEntry]]    $Changed
    [System.Collections.Generic.List[ChronistEntry]]    $Added
    [System.Collections.Generic.List[ChronistEntry]]    $Fixed
    [ChronistLinkReferences] $LinkReferences
    #endregion Instance properties
    #region    Instance methods
    #endregion Instance methods
    #region    Constructors
    #endregion Constructors
}

class ChronistChangelog {
    #region    Static properties
    #endregion Static properties
    #region    Static methods
    #endregion Static methods
    #region    Instance properties
    [string]                 $ProjectName
    [string]                 $Overview
    [ChronistUnreleased]     $Unreleased
    [System.Collections.Generic.List[ChronistRelease]]  $Releases
    [ChronistLinkReferences] $LinkReferences
    #endregion Instance properties
    #region    Instance methods
    #endregion Instance methods
    #region    Constructors
    #endregion Constructors
}

class ChronistConfiguration {
    #region    Static properties
    #endregion Static properties
    #region    Static methods
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

function New-ChronistEntry {
    [cmdletbinding()]
    param(

    )

    begin {

    }

    process {

    }

    end {

    }
}

function New-ChronistRelease {
    [cmdletbinding()]
    param(

    )

    begin {

    }

    process {

    }

    end {

    }
}

function Initialize-ChronistProject {
    [cmdletbinding()]
    param(

    )

    begin {

    }

    process {

    }

    end {

    }
}

function Import-ChronistEntry {
    [cmdletbinding()]
    param(

    )

    begin {

    }

    process {

    }

    end {

    }
}

function Export-ChronistEntry {
    [cmdletbinding()]
    param(

    )

    begin {

    }

    process {

    }

    end {

    }
}

function Resolve-ChronistEntry {
    [cmdletbinding()]
    param(

    )

    begin {

    }

    process {

    }

    end {

    }
}

function Update-ChronistEntry {
    [cmdletbinding()]
    param(

    )

    begin {

    }

    process {

    }

    end {

    }
}

function Resolve-ChronistRelease {
    [cmdletbinding()]
    param(

    )

    begin {

    }

    process {

    }

    end {

    }
}

function Update-ChronistChangelog {
    [cmdletbinding()]
    param(

    )

    begin {

    }

    process {

    }

    end {

    }
}

function Export-ChronistChangelog {
    [cmdletbinding()]
    param(
        # Foo
        [Parameter(
            Position = 0,
            ParameterSetName = 'Foo'
        )]
        [string]
        $Foo
    )

    begin {

    }

    process {

    }

    end {

    }
}
