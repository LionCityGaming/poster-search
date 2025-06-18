#!/usr/bin/env bash

# Version information
readonly VERSION="0.7.2"  # Major.Minor.Patch

# Changelog:
# v0.7.2 - Reintroduced color support for usernames from USERS_CONFIG
# v0.7.1 - Fixed macOS compatibility, removed menu colors, moved user config to env
# v0.7.0 - Enhanced interactive menu system with consistent navigation
# v0.6.0 - Added external poster-search.env configuration file support
# v0.5.0 - Added interactive mode (-i flag) with menu-driven interface
# v0.4.0 - Added disk usage information to file count display (-c flag)
# v0.3.1 - Fixed total file count calculation and added sorting options
# v0.3.0 - Added file count function (-c flag) to show files per user
# v0.2.1 - Added tput detection and color fallback
# v0.2.0 - Complete rebuild with simplified codebase

# ============================================================================
# User Configuration
# ============================================================================

# Load configuration from poster-search.env file
load_config() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local env_file="$script_dir/poster-search.env"
    
    if [ -f "$env_file" ]; then
        [ "$DEBUG" = "1" ] && echo "[DEBUG] Loading configuration from: $env_file" >&2
        
        # Source the poster-search.env file safely
        while IFS= read -r line; do
            # Skip empty lines and comments
            [[ "$line" =~ ^[[:space:]]*$ ]] && continue
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            
            # Process valid configuration lines
            if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=[[:space:]]*(.*) ]]; then
                local var_name="${BASH_REMATCH[1]}"
                local var_value="${BASH_REMATCH[2]}"
                
                # Remove surrounding quotes if present
                var_value=$(echo "$var_value" | sed -E 's/^["'\'']//;s/["'\'']$//')
                
                [ "$DEBUG" = "1" ] && echo "[DEBUG] Setting $var_name=$var_value" >&2
                
                case "$var_name" in
                    "POSTER_PATHS")
                        # Parse comma-separated paths
                        IFS=',' read -ra SEARCH_PATHS <<< "$var_value"
                        # Trim whitespace from each path
                        for i in "${!SEARCH_PATHS[@]}"; do
                            SEARCH_PATHS[$i]=$(echo "${SEARCH_PATHS[$i]}" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')
                        done
                        ;;
                    "USERS_CONFIG")
                        # Parse comma-separated user:color pairs
                        IFS=',' read -ra USERS <<< "$var_value"
                        # Trim whitespace from each user entry
                        for i in "${!USERS[@]}"; do
                            USERS[$i]=$(echo "${USERS[$i]}" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')
                        done
                        ;;
                esac
            fi
        done < "$env_file"
        
        [ "$DEBUG" = "1" ] && {
            echo "[DEBUG] Loaded ${#SEARCH_PATHS[@]} search paths:" >&2
            for path in "${SEARCH_PATHS[@]}"; do
                echo "[DEBUG]   - $path" >&2
            done
            echo "[DEBUG] Loaded ${#USERS[@]} users" >&2
        }
    else
        [ "$DEBUG" = "1" ] && echo "[DEBUG] No poster-search.env file found at: $env_file" >&2
        echo "Error: poster-search.env file not found at: $env_file" >&2
        echo "Please create it based on poster-search.env.example" >&2
        create_example_env "$script_dir"
        exit 1
    fi
}

# Create an example poster-search.env file
create_example_env() {
    local script_dir="$1"
    local example_file="$script_dir/poster-search.env.example"
    
    if [ ! -f "$example_file" ]; then
        [ "$DEBUG" = "1" ] && echo "[DEBUG] Creating example poster-search.env file at: $example_file" >&2
        
        cat > "$example_file" << 'EOF'
# Poster Search Configuration
# Copy this file to poster-search.env and modify as needed

# Poster directory paths (comma-separated)
POSTER_PATHS="/etc/komodo/stacks/daps-ui/daps-ui/posters,/path/to/additional/posters"

# User configuration (comma-separated user:color pairs)
# Format: username:color_code
# Color codes are ANSI color codes (e.g., 1;31 for light red, 0;32 for dark green)
USERS_CONFIG="LionCityGaming:1;31,IamSpartacus:1;32,Drazzilb:1;34,Darkkazul:1;35,dsaq:1;33,solen:1;36,BZ:0;31,chrisdc:0;32,Quafley:0;33,sahara:0;34,MajorGiant:0;35,Stupifier:0;36,Overbook874:91,Mareau:92,Jpalenz77:93,TokenMinal:94,MiniMyself:95,zarox:96,dweagle79:1;91,reitenth:1;92,wesisinmood:1;93,Kalyanrajnish:1;94"

# Examples of ANSI color codes:
# 0;30 = Dark Black    1;30 = Light Black (Gray)
# 0;31 = Dark Red      1;31 = Light Red
# 0;32 = Dark Green    1;32 = Light Green
# 0;33 = Dark Yellow   1;33 = Light Yellow
# 0;34 = Dark Blue     1;34 = Light Blue
# 0;35 = Dark Magenta  1;35 = Light Magenta
# 0;36 = Dark Cyan     1;36 = Light Cyan
# 0;37 = Dark White    1;37 = Light White
# 91-97 = Bright colors (91=bright red, 92=bright green, etc.)
EOF
        echo "Example configuration created at: $example_file"
        echo "Copy it to poster-search.env and modify as needed:"
        echo "  cp $example_file ${script_dir}/poster-search.env"
    fi
}

# Load external configuration
load_config

# Check if terminal supports colors
if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
    HAS_COLORS=1
    [ "$DEBUG" = "1" ] && echo "[DEBUG] Color output enabled" >&2
else
    HAS_COLORS=0
    [ "$DEBUG" = "1" ] && echo "[DEBUG] Color output disabled" >&2
fi

# Display ASCII title
show_ascii_title() {
    if [ "$HAS_COLORS" -eq 1 ]; then
        printf "\e[1;36m"
        echo "=============================================================================="
        echo "                         POSTER  SEARCH  TOOL                               "
        echo "=============================================================================="
        printf "\e[0m\e[1;35m                              v0.7.2\e[0m\n"
        printf "\e[1;34m==============================================================================\e[0m\n"
    else
        echo ""
        echo "=============================================================================="
        echo "                         POSTER  SEARCH  TOOL                               "
        echo "=============================================================================="
        echo "                              v0.7.2"
        echo "=============================================================================="
        echo ""
    fi
}

# Color handling functions
color_text() {
    local color="$1"
    local text="$2"
    if [ "$HAS_COLORS" -eq 1 ]; then
        printf "\e[%sm%-15s\e[0m" "$color" "$text"
    else
        printf "%-15s" "$text"
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

Usage: $0 [-u username] [-s sort] [-f format] [-l] [-c] [-i] [-h] [search term]

Options:
    -h          Show this help text
    -l          List all synced drives
    -c          Show file count and disk usage per user
    -i          Interactive mode (menu-driven interface)
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
    $0 -c                       # Show file count and disk usage per drive
    $0 -c -f jpg                # Show JPG file count and disk usage per drive
    $0 -c -s count-desc         # Show file count per drive, highest count first
    $0 -c -s size-desc          # Show file count per drive, largest size first
    $0 -i                       # Start interactive mode
EOF
}

# List users with their colors
list_users() {
    local count=1
    echo "Drives (in priority order):"
    for user_data in "${USERS[@]}"; do
        local user="${user_data%%:*}"
        local color="${user_data##*:}"
        printf "%3d. " "$count"
        color_text "$color" "$user"
        echo
        ((count++))
    done
}

# Format bytes into human-readable format
format_bytes() {
    local bytes="$1"
    
    # Handle scientific notation and ensure valid number
    if [[ "$bytes" == *"e+"* ]] || [[ "$bytes" == *"E+"* ]]; then
        bytes=$(awk "BEGIN {printf \"%.0f\", $bytes}")
    fi
    
    # Ensure bytes is a valid integer
    if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
        printf "0 B"
        return
    fi
    
    # Use awk for calculations to handle large numbers
    awk -v bytes="$bytes" 'BEGIN {
        if (bytes < 1024) {
            printf "%.0f B", bytes
        } else if (bytes < 1048576) {
            printf "%.1f KB", bytes/1024
        } else if (bytes < 1073741824) {
            printf "%.1f MB", bytes/1073741824
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

    echo "File count and disk usage per drive:"
    echo "==================================="
    
    # Collect all user directories and their file counts + disk usage
    for path in "${SEARCH_PATHS[@]}"; do
        [ ! -d "$path" ] && {
            [ "$DEBUG" = "1" ] && echo "[DEBUG] Skipping non-existent path: $path" >&2
            continue
        }

        [ "$DEBUG" = "1" ] && echo "[DEBUG] Counting files in path: $path" >&2

        # Find all subdirectories (user folders)
        while IFS= read -r -d '' user_dir; do
            local user=$(basename "$user_dir")
            
            [ "$DEBUG" = "1" ] && echo "[DEBUG] Processing user directory: $user_dir" >&2
            
            # Use find with -exec to get both count and size
            local find_cmd="find \"$user_dir\" -type f"
            
            case "$format" in
                "jpg")  find_cmd+=" -iname \"*.jpg\"" ;;
                "jpeg") find_cmd+=" -iname \"*.jpeg\"" ;;
                "png")  find_cmd+=" -iname \"*.png\"" ;;
                "all")  find_cmd+=" \( -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.png\" \)" ;;
            esac
            
            # Add -exec to get size in bytes
            find_cmd+=" -exec stat -f \"%z\" {} \;"
            
            [ "$DEBUG" = "1" ] && echo "[DEBUG] Find command: $find_cmd" >&2
            
            # Execute find and process results
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
            
        done < <(find "$path" -maxdepth 1 -type d -print0 2>/dev/null)
    done

    # Calculate totals
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
        "size-desc") sort_cmd="sort -t'|' -k4,4nr"
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
    printf "%-15s   %5s files   [%s]\n" "Total Count:" "$total_files" "$(format_bytes "$total_size")"
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
        local find_cmd="find \"$path\" -type f"

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

        printf "%3d. " "$count"
        color_text "$color" "$owner"
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

# Interactive mode function
interactive_mode() {
    local username=""
    local format="all"
    local sort_by="priority"
    local verbose=0
    
    clear
    show_ascii_title
    echo "Interactive Mode"
    echo "================"
    echo
    
    while true; do
        echo "Main Menu:"
        echo "  1) Search for posters"
        echo "  2) Show collection statistics"
        echo "  3) List all synced drives"
        echo "  4) Advanced search options"
        echo "  5) Exit"
        echo
        printf "Choose an option (1-5): "
        read choice
        echo
        
        case $choice in
            1)
                printf "Enter search term (or press Enter to cancel): "
                read search_term
                echo
                if [ -z "$search_term" ]; then
                    echo "Search cancelled, returning to main menu..."
                    echo
                    printf "Press Enter to continue..."
                    read
                    clear
                    show_ascii_title
                    echo "Interactive Mode"
                    echo "================"
                    echo
                    continue
                fi
                echo "Searching..."
                search_files "$search_term" "$username" "$format" "$sort_by" "$verbose"
                echo
                if [ "$stats_choice" != "4" ]; then
                    printf "Press Enter to continue..."
                    read
                    clear
                    show_ascii_title
                    echo "Interactive Mode"
                    echo "================"
                    echo
                fi
                ;;
            2)
                echo "Collection Statistics Options:"
                echo "  1) Back to main menu"
                echo "  2) Show all files"
                echo "  3) Show by format"
                echo "  4) Choose sorting"
                echo
                printf "Choose option (1-4): "
                read stats_choice
                echo
                
                case $stats_choice in
                    1)
                        clear
                        show_ascii_title
                        echo "Interactive Mode"
                        echo "================"
                        echo
                        continue
                        ;;
                    2)
                        show_file_counts "all" "priority"
                        ;;
                    3)
                        echo "Choose format:"
                        echo "  1) Back to main menu"
                        echo "  2) JPG files only"
                        echo "  3) JPEG files only"
                        echo "  4) PNG files only"
                        echo "  5) All formats"
                        printf "Choose format (1-5): "
                        read format_choice
                        case $format_choice in
                            1) 
                                clear
                                show_ascii_title
                                echo "Interactive Mode"
                                echo "================"
                                echo
                                continue 2
                                ;;
                            2) show_file_counts "jpg" "priority" ;;
                            3) show_file_counts "jpeg" "priority" ;;
                            4) show_file_counts "png" "priority" ;;
                            5) show_file_counts "all" "priority" ;;
                            *) show_file_counts "all" "priority" ;;
                        esac
                        ;;
                    4)
                        echo "Sort by:"
                        echo "  1) Back to main menu"
                        echo "  2) User priority (default)"
                        echo "  3) Username alphabetically"
                        echo "  4) File count (highest first)"
                        echo "  5) File count (lowest first)"
                        echo "  6) Disk usage (largest first)"
                        echo "  7) Disk usage (smallest first)"
                        printf "Choose sort option (1-7): "
                        read sort_choice
                        local stats_sort="priority"
                        case $sort_choice in
                            1) 
                                clear
                                show_ascii_title
                                echo "Interactive Mode"
                                echo "================"
                                echo
                                continue 2
                                ;;
                            2) stats_sort="priority" ;;
                            3) stats_sort="username" ;;
                            4) stats_sort="count-desc" ;;
                            5) stats_sort="count-asc" ;;
                            6) stats_sort="size-desc" ;;
                            7) stats_sort="size-asc" ;;
                        esac
                        if [ "$sort_choice" != "1" ]; then
                            show_file_counts "$format" "$stats_sort"
                        fi
                        ;;
                esac
                echo
                if [ "$stats_choice" != "1" ] && [ "$format_choice" != "1" ] && [ "$sort_choice" != "1" ]; then
                    printf "Press Enter to continue..."
                    read
                    clear
                    show_ascii_title
                    echo "Interactive Mode"
                    echo "================"
                    echo
                fi
                ;;
            3)
                list_users
                echo
                printf "Press Enter to continue..."
                read
                clear
                show_ascii_title
                echo "Interactive Mode"
                echo "================"
                echo
                ;;
            4)
                echo "Advanced Search Options:"
                echo
                echo "Current settings:"
                echo "  Format filter: $format"
                echo "  Drive filter: ${username:-none}"
                echo "  Sort by: $sort_by"
                echo "  Verbose mode: $([ $verbose -eq 1 ] && echo "enabled" || echo "disabled")"
                echo
                echo "Change settings:"
                echo "  1) Back to main menu"
                echo "  2) Set format filter"
                echo "  3) Set drive filter"
                echo "  4) Set sort order"
                echo "  5) Toggle verbose mode"
                echo "  6) Reset to defaults"
                echo
                printf "Choose option (1-6): "
                read adv_choice
                echo
                
                case $adv_choice in
                    1)
                        clear
                        show_ascii_title
                        echo "Interactive Mode"
                        echo "================"
                        echo
                        continue
                        ;;
                    2)
                        echo "Choose format:"
                        echo "  1) Back to main menu"
                        echo "  2) All formats"
                        echo "  3) JPG only"
                        echo "  4) JPEG only"
                        echo "  5) PNG only"
                        printf "Choose format (1-5): "
                        read fmt_choice
                        case $fmt_choice in
                            1) 
                                clear
                                show_ascii_title
                                echo "Interactive Mode"
                                echo "================"
                                echo
                                continue 2
                                ;;
                            2) format="all" ;;
                            3) format="jpg" ;;
                            4) format="jpeg" ;;
                            5) format="png" ;;
                            *) format="all" ;;
                        esac
                        if [ "$fmt_choice" != "1" ]; then
                            echo "Format set to: $format"
                        fi
                        ;;
                    3)
                        echo "Available drives:"
                        local count=1
                        for user_data in "${USERS[@]}"; do
                            local user="${user_data%%:*}"
                            printf "  %3d. %s\n" "$count" "$user"
                            ((count++))
                        done
                        echo
                        printf "Enter drive name (or press Enter to clear filter): "
                        read username
                        echo "Drive filter set to: ${username:-none}"
                        ;;
                    4)
                        echo "Sort options:"
                        echo "  1) Back to main menu"
                        echo "  2) User priority (default)"
                        echo "  3) Username alphabetically"
                        echo "  4) Filename alphabetically"
                        echo "  5) Year (newest first)"
                        echo "  6) Year (oldest first)"
                        printf "Choose sort option (1-6): "
                        read sort_choice
                        case $sort_choice in
                            1) 
                                clear
                                show_ascii_title
                                echo "Interactive Mode"
                                echo "================"
                                echo
                                continue 2
                                ;;
                            2) sort_by="priority" ;;
                            3) sort_by="username" ;;
                            4) sort_by="filename" ;;
                            5) sort_by="year-desc" ;;
                            6) sort_by="year-asc" ;;
                            *) sort_by="priority" ;;
                        esac
                        if [ "$sort_choice" != "1" ]; then
                            echo "Sort order set to: $sort_by"
                        fi
                        ;;
                    5)
                        verbose=$((1 - verbose))
                        echo "Verbose mode: $([ $verbose -eq 1 ] && echo "enabled" || echo "disabled")"
                        ;;
                    6)
                        username=""
                        format="all"
                        sort_by="priority"
                        verbose=0
                        echo "Settings reset to defaults"
                        ;;
                esac
                if [ "$adv_choice" != "1" ] && [ "$fmt_choice" != "1" ] && [ "$sort_choice" != "1" ]; then
                    echo
                    printf "Press Enter to continue..."
                    read
                    clear
                    show_ascii_title
                    echo "Interactive Mode"
                    echo "================"
                    echo
                fi
                ;;
            5)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option. Please choose 1-5."
                echo
                printf "Press Enter to continue..."
                read
                clear
                show_ascii_title
                echo "Interactive Mode"
                echo "================"
                echo
                ;;
        esac
    done
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
    local interactive=0

    # Parse options
    while getopts "hu:f:s:lvdci" opt; do
        case $opt in
            h) show_help; exit 0 ;;
            l) list_users; exit 0 ;;
            c) show_counts=1 ;;
            i) interactive=1 ;;
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

    # Handle interactive mode
    if [ "$interactive" -eq 1 ]; then
        interactive_mode
        exit 0
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
