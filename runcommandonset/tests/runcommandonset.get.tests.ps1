# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Describe 'tests for runcommandonset get' {
    BeforeAll {
        $oldPath = $env:DSC_RESOURCE_PATH
        $env:DSC_RESOURCE_PATH = Join-Path $PSScriptRoot ".."
    }

    AfterAll {
        $env:DSC_RESOURCE_PATH = $oldPath
    }

    It 'Input passed for executable, arguments, and exit code' {
        $json = @"
        {
            "executable": "foo",
            "arguments": ["bar", "baz"],
            "exit_code": 5,
        }
"@

        $result = $json | dsc resource get -r Microsoft.DSC.Transitional/RunCommandOnSet | ConvertFrom-Json
        $result.actualState.arguments | Should -BeExactly @('bar', 'baz')
        $result.actualState.executable | Should -BeExactly 'foo'
        $result.actualState.exit_code | Should -BeExactly 5
    }

    It 'Executable is a required input via CLI arguments' {
        $null = runcommandonset get -a foo
        $LASTEXITCODE | Should -Be 4
    }

    It 'Executable is a required input via STDIN' {
        '{ "arguments": "foo" }' | dsc resource get -r Microsoft.DSC.Transitional/RunCommandOnSet
        $LASTEXITCODE | Should -Be 2
    }
}
