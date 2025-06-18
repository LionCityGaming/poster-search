#!/usr/bin/env bash

# Version information
readonly VERSION="0.4.0"  # Major.Minor.Patch

# Changelog:
# v0.4.0 - Added disk usage information to file count display (-c flag)
#        - New sort options: size-asc, size-desc for sorting by disk usage
#        - Enhanced display format to show both file count and space used
#        - Added human-readable size formatting (B, KB, MB, GB)
# v0.3.1 - Fixed total file count calculation (was showing 0 due to subshell issue)
#        - Added sorting options for file count display (-c flag)
#        - New sort options: count-asc, count-desc for sorting by file count
#        - Enhanced -s argument to work with both search and count modes
# v0.3.0 - Added file count function (-c flag) to show files per user
#        - Added total file count display
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
    "/etc/komodo/stacks/daps-ui/daps-ui/posters"    # Main DAPS posters directory
    # Add additional paths here
)

# User priority and color mapping (in order of priority)
declare -a USERS=(
    "LionCityGaming:1;31"  # Light Red
    "IamSpartacus:1;32"    # Light Green
    "Drazzilb:1;34"        # Light Blue
    "Darkkazul:1;35"       # Light Magenta
    "dsaq:1;33"            # Light Yellow
    "solen:1;36"           # Light Cyan
    "BZ:0;31"              # Dark Red
    "chrisdc:0;32"         # Dark Green
    "Quafley:0;33"         # Dark Yellow
    "sahara:0;34"          # Dark Blue
    "MajorGiant:0;35"      # Dark Magenta
    "Stupifier:0;36"       # Dark Cyan
    "Overbook874:91"       # Light Red
    "Mareau:92"            # Light Green
    "Jpalenz77:93"         # Light Yellow
    "TokenMinal:94"        # Light Blue
    "MiniMyself:95"        # Light Magenta
    "zarox:96"             # Light Cyan
    "dweagle79:1;91"       # Bright Light Red
    "reitenth:1;92"        # Bright Light Green
    "wesisinmood:1;93"     # Bright Light Yellow
    "Kalyanrajnish:1;94"   # Bright Light Blue
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

Usage: $0 [-u username] [-s sort] [-f format] [-l] [-c] [-h] [search term]

Options:
    -h          Show this help text
    -l          List all users
    -c          Show file count and disk usage per user
    -u user     Filter by username
    -f format   Filter by format: jpg, jpeg, png, or all (default: all)
    -s sort     Sort by: priority (default), username, filename, year-asc, year-desc
                For -c flag: priority (default), username, count-asc, count-desc, size-asc, size-desc
    -v          Verbose output (shows full path)
    -d          Debug mode (shows script operations)

Examples:
    $0 movie                    # Search for "movie" in all formats
    $0 -f png logo              # Search for "logo" in PNG files only
    $0 -u LionCityGaming movie  # Search for "movie" in LionCityGaming's files
    $0 -s year-desc movie       # Search for "movie", newest first
    $0 -c                       # Show file count and disk usage per user
    $0 -c -f jpg                # Show JPG file count and disk usage per user
    $0 -c -s count-desc         # Show file count per user, highest count first
    $0 -c -s size-desc          # Show file count per user, largest size first
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

# Function to format bytes into human-readable format
format_bytes() {
    local bytes="$1"
    
    # Handle scientific notation and ensure we have a valid number
    if [[ "$bytes" == *"e+"* ]] || [[ "$bytes" == *"E+"* ]]; then
        # Convert scientific notation to regular number using awk
        bytes=$(awk "BEGIN {printf \"%.0f\", $bytes}")
    fi
    
    # Ensure bytes is a valid integer
    if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
        printf "0 B"
        return
    fi
    
    # Use awk for all calculations to handle large numbers properly
    awk -v bytes="$bytes" 'BEGIN {
        if (bytes < 1024) {
            printf "%.0f B", bytes
        } else if (bytes < 1048576) {
            printf "%.1f KB", bytes/1024
        } else if (bytes < 1073741824) {
            printf "%.1f MB", bytes/1048576
        } else if (bytes < 1099511627776) {
            printf "%.1f GB", bytes/1073741824
        } else {
            printf "%.1f TB", bytes/1099511627776
        }
    }'
}

# Show file count per user with disk usage
show_file_counts() {
    local format="$1"
    local sort_by="$2"
    local temp_file=$(mktemp)
    
    [ "$DEBUG" = "1" ] && echo "[DEBUG] Counting files with format: $format, sort: $sort_by" >&2

    echo "File count and disk usage per user:"
    echo "==================================="
    
    # Collect all user directories and their file counts + disk usage
    for path in "${SEARCH_PATHS[@]}"; do
        [ ! -d "$path" ] && {
            [ "$DEBUG" = "1" ] && echo "[DEBUG] Skipping non-existent path: $path" >&2
            continue
        }

        [ "$DEBUG" = "1" ] && echo "[DEBUG] Counting files in path: $path" >&2

        # Find all subdirectories (user folders) and process them directly
        while IFS= read -r -d '' user_dir; do
            local user=$(basename "$user_dir")
            
            [ "$DEBUG" = "1" ] && echo "[DEBUG] Processing user directory: $user_dir" >&2
            
            # Use find with -printf to get both count and size in one pass - MUCH faster!
            local find_cmd="find \"$user_dir\" -type f"
            
            case "$format" in
                "jpg")  find_cmd+=" -iname \"*.jpg\"" ;;
                "jpeg") find_cmd+=" -iname \"*.jpeg\"" ;;
                "png")  find_cmd+=" -iname \"*.png\"" ;;
                "all")  find_cmd+=" \( -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.png\" \)" ;;
            esac
            
            # Add -printf to get size in bytes - this is MUCH faster than calling stat on each file
            find_cmd+=" -printf \"%s\n\""
            
            [ "$DEBUG" = "1" ] && echo "[DEBUG] Find command: $find_cmd" >&2
            
            # Execute find and process results - this gets both count and total size efficiently
            local count=0
            local size_bytes=0
            
            while IFS= read -r file_size; do
                if [[ "$file_size" =~ ^[0-9]+$ ]]; then
                    ((count++))
                    ((size_bytes += file_size))
                fi
            done < <(eval "$find_cmd" 2>/dev/null)
            
            [ "$DEBUG" = "1" ] && echo "[DEBUG] User: $user, Files: $count, Size: $size_bytes bytes" >&2
            
            # Find user's priority for sorting
            local priority=999
            for i in "${!USERS[@]}"; do
                if [[ "${USERS[$i]}" == "${user}:"* ]]; then
                    priority=$i
                    break
                fi
            done
            
            echo "$priority|$user|$count|$size_bytes" >> "$temp_file"
            
        done < <(find "$path" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    done

    # Calculate totals before displaying - use awk to handle large numbers
    local total_files=$(awk -F'|' '{sum += $3} END {printf "%.0f", sum}' "$temp_file")
    local total_size=$(awk -F'|' '{sum += $4} END {printf "%.0f", sum}' "$temp_file")
    
    # Sort based on the sort_by parameter
    local sort_cmd
    case "$sort_by" in
        "username")   sort_cmd="sort -t'|' -k2,2"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting file counts by username" >&2 ;;
        "count-asc")  sort_cmd="sort -t'|' -k3,3n"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting file counts by count (ascending)" >&2 ;;
        "count-desc") sort_cmd="sort -t'|' -k3,3nr"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting file counts by count (descending)" >&2 ;;
        "size-asc")   sort_cmd="sort -t'|' -k4,4n"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting file counts by size (ascending)" >&2 ;;
        "size-desc")  sort_cmd="sort -t'|' -k4,4nr"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting file counts by size (descending)" >&2 ;;
        *)           sort_cmd="sort -t'|' -k1,1n"
                     [ "$DEBUG" = "1" ] && echo "[DEBUG] Sorting file counts by priority (default)" >&2 ;;
    esac
    
    # Sort and display
    eval "$sort_cmd $temp_file" | while IFS='|' read -r priority user count size_bytes; do
        # Find user's color
        local color="0"
        for user_data in "${USERS[@]}"; do
            if [[ "$user_data" == "${user}:"* ]]; then
                color="${user_data##*:}"
                break
            fi
        done
        
        color_text "$color" "$user"
        printf "   %5d files" "$count"
        
        # Add format indicator if not 'all'
        if [ "$format" != "all" ]; then
            printf " (.%s)" "$format"
        fi
        
        # Add disk usage
        printf "   [%s]" "$(format_bytes "$size_bytes")"
        echo
    done
    
    echo "==================================="
    printf "Total Count: %s files [%s]\n" "$total_files" "$(format_bytes "$total_size")"
    if [ "$format" != "all" ]; then
        printf "(Only %s files counted)\n" "$format"
    fi
    
    rm -f "$temp_file"
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
    local show_counts=0

    # Parse options
    while getopts "hu:f:s:lvdc" opt; do
        case $opt in
            h) show_help; exit 0 ;;
            l) list_users; exit 0 ;;
            c) show_counts=1 ;;
            u) username="$OPTARG" ;;
            f) case "$OPTARG" in
                   jpg|jpeg|png|all) format="$OPTARG" ;;
                   *) echo "Invalid format. Use: jpg, jpeg, png, or all" >&2; exit 1 ;;
               esac ;;
            s) case "$OPTARG" in
                   username|filename|year-asc|year-desc|priority|count-asc|count-desc|size-asc|size-desc) sort_by="$OPTARG" ;;
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

    # Handle file count display
    if [ "$show_counts" -eq 1 ]; then
        show_file_counts "$format" "$sort_by"
        exit 0
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
