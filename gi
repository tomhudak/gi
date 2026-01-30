#!/usr/bin/env bash
#
# gi - A typo-tolerant git wrapper
# https://github.com/tomhudak/gi
#
# Handles common git typos like "gi tadd" (meant "git add")
# and passes corrected commands to git.

set -euo pipefail

VERSION="1.0.0"

# Color output (disable with GI_NO_COLOR=1)
if [[ -z "${GI_NO_COLOR:-}" ]] && [[ -t 1 ]]; then
    YELLOW='\033[0;33m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
else
    YELLOW=''
    GREEN=''
    NC=''
fi

# Show what command we're actually running (disable with GI_QUIET=1)
show_correction() {
    if [[ -z "${GI_QUIET:-}" ]]; then
        echo -e "${YELLOW}gi:${NC} running ${GREEN}git $*${NC}" >&2
    fi
}

# Common typo corrections mapping
# Format: typo → correct command
declare -A TYPO_MAP=(
    # "t" prefix typos (the main use case - typing "gi tadd" instead of "git add")
    ["tadd"]="add"
    ["tad"]="add"
    ["tbranch"]="branch"
    ["tcheckout"]="checkout"
    ["tchekcout"]="checkout"
    ["tclone"]="clone"
    ["tcommit"]="commit"
    ["tconfig"]="config"
    ["tdiff"]="diff"
    ["tfetch"]="fetch"
    ["tinit"]="init"
    ["tlog"]="log"
    ["tmerge"]="merge"
    ["tmv"]="mv"
    ["tpull"]="pull"
    ["tpush"]="push"
    ["trebase"]="rebase"
    ["tremote"]="remote"
    ["treset"]="reset"
    ["trestore"]="restore"
    ["trm"]="rm"
    ["tshow"]="show"
    ["tstash"]="stash"
    ["tstatus"]="status"
    ["tstat"]="status"
    ["tswitch"]="switch"
    ["ttag"]="tag"

    # Double letter typos
    ["addd"]="add"
    ["branchh"]="branch"
    ["checkoutt"]="checkout"
    ["clonee"]="clone"
    ["comit"]="commit"
    ["committ"]="commit"
    ["commmit"]="commit"
    ["configg"]="config"
    ["difff"]="diff"
    ["fetchh"]="fetch"
    ["initt"]="init"
    ["logg"]="log"
    ["mergee"]="merge"
    ["pulll"]="pull"
    ["pushh"]="push"
    ["pussh"]="push"
    ["rebasee"]="rebase"
    ["resett"]="reset"
    ["showw"]="show"
    ["stashh"]="stash"
    ["statuss"]="status"
    ["tagg"]="tag"

    # Swapped/transposed letters
    ["dif"]="diff"
    ["idff"]="diff"
    ["psuh"]="push"
    ["psush"]="push"
    ["puhs"]="push"
    ["pul"]="pull"
    ["pll"]="pull"
    ["plul"]="pull"
    ["puyll"]="pull"
    ["stauts"]="status"
    ["sttaus"]="status"
    ["staus"]="status"
    ["stats"]="status"
    ["stat"]="status"
    ["statsu"]="status"
    ["satus"]="status"
    ["chekout"]="checkout"
    ["chekcout"]="checkout"
    ["checkou"]="checkout"
    ["checkout"]="checkout"
    ["chekc"]="checkout"
    ["chekcout"]="checkout"
    ["comit"]="commit"
    ["commti"]="commit"
    ["ocmmit"]="commit"
    ["cmmit"]="commit"
    ["commt"]="commit"
    ["brnach"]="branch"
    ["brnahc"]="branch"
    ["bracnh"]="branch"
    ["barnch"]="branch"
    ["brnch"]="branch"
    ["brach"]="branch"
    ["marge"]="merge"
    ["emrge"]="merge"
    ["mrege"]="merge"
    ["rebse"]="rebase"
    ["reabse"]="rebase"
    ["reabase"]="rebase"
    ["feetch"]="fetch"
    ["fethc"]="fetch"
    ["fetc"]="fetch"
    ["cloen"]="clone"
    ["cloone"]="clone"
    ["clonw"]="clone"
    ["clon"]="clone"
    ["remtoe"]="remote"
    ["reomte"]="remote"
    ["rmeote"]="remote"
    ["stahs"]="stash"
    ["satsh"]="stash"
    ["stasj"]="stash"
    ["swtich"]="switch"
    ["swich"]="switch"
    ["swithc"]="switch"
    ["rset"]="reset"
    ["reste"]="reset"
    ["restor"]="restore"
    ["restoer"]="restore"

    # Missing letters / shortcuts
    ["ad"]="add"
    ["br"]="branch"
    ["ch"]="checkout"
    ["co"]="checkout"
    ["ci"]="commit"
    ["cm"]="commit"
    ["df"]="diff"
    ["fe"]="fetch"
    ["lg"]="log"
    ["mg"]="merge"
    ["pl"]="pull"
    ["ps"]="push"
    ["rb"]="rebase"
    ["rs"]="reset"
    ["rt"]="remote"
    ["sh"]="show"
    ["st"]="status"
    ["sw"]="switch"

    # Common mistakes
    ["cheery-pick"]="cherry-pick"
    ["chery-pick"]="cherry-pick"
    ["cherrypick"]="cherry-pick"
    ["cherry"]="cherry-pick"
    ["bisec"]="bisect"
    ["submoduel"]="submodule"
    ["submodle"]="submodule"
    ["worktere"]="worktree"
    ["wortree"]="worktree"
)

# Print help
print_help() {
    cat << 'EOF'
gi - A typo-tolerant git wrapper

USAGE:
    gi <command> [args...]

DESCRIPTION:
    gi corrects common git typos and passes the corrected command to git.

    The main use case is when you type "gi tadd" instead of "git add" -
    the "t" from "git" gets attached to the command. gi handles this
    and many other common typos.

EXAMPLES:
    gi tadd .           →  git add .
    gi tcommit -m "x"   →  git commit -m "x"
    gi tpush            →  git push
    gi stauts           →  git status
    gi psuh             →  git push
    gi comit -m "x"     →  git commit -m "x"

OPTIONS:
    --help, -h      Show this help message
    --version, -v   Show version
    --list-typos    List all known typo corrections

ENVIRONMENT:
    GI_QUIET=1      Don't show correction messages
    GI_NO_COLOR=1   Disable colored output

MORE INFO:
    https://github.com/tomhudak/gi
EOF
}

# Print version
print_version() {
    echo "gi version $VERSION"
}

# List all typo corrections
list_typos() {
    echo "Known typo corrections:"
    echo ""
    for typo in $(echo "${!TYPO_MAP[@]}" | tr ' ' '\n' | sort); do
        printf "  %-15s → %s\n" "$typo" "${TYPO_MAP[$typo]}"
    done
}

# Try to correct a command using fuzzy matching (Levenshtein distance)
# This is a fallback for typos not in the map
fuzzy_match() {
    local input="$1"
    local -a git_commands=(
        "add" "bisect" "branch" "checkout" "cherry-pick" "clone" "commit"
        "config" "diff" "fetch" "grep" "init" "log" "merge" "mv" "pull"
        "push" "rebase" "remote" "reset" "restore" "revert" "rm" "show"
        "stash" "status" "submodule" "switch" "tag" "worktree"
    )

    # Simple prefix matching for commands starting with 't'
    if [[ "$input" == t* ]]; then
        local without_t="${input:1}"
        for cmd in "${git_commands[@]}"; do
            if [[ "$cmd" == "$without_t"* ]]; then
                echo "$cmd"
                return 0
            fi
        done
    fi

    # Check if input is a prefix of any command
    for cmd in "${git_commands[@]}"; do
        if [[ "$cmd" == "$input"* ]] && [[ ${#input} -ge 2 ]]; then
            echo "$cmd"
            return 0
        fi
    done

    return 1
}

# Main logic
main() {
    # Handle no arguments
    if [[ $# -eq 0 ]]; then
        git
        return $?
    fi

    local cmd="$1"
    shift

    # Handle special flags
    case "$cmd" in
        --help|-h)
            print_help
            return 0
            ;;
        --version|-v)
            print_version
            return 0
            ;;
        --list-typos)
            list_typos
            return 0
            ;;
    esac

    # Check if command is in typo map
    if [[ -v "TYPO_MAP[$cmd]" ]]; then
        local corrected="${TYPO_MAP[$cmd]}"
        show_correction "$corrected" "$@"
        git "$corrected" "$@"
        return $?
    fi

    # Try fuzzy matching for unknown commands
    local fuzzy_result
    if fuzzy_result=$(fuzzy_match "$cmd"); then
        show_correction "$fuzzy_result" "$@"
        git "$fuzzy_result" "$@"
        return $?
    fi

    # No correction found - pass through to git as-is
    # (git will show its own error for unknown commands)
    git "$cmd" "$@"
    return $?
}

main "$@"
