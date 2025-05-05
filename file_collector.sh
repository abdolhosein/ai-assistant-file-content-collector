#!/bin/bash

# ==============================================
# CONFIGURATION
# ==============================================
DEFAULT_OUTPUT_FILE="combined_contents.txt"
DEFAULT_TARGET_DIR="."
ITEMS_PER_PAGE=10  # Items per selection page

# Colors for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# ==============================================
# FUNCTIONS
# ==============================================

# Show script usage
usage() {
    echo -e "${YELLOW}Usage: $0 [-d directory] [-o output_file] [-h]${NC}"
    echo -e "  -d  Target directory (default: current directory)"
    echo -e "  -o  Output file name (default: $DEFAULT_OUTPUT_FILE)"
    echo -e "  -h  Show this help message"
    exit 1
}

# Cross-platform realpath replacement
get_abs_path() {
    local path="$1"
    if command -v realpath >/dev/null; then
        realpath "$path"
    elif command -v python >/dev/null; then
        python -c "import os; print(os.path.abspath('$path'))"
    else
        echo "$path"  # Fallback
    fi
}

# Fixed paginated selection menu
# Bash 3.2 compatible paginated menu (no -n)
# Enhanced paginated menu with keyboard navigation
paginated_menu() {
    local prompt="$1"
    local items_name=$2[@]
    local selected_name=$3
    
    local -a items=("${!items_name}")
    local -a selected=("${!selected_name}")
    local -a selected_indexes=()
    
    # Initialize selected indexes
    for ((i=0; i<${#items[@]}; i++)); do
        if [[ " ${selected[@]} " =~ " ${items[i]} " ]]; then
            selected_indexes+=($i)
        fi
    done
    
    local page=0
    local total_items=${#items[@]}
    local total_pages=$(( (total_items + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE ))
    local cursor_pos=0  # Cursor position within current page
    
    while true; do
        clear
        echo -e "${BLUE}$prompt${NC}"
        echo -e "Page $((page + 1))/$total_pages (${#selected_indexes[@]} selected)"
        echo "------------------------------------------------------------"
        
        local start=$((page * ITEMS_PER_PAGE))
        local end=$((start + ITEMS_PER_PAGE - 1))
        
        # Display items for current page
        for ((i=start; i<=end && i<total_items; i++)); do
            local item="${items[i]}"
            local display_num=$((i+1))
            
            # Highlight cursor position
            if (( i == start + cursor_pos )); then
                if [[ " ${selected_indexes[@]} " =~ " $i " ]]; then
                    echo -e "${GREEN}➤ [✓] $display_num. ${item}${NC}"
                else
                    echo -e "${BLUE}➤ [ ] $display_num. ${item}${NC}"
                fi
            else
                if [[ " ${selected_indexes[@]} " =~ " $i " ]]; then
                    echo -e "${GREEN}  [✓] $display_num. ${item}${NC}"
                else
                    echo "  [ ] $display_num. ${item}"
                fi
            fi
        done
        
        echo "------------------------------------------------------------"
        echo -e "Arrows(${GREEN}↑↓${NC}|${GREEN}←→${NC}): Navigate | ${GREEN}Space${NC}: Toggle    |  ${GREEN}Enter${NC}: Confirm"
        echo -e "${GREEN}a${NC}: Select All           | ${GREEN}u${NC}: Unselect All  |  ${GREEN}q${NC}: Quit"
        echo "------------------------------------------------------------"
        
        # Read single character input
        IFS= read -rsn1 key
        
        # Handle arrow keys (multi-character sequences)
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 1 key2
            key+="$key2"
        fi
        
        case "$key" in
            # Up arrow
            $'\x1b[A') 
                ((cursor_pos > 0)) && ((cursor_pos--))
                ;;
            # Down arrow
            $'\x1b[B')
                ((cursor_pos < ITEMS_PER_PAGE - 1 && start + cursor_pos < total_items - 1)) && ((cursor_pos++))
                ;;
            # Left arrow (previous page)
            $'\x1b[D')
                if ((page > 0)); then
                    ((page--))
                    cursor_pos=0
                fi
                ;;
            # Right arrow (next page)
            $'\x1b[C')
                if ((page < total_pages - 1)); then
                    ((page++))
                    cursor_pos=0
                fi
                ;;
            # Space (toggle selection)
            ' ')
                local current_index=$((start + cursor_pos))
                if [[ " ${selected_indexes[@]} " =~ " $current_index " ]]; then
                    selected_indexes=("${selected_indexes[@]/$current_index/}")
                else
                    selected_indexes+=($current_index)
                fi
                # Remove empty elements
                selected_indexes=($(echo "${selected_indexes[@]}" | tr ' ' '\n' | grep '[^[:space:]]' | tr '\n' ' '))
                ;;
            # Enter (confirm selection)
            '')
                break
                ;;
            # Select all visible
            'a')
                for ((i=start; i<=end && i<total_items; i++)); do
                    if [[ ! " ${selected_indexes[@]} " =~ " $i " ]]; then
                        selected_indexes+=($i)
                    fi
                done
                ;;
            # Unselect all visible
            'u')
                for ((i=start; i<=end && i<total_items; i++)); do
                    selected_indexes=("${selected_indexes[@]/$i/}")
                done
                selected_indexes=($(echo "${selected_indexes[@]}" | tr ' ' '\n' | grep '[^[:space:]]' | tr '\n' ' '))
                ;;
            # Quit
            'q')
                selected_indexes=()
                break
                ;;
        esac
    done
    
    # Convert indexes back to selected items
    selected=()
    for idx in "${selected_indexes[@]}"; do
        selected+=("${items[idx]}")
    done
    
    # Return selected items through global variable
    eval "$selected_name=(\"\${selected[@]}\")"
}

# paginated_menu() {
#     local prompt="$1"
#     local items_name=$2[@]
#     local selected_name=$3
    
#     local -a items=("${!items_name}")
#     local -a selected=("${!selected_name}")
    
#     local page=0
#     local total_items=${#items[@]}
#     local total_pages=$(( (total_items + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE ))
    
#     while true; do
#         clear
#         echo -e "${BLUE}$prompt${NC}"
#         echo -e "Page $((page + 1))/$total_pages (${#selected[@]} selected)"
#         echo "------------------------------------------------------------"
        
#         local start=$((page * ITEMS_PER_PAGE))
#         local end=$((start + ITEMS_PER_PAGE - 1))
        
#         # Display items for current page
#         for ((i=start; i<=end && i<total_items; i++)); do
#             local item="${items[i]}"
#             if [[ " ${selected[@]} " =~ " ${item} " ]]; then
#                 echo -e "${GREEN}[✓] $((i+1)). ${item}${NC}"
#             else
#                 echo "[ ] $((i+1)). ${item}"
#             fi
#         done
        
#         echo "------------------------------------------------------------"
#         echo "n: Next page, p: Previous page"
#         echo "a: Select all visible, u: Unselect all visible"
#         echo "t: Toggle all items, c: Confirm selection"
#         echo "Enter item numbers to toggle (comma separated)"
#         echo "------------------------------------------------------------"
        
#         read -p "Your choice: " choice
        
#         case "$choice" in
#             n) ((page < total_pages-1)) && ((page++)) ;;
#             p) ((page > 0)) && ((page--)) ;;
#             a)  # Select all on current page
#                 for ((i=start; i<=end && i<total_items; i++)); do
#                     local item="${items[i]}"
#                     if [[ ! " ${selected[@]} " =~ " ${item} " ]]; then
#                         selected+=("$item")
#                     fi
#                 done
#                 ;;
#             u)  # Unselect all on current page
#                 for ((i=start; i<=end && i<total_items; i++)); do
#                     local item="${items[i]}"
#                     selected=("${selected[@]/$item/}")
#                 done
#                 # Remove empty elements
#                 selected=($(echo "${selected[@]}" | tr ' ' '\n' | grep '[^[:space:]]' | tr '\n' ' '))
#                 ;;
#             t)  # Toggle all items
#                 if (( ${#selected[@]} == total_items )); then
#                     selected=()
#                 else
#                     selected=("${items[@]}")
#                 fi
#                 ;;
#             c) break ;;
#             *)  # Toggle specific items
#                 IFS=',' read -ra nums <<< "$choice"
#                 for num in "${nums[@]}"; do
#                     num=$(echo "$num" | tr -d '[:space:]')
#                     if [[ "$num" =~ ^[0-9]+$ ]] && ((num >= 1 && num <= total_items)); then
#                         local idx=$((num-1))
#                         local item="${items[idx]}"
#                         if [[ " ${selected[@]} " =~ " ${item} " ]]; then
#                             selected=("${selected[@]/$item/}")
#                         else
#                             selected+=("$item")
#                         fi
#                     fi
#                 done
#                 # Remove empty elements
#                 selected=($(echo "${selected[@]}" | tr ' ' '\n' | grep '[^[:space:]]' | tr '\n' ' '))
#                 ;;
#         esac
#     done
    
#     # Return selected items through global variable
#     eval "$selected_name=(\"\${selected[@]}\")"
# }

# ==============================================
# MAIN SCRIPT
# ==============================================

# Parse command-line arguments
while getopts ":d:o:h" opt; do
    case "$opt" in
        d) TARGET_DIR="$OPTARG" ;;
        o) OUTPUT_FILE="$OPTARG" ;;
        h) usage ;;
        \?) echo -e "${RED}Invalid option -$OPTARG${NC}" >&2; usage ;;
    esac
done

# Prompt for target directory if not provided
if [ -z "$TARGET_DIR" ]; then
    read -p "Enter target directory [default: $DEFAULT_TARGET_DIR]: " TARGET_DIR
    TARGET_DIR="${TARGET_DIR:-$DEFAULT_TARGET_DIR}"
fi

# Validate target directory
TARGET_DIR=$(get_abs_path "$TARGET_DIR")
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Directory '$TARGET_DIR' does not exist.${NC}"
    exit 1
fi

# Prompt for output file if not provided
if [ -z "$OUTPUT_FILE" ]; then
    read -p "Enter output file name [default: $DEFAULT_OUTPUT_FILE]: " OUTPUT_FILE
    OUTPUT_FILE="${OUTPUT_FILE:-$DEFAULT_OUTPUT_FILE}"
fi

# ==============================================
# DIRECTORY SELECTION
# ==============================================
echo -e "${YELLOW}Scanning subdirectories in $TARGET_DIR...${NC}"
subdirs=()

# Use temporary file for cross-platform compatibility
TMPFILE=$(mktemp)
find "$TARGET_DIR" -type d -print0 2>/dev/null > "$TMPFILE"

while IFS= read -r -d $'\0' dir; do
    dir_abs=$(cd "$dir" && pwd 2>/dev/null)
    [ -z "$dir_abs" ] && continue  # Skip if cd fails
    
    rel_dir="${dir_abs#$TARGET_DIR/}"
    [ "$rel_dir" = "$dir_abs" ] && rel_dir="."  # Handle root dir
    
    subdirs+=("$rel_dir")
done < "$TMPFILE"
rm -f "$TMPFILE"

# Ensure root directory is included
if [[ ! " ${subdirs[@]} " =~ " . " ]]; then
    subdirs=("." "${subdirs[@]}")
fi

# Remove duplicates and sort
subdirs=($(printf "%s\n" "${subdirs[@]}" | sort -u))

# Debug output - show what directories were found
echo -e "${BLUE}Found ${#subdirs[@]} directories:${NC}"
printf ' - %s\n' "${subdirs[@]}"
echo ""

# Let user select directories
selected_subdirs=()
if [ "${#subdirs[@]}" -eq 1 ] && [ "${subdirs[0]}" = "." ]; then
    selected_subdirs=(".")
else
    paginated_menu "Select directories to scan:" subdirs selected_subdirs
fi

[ "${#selected_subdirs[@]}" -eq 0 ] && exit 0

# ==============================================
# FILE TYPE SCANNING (Bash 3.2 Compatible)
# ==============================================
echo -e "${YELLOW}Scanning for file types...${NC}"

# Bash 3.2 alternative to associative arrays
file_types_str=""

for subdir in "${selected_subdirs[@]}"; do
    full_path="$TARGET_DIR/$subdir"
    while IFS= read -r -d $'\0' file; do
        filename=$(basename -- "$file")
        extension="${filename##*.}"
        [ "$filename" = "$extension" ] && extension="(NoExtension)"
        # Append to string if not already present
        if [[ ! "$file_types_str" =~ "|$extension|" ]]; then
            file_types_str+="|$extension|"
        fi
    done < <(find "$full_path" -maxdepth 1 -type f -print0 2>/dev/null)
done

# Convert string to array
file_types=()
for ext in $(echo "$file_types_str" | tr '|' '\n' | sort -u); do
    [ -n "$ext" ] && file_types+=("$ext")
done

if [ "${#file_types[@]}" -eq 0 ]; then
    echo -e "${RED}No files found in selected directories.${NC}"
    exit 0
fi

# Let user select file types
selected_types=()
paginated_menu "Select file types to include:" file_types selected_types
[ "${#selected_types[@]}" -eq 0 ] && exit 0

# ==============================================
# PROCESSING FILES
# ==============================================
echo -e "${YELLOW}Processing files...${NC}"
> "$OUTPUT_FILE"  # Clear output file
processed_files=0

for subdir in "${selected_subdirs[@]}"; do
    full_path="$TARGET_DIR/$subdir"

    for ext in "${selected_types[@]}"; do
        if [ "$ext" = "(NoExtension)" ]; then
            find_args=(-not -name "*.*")
        else
            find_args=(-name "*.$ext")
        fi

        while IFS= read -r -d $'\0' file; do
            rel_path="${file#$TARGET_DIR/}"
            echo -e "${GREEN}Adding: $rel_path${NC}"
            echo "===== $rel_path =====" >> "$OUTPUT_FILE"
            cat "$file" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"  # Add spacing
            echo "" >> "$OUTPUT_FILE"  # Add line spacing
            ((processed_files++))
        done < <(find "$full_path" -maxdepth 1 -type f "${find_args[@]}" -print0 2>/dev/null)
    done

done

echo -e "${GREEN}Done! Processed $processed_files files.${NC}"
echo -e "Output saved to: ${YELLOW}$OUTPUT_FILE${NC}"