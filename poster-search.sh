#!/usr/bin/env bash

# Version information
readonly VERSION="0.2.1"  # Major.Minor.Patch

# Changelog:
# v0.2.1 - Added tput detection and color fallback
#        - Added verbose output mode (-v flag) for full paths
# v0.2.0 - Complete rebuild with simplified codebase
#        - Same feature set, more maintainable code
#        - Optimized search performance

# ============================================================================
# User Configuration
# ============================================================================

# Check if terminal supports colors
if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
    HAS_COLORS=1
    [ "$DEBUG" = "1" ] && echo "[DEBUG] Color output enabled" >&2
else
    HAS_COLORS=0
    [ "$DEBUG" = "1" ] && echo "[DEBUG] Color output disabled" >&2
fi

# Search paths - Add or modify paths as needed
declare -a SEARCH_PATHS=(
    "/volume2/docker/dockge/stacks/daps/posters"    # Main DAPS posters directory
    # Add additional paths here
)

# User priority and color mapping
declare -a USERS=(
    "LionCityGaming:1;31"  # Light Red
    "IamSpartacus:1;32"    # Light Green
    "Drazzilb:1;34"        # Light Blue
    "BZ:1;33"              # Light Yellow
    "dsaq:1;35"            # Light Magenta
    "solen:1;36"           # Light Cyan
    "Quafley:0;32"         # Dark Green
    "sahara:0;34"          # Dark Blue
    "MajorGiant:0;35"      # Dark Magenta
    "Stupifier:0;33"       # Dark Yellow
    "Overbook874:0;36"     # Dark Cyan
    "Mareau:95"            # Light Magenta
    "TokenMinal:94"        # Light Blue
    "Kalyanrajnish:96"     # Light Cyan
    "MiniMyself:92"        # Light Green
    "TheOtherGuy:93"       # Light Yellow
    "Reitenth:1;36"        # Light Cyan
    "WenIsInMood:91"       # Light Red
    "Jpalenz77:0;31"       # Dark Red
    "chrisdc:1;35"         # Light Magenta
    "zarox:0;33"           # Dark Yellow
)

# Color handling functions
color_text() {
    if [ "$HAS_COLORS" -eq 1 ]; then
        printf "\e[%sm%-15s\e[0m" "$1" "$2"
    else
        printf "%-15s" "$2"
    fi
}

highlight_search() {
    if [ "$HAS_COLORS" -eq 1 ]; then
        echo "$1" | sed -E "s/($2)/\x1b[7;33m\1\x1b[0m/gi"
    else
        echo "$1"
    fi
}

# ============================================================================
# Function Definitions
# ============================================================================

# Show help text
show_help() {
    cat << EOF
Poster Search Tool v${VERSION}

Usage: $0 [-u username] [-s sort] [-f format] [-l] [-h] [search term]

Options:
    -h          Show this help text
    -l          List all users
    -u user     Filter by username
    -f format   Filter by format: jpg, jpeg, png, or all (default: all)
    -s sort     Sort by: priority (default), username, filename, year-asc, year-desc
    -v          Verbose output (shows full path)
    -d          Debug mode (shows script operations)

Examples:
    $0 movie                    # Search for "movie" in all formats
    $0 -f png logo              # Search for "logo" in PNG files only
    $0 -u LionCityGaming movie  # Search for "movie" in LionCityGaming's files
    $0 -s year-desc movie       # Search for "movie", newest first
EOF
}

# List users with their colors
list_users() {
    local count=1
    echo "Users (in priority order):"
    for user_data in "${USERS[@]}"; do
        local user="${user_data%%:*}"
        local color="${user_data##*:}"
        printf "%3d. " "$count"
        color_text "$color" "$user"
        echo
        ((count++))
    done
}

# Search for files
search_files() {
    local search_term="$1"
    local username="$2"
    local format="$3"
    local sort_by="$4"
    local verbose="$5"
    local results_file=$(mktemp)

    [ "$DEBUG" = "1" ] && {
        echo "[DEBUG] Search parameters:" >&2
        echo "[DEBUG]   Search term: '$search_term'" >&2
        echo "[DEBUG]   Username: '$username'" >&2
        echo "[DEBUG]   Format: '$format'" >&2
        echo "[DEBUG]   Sort by: '$sort_by'" >&2
        echo "[DEBUG]   Verbose: '$verbose'" >&2
        echo "[DEBUG]   Results file: '$results_file'" >&2
    }

    for path in "${SEARCH_PATHS[@]}"; do
        [ ! -d "$path" ] && {
            [ "$DEBUG" = "1" ] && echo "[DEBUG] Skipping non-existent path: $path" >&2
            continue
        }

        [ "$DEBUG" = "1" ] && echo "[DEBUG] Searching in path: $path" >&2

        # Build format and search term filters for find
        local find_cmd="find \"$path\" -mindepth 1 -type f "

        # Add format filter
        case "$format" in
            "jpg")  find_cmd+=" -iname \"*.jpg\""
                   [ "$DEBUG" = "1" ] && echo "[DEBUG] Format filter: *.jpg" >&2 ;;
            "jpeg") find_cmd+=" -iname \"*.jpeg\""
                   [ "$DEBUG" = "1" ] && echo "[DEBUG] Format filter: *.jpeg" >&2 ;;
            "png")  find_cmd+=" -iname \"*.png\""
                   [ "$DEBUG" = "1" ] && echo "[DEBUG] Format filter: *.png" >&2 ;;
            "all")  find_cmd+=" \( -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.png\" \)"
                   [ "$DEBUG" = "1" ] && echo "[DEBUG] Format filter: all image types" >&2 ;;
        esac

        # Add search term filter if provided
        if [ -n "$search_term" ]; then
            case "$format" in
                "jpg")  find_cmd+=" -a -iname \"*${search_term}*.jpg\"" ;;
                "jpeg") find_cmd+=" -a -iname \"*${search_term}*.jpeg\"" ;;
                "png")  find_cmd+=" -a -iname \"*${search_term}*.png\"" ;;
                "all")  find_cmd+=" -a \( -iname \"*${search_term}*.jpg\" -o -iname \"*${search_term}*.jpeg\" -o -iname \"*${search_term}*.png\" \)" ;;
            esac
        fi

        # Process files found by find
        [ "$DEBUG" = "1" ] && echo "[DEBUG] Executing find command: $find_cmd" >&2
        eval "$find_cmd" | while read -r file; do
            [ "$DEBUG" = "1" ] && echo "[DEBUG] Processing file: $file" >&2
            local owner=$(basename "$(dirname "$file")")

            # Apply username filter if specified
            if [ -n "$username" ]; then
                [[ ${owner,,} != *${username,,}* ]] && {
                    [ "$DEBUG" = "1" ] && echo "[DEBUG] Skipping file (username mismatch): $file" >&2
                    continue
                }
            fi

            # Get user's priority for sorting
            local priority=999
            for i in "${!USERS[@]}"; do
                if [[ "${USERS[$i]}" == "${owner}:"* ]]; then
                    priority=$i
                    break
                fi
            done

            local filename=$(basename "$file")
            local year=9999
            if [[ $filename =~ \(([0-9]{4})\) ]]; then
                year="${BASH_REMATCH[1]}"
            fi

            echo "$year|$priority|$owner|$filename|$file" >> "$results_file"
        done
    done

    # Sort and display results
    local sort_cmd
    case "$sort_by" in
        "username")   sort_cmd="sort -t'|' -k3,3 -k4,4"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting by username" >&2 ;;
        "filename")   sort_cmd="sort -t'|' -k4,4"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting by filename" >&2 ;;
        "year-asc")   sort_cmd="sort -t'|' -k1,1n -k4,4"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting by year (ascending)" >&2 ;;
        "year-desc")  sort_cmd="sort -t'|' -k1,1nr -k4,4"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting by year (descending)" >&2 ;;
        *)           sort_cmd="sort -t'|' -k2,2n -k1,1nr"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting by priority (default)" >&2 ;;
    esac

    # Display results
    local count=1
    eval "$sort_cmd $results_file" | while IFS='|' read -r year priority owner filename filepath; do
        # Find user's color
        local color="0"
        for user_data in "${USERS[@]}"; do
            if [[ "$user_data" == "${owner}:"* ]]; then
                color="${user_data##*:}"
                break
            fi
        done

        # Format the display line with appropriate coloring
        printf "%3d. " "$count"
        color_text "$color" "$owner"
        # Print filename with optional path in verbose mode
        if [ "$verbose" -eq 1 ]; then
            printf "   %s\n" "$(highlight_search "$filename" "$search_term")"
            printf "      Path: %s\n\n" "$filepath"
        else
            printf "   %s\n" "$(highlight_search "$filename" "$search_term")"
        fi
        ((count++))
    done

    rm -f "$results_file"
}

# ============================================================================
# Main Script
# ============================================================================

main() {
    local username=""
    local format="all"
    local sort_by="priority"
    local verbose=0

    # Parse options
    while getopts "hu:f:s:lvd" opt; do
        case $opt in
            h) show_help; exit 0 ;;
            l) list_users; exit 0 ;;
            u) username="$OPTARG" ;;
            f) case "$OPTARG" in
                   jpg|jpeg|png|all) format="$OPTARG" ;;
                   *) echo "Invalid format. Use: jpg, jpeg, png, or all" >&2; exit 1 ;;
               esac ;;
            s) case "$OPTARG" in
                   username|filename|year-asc|year-desc|priority) sort_by="$OPTARG" ;;
                   *) echo "Invalid sort option" >&2; exit 1 ;;
               esac ;;
            d) DEBUG=1 ;;
            v) verbose=1 ;;
            ?) show_help >&2; exit 1 ;;
        esac
    done
    shift $((OPTIND-1))

    # Get search term
    local search_term="$*"

    # Check if terminal supports colors after DEBUG is set
    if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
        HAS_COLORS=1
        [ "$DEBUG" = "1" ] && echo "[DEBUG] Color output enabled" >&2
    else
        HAS_COLORS=0
        [ "$DEBUG" = "1" ] && echo "[DEBUG] Color output disabled" >&2
    fi

    # If no search term and no format specified, show usage
    if [ -z "$search_term" ] && [ "$format" = "all" ]; then
        show_help
        exit 1
    fi

    # Perform search
    search_files "$search_term" "$username" "$format" "$sort_by" "$verbose"
}

main "$@"
