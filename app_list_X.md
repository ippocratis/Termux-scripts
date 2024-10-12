Extended app list script.

- Retrieves a list of installed APKs and their details (name, package, links) using pm and aapt.
- Checks F-Droid and Play Store links for each app.
- Categorizes apps based on their installer into sections dynamically.
- Lists Magisk modules along with their update URLs from /data/adb/modules.
- Requires tput, aapt, wget, awk, and pkg. Checks if installed and installs if missing.

```
#!/bin/bash

# Function to check if a command exists and install it without sudo
check_install() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 not found. Installing..."
        pkg install -y "$2"
    else
        echo "$1 is already installed."
    fi
}

# Check and install tput, aapt, wget, and awk if not installed (without sudo)
check_install tput ncurses-utils
check_install aapt aapt
check_install wget wget
check_install awk gawk

# Define colors using tput (now that we ensured it's installed)
bold=$(tput bold)
underline=$(tput smul)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
cyan=$(tput setaf 6)
magenta=$(tput setaf 5)

# Create a temporary file to hold the raw data
temp_file=$(mktemp)

# Extract the number of packages to process (using su for pm command)
total=$(su -c "pm list packages -3 -f -i" | sed -n 's|package:\(/data/app/[^/]\+/[^/]\+/base.apk\)=\([^ ]\+\)  installer=\([^ ]\+\)|\1 \2 \3|p' | wc -l)
count=0

# Function to display progress bar
show_progress() {
    local progress=$(( count * 100 / total ))
    local bar_length=50
    local filled_length=$(( progress * bar_length / 100 ))
    local bar=$(printf "%-${filled_length}s" "#" | sed 's/ /#/g')
    local spaces=$(printf "%-$((bar_length - filled_length))s")
    
    # Display the progress bar with color
    printf "\r${bold}${green}Progress: [${blue}%s${spaces}${green}] ${yellow}%d%% ${cyan}(%d/%d)${normal}" "$bar" "$progress" "$count" "$total"
}

# Extract APK file paths, package names, and installation methods (using su for pm command)
su -c "pm list packages -3 -f -i" | sed -n 's|package:\(/data/app/[^/]\+/[^/]\+/base.apk\)=\([^ ]\+\)  installer=\([^ ]\+\)|\1 \2 \3|p' | while read apk package installer; do
    # Increment counter and show progress
    count=$((count + 1))
    show_progress
    
    # Extract application name using aapt
    app_name=$(aapt dump badging "$apk" 2>/dev/null | grep 'application: label=' | awk -F"'" '{print $2}')
    
    # Only proceed if both app_name and package are available
    if [ -n "$app_name" ] && [ -n "$package" ]; then
        # Format the application name based on word count
        if [ $(echo "$app_name" | awk '{print NF}') -le 1 ]; then
            short_name="$app_name"
        else
            short_name=$(echo "$app_name" | awk '{print $1 "_" $2}')
        fi
        
        # Generate F-Droid and Play Store links
        fdroid_link="https://f-droid.org/en/packages/$package"
        playstore_link="https://play.google.com/store/apps/details?id=$package"
        
        # Validate the F-Droid link with wget --spider
        if wget --spider "$fdroid_link" 2>/dev/null; then
            link="$fdroid_link"
        else
            link="$playstore_link"
        fi
        
        # Write application name, package name, valid link, and installer to the temporary file
        echo "$short_name $package $link $installer" >> "$temp_file"
    fi
done

# Collect all unique installers into an array
installers=($(awk '{print $4}' "$temp_file" | sort | uniq))

# Function to print section dynamically based on installer
print_section_dynamic() {
    local installer="$1"
    
    echo -e "${bold}${cyan}====================================${normal}"
    echo -e "${bold}${underline}${green}Apps installed via $installer:${normal}"
    echo -e "${cyan}------------------------------------${normal}"
    
    # Filter based on installer and print app details
    awk -v installer="$installer" '{
        if ($4 == installer) {
            print "\033[1;34mApp Name:\033[0m " $1;
            print "\033[1;33mPackage:\033[0m " $2;
            print "\033[1;32mLink:\033[0m " $3;
            print "---";
        }
    }' "$temp_file"
    echo
}

# Loop through each unique installer and create a section dynamically
for installer in "${installers[@]}"; do
    print_section_dynamic "$installer"
done

# Function to print Magisk module names and update URLs
BOLD="\033[1m"
NORMAL="\033[0m"
YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

# Function to print Magisk module names and update URLs
print_modules() {
    echo -e "${BOLD}${CYAN}====================================${NORMAL}"
    echo -e "${BOLD}${GREEN}Magisk Modules:${NORMAL}"
    echo -e "${CYAN}------------------------------------${NORMAL}"

    su -c '
        bold="\033[1m"; 
        normal="\033[0m"; 
        yellow="\033[33m"; 
        green="\033[32m"; 
        red="\033[31m"; 

        for module_dir in /data/adb/modules/*; do
            if [ -d "$module_dir" ]; then
                # Read module.prop and extract information
                if [ -f "$module_dir/module.prop" ]; then
                    module_name=$(grep "^name=" "$module_dir/module.prop" | cut -d"=" -f2)
                    update_url=$(grep "^updateJson=" "$module_dir/module.prop" | cut -d"=" -f2)

                    # Display module name and update URL if available
                    echo -e "${bold}${yellow}Module Name:${normal} $module_name"
                    if [ -n "$update_url" ]; then
                        echo -e "${bold}${green}Update URL:${normal} $update_url"
                    else
                        echo -e "${bold}${red}Update URL:${normal} Not Available"
                    fi
                    echo "---"
                fi
            fi
        done'
}

# Call the function to print Magisk module details
print_modules

# Clean up temporary file
rm "$temp_file"

```
