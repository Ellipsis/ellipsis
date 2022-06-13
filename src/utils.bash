# utils.bash
#
# Utility functions used by ellipsis.

# check if a command or function exists
utils.cmd_exists() {
    hash "$1" &> /dev/null
}

# Check for interactive tty
utils.is_interactive() {
    if [ ! -t 1 ]; then
        return 1
    fi
    return 0
}

# prompt with message and return true if yes/YES, otherwise false
# If a default is provided, there will be no prompt in a non interactive terminal
utils.prompt() {
    local prompt="$1"
    local default="$2"

    if utils.is_interactive || utils.is_true "$ELLIPSIS_FORCE_PROMPT"; then
        read -r -p "$prompt " answer
    fi

    # Use default if answer is empty or tty is non interactive
    if [ -z "$answer" ]; then
        answer="$default"
    fi

    if ! utils.is_true "$answer"; then
        return 1
    fi
    return 0
}

# Run web-based installers
utils.run_installer() {
    local url="${url:-$1}"
    # save reference to current dir
    local cwd="$(pwd)"
    # create temp dir and cd to it
    local tmp_dir="$(mktemp -d "$TMPDIR.XXXXXX")" && cd "$tmp_dir"
    # download installer
    curl -sL "$url" > "tmp-$$.sh"
    # run with ELLIPSIS env var set
    ELLIPSIS=1 sh "tmp-$$.sh"
    # change back to original dir and clean up
    cd "$cwd"
    rm -rf "$tmp_dir"
}

utils.strip_colors() {
    echo "$@" | sed -e 's/\[[^m]*m//g'
}

# Compare version strings
#
# Usage:
#   utils.version_compare "1.2-Alpha" "lt" "1.4"
#
# Operants: <, lt, <=, le, >, gt, >=, ge, ==, =, eq, !=, ne
# Return: false or true based on result
utils.version_compare() {
    # Strip everything behind a dash (eg. 1.2.0-rc1 -> 1.2.0)
    local v1="${1%%-*}"
    local v2="${3%%-*}"

    # Split version numbers into array
    v1=(${v1//./ })
    v2=(${v2//./ })

    # Initialize loop operants and return code
    case "$2" in
        \<|lt|-lt)
            local op_success="-lt"
            local op_fail="-gt"
            local equal_return=1
            ;;
        \<=|le|-le)
            local op_success="-lt"
            local op_fail="-gt"
            local equal_return=0
            ;;
        \>|gt|-gt)
            local op_success="-gt"
            local op_fail="-lt"
            local equal_return=1
            ;;
        \>=|ge|-ge)
            local op_success="-gt"
            local op_fail="-lt"
            local equal_return=0
            ;;
        ==|=|eq|-eq)
            local op_success=""
            local op_fail="-ne"
            local equal_return=0
            ;;
        !=|ne|-ne)
            local op_success="-ne"
            local op_fail=""
            local equal_return=1
            ;;
    esac

    # Compare all parts of the version string
    for index in ${!v1[*]}; do
        # Check if equal
        if [ "${v1[$index]}" -eq "${v2[$index]}" ]; then
            continue
        fi

        # Check for fail if possible
        if [ -n "$op_fail" ]; then
            if [ "${v1[$index]}" $op_fail "${v2[$index]}" ]; then
                return 1
            fi
        fi

        # Check for success if possible
        if [ -n "$op_success" ]; then
            if [ "${v1[$index]}" $op_success "${v2[$index]}" ]; then
                return 0
            fi
        fi
    done

    return $equal_return
}

# Check if an option is set to true (or 1) in a safe manner
utils.is_true() {
    local var="$1"

    case $var in
        true|True|TRUE|yes|Yes|YES|y|Y|1)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
