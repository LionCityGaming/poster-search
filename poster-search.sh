#!/usr/bin/env bash

# Version information
readonly VERSION="0.1.1"  # Major.Minor.Patch

# Changelog:
# v0.1.1 - Added priority-based sorting (now default)
#        - Added PNG file support to search results
#        - Added file format filter option (-f)
#        - Made search term optional when using format filter
#        - Reformatted user list for better readability
#        - Changed default sort from year-desc to priority order
#        - Modified -l list to show users in priority order (previously alphabetical)

readonly SEARCH_PATH="/volume2/docker/dockge/stacks/daps/posters"  # Default search path

# User priority order and color codes
declare -a user_order=(
    "LionCityGaming"     # 1;31  - Light Red
    "IamSpartacus"       # 1;32  - Light Green
    "Drazzib"           # 1;34  - Light Blue
    "BZ"                # 1;33  - Light Yellow
    "dsaq"              # 1;35  - Light Magenta
    "solen"             # 1;36  - Light Cyan
    "Quafley"           # 0;32  - Dark Green
    "sahara"            # 0;34  - Dark Blue
    "MajorGiant"        # 0;35  - Dark Magenta
    "Stupifier"         # 0;33  - Dark Yellow
    "Overbook874"       # 0;36  - Dark Cyan
    "Mareau"            # 95    - Light Magenta
    "TokenMinal"        # 94    - Light Blue
    "Kalyanrajnish"     # 96    - Light Cyan
    "MiniMyself"        # 92    - Light Green
    "TheOtherGuy"       # 93    - Light Yellow
    "Reitenth"          # 1;36  - Light Cyan
    "WenIsInMood"       # 91    - Light Red
    "Jpalenz77"         # 0;31  - Dark Red
    "chrisdc"           # 1;35  - Light Magenta
    "zarox"             # 0;33  - Dark Yellow
)

# Map users to their color codes
declare -A colors=(
    ["LionCityGaming"]="1;31"
    ["IamSpartacus"]="1;32"
    ["Drazzib"]="1;34"
    ["BZ"]="1;33"
    ["dsaq"]="1;35"
    ["solen"]="1;36"
    ["Quafley"]="0;32"
    ["sahara"]="0;34"
    ["MajorGiant"]="0;35"
    ["Stupifier"]="0;33"
    ["Overbook874"]="0;36"
    ["Mareau"]="95"
    ["TokenMinal"]="94"
    ["Kalyanrajnish"]="96"
    ["MiniMyself"]="92"
    ["TheOtherGuy"]="93"
    ["Reitenth"]="1;36"
    ["WenIsInMood"]="91"
    ["Jpalenz77"]="0;31"
    ["chrisdc"]="1;35"
    ["zarox"]="0;33"
)

# Help text function
show_help() {
    cat << EOF
VERSION: $VERSION
CONFIGURATION:
    Default search path can be modified by changing SEARCH_PATH at the top of the script.
    Drive names should be modified according to your own naming scheme.
OPTIONS:
    -h              Show this help text
    -l              List all synced drives
    -u username     Filter results by username (case insensitive, partial match)
    -f format       Filter by file format (jpg, jpeg, png, or all)
    -s sort_option  Sort results by one of these options:
                    - username   : Sort alphabetically by username
                    - filename   : Sort alphabetically by filename
                    - year-asc   : Sort by year, oldest first
                    - year-desc  : Sort by year, newest first
                    - priority   : Sort by priority order defined in script (default)
EOF
}

# Function to list users with colors
list_users() {
    local max_length=0
    local count=1
    
    # Find longest username for padding
    for user in "${user_order[@]}"; do
        (( ${#user} > max_length )) && max_length=${#user}
    done
    
    echo "Synced Drives:"
    # Print usernames in script order with their colors
    for user in "${user_order[@]}"; do
        printf "%3d. \e[${colors[$user]}m%-${max_length}s\e[0m\n" "$count" "$user"
        ((count++))
    done
}

# Function to get user index from order array
get_user_index() {
    local user=$1
    for i in "${!user_order[@]}"; do
        if [[ "${user_order[$i]}" == "$user" ]]; then
            echo "$i"
            return
        fi
    done
    echo "999999"  # Return large number for users not in array
}

# Function to process and display search results
process_results() {
    local sort_by=$1
    local search_term=$2
    local temp_file=$3
    local count=1
    local max_length=0
    
    # Find longest username
    for user in "${user_order[@]}"; do
        (( ${#user} > max_length )) && max_length=${#user}
    done
    
    # Create temporary files for sorting
    local temp_years=$(mktemp)
    local temp_no_years=$(mktemp)
    
    # Split files based on year presence
    while IFS='|' read -r year owner filename fullpath; do
        if [ "$year" = "9999" ]; then
            if [ "$sort_by" = "priority" ]; then
                local idx=$(get_user_index "$owner")
                echo "$year|$idx|$owner|$filename|$fullpath" >> "$temp_no_years"
            else
                echo "$year|$owner|$filename|$fullpath" >> "$temp_no_years"
            fi
        else
            if [ "$sort_by" = "priority" ]; then
                local idx=$(get_user_index "$owner")
                echo "$year|$idx|$owner|$filename|$fullpath" >> "$temp_years"
            else
                echo "$year|$owner|$filename|$fullpath" >> "$temp_years"
            fi
        fi
    done < "$temp_file"
    
    # Determine sort command
    local sort_cmd
    case "$sort_by" in
        "username")   sort_cmd="sort -t'|' -k2,2 -k3,3" ;;
        "filename")   sort_cmd="sort -t'|' -k3,3" ;;
        "year-asc")   sort_cmd="sort -t'|' -k1,1n -k3,3" ;;
        "year-desc")  sort_cmd="sort -t'|' -k1,1nr -k3,3" ;;
        "priority")   sort_cmd="sort -t'|' -k2,2n -k1,1nr" ;;
    esac
    
    # Process and display results
    display_results "$temp_years" "$sort_cmd" "$search_term" "$max_length" "$sort_by"
    display_results "$temp_no_years" "$sort_cmd" "$search_term" "$max_length" "$sort_by"
    
    # Cleanup
    rm -f "$temp_years" "$temp_no_years"
}

# Function to display formatted results
display_results() {
    local input_file=$1
    local sort_cmd=$2
    local search_term=$3
    local max_length=$4
    local sort_by=$5
    
    while IFS='|' read -r year idx owner filename fullpath; do
        if [ "$sort_by" = "script" ]; then
            local color_code=${colors[$owner]:-"0"}
            local highlighted_filename=$(echo "$filename" | sed -E "s/($search_term)/\x1b[7;33m\1\x1b[0m/gi")
            printf "%3d. \e[${color_code}m%-${max_length}s\e[0m%1s%s\n" "$count" "$owner" "" "$highlighted_filename"
        else
            local color_code=${colors[$owner]:-"0"}
            local highlighted_filename=$(echo "$filename" | sed -E "s/($search_term)/\x1b[7;33m\1\x1b[0m/gi")
            printf "%3d. \e[${color_code}m%-${max_length}s\e[0m%1s%s\n" "$count" "$owner" "" "$highlighted_filename"
        fi
        ((count++))
    done < <(eval "$sort_cmd $input_file")
}

# Main script execution
main() {
    local username=""
    local list_users_flag=false
    local sort_by="priority"
    local search_path="$SEARCH_PATH"
    local format="all"
    
    # Parse command line arguments
    while getopts ":hu:ls:p:f:" opt; do
        case $opt in
            h) show_help; exit 0 ;;
            u) username="$OPTARG" ;;
            l) list_users_flag=true ;;
            f) case "$OPTARG" in
                   jpg|jpeg|png|all) format="$OPTARG" ;;
                   *) echo "Invalid format. Use: jpg, jpeg, png, or all" >&2; exit 1 ;;
               esac ;;
            s) case "$OPTARG" in
                   username|filename|year-asc|year-desc|priority) sort_by="$OPTARG" ;;
                   *) echo "Invalid sort option. Use: username, filename, year-asc, year-desc, or priority" >&2; exit 1 ;;
               esac ;;
            p) search_path="$OPTARG" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
            :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
        esac
    done
    
    # Handle list users flag
    if [ "$list_users_flag" = true ]; then
        list_users
        exit 0
    fi
    
    # Shift off the options and their parameters
    shift $((OPTIND-1))
    
    # Check for search terms or format filter
    if [ $# -eq 0 ] && [ "$format" = "all" ]; then
        echo "Usage: [-u username] [-l] [-s sort_option] [-f format] search terms..."
        echo "  -u username : Filter results by username (case insensitive, partial match)"
        echo "  -l         : List all available usernames"
        echo "  -f format  : Filter by file format: jpg, jpeg, png, or all (default: all)"
        echo "  -s option  : Sort results by: username, filename, year-asc, year-desc, or priority (default: priority)"
        exit 1
    fi
    
    # Process search
    local search_term="$*"
    local temp_file=$(mktemp)
    
    # Build and execute find command
    local find_cmd="find \"$search_path\" -type f "
    
    # Add extension filter
    case "$format" in
        "jpg")  find_cmd+=" -iname \"*.jpg\"" ;;
        "jpeg") find_cmd+=" -iname \"*.jpeg\"" ;;
        "png")  find_cmd+=" -iname \"*.png\"" ;;
        "all")  find_cmd+=" \( -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.png\" \)" ;;
    esac

    # Add search term if provided
    if [ $# -gt 0 ]; then
        local term_cmd
        case "$format" in
            "jpg")  term_cmd=" -iname \"*${search_term}*.jpg\"" ;;
            "jpeg") term_cmd=" -iname \"*${search_term}*.jpeg\"" ;;
            "png")  term_cmd=" -iname \"*${search_term}*.png\"" ;;
            "all")  term_cmd=" \( -iname \"*${search_term}*.jpg\" -o -iname \"*${search_term}*.jpeg\" -o -iname \"*${search_term}*.png\" \)" ;;
        esac
        find_cmd="$find_cmd -a $term_cmd"
    fi
    if [ -n "$username" ]; then
        local username_lower=$(echo "$username" | tr '[:upper:]' '[:lower:]')
        find_cmd="$find_cmd | while IFS= read -r line; do
            dir_name=\$(echo \"\$line\" | awk -F'/' '{print \$8}')
            if echo \"\$dir_name\" | tr '[:upper:]' '[:lower:]' | grep -q \"$username_lower\"; then
                echo \"\$line\"
            fi
        done"
    fi
    
    # Process files and extract information
    while IFS= read -r file; do
        local owner=$(echo "$file" | awk -F'/' '{print $8}')
        local filename=$(echo "$file" | awk -F'/' '{print $9}')
        local year="9999"
        
        if [[ $file =~ \(([0-9]{4})\) ]]; then
            year="${BASH_REMATCH[1]}"
        fi
        
        echo "$year|$owner|$filename|$file" >> "$temp_file"
    done < <(eval "$find_cmd")
    
    # Process and display results
    process_results "$sort_by" "$search_term" "$temp_file"
    
    # Cleanup
    rm -f "$temp_file"
}

# Execute main function
main "$@"