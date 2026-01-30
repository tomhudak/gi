#Requires -Version 5.1
<#
.SYNOPSIS
    gi - A typo-tolerant git wrapper for Windows PowerShell

.DESCRIPTION
    Handles common git typos like "gi tadd" (meant "git add")
    and passes corrected commands to git.

.EXAMPLE
    gi tadd .
    gi tcommit -m "fix bug"
    gi psuh origin main

.LINK
    https://github.com/tomhudak/gi
#>

$Version = "1.0.0"

# Typo corrections mapping
$TypoMap = @{
    # "t" prefix typos (typing "gi tadd" instead of "git add")
    "tadd" = "add"
    "tad" = "add"
    "tbranch" = "branch"
    "tcheckout" = "checkout"
    "tchekcout" = "checkout"
    "tclone" = "clone"
    "tcommit" = "commit"
    "tconfig" = "config"
    "tdiff" = "diff"
    "tfetch" = "fetch"
    "tinit" = "init"
    "tlog" = "log"
    "tmerge" = "merge"
    "tmv" = "mv"
    "tpull" = "pull"
    "tpush" = "push"
    "trebase" = "rebase"
    "tremote" = "remote"
    "treset" = "reset"
    "trestore" = "restore"
    "trm" = "rm"
    "tshow" = "show"
    "tstash" = "stash"
    "tstatus" = "status"
    "tstat" = "status"
    "tswitch" = "switch"
    "ttag" = "tag"

    # Double letter typos
    "addd" = "add"
    "branchh" = "branch"
    "checkoutt" = "checkout"
    "clonee" = "clone"
    "comit" = "commit"
    "committ" = "commit"
    "commmit" = "commit"
    "configg" = "config"
    "difff" = "diff"
    "fetchh" = "fetch"
    "initt" = "init"
    "logg" = "log"
    "mergee" = "merge"
    "pulll" = "pull"
    "pushh" = "push"
    "pussh" = "push"
    "rebasee" = "rebase"
    "resett" = "reset"
    "showw" = "show"
    "stashh" = "stash"
    "statuss" = "status"
    "tagg" = "tag"

    # Swapped/transposed letters
    "dif" = "diff"
    "idff" = "diff"
    "psuh" = "push"
    "psush" = "push"
    "puhs" = "push"
    "pul" = "pull"
    "pll" = "pull"
    "plul" = "pull"
    "puyll" = "pull"
    "stauts" = "status"
    "sttaus" = "status"
    "staus" = "status"
    "stats" = "status"
    "stat" = "status"
    "statsu" = "status"
    "satus" = "status"
    "chekout" = "checkout"
    "chekcout" = "checkout"
    "checkou" = "checkout"
    "chekc" = "checkout"
    "commti" = "commit"
    "ocmmit" = "commit"
    "cmmit" = "commit"
    "commt" = "commit"
    "brnach" = "branch"
    "brnahc" = "branch"
    "bracnh" = "branch"
    "barnch" = "branch"
    "brnch" = "branch"
    "brach" = "branch"
    "marge" = "merge"
    "emrge" = "merge"
    "mrege" = "merge"
    "rebse" = "rebase"
    "reabse" = "rebase"
    "reabase" = "rebase"
    "feetch" = "fetch"
    "fethc" = "fetch"
    "fetc" = "fetch"
    "cloen" = "clone"
    "cloone" = "clone"
    "clonw" = "clone"
    "clon" = "clone"
    "remtoe" = "remote"
    "reomte" = "remote"
    "rmeote" = "remote"
    "stahs" = "stash"
    "satsh" = "stash"
    "stasj" = "stash"
    "swtich" = "switch"
    "swich" = "switch"
    "swithc" = "switch"
    "rset" = "reset"
    "reste" = "reset"
    "restor" = "restore"
    "restoer" = "restore"

    # Missing letters / shortcuts
    "ad" = "add"
    "br" = "branch"
    "ch" = "checkout"
    "co" = "checkout"
    "ci" = "commit"
    "cm" = "commit"
    "df" = "diff"
    "fe" = "fetch"
    "lg" = "log"
    "mg" = "merge"
    "pl" = "pull"
    "ps" = "push"
    "rb" = "rebase"
    "rs" = "reset"
    "rt" = "remote"
    "sh" = "show"
    "st" = "status"
    "sw" = "switch"

    # Common mistakes
    "cheery-pick" = "cherry-pick"
    "chery-pick" = "cherry-pick"
    "cherrypick" = "cherry-pick"
    "cherry" = "cherry-pick"
    "bisec" = "bisect"
    "submoduel" = "submodule"
    "submodle" = "submodule"
    "worktere" = "worktree"
    "wortree" = "worktree"
}

function Show-Correction {
    param([string]$Command, [string[]]$Arguments)

    if (-not $env:GI_QUIET) {
        $argString = if ($Arguments) { " $($Arguments -join ' ')" } else { "" }
        Write-Host "gi: " -ForegroundColor Yellow -NoNewline
        Write-Host "running " -NoNewline
        Write-Host "git $Command$argString" -ForegroundColor Green
    }
}

function Show-Help {
    @"
gi - A typo-tolerant git wrapper

USAGE:
    gi <command> [args...]

DESCRIPTION:
    gi corrects common git typos and passes the corrected command to git.

    The main use case is when you type "gi tadd" instead of "git add" -
    the "t" from "git" gets attached to the command. gi handles this
    and many other common typos.

EXAMPLES:
    gi tadd .           ->  git add .
    gi tcommit -m "x"   ->  git commit -m "x"
    gi tpush            ->  git push
    gi stauts           ->  git status
    gi psuh             ->  git push

OPTIONS:
    --help, -h      Show this help message
    --version, -v   Show version
    --list-typos    List all known typo corrections

ENVIRONMENT:
    `$env:GI_QUIET = 1   Don't show correction messages

MORE INFO:
    https://github.com/tomhudak/gi
"@
}

function Show-Version {
    "gi version $Version"
}

function Show-Typos {
    Write-Output "Known typo corrections:"
    Write-Output ""
    $TypoMap.GetEnumerator() | Sort-Object Name | ForEach-Object {
        "  {0,-15} -> {1}" -f $_.Name, $_.Value
    }
}

function Find-FuzzyMatch {
    param([string]$Input)

    $gitCommands = @(
        "add", "bisect", "branch", "checkout", "cherry-pick", "clone", "commit",
        "config", "diff", "fetch", "grep", "init", "log", "merge", "mv", "pull",
        "push", "rebase", "remote", "reset", "restore", "revert", "rm", "show",
        "stash", "status", "submodule", "switch", "tag", "worktree"
    )

    # Simple prefix matching for commands starting with 't'
    if ($Input.StartsWith("t")) {
        $withoutT = $Input.Substring(1)
        foreach ($cmd in $gitCommands) {
            if ($cmd.StartsWith($withoutT)) {
                return $cmd
            }
        }
    }

    # Check if input is a prefix of any command
    if ($Input.Length -ge 2) {
        foreach ($cmd in $gitCommands) {
            if ($cmd.StartsWith($Input)) {
                return $cmd
            }
        }
    }

    return $null
}

# Main logic
function Main {
    param([string[]]$Arguments)

    # Handle no arguments
    if (-not $Arguments -or $Arguments.Count -eq 0) {
        & git
        return
    }

    $cmd = $Arguments[0]
    $remainingArgs = if ($Arguments.Count -gt 1) { $Arguments[1..($Arguments.Count-1)] } else { @() }

    # Handle special flags
    switch ($cmd) {
        { $_ -in "--help", "-h" } {
            Show-Help
            return
        }
        { $_ -in "--version", "-v" } {
            Show-Version
            return
        }
        "--list-typos" {
            Show-Typos
            return
        }
    }

    # Check if command is in typo map
    if ($TypoMap.ContainsKey($cmd)) {
        $corrected = $TypoMap[$cmd]
        Show-Correction -Command $corrected -Arguments $remainingArgs
        & git $corrected @remainingArgs
        return
    }

    # Try fuzzy matching for unknown commands
    $fuzzyResult = Find-FuzzyMatch -Input $cmd
    if ($fuzzyResult) {
        Show-Correction -Command $fuzzyResult -Arguments $remainingArgs
        & git $fuzzyResult @remainingArgs
        return
    }

    # No correction found - pass through to git as-is
    & git $cmd @remainingArgs
}

Main -Arguments $args
