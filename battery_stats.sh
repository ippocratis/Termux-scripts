Battery stats


To get a detailed power estimate

`su -c 'dumpsys batterystats' | awk '/Statistics since last charge:/,/idle/'`


Get screen off discharge rate. 
Based on Time on battery screen off: and Screen off discharge:  sections from dumpsys batterystats

```
#!/bin/bash

result1=$(su -c 'dumpsys batterystats | grep "Time on battery screen off" | awk -F"[hms ]+" "/Time on battery screen off:/ {print \$8*60 + \$9 + \$10/60}"')
result2=$(su -c 'dumpsys batterystats | grep "Screen off discharge" | awk "/Screen off discharge:/ {print \$4}"')

# Checking if both results are non-empty before division
if [[ -n $result1 && -n $result2 ]]; then
    result3=$(awk -v r2="$result2" -v r1="$result1" 'BEGIN {printf "%.2f", r2 * 60 / r1}')
    result=$(awk -v r3="$result3" 'BEGIN {printf "%.2f", r3 * 100 / 5000}')
    echo $result
else
    echo "One or both of the results are empty."
fi
```






Get screen on discharge rate. 
Based on "Screen on:" and "Screen on discharge:" sections from dumpsys batterystats

```
#!/bin/bash

result1=$(su -c 'dumpsys batterystats | grep "Screen on:" | awk -F"[hms ]+" "/Screen on:/ {print \$4*60 + \$5 + \$6/60; exit}"')
result2=$(su -c 'dumpsys batterystats | grep "Screen on discharge:" | awk "/Screen on discharge:/ {print \$4}"')

# Checking if both results are non-empty before division
if [[ -n $result1 && -n $result2 ]]; then
    result3=$(awk -v r2="$result2" -v r1="$result1" 'BEGIN {printf "%.2f", r2 * 60 / r1}')
    result=$(awk -v r3="$result3" 'BEGIN {printf "%.2f", r3 * 100 / 5000}')
    echo $result
else
    echo "One or both of the results are empty."
fi
```



Get number of CPU cores:

`su -c cat /proc/cpuinfo`

`su -c top`

CPU %: number of cores multiplied by 100

usr: user cpu time (or) % CPU time spent in user space

sys: system cpu time (or) % CPU time spent in kernel space

nic: user nice cpu time (or) % CPU time spent on low priority processes

idle: idle cpu time (or) % CPU time spent idle

irq: hardware irq (or) % CPU time spent servicing/handling hardware interrupts

sirq: software irq (or) % CPU time spent servicing/handling software interrupts


All in one:

```
#!/bin/bash

# Get the screen on rate
result1=$(su -c 'dumpsys batterystats | grep "Screen on:" | awk -F"[hms ]+" "/Screen on:/ {print \$4*60 + \$5 + \$6/60; exit}"')
result2=$(su -c 'dumpsys batterystats | grep "Screen on discharge:" | awk "/Screen on discharge:/ {print \$4}"')

if [[ -n $result1 && -n $result2 ]]; then
    screen_on_rate=$(awk -v r2="$result2" -v r1="$result1" 'BEGIN {printf "%.2f", r2 * 60 / r1}')
    screen_on_rate_percent=$(awk -v r3="$screen_on_rate" 'BEGIN {printf "%.2f", r3 * 100 / 5000}')
else
    screen_on_rate="N/A"
    screen_on_rate_percent="N/A"
fi

# Get the screen off rate
result1=$(su -c 'dumpsys batterystats | grep "Time on battery screen off" | awk -F"[hms ]+" "/Time on battery screen off:/ {print \$8*60 + \$9 + \$10/60}"')
result2=$(su -c 'dumpsys batterystats | grep "Screen off discharge" | awk "/Screen off discharge:/ {print \$4}"')

if [[ -n $result1 && -n $result2 ]]; then
    screen_off_rate=$(awk -v r2="$result2" -v r1="$result1" 'BEGIN {printf "%.2f", r2 * 60 / r1}')
    screen_off_rate_percent=$(awk -v r3="$screen_off_rate" 'BEGIN {printf "%.2f", r3 * 100 / 5000}')
else
    screen_off_rate="N/A"
    screen_off_rate_percent="N/A"
fi

# Print results in table format
printf "%-20s %-20s\n" "Metric" "Value"
printf "%-20s %-20s\n" "Screen On Rate" "$screen_on_rate_percent%"
printf "%-20s %-20s\n" "Screen Off Rate" "$screen_off_rate_percent%"

# Print detailed battery stats
echo -e "\nDetailed Battery Stats:"
su -c 'dumpsys batterystats' | awk '/Screen on:/,/Interactive:/'
echo -e "\nScreen Off Stats:"
su -c 'dumpsys batterystats' | awk '/Time on battery screen off:/,/) uptime/'
```

Output:
- On rate per hour
- Off rate per hour
- Screen on and interactive time (full time and time device was actually interacted with)
- count (how many times the screen was turned on
- Screen off and uptime (time device.not idle during screen off)
