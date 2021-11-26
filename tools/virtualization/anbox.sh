#!/usr/bin/env bash
#####################
install_anbox() {
	cat <<-'EndOfFile'
		WARNING!本软件需要安装内核模块补丁,且无法保证可以正常运行!
		您亦可使用以下补丁，并将它们构建为模块。
		https://salsa.debian.org/kernel-team/linux/blob/master/debian/patches/debian/android-enable-building-ashmem-and-binder-as-modules.patch
		https://salsa.debian.org/kernel-team/linux/blob/master/debian/patches/debian/export-symbols-needed-by-android-drivers.patch
		若模块安装失败，则请前往官网阅读说明https://docs.anbox.io/userguide/install_kernel_modules.html
		如需卸载该模块，请手动输apt purge -y anbox-modules-dkms
	EndOfFile
	do_you_want_to_continue
	DEPENDENCY_01=''
	if [ "${LINUX_DISTRO}" = "debian" ]; then
		if [ "${DEBIAN_DISTRO}" = "ubuntu" ]; then
			add-apt-repository ppa:morphis/anbox-support
			apt update
			apt install anbox-modules-dkms
			apt install linux-headers-generic
		else
			REPO_URL='http://ppa.launchpad.net/morphis/anbox-support/ubuntu/pool/main/a/anbox-modules/'
			GREP_NAME='all'
			download_ubuntu_ppa_deb_model_01
		fi
		modprobe ashmem_linux
		modprobe binder_linux
		ls -1 /dev/{ashmem,binder}
		DEPENDENCY_02='anbox'
		beta_features_quick_install
	elif [ "${LINUX_DISTRO}" = "arch" ]; then
		DEPENDENCY_01='anbox-modules-dkms-git'
		DEPENDENCY_02='anbox-git'
		beta_features_quick_install
	else
		non_debian_function
	fi
	if [ $(command -v anbox) ] && [ ! -f "/var/lib/anbox/android.img" ]; then
		download_anbox_rom
	fi
	service anbox-container-manager start
	echo "service anbox-container-manager start"
	service anbox-container-manager start || systemctl start anbox-container-manager
	service anbox-container-manager status || systemctl status anbox-container-manager
	echo 'anbox launch --package=org.anbox.appmgr --component=org.anbox.appmgr.AppViewActivity'
	echo 'Do you want to start it?'
	do_you_want_to_continue
	anbox launch --package=org.anbox.appmgr --component=org.anbox.appmgr.AppViewActivity
}
###########
download_anbox_rom() {
	lsmod | grep -e ashmem_linux -e binder_linux
	ls -lh /dev/binder /dev/ashmem
	anbox check-features
	if [ "${ARCH_TYPE}" = "amd64" ]; then
		THE_LATEST_ISO_LINK="https://build.anbox.io/android-images/2018/07/19/android_amd64.img"
	elif [ "${ARCH_TYPE}" = "arm64" ]; then
		THE_LATEST_ISO_LINK="https://build.anbox.io/android-images/2017/08/04/android_1_arm64.img"
	fi
	echo ${THE_LATEST_ISO_LINK}
	do_you_want_to_continue
	aria2c --allow-overwrite=true -s 16 -x 16 -k 1M "${THE_LATEST_ISO_LINK}"
}
#############
install_anbox