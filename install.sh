#!/usr/bin/sudo /bin/bash

echo "Please make sure that you have connected the Internet !!!"

function check_internect()
{
	ping -c 3 -i 0.2 $1>/dev/null
	if [ $? -eq 0 ]; then
		return 0
	else
		return -1
	fi
}

check_internect www.baidu.com

if [ $? -ne 0 ]; then 
	echo "Please make sure that you have connected the Internet !!!" 
	exit -1 
else
	echo "Internect Connected correctly."
	mv /etc/apt/sources.list /etc/apt/sources.list.old
	if [ $? -ne 0 ]; then
		echo "mv the sources failed ! "
	else
		echo "mv the sources.list successfully ! "
	fi
	cp sources.list /etc/apt/sources.list
	if [ $? -ne 0 ]; then
		echo "cp the sources failed ! "
	else
		echo "cp the sources.list successfully ! "
	fi

	apt-get update

	if [ $? -ne 0 ]; then
                echo "apt-get update failed ! "
        else
                echo "apt-get update successfully ! "
        fi

	apt-get install gcc make linux-headers-$(uname -r) git-core iw libpcap-dev

	echo blacklist iwldvm | sudo tee -a /etc/modprobe.d/csitool.conf

	echo blacklist iwlwifi | sudo tee -a /etc/modprobe.d/csitool.conf

	unzip linux-80211n-csitool-csitool-3.13.zip

	make -C /lib/modules/$(uname -r)/build M=$(pwd)/linux-80211n-csitool-csitool-3.13/drivers/net/wireless/iwlwifi modules

	sudo make -C /lib/modules/$(uname -r)/build M=$(pwd)/linux-80211n-csitool-csitool-3.13/drivers/net/wireless/iwlwifi INSTALL_MOD_DIR=updates modules_install

	sudo depmod

	for file in /lib/firmware/iwlwifi-5000-*.ucode; do sudo mv $file $file.orig; done

	sudo cp linux-80211n-csitool-supplementary/firmware/iwlwifi-5000-2.ucode.sigcomm2010 /lib/firmware/

	sudo ln -s iwlwifi-5000-2.ucode.sigcomm2010 /lib/firmware/iwlwifi-5000-2.ucode

	make -C linux-80211n-csitool-supplementary/netlink

	cd lorcon-old

	echo "Go into the $(pwd) path."

	./configure

	make

	make install

	cd ..

	echo "Go back to $(pwd) path."

	make -C linux-80211n-csitool-supplementary/injection
	
	chmod a+x linux-80211n-csitool-supplementary/injection/receiver.sh

	chmod a+x linux-80211n-csitool-supplementary/injection/transmitter.sh

	chmod a+x inject_setting.sh

	exit 0
fi
