Force doze

`su -c dumpsys deviceidle enable`

`su -c dumpsys deviceidle force-idle`





Since Android 12, the flags have been migrated to DeviceConfig with device_idle as the namespace. To change the configuration, use adb shell device_config put device_idle [KEY] [VALUE] 

e.g.
device_config put device_idle sensing_to 0

All Settings:                                                 flex_time_short=                         light_after_inactive_to=
light_idle_to= light_idle_to_initial_flex=
light_max_idle_to_flex=+15m0s0ms
light_idle_factor=2.0
light_max_idle_to=+15m0s0ms  light_idle_maintenance_min_budge
light_idle_maintenance_max_budget=
min_light_maintenance_time=
min_deep_maintenance_time=
inactive_to=
sensing_to=
locating_to=
location_accuracy=
motion_inactive_to=
motion_inactive_to_flex=
idle_after_inactive_to=
idle_pending_to=
max_idle_pending_to=
idle_pending_factor=
quick_doze_delay_to=
idle_to=
max_idle_to=
idle_factor=
min_time_to_alarm= max_temp_app_allowlist_duration_ms= mms_temp_app_allowlist_duration_ms= sms_temp_app_allowlist_duration_ms= notification_allowlist_duration_ms=
wait_for_unlock=
pre_idle_factor_long=
pre_idle_factor_short=
use_window_alarms=

Test if doze is enabled

`su -c dumpsys deviceidle enabled`

Should return 1

Some recomended values

#!/usr/bin/env bash

device_config reset trusted_defaults device_idle
device_config put device_idle light_after_inactive_to 30000
device_config put device_idle light_pre_idle_to 120000
device_config put device_idle light_idle_to 300000
device_config put device_idle light_idle_factor 2
device_config put device_idle light_max_idle_to 900000
device_config put device_idle light_idle_maintenance_min_budget 30000
device_config put device_idle light_idle_maintenance_max_budget 180000
device_config put device_idle inactive_to 900000
device_config put device_idle sensing_to 0
device_config put device_idle locating_to 0
device_config put device_idle motion_inactive_to 0
device_config put device_idle idle_after_inactive_to 900000
device_config put device_idle idle_pending_to 60000
device_config put device_idle max_idle_pending_to 120000
device_config put device_idle idle_pending_factor 2
device_config put device_idle idle_to 900000
device_config put device_idle max_idle_to 21600000
device_config put device_idle idle_factor 2
device_config put device_idle wait_for_unlock true



Make persistent

`su -c device_config set_sync_disabled_for_tests  persistent`

https://developer.android.com/training/monitoring-device-state/doze-standby
