Search recursively and case *insensitive* through a specified dir for matches to given multiple search terms in multiple file formats .doc, .docx, and .pdf. 


It summarizes the findings by displaying the file paths, match numbers, and page numbers in a color-coded format for easier readability.



Requires:
antiword: A tool to read .doc files.

`pkg install antiword`

pandoc: A universal document converter, used to read .docx files.

`pkg install pandoc`

pdfgrep: A tool for searching text in PDF files.

`pkg install pdfgrep`

Usage:

bash search_summary.sh "search_term1" "search_term2" /path/to/directory/

Reminder:

You need to run termux-setup-storage to grant shared storage access permission to read from /storage/emulated/0/ (or /sdcard/).

```
#!/bin/bash

# Color codes
RED='\033[0;31m'        # Red for errors
GREEN='\033[0;32m'      # Green for success messages
YELLOW='\033[0;33m'     # Yellow for match numbers
CYAN='\033[0;36m'       # Cyan for file names
NC='\033[0m'            # No Color

# Check for the correct number of arguments
if [ "$#" -lt 2 ]; then
    echo -e "${RED}Usage: $0 <search_term1> <search_term2> ... <search_termN> <directory>${NC}"
    exit 1
fi

# Assign the last argument as the directory and the rest as search terms
directory="${@: -1}"
search_terms=("${@:1:$#-1}")

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo -e "${RED}Directory not found: $directory${NC}"
    exit 1
fi

# Loop through each search term
for search_term in "${search_terms[@]}"; do
    echo -e "${GREEN}Searching for: $search_term${NC}"
    match_count=0  # Initialize match count for each search term

    # Search in .doc files
    find "$directory" -type f -name "*.doc" | while read -r doc; do
        matches=$(antiword "$doc" 2>/dev/null | grep -ni "$search_term")
        if [ ! -z "$matches" ]; then
            echo -e "${CYAN}Found in: $doc${NC}"
            while read -r line; do
                match_count=$((match_count + 1))
                page_num=$(echo "$line" | cut -d: -f1)  # Extract page number from match output
                match_text=$(echo "$line" | cut -d: -f2-)
                echo -e "  ${YELLOW}Match #$match_count (Page $page_num): ${NC}$match_text"
            done <<< "$matches"
        fi
    done

    # Search in .docx files
    find "$directory" -type f -name "*.docx" | while read -r docx; do
        matches=$(pandoc -t plain "$docx" 2>/dev/null | grep -ni "$search_term")
        if [ ! -z "$matches" ]; then
            echo -e "${CYAN}Found in: $docx${NC}"
            while read -r line; do
                match_count=$((match_count + 1))
                page_num=$(echo "$line" | cut -d: -f1)  # Extract page number from match output
                match_text=$(echo "$line" | cut -d: -f2-)
                echo -e "  ${YELLOW}Match #$match_count (Page $page_num): ${NC}$match_text"
            done <<< "$matches"
        fi
    done

    # Search in PDF files
    find "$directory" -type f -name "*.pdf" | while read -r pdf; do
        matches=$(pdfgrep -ni "$search_term" "$pdf" 2>/dev/null)
        if [ ! -z "$matches" ]; then
            echo -e "${CYAN}Found in: $pdf${NC}"
            while read -r line; do
                match_count=$((match_count + 1))
                page_num=$(echo "$line" | cut -d: -f1)  # Extract page number from match output
                match_text=$(echo "$line" | cut -d: -f2-)
                echo -e "  ${YELLOW}Match #$match_count (Page $page_num): ${NC}$match_text"
            done <<< "$matches"
        fi
    done
done
```
