Quick script that prints a list of installed apps by ap name.and package name categorized by install source.

```
#!/bin/bash

# Define a temporary file to hold the raw data
temp_file=$(mktemp)

# Extract APK file paths, package names, and installation methods
pm list packages -3 -f -i | sed -n 's|package:\(/data/app/[^/]\+/[^/]\+/base.apk\)=\([^ ]\+\)  installer=\([^ ]\+\)|\1 \2 \3|p' | while read apk package installer; do
    # Extract application name using aapt
    app_name=$(aapt dump badging "$apk" 2>/dev/null | grep 'application: label=' | awk -F"'" '{print $2}')
    
    # Format application name based on word count
    if [ $(echo "$app_name" | awk '{print NF}') -le 1 ]; then
        short_name="$app_name"
    else
        short_name=$(echo "$app_name" | awk '{print $1 "_" $2}')
    fi
    
    # Print application name, package name, and installer to the temporary file
    echo "$short_name $package $installer" >> "$temp_file"
done

# Define function to print section with separator
print_section() {
    local section_title="$1"
    local installer_filter="$2"
    
    echo "===================================="
    echo "$section_title:"
    echo "------------------------------------"
    grep "$installer_filter" "$temp_file" | awk '{print $1, $2}'
    echo
}

# Print sections with visual separators
print_section "Aurora/Play Store Apps (com.android.vending)" 'com.android.vending'
print_section "Aurora Droid Apps (com.aurora.adroid)" 'com.aurora.adroid'
print_section "Obtainium Apps (dev.imranr.obtainium)" 'dev.imranr.obtainium'
print_section "APK Installs (com.android.packageinstaller)" 'com.android.packageinstaller'

# Print unknown category with proper handling
echo "===================================="
echo "Unknown (null):"
echo "------------------------------------"
grep -v 'com.android.vending\|com.aurora.adroid\|dev.imranr.obtainium\|com.android.packageinstaller' "$temp_file" | awk '{print $1, $2}'

# Clean up temporary file
rm "$temp_file"
```
