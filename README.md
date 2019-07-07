This is ***CSI-Tools*** of ***Intel 5300 NIC***.

These codes have been tested on ***Ubuntu 12.04.5 LTS***.

Install csi-tools using the ***install.sh***.

Run ***injection*** setting script using the ***inject_setting.sh***.

High-precision timestamp is supported in this version. If you want to use it, just run ***syn_log_to_file*** instead of ***log_to_file*** to log csi. 

Then, run read_syn_bf_file.m to spare the ***csi.dat*** file.

The timestamp will have two parts. One of it called ***timestamp_high***, another called ***timestamp_low***.

True timestamp can be computed by formula:$timestamp = 2^{32} * timestamp_high + timestamp_low$.

Other operations can refer to [Linux 802.11n CSI Tool](http://dhalperi.github.io/linux-80211n-csitool/index.html)
