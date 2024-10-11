List all packages that grants a specific permission e.g. for signature spoofing

```
#!/bin/bash

echo "Starting package inspection..."

# Initialize an array to store packages with FAKE_PACKAGE_SIGNATURE permission
found_packages=()

# List all packages and process them
for package in $(su -c 'pm list packages' | cut -d':' -f2); do
    echo "Processing package: $package"
    
    # Run dumpsys for the current package
    echo "Running 'dumpsys package $package'..."
    result=$(su -c "dumpsys package $package 2>/dev/null | grep 'FAKE_PACKAGE_SIGNATURE'")
    
    if [[ -z $result ]]; then
        echo "No FAKE_PACKAGE_SIGNATURE found for package: $package"
    else
        echo "FAKE_PACKAGE_SIGNATURE found in package: $package"
        
        # Extract and print the relevant signature info
        signature_info=$(echo $result | awk -F'android.permission.FAKE_PACKAGE_SIGNATURE:' '{print $2}')
        echo "Signature info for $package: $signature_info"
        
        # Add package to the found list
        found_packages+=("$package")
    fi
done

# Final report on found packages
if [[ ${#found_packages[@]} -gt 0 ]]; then
    echo ""
    echo "Summary of packages with FAKE_PACKAGE_SIGNATURE permission:"
    for found_package in "${found_packages[@]}"; do
        echo "- $found_package"
    done
else
    echo ""
    echo "No packages with FAKE_PACKAGE_SIGNATURE permission found."
fi

echo "Package inspection completed."
```
