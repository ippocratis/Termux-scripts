Disable wifi multicast

Check battery drain by WiFi interface 

`su -c dumpsys wifi |grep  mAh`

Monitor the interface for multicast

`su -c ifconfig wlan0`

Disable it

`su -c ifconfig wlan0  -multicast`

Enable it (just saying)

`su -c ifconfig wlan0  multicast`

Multicast parameters filepath

`su -c cat /proc/net/igmp |grep wlan`

In the compressed Kernel configuration under /proc/config.gz

`su -c zcat /proc/config.gz |grep CONFIG_IP_MULTICAST`

Run a script on boot with termux.boot

Download, unpackage and install from GitHub actions artifacts 
https://github.com/termux/termux-boot/actions

Add `su -c ifconfig wlan0  -multicast` in a .sh file under   ~/.termux/boot/

ifconfig is deprecated use ip

`pkg install iproute2`

`su -c ip link show`

Reveals more interfaces using multicast:

`su -c ip link show > c && cat c |grep MULTICAST`

- wifi-aware0 (nearby devices)
- p2p0 (WiFi direct)
- gretap (tunel interface)
- erspan (wtf is this?)
