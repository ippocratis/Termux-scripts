Bluetooth on/off bash script for termux widget


For roms without disabled quicksettings on secure lockscreen
That I remove the airplane and network tiles


1)download termux
https://f-droid.org/en/packages/com.termux/

2)download termux widget
https://f-droid.org/en/packages/com.termux.widget/

3)install tsu
pkg install tsu

4)know you termux $HOME
echo $HOME

5)create the folders , the files with the bash scripts and give execute permissions to the files  on a user folder
```
mkdir -p /data/data/com.termux/files/home/.shortcuts && mkdir -p /data/data/com.termux/files/home/.shortcuts/tasks && mkdir -p /storage/emulated/0/.shortcuts && touch /storage/emulated/0/.shortcuts/bl-on.sh && touch /storage/emulated/0/.shortcuts/bl-off.sh && touch  /data/data/com.termux/files/home/.shortcuts/tasks/bl-on.sh && touch /data/data/com.termux/files/home/.shortcuts/tasks/bl-off.sh && echo -e "am start -a android.bluetooth.adapter.action.REQUEST_DISABLE" >>  /storage/emulated/0/.shortcuts/bl-off.sh && echo -e "am start -a android.bluetooth.adapter.action.REQUEST_ENABLE" >> /storage/emulated/0/.shortcuts/bl-on.sh && echo -e "sudo -E sh /storage/emulated/0/.shortcuts/bl-on.sh" >> /data/data/com.termux/files/home/.shortcuts/tasks/bl-on.sh && echo -e "sudo -E sh /storage/emulated/0/.shortcuts/bl-off.sh" >> /data/data/com.termux/files/home/.shortcuts/tasks/bl-off.sh && chmod 755 /storage/emulated/0/.shortcuts/bl-on.sh && chmod 755 /storage/emulated/0/.shortcuts/bl-off.sh && chmod  755 /data/data/com.termux/files/home/.shortcuts/tasks/bl-off.sh && chmod 755 /data/data/com.termux/files/home/.shortcuts/tasks/bl-on.sh
```
