#!/usr/bin/sudo /bin/bash

echo "Please input your choice[T/R/C/A]:"
echo "T/R means that you want to set the system to transmit/receive data in injection mode;"
echo "N/A means that you want to set system to log CSI in client/AP mode."

read -n1 -p "Input[T/R/C/A]:" type

echo ""

function fix_command()
{
	num=$1
	while((i < $num))
	do
		rfkill unblock wlan
		let "i++"
	done
	return 0
}

mag=0x1c911
chn=64
bw=HT40-

case $type in
T|t)
	echo "Please set transmitting parameters:<Channel (default:$chn)> <bandwith (default:$bw)> <magic-num (default:$mag)>"
	read -p "parameters:" tchn tbw tmag
	if [ ! -n "$tchn" ]; then
		echo "use default setting of channel"
	else
		chn=$tchn
	fi
	if [ ! -n "$tbw" ]; then
                echo "use default setting of channel"
        else
                bw=$tbw
        fi
	if [ ! -n "$tmag" ]; then
                echo "use default setting of channel"
        else
                mag=$tmag
        fi
	echo "   your parameters are $chn $bw $mag."
	echo "Now start the setting script!"
	source ./linux-80211n-csitool-supplementary/injection/transmitter.sh $chn $bw
	if [ $? -ne 0 ]; then
		echo "Some thing go wrong !! Trying to fix it !!"
		fix_command 3
		if [ $? -ne 0 ]; then
			echo "Fix failed !!!"
			exit -1
		else
			source ./linux-80211n-csitool-supplementary/injection/transmitter.sh $chn $bw
			if [ $? -ne 0]; then
				echo "Fix failed !!!"
				exit -1
			else
				echo "Fix successfully !"
			fi
		fi
	fi
	echo "Now run the long command !"
	sudo echo $mag |sudo tee /sys/kernel/debug/ieee80211/phy0/iwlwifi/iwldvm/debug/monitor_tx_rate
	if [ $? -ne 0 ]; then
		echo "Long command go wrong !"
	else
		echo "Long command complete !"
	fi
	echo "YOU FINAL CHOICES IS AS FLOW:"
        echo "Mode:Injection(Transmit pachages); channel:$chn; bandwidth:$bw; magic:$mag "
	;;
R|r)
	echo "Please set receiving parameters:<Channel (default:64)> <bandwith (default:HT40-)>"
	read -p "parameters:" rchn rbw
	if [ ! -n "$rchn" ]; then
                echo "use default setting of channel"
        else
                chn=$rchn
        fi
        if [ ! -n "$rbw" ]; then
                echo "use default setting of channel"
        else
                bw=$rbw
	fi
	echo "   your parameters are $chn $bw."
	echo "Now start the setting script!"
	source ./linux-80211n-csitool-supplementary/injection/receiver.sh $chn $bw
	if [ $? -ne 0 ]; then
		echo "Some thing go wrong !! Trying to fix it !!"
		fix_command 3
		if [ $? -ne 0 ]; then
                        echo "Fix failed !!!"
                        exit -1
                else
                        source ./linux-80211n-csitool-supplementary/injection/transmitter.sh $chn $bw
                        if [ $? -ne 0]; then
                                echo "Fix failed !!!"
                                exit -1
                        else
                                echo "Fix successfully !"
                        fi
                fi
	else
		echo "sucessfully run !"
	fi
	echo "YOU FINAL CHOICES IS AS FLOW:"
	echo "Mode:Injection(Receive pachages); channel:$chn; bandwidth:$bw"
	;;
C|c)
	modprobe -r iwldvm iwlwifi mac80211
	if [ $? -ne 0 ]; then
		echo "Unload the drivers failed,device may be busy !"
	else
		echo "Unload the dirver Successfully !"
	fi
	defaultlogmode=0x1
	echo "Please choose the log mode [A/B]. If you choose A(connector_log=0x1), you will only log the CSI. If you choose B(connector_log=0x5), you will log both the CSI and its Beacon Frame !"
	read -n1 -p "your choice is [A/B]:" logMode
	if [ $logMode == 'A' -o $logMode == 'B' ]; then
		if [ $logMode == 'B' ]; then
			defaultlogmode=0x5
		fi
		echo "You have choose connector_log=$defaultlogmode ."
		modprobe iwlwifi connector_log=$defaultlogmode
		if [ $? -ne 0 ]; then
			echo "Failed when setting the log mode !!!"
			exit -1
		else
			echo "Successfully load the driver with log mode $defaultlogmode !"
		fi
	else
		echo "No choice or error choice. Use the default logmode: connector_log=$defaultlogmode ."
		modprobe iwlwifi connector_log=$defaultlogmode
		if [ $? -ne 0 ]; then
                        echo "Failed when setting the log mode !!!"
                        exit -1
                else
                        echo "Successfully load the driver with log mode 0X1 !"
                fi
	fi
	echo "YOU FINAL CHOICES IS AS FLOW:"
        echo "Mode:Client; log_mode:$defaultlogmode"
	;;
A|a)
	echo "NOT FINISH"
	;;
*)
	echo "Your Input is error, Bad guy ! Do it again !"
	;;
esac
exit 0
