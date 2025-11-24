# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../build.helpers.psm1

BeforeDiscovery {
    # Limit the folders to recursively search for rust i18n translation strings
    $rootFolders = @(
        'adapters'
        'dsc'
        'extensions'
        'grammars'
        'lib'
        'pal'
        'resources'
        'tools'
        'y2j'
    )
    $localeFolders = $rootFolders | ForEach-Object -Process {
        Get-ChildItem $PSScriptRoot/../../$_/locales -Recurse -Directory
    }
    
    $projects = @()
    $localeFolders | ForEach-Object -Process {
        $projects   += @{
            project         = Split-Path $_ -Parent
            translationInfo = [DscProjectRustTranslationInfo]::new($_)
        }
    }
}

Describe 'Internationalization tests' {
    Context '<project>' -ForEach $projects {
        It 'Uses translation strings' {
            $check = @{
                Not           = $true
                BeNullOrEmpty = $true
                Because       = "'$project' defines at least one translation file"
            }
            $translationInfo.UsedTranslations | Should @check
        }
        It 'Does not define any duplicate translation strings' {
            $check = @{
                BeNullOrEmpty = $true
                Because = (@(
                    "The following translation keys are defined more than once:"
                    $translationInfo.DuplicateTranslations | ConvertTo-Json -Depth 2
                ) -join ' ')
            }

            $translationInfo.DuplicateTranslations | Should @check
        }

        It 'Uses every defined translation string' {
            $check = @{
                BeNullOrEmpty = $true
                Because = (@(
                    "The following translation keys are defined but not used:"
                    $translationInfo.UnusedTranslations | ConvertTo-Json -Depth 2
                ) -join ' ')
            }
            $translationInfo.UnusedTranslations | Should @check
        }

        It 'Defines every used translation string' {
            $check = @{
                BeNullOrEmpty = $true
                Because = (@(
                    "The following translation keys are used but not defined:"
                    $translationInfo.MissingTranslations | ConvertTo-Json -Depth 2
                ) -join ' ')
            }
            $translationInfo.MissingTranslations | Should @check
        }
    }
}
