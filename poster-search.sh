#!/usr/bin/env bash

# Version information
readonly VERSION="0.2.0"  # Major.Minor.Patch

# Changelog:
# v0.2.0 - Complete rebuild with simplified codebase
#        - Same feature set, more maintainable code
#        - Optimized search performance

# ============================================================================
# User Configuration
# ============================================================================

# Search paths - Add or modify paths as needed
declare -a SEARCH_PATHS=(
    "/volume2/docker/dockge/stacks/daps/posters"    # Main DAPS posters directory
    # Add additional paths here
)

# User priority and color mapping
declare -a USERS=(
    "LionCityGaming:1;31"  # Light Red
    "IamSpartacus:1;32"    # Light Green
    "Drazzib:1;34"         # Light Blue
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
    "Jpalenz77:0;31"      # Dark Red
    "chrisdc:1;35"         # Light Magenta
    "zarox:0;33"           # Dark Yellow
)

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

Examples:
    $0 movie                     # Search for "movie" in all formats
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
        printf "%3d. \e[${color}m%-15s\e[0m\n" "$count" "$user"
        ((count++))
    done
}

# Search for files
search_files() {
    local search_term="$1"
    local username="$2"
    local format="$3"
    local sort_by="$4"
    local results_file=$(mktemp)

    for path in "${SEARCH_PATHS[@]}"; do
        [ ! -d "$path" ] && continue

        # Build format and search term filters for find
        local find_cmd="find \"$path\" -mindepth 1 -type f "
        
        # Add format filter
        case "$format" in
            "jpg")  find_cmd+=" -iname \"*.jpg\"" ;;
            "jpeg") find_cmd+=" -iname \"*.jpeg\"" ;;
            "png")  find_cmd+=" -iname \"*.png\"" ;;
            "all")  find_cmd+=" \( -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.png\" \)" ;;
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
        eval "$find_cmd" | while read -r file; do
            local owner=$(basename "$(dirname "$file")")
            
            # Apply username filter if specified
            if [ -n "$username" ]; then
                [[ ${owner,,} != *${username,,}* ]] && continue
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

            echo "$year|$priority|$owner|$filename" >> "$results_file"
        done
    done

    # Sort and display results
    local sort_cmd
    case "$sort_by" in
        "username")   sort_cmd="sort -t'|' -k3,3 -k4,4" ;;
        "filename")   sort_cmd="sort -t'|' -k4,4" ;;
        "year-asc")   sort_cmd="sort -t'|' -k1,1n -k4,4" ;;
        "year-desc")  sort_cmd="sort -t'|' -k1,1nr -k4,4" ;;
        *)           sort_cmd="sort -t'|' -k2,2n -k1,1nr" ;;  # priority (default)
    esac

    # Display results
    local count=1
    eval "$sort_cmd $results_file" | while IFS='|' read -r year priority owner filename; do
        # Find user's color
        local color="0"
        for user_data in "${USERS[@]}"; do
            if [[ "$user_data" == "${owner}:"* ]]; then
                color="${user_data##*:}"
                break
            fi
        done
        
        # Highlight search term if specified
        if [ -n "$search_term" ]; then
            filename=$(echo "$filename" | sed -E "s/($search_term)/\x1b[7;33m\1\x1b[0m/gi")
        fi
        
        printf "%3d. \e[${color}m%-15s\e[0m   %s\n" "$count" "$owner" "$filename"
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

    # Parse options
    while getopts "hu:f:s:l" opt; do
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
            ?) show_help >&2; exit 1 ;;
        esac
    done
    shift $((OPTIND-1))

    # Get search term
    local search_term="$*"
    
    # If no search term and no format specified, show usage
    if [ -z "$search_term" ] && [ "$format" = "all" ]; then
        show_help
        exit 1
    fi

    # Perform search
    search_files "$search_term" "$username" "$format" "$sort_by"
}

main "$@"
