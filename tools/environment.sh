#!/usr/bin/env bash
########################
check_current_user_name_and_group() {
    CURRENT_USER_NAME=$(cat /etc/passwd | grep "${HOME}" | awk -F ':' '{print $1}')
    CURRENT_USER_GROUP=$(cat /etc/passwd | grep "${HOME}" | awk -F ':' '{print $5}' | cut -d ',' -f 1)
    if [ -z "${CURRENT_USER_GROUP}" ]; then
        CURRENT_USER_GROUP=${CURRENT_USER_NAME}
    fi
}
#########################
gnu_linux_env_02() {
    OPT_URL_01='https://bintray.proxy.ustclug.org/debianopt/debianopt'
    OPT_URL_02='https://dl.bintray.com/debianopt/debianopt'
    OPT_REPO_LIST='/etc/apt/sources.list.d/debianopt.list'
    ELECTRON_MIRROR_STATION='https://mirrors.huaweicloud.com/electron'
    TIGER_VNC_DEFAULT_CONFIG_FILE='/etc/tigervnc/vncserver-config-defaults'
    XSESSION_FILE='/etc/X11/xinit/Xsession'
}
########################
uncompress_theme_file() {
    case "${TMOE_THEME_ITEM:0-6:6}" in
    tar.xz)
        tar -Jxvf ${TMOE_THEME_ITEM} -C ${EXTRACT_FILE_PATH} 2>/dev/null
        ;;
    tar.gz)
        tar -zxvf ${TMOE_THEME_ITEM} -C ${EXTRACT_FILE_PATH} 2>/dev/null
        ;;
    *)
        tar -xvf ${TMOE_THEME_ITEM} -C ${EXTRACT_FILE_PATH} 2>/dev/null
        ;;
    esac
}
############
check_tar_ext_format() {
    case "${TMOE_THEME_ITEM:0-6:6}" in
    tar.xz)
        EXTRACT_FILE_FOLDER=$(tar -Jtf ${TMOE_THEME_ITEM} | cut -d '/' -f 1 | sort -u | sed ":a;N;s/\n/ /g;ta")
        ;;
    tar.gz)
        EXTRACT_FILE_FOLDER=$(tar -ztf ${TMOE_THEME_ITEM} | cut -d '/' -f 1 | sort -u | sed ":a;N;s/\n/ /g;ta")
        ;;
    *)
        EXTRACT_FILE_FOLDER=$(tar -tf ${TMOE_THEME_ITEM} | cut -d '/' -f 1 | sort -u | sed ":a;N;s/\n/ /g;ta")
        ;;
    esac
    EXTRACT_FILE_FOLDER_HEAD_01=$(echo ${EXTRACT_FILE_FOLDER} | awk '{print $1}')
    check_theme_folder_exists_status
}
################
check_theme_folder_exists_status() {
    if [ -e "${EXTRACT_FILE_PATH}/${EXTRACT_FILE_FOLDER_HEAD_01}" ]; then
        echo "检测到您已安装该主题，如需删除，请手动输${YELLOW}cd ${EXTRACT_FILE_PATH} ; ls ;rm -rv ${EXTRACT_FILE_FOLDER} ${RESET}"
        echo "是否重新解压？"
        echo "Do you want to uncompress again?"
        do_you_want_to_continue
    fi
    uncompress_theme_file
}
###################
check_theme_folder() {
    if [ -e "${HOME}/Pictures/${CUSTOM_WALLPAPER_NAME}" ] || [ -e ${HOME}/图片/${CUSTOM_WALLPAPER_NAME} ]; then
        echo "检测到您${RED}已经下载过${RESET}该壁纸包了"
        echo "壁纸包位于${BLUE}${HOME}/Pictures/${CUSTOM_WALLPAPER_NAME}${RESET}(图片)目录"
        echo "Do you want to ${RED}download again?${RESET}"
        echo "是否想要重新下载？"
        do_you_want_to_continue
    fi
}
##############
move_wallpaper_model_01() {
    if [ -e "data.tar.xz" ]; then
        tar -Jxvf data.tar.xz 2>/dev/null
    elif [ -e "data.tar.gz" ]; then
        tar -zxvf data.tar.gz 2>/dev/null
    elif [ -e "data.tar.zst" ]; then
        tar --zstd -xvf data.tar.zst &>/dev/null || zstdcat "data.tar.zst" | tar xvf -
    else
        tar -xvf data.* 2>/dev/null
    fi
    if [ "${SET_MINT_AS_WALLPAPER}" = 'true' ]; then
        mv ./usr/share/${WALLPAPER_NAME}/* /usr/share/${CUSTOM_WALLPAPER_NAME}
        rm -rf /tmp/.${THEME_NAME}
        echo "${BLUE}壁纸包${RESET}已经保存至/usr/share/${CUSTOM_WALLPAPER_NAME}${RESET}"
        echo "${BLUE}The wallpaper-pack${RESET} have been saved to ${YELLOW}/usr/share/${CUSTOM_WALLPAPER_NAME}${RESET}"
    else
        if [ -d "${HOME}/图片" ]; then
            mv ./usr/share/${WALLPAPER_NAME} ${HOME}/图片/${CUSTOM_WALLPAPER_NAME}
        else
            mkdir -p ${HOME}/Pictures/
            mv ./usr/share/${WALLPAPER_NAME} ${HOME}/Pictures/${CUSTOM_WALLPAPER_NAME}
        fi
        rm -rf /tmp/.${THEME_NAME}
        echo "${BLUE}壁纸包${RESET}已经保存至${YELLOW}${HOME}/图片/${CUSTOM_WALLPAPER_NAME}${RESET}"
        echo "${BLUE}The wallpaper-pack${RESET} have been saved to ${YELLOW}${HOME}/Pictures/${CUSTOM_WALLPAPER_NAME}${RESET}"
    fi
}
#################
move_wallpaper_model_02() {
    if [ -d "${HOME}/图片" ]; then
        tar -Jxvf data.tar.xz -C ${HOME}/图片
    else
        mkdir -p ${HOME}/Pictures/
        tar -Jxvf data.tar.xz -C ${HOME}/Pictures/
    fi
    rm -rf /tmp/.${THEME_NAME}
    echo "${BLUE}壁纸包${RESET}已经保存至${YELLOW}${HOME}/图片/${CUSTOM_WALLPAPER_NAME}${RESET}"
    echo "${BLUE}The wallpaper-pack${RESET} have been saved to ${YELLOW}${HOME}/Pictures/${CUSTOM_WALLPAPER_NAME}${RESET}"
}
#################
grep_theme_model_01() {
    check_theme_folder
    mkdir -p /tmp/.${THEME_NAME}
    cd /tmp/.${THEME_NAME}
    THE_LATEST_THEME_VERSION="$(curl -L ${THEME_URL} | grep '.deb' | grep "${GREP_NAME}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)"
    download_theme_deb_and_extract_01
}
###############
aria2c_download_theme_file() {
    THE_LATEST_THEME_LINK="${THEME_URL}${THE_LATEST_THEME_VERSION}"
    echo ${THE_LATEST_THEME_LINK}
    aria2c --allow-overwrite=true -s 5 -x 5 -k 1M -o "${THE_LATEST_THEME_VERSION}" "${THE_LATEST_THEME_LINK}"
}
##########
download_theme_deb_and_extract_01() {
    aria2c_download_theme_file
    if [ "${BUSYBOX_AR}" = 'true' ]; then
        busybox ar xv ${THE_LATEST_THEME_VERSION}
    else
        ar xv ${THE_LATEST_THEME_VERSION}
    fi
}
###############
#多GREP
grep_theme_model_03() {
    if [ ${FORCIBLY_DOWNLOAD} != 'true' ]; then
        check_theme_folder
    fi
    mkdir -p /tmp/.${THEME_NAME}
    cd /tmp/.${THEME_NAME}
    THE_LATEST_THEME_VERSION="$(curl -L ${THEME_URL} | grep "${GREP_NAME_01}" | grep "${GREP_NAME_02}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)"
    download_theme_deb_and_extract_01
}
############################
grep_theme_model_04() {
    check_theme_folder
    mkdir -p /tmp/.${THEME_NAME}
    cd /tmp/.${THEME_NAME}
    THE_LATEST_THEME_VERSION="$(curl -L ${THEME_URL} | grep "${GREP_NAME_01}" | grep "${GREP_NAME_02}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)"
    aria2c_download_theme_file
    mv ${THE_LATEST_THEME_VERSION} data.tar.xz
}
############################
#tar.xz
#manjaro仓库
grep_theme_model_02() {
    check_theme_folder
    mkdir -p /tmp/.${THEME_NAME}
    cd /tmp/.${THEME_NAME}
    THE_LATEST_THEME_VERSION="$(curl -L ${THEME_URL} | grep -v '.xz.sig' | grep "${GREP_NAME}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)"
    aria2c_download_theme_file
}
###########
update_icon_caches_model_01() {
    cd /
    tar -Jxvf /tmp/.${THEME_NAME}/data.tar.xz ./usr
    rm -rf /tmp/.${THEME_NAME}
    echo "updating icon caches..."
    echo "正在刷新图标缓存..."
    update-icon-caches /usr/share/icons/${ICON_NAME} 2>/dev/null &
    tips_of_delete_icon_theme
}
############
tips_of_delete_icon_theme() {
    echo "解压${BLUE}完成${RESET}，如需${RED}删除${RESET}，请手动输${YELLOW}rm -rf /usr/share/icons/${ICON_NAME} ${RESET}"
}
###################
update_icon_caches_model_02() {
    tar -Jxvf /tmp/.${THEME_NAME}/${THE_LATEST_THEME_VERSION} 2>/dev/null
    cp -rf usr /
    cd /
    rm -rf /tmp/.${THEME_NAME}
    echo "updating icon caches..."
    echo "正在刷新图标缓存..."
    update-icon-caches /usr/share/icons/${ICON_NAME} 2>/dev/null &
    tips_of_delete_icon_theme
}
####################
download_raspbian_pixel_icon_theme() {
    THEME_NAME='raspbian_pixel_icon_theme'
    ICON_NAME='PiX'
    GREP_NAME='all.deb'
    THEME_URL='https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/pool/ui/p/pix-icons/'
    grep_theme_model_01
    update_icon_caches_model_01
    XFCE_ICON_NAME='PiX'
    set_default_xfce_icon_theme
}
################
#non-zst
grep_arch_linux_pkg() {
    ARCH_WALLPAPER_VERSION=$(cat index.html | grep -Ev '.xz.sig|.zst.sig|.pkg.tar.zst' | egrep "${GREP_NAME}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)
    ARCH_WALLPAPER_URL="${THEME_URL}${ARCH_WALLPAPER_VERSION}"
    echo "${ARCH_WALLPAPER_URL}"
    aria2c --allow-overwrite=true -o data.tar.xz -x 5 -s 5 -k 1M ${ARCH_WALLPAPER_URL}
}
################
#grep zst
grep_arch_linux_pkg_02() {
    ARCH_WALLPAPER_VERSION=$(cat index.html | grep '.pkg.tar.zst' | grep -Ev '.xz.sig|.zst.sig' | grep "${GREP_NAME}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)
    ARCH_WALLPAPER_URL="${THEME_URL}${ARCH_WALLPAPER_VERSION}"
    echo "${ARCH_WALLPAPER_URL}"
    aria2c --allow-overwrite=true -o data.tar.zst -x 5 -s 5 -k 1M ${ARCH_WALLPAPER_URL}
}
###################
grep_arch_linux_pkg_03() {
    ARCH_WALLPAPER_VERSION=$(cat index.html | grep '.pkg.tar.zst' | grep -Ev '.xz.sig|.zst.sig' | grep "${GREP_NAME}" | grep -v "${GREP_NAME_V}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)
    ARCH_WALLPAPER_URL="${THEME_URL}${ARCH_WALLPAPER_VERSION}"
    echo "${YELLOW}${ARCH_WALLPAPER_URL}${RESET}"
    aria2c --allow-overwrite=true -o data.tar.zst -x 5 -s 5 -k 1M ${ARCH_WALLPAPER_URL}
}
#################
grep_arch_linux_pkg_04() {
    #JetBrains IDE
    ARCH_WALLPAPER_VERSION=$(cat index.html | grep '.pkg.tar.zst' | grep -Ev '.xz.sig|.zst.sig' | grep -v '\-jre\-' | grep "${GREP_NAME}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)
    cd ${DOWNLOAD_PATH}
    LOCAL_ARCH_PKG_VERSION=$(ls -t ${GREP_NAME}*.pkg.tar.zst 2>/dev/null | head -n 1)
    case ${LOCAL_ARCH_PKG_VERSION} in
    ${ARCH_WALLPAPER_VERSION}) echo "检测到您已经下载最新版的${LOCAL_ARCH_PKG_VERSION},如需删除安装包，请输${RED}rm -v${RESET} ${BLUE}${DOWNLOAD_PATH}/${LOCAL_ARCH_PKG_VERSION}${RESET}" ;;
    *)
        ARCH_WALLPAPER_URL="${THEME_URL}${ARCH_WALLPAPER_VERSION}"
        #echo "${YELLOW}${ARCH_WALLPAPER_URL}${RESET}"
        aria2c --allow-overwrite=true -d ${DOWNLOAD_PATH} -o ${ARCH_WALLPAPER_VERSION} -x 5 -s 5 -k 1M ${ARCH_WALLPAPER_URL}
        ;;
    esac
    echo ${ARCH_WALLPAPER_VERSION} | sed "s@${GREP_NAME}-@@g" | sed 's@.pkg.tar.zst@@' >"${LOCAL_APP_VERSION_TXT}"
}
#################
check_opt_app_version() {
    LOCAL_APP_VERSION_TXT="${TMOE_LINUX_DIR}/${GREP_NAME}-version"
    if [ -e "${LOCAL_APP_VERSION_TXT}" ]; then
        LOCAL_OPT_APP_VERSION=$(cat ${LOCAL_APP_VERSION_TXT} | head -n 1)
    else
        LOCAL_OPT_APP_VERSION="NOT-INSTALLED未安装"
    fi
}
##############
check_archlinux_cn_html_date() {
    THEME_URL='https://mirrors.bfsu.edu.cn/archlinuxcn/x86_64/'
    ARCH_LINUX_CN_REPO_DIR='/tmp/.ARCH_LINUX_CN_REPO'
    ARCH_LINUX_CN_REPO_HTML="${ARCH_LINUX_CN_REPO_DIR}/index.html"
    if [ ! -e "${ARCH_LINUX_CN_REPO_DIR}" ]; then
        mkdir -p ${ARCH_LINUX_CN_REPO_DIR}
    fi
    cd ${ARCH_LINUX_CN_REPO_DIR}

    if [ -e "${ARCH_LINUX_CN_REPO_HTML}" ]; then
        FILE_TIME=$(date -d "$(stat -c '%y' ${ARCH_LINUX_CN_REPO_HTML})" +"%Y%m%d")
        case ${FILE_TIME} in
        "$(date +%Y%m%d)") ;;
        *) download_arch_linux_cn_repo_html ;;
        esac
    else
        download_arch_linux_cn_repo_html
    fi
}
##########
check_opt_dir_01() {
    APP_OPT_DIR="/opt/${GREP_NAME}"
    if [ -e "${APP_OPT_DIR}" ]; then
        echo "安装完成，如需卸载，请输${RED}rm -rv${RESET}${BLUE}${APP_OPT_DIR} ${APPS_LNK_DIR}/${GREP_NAME}.desktop ${LOCAL_OPT_APP_VERSION}${RESET}"
        echo "是否需要强制更新？"
        echo "Do you want to mandatory upgrade ${GREP_NAME}?"
        do_you_want_to_continue
    fi
}
###########
check_download_path() {
    if [ -e "${HOME}/sd" ]; then
        DOWNLOAD_PATH=${HOME}/sd/Download
    elif [ -e "/sdcard" ]; then
        DOWNLOAD_PATH=/sdcard/Download
    else
        DOWNLOAD_PATH=${HOME}/sd/Download
    fi
    mkdir -p ${DOWNLOAD_PATH}
}
###########
download_arch_linux_cn_repo_html() {
    aria2c -o index.html --allow-overwrite=true ${THEME_URL}
}
############
download_arch_community_repo_html() {
    THEME_NAME=${GREP_NAME}
    mkdir -p /tmp/.${THEME_NAME}
    cd /tmp/.${THEME_NAME}
    aria2c --allow-overwrite=true -o index.html "${THEME_URL}"
}
##############
upcompress_deb_file() {
    if [ -e "data.tar.xz" ]; then
        cd /
        tar -Jxvf /tmp/.${THEME_NAME}/data.tar.xz ./usr
    elif [ -e "data.tar.gz" ]; then
        cd /
        tar -zxvf /tmp/.${THEME_NAME}/data.tar.gz ./usr
    fi
    rm -rf /tmp/.${THEME_NAME}
}
####################
do_you_want_to_close_the_sandbox_mode() {
    echo "请问您是否需要关闭沙盒模式？"
    echo "若您需要以root权限运行该应用，则需要关闭，否则请保持开启状态。"
    echo "${YELLOW}Do you need to turn off the sandbox mode?[Y/n]${RESET}"
    echo "Press enter to close this mode,type n to cancel."
    echo "按${YELLOW}回车${RESET}键${RED}关闭${RESET}该模式，输${YELLOW}n${RESET}取消"
}
#######################
check_file_selection_items() {
    if [[ -d "${SELECTION}" ]]; then # 目录是否已被选择
        tmoe_file "$1" "${SELECTION}"
    elif [[ -f "${SELECTION}" ]]; then # 文件已被选择？
        if [[ ${SELECTION} == *${FILE_EXT_01} ]] || [[ ${SELECTION} == *${FILE_EXT_02} ]]; then
            # 检查文件扩展名
            if (whiptail --title "Confirm Selection" --yes-button "Confirm确认" --no-button "Back返回" --yesno "目录: $CURRENT_DIR\n文件: ${SELECTION}" 10 55 4); then
                FILE_NAME="${SELECTION}"
                FILE_PATH="${CURRENT_DIR}"
                #将文件路径作为已经选择的变量
            else
                tmoe_file "$1" "$CURRENT_DIR"
            fi
        else
            whiptail --title "WARNING: File Must have ${FILE_EXT_01} or ${FILE_EXT_02} Extension" \
                --msgbox "${SELECTION}\n您必须选择${FILE_EXT_01}或${FILE_EXT_02}格式的文件。You Must Select a ${FILE_EXT_01} or ${FILE_EXT_02} file" 0 0
            tmoe_file "$1" "$CURRENT_DIR"
        fi
    else
        whiptail --title "WARNING: Selection Error" \
            --msgbox "无法选择该文件或文件夹，请返回。Error Changing to Path ${SELECTION}" 0 0
        tmoe_file "$1" "$CURRENT_DIR"
    fi
}
#####################
tmoe_file() {
    if [ -z $2 ]; then
        DIR_LIST=$(ls -lAhp | awk -F ' ' ' { print $9 " " $5 } ')
    else
        cd "$2"
        DIR_LIST=$(ls -lAhp | awk -F ' ' ' { print $9 " " $5 } ')
    fi
    ###########################
    CURRENT_DIR=$(pwd)
    # 检测是否为根目录
    if [ "$CURRENT_DIR" == "/" ]; then
        SELECTION=$(whiptail --title "$1" \
            --menu "${MENU_01}\n$CURRENT_DIR" 0 0 0 \
            --title "$TMOE_TITLE" \
            --cancel-button Cancel取消 \
            --ok-button Select选择 $DIR_LIST 3>&1 1>&2 2>&3)
    else
        SELECTION=$(whiptail --title "$1" \
            --menu "${MENU_01}\n$CURRENT_DIR" 0 0 0 \
            --title "$TMOE_TITLE" \
            --cancel-button Cancel取消 \
            --ok-button Select选择 ../ 返回 $DIR_LIST 3>&1 1>&2 2>&3)
    fi
    ########################
    EXIT_STATUS=$?
    if [ ${EXIT_STATUS} = 1 ]; then # 用户是否取消操作？
        return 1
    elif [ ${EXIT_STATUS} = 0 ]; then
        check_file_selection_items
    fi
    ############
}
################
install_deb_file_common_model_02() {
    cd /tmp
    echo ${LATEST_DEB_URL}
    aria2c --allow-overwrite=true -s 5 -x 5 -k 1M -o "${LATEST_DEB_VERSION}" "${LATEST_DEB_URL}"
    apt show ./${LATEST_DEB_VERSION}
    apt install -y ./${LATEST_DEB_VERSION}
    rm -fv ./${LATEST_DEB_VERSION}
}
###############
install_deb_file_common_model_01() {
    LATEST_DEB_URL="${LATEST_DEB_REPO}${LATEST_DEB_VERSION}"
    install_deb_file_common_model_02
}
###################
download_ubuntu_kylin_deb_file_model_02() {
    LATEST_DEB_VERSION=$(curl -L "${LATEST_DEB_REPO}" | grep '.deb' | grep "${ARCH_TYPE}" | grep "${GREP_NAME}" | tail -n 1 | cut -d '=' -f 5 | cut -d '"' -f 2)
    install_deb_file_common_model_01
}
################
download_debian_cn_repo_deb_file_model_01() {
    LATEST_DEB_VERSION=$(curl -L "${LATEST_DEB_REPO}" | grep '.deb' | grep "${ARCH_TYPE}" | grep "${GREP_NAME}" | tail -n 1 | cut -d '=' -f 2 | cut -d '"' -f 2)
    install_deb_file_common_model_01
}
######################
download_tuna_repo_deb_file_model_03() {
    LATEST_DEB_VERSION=$(curl -L "${LATEST_DEB_REPO}" | grep '.deb' | grep "${ARCH_TYPE}" | grep "${GREP_NAME}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)
    install_deb_file_common_model_01
}
################
download_tuna_repo_deb_file_all_arch() {
    LATEST_DEB_VERSION=$(curl -L "${LATEST_DEB_REPO}" | grep '.deb' | grep "all" | grep "${GREP_NAME}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)
    LATEST_DEB_URL="${LATEST_DEB_REPO}${LATEST_DEB_VERSION}"
    echo ${LATEST_DEB_URL}
    aria2c --allow-overwrite=true -s 5 -x 5 -k 1M -o "${LATEST_DEB_VERSION}" "${LATEST_DEB_URL}"
    apt show ./${LATEST_DEB_VERSION} 2>/dev/null
}
##此处不要自动安装deb包
######################
press_enter_to_return_configure_xrdp() {
    press_enter_to_return
    configure_xrdp
}
#############
press_enter_to_return_configure_xwayland() {
    press_enter_to_return
    configure_xwayland
}
#######################
beta_features_management_menu() {
    if (whiptail --title "您想要对这个小可爱做什么呢 " --yes-button "reinstall重装" --no-button "remove移除" --yesno "检测到您已安装${DEPENDENCY_01} ${DEPENDENCY_02} \nDo you want to reinstall or remove it? ♪(^∇^*) " 0 50); then
        echo "${GREEN} ${TMOE_INSTALLATON_COMMAND} ${DEPENDENCY_01} ${DEPENDENCY_02} ${RESET}"
        echo "即将为您重装..."
    else
        ${TMOE_REMOVAL_COMMAND} ${DEPENDENCY_01} ${DEPENDENCY_02}
        press_enter_to_return
        #tmoe_linux_tool_menu
        ${RETURN_TO_WHERE}
    fi
}
##############
non_debian_function() {
    if [ "${LINUX_DISTRO}" != 'debian' ]; then
        echo "非常抱歉，本功能仅适配deb系发行版"
        echo "Sorry, this feature is only suitable for debian based distributions"
        press_enter_to_return
        if [ ! -z ${RETURN_TO_WHERE} ]; then
            ${RETURN_TO_WHERE}
        else
            beta_features
        fi
    fi
}
############
press_enter_to_reinstall() {
    echo "检测到${YELLOW}您已安装${RESET} ${GREEN} ${DEPENDENCY_01} ${DEPENDENCY_02} ${RESET}"
    echo "如需${RED}卸载${RESET}，请手动输${RED}${TMOE_REMOVAL_COMMAND}${RESET} ${BLUE}${DEPENDENCY_01} ${DEPENDENCY_02} ${RESET}"
    press_enter_to_reinstall_yes_or_no
}
################
if_return_to_where_no_empty() {
    if [ ! -z ${RETURN_TO_WHERE} ]; then
        ${RETURN_TO_WHERE}
    else
        beta_features
    fi
}
##########
press_enter_to_reinstall_yes_or_no() {
    echo "按${GREEN}回车键${RESET}${RED}重新安装${RESET},输${YELLOW}n${RESET}${BLUE}返回${RESET}"
    echo "输${YELLOW}m${RESET}打开${BLUE}管理菜单${RESET}"
    echo "${YELLOW}Do you want to reinstall it?[Y/m/n]${RESET}"
    echo "Press enter to reinstall,type n to return,type m to open management menu."
    read opt
    case $opt in
    y* | Y* | "") ;;
    n* | N*)
        echo "skipped."
        if_return_to_where_no_empty
        ;;
    m* | M*)
        beta_features_management_menu
        ;;
    *)
        echo "Invalid choice. skipped."
        if_return_to_where_no_empty
        ;;
    esac
}
#######################
beta_features_install_completed() {
    echo "安装${GREEN}完成${RESET},如需${RED}卸载${RESET}，请手动输${RED}${TMOE_REMOVAL_COMMAND}${RESET} ${BLUE}${DEPENDENCY_01} ${DEPENDENCY_02} ${RESET}"
    echo "The installation is complete. If you want to remove, please enter the above highlighted command."
}
####################
beta_features_quick_install() {
    #if [ "${NON_DEBIAN}" = 'true' ]; then
    #   non_debian_function
    #fi
    #############
    if [ ! -z "${DEPENDENCY_01}" ]; then
        DEPENDENCY_01_COMMAND=$(echo ${DEPENDENCY_01} | awk -F ' ' '$0=$NF')
        if [ $(command -v ${DEPENDENCY_01_COMMAND}) ]; then
            echo "检测到${YELLOW}您已安装${RESET} ${GREEN} ${DEPENDENCY_01} ${RESET}"
            echo "如需${RED}卸载${RESET}，请手动输${RED}${TMOE_REMOVAL_COMMAND}${RESET} ${BLUE}${DEPENDENCY_01}${RESET}"
            EXISTS_COMMAND='true'
        fi
    fi
    #############
    if [ ! -z "${DEPENDENCY_02}" ]; then
        DEPENDENCY_02_COMMAND=$(echo ${DEPENDENCY_02} | awk -F ' ' '$0=$NF')
        if [ $(command -v ${DEPENDENCY_02_COMMAND}) ]; then
            echo "检测到${YELLOW}您已安装${RESET} ${GREEN} ${DEPENDENCY_02} ${RESET}"
            echo "如需${RED}卸载${RESET}，请手动输${RED}${TMOE_REMOVAL_COMMAND}${RESET} ${BLUE}${DEPENDENCY_02}${RESET}"
            EXISTS_COMMAND='true'
        fi
    fi
    ###############
    echo "正在${YELLOW}安装${RESET}相关${GREEN}软件包${RESET}及其${BLUE}依赖...${RESET}"
    echo "${GREEN}${TMOE_INSTALLATON_COMMAND}${RESET} ${BLUE}${DEPENDENCY_01}${RESET} ${YELLOW}${DEPENDENCY_02}${RESET}"
    echo "Tmoe-linux tool will ${YELLOW}install${RESET} relevant ${BLUE}dependencies${RESET} for you."
    ############
    if [ "${EXISTS_COMMAND}" = "true" ]; then
        EXISTS_COMMAND='false'
        press_enter_to_reinstall_yes_or_no
    fi
    ############
    different_distro_software_install
    #############
    beta_features_install_completed
}
################
check_tmoe_linux_desktop_link() {
    if [ ! -e "${APPS_LNK_DIR}/tmoe-linux.desktop" ]; then
        mkdir -p ${APPS_LNK_DIR}
        creat_tmoe_linux_desktop_icon
    fi
    TMOE_ICON_FILE='/usr/share/icons/tmoe-linux.png'
    if [ -e "${TMOE_ICON_FILE}" ]; then
        rm ${TMOE_ICON_FILE}
        creat_tmoe_linux_desktop_icon
    fi
}
###################
creat_tmoe_linux_desktop_icon() {
    if [ ! $(command -v debian-i) ]; then
        cd /usr/local/bin
        curl -Lv -o debian-i 'https://gitee.com/mo2/linux/raw/master/tool.sh'
        chmod +x debian-i
    fi
    cp ${TMOE_TOOL_DIR}/app/lnk/tmoe-linux.desktop ${APPS_LNK_DIR}/tmoe-linux.desktop
}
####################
arch_does_not_support() {
    echo "${RED}WARNING！${RESET}检测到${YELLOW}架构${RESET}${RED}不支持！${RESET}"
    echo "Press ${GREEN}enter${RESET} to ${BLUE}return.${RESET}"
    echo "按${GREEN}回车键${RESET}${BLUE}返回${RESET}"
    read
    ${RETURN_TO_WHERE}
}
##########################
do_you_want_to_continue() {
    TMOE_TIPS_01="Do you want to continue?${YELLOW}[Y/n]${RESET}"
    if [ -e /usr/games/lolcat ]; then
        echo ${TMOE_TIPS_01} | /usr/games/lolcat -a -d 8
    elif [ "$(command -v lolcat)" ]; then
        echo ${TMOE_TIPS_01} | lolcat
    else
        echo ${TMOE_TIPS_01}
    fi
    echo "Press ${GREEN}enter${RESET} to ${BLUE}continue${RESET},type ${YELLOW}n${RESET} to ${BLUE}return.${RESET}"
    echo "按${GREEN}回车键${RESET}${BLUE}继续${RESET}，输${YELLOW}n${RESET}${BLUE}返回${RESET}"
    read opt
    case $opt in
    y* | Y* | "") ;;

    n* | N*)
        echo "skipped."
        ${RETURN_TO_WHERE}
        ;;
    *)
        echo "Invalid choice. skipped."
        ${RETURN_TO_WHERE}
        #beta_features
        ;;
    esac
}
######################
different_distro_software_install() {
    if [ "${LINUX_DISTRO}" = "debian" ]; then
        apt update
        if [ ! -z "${DEPENDENCY_01}" ]; then
            apt install -y ${DEPENDENCY_01} || aptitude install ${DEPENDENCY_01}
        fi
        if [ ! -z "${DEPENDENCY_02}" ]; then
            apt install -y ${DEPENDENCY_02} || aptitude install ${DEPENDENCY_02}
        fi
        ################
    elif [ "${LINUX_DISTRO}" = "alpine" ]; then
        apk update
        apk add ${DEPENDENCY_01}
        apk add ${DEPENDENCY_02}
        ################
    elif [ "${LINUX_DISTRO}" = "arch" ]; then
        if [ ! -z "${DEPENDENCY_01}" ]; then
            pacman -Syu --noconfirm ${DEPENDENCY_01} || su ${CURRENT_USER_NAME} -c "yay -S ${DEPENDENCY_01}" || echo "无法以${RED}${CURRENT_USER_NAME}${RESET}身份运行${GREEN}yay -S${RESET} ${BLUE}${DEPENDENCY_01}${RESET}"
        fi
        if [ ! -z "${DEPENDENCY_02}" ]; then
            pacman -S --noconfirm ${DEPENDENCY_02} || su ${CURRENT_USER_NAME} -c "yay -S ${DEPENDENCY_02}" || echo "无法以${RED}${CURRENT_USER_NAME}${RESET}身份运行${GREEN}yay -S${RESET} ${BLUE}${DEPENDENCY_02}${RESET},请手动执行"
        fi
        ################
    elif [ "${LINUX_DISTRO}" = "redhat" ]; then
        if [ ! -z "${DEPENDENCY_01}" ]; then
            dnf install -y --skip-broken ${DEPENDENCY_01} || yum install -y --skip-broken ${DEPENDENCY_01}
        fi
        if [ ! -z "${DEPENDENCY_02}" ]; then
            dnf install -y --skip-broken ${DEPENDENCY_02} || yum install -y --skip-broken ${DEPENDENCY_02}
        fi
        ################
    elif [ "${LINUX_DISTRO}" = "openwrt" ]; then
        #opkg update
        opkg install ${DEPENDENCY_01}
        opkg install ${DEPENDENCY_02}
        ################
    elif [ "${LINUX_DISTRO}" = "gentoo" ]; then
        emerge -vk ${DEPENDENCY_01}
        emerge -vk ${DEPENDENCY_02}
        ################
    elif [ "${LINUX_DISTRO}" = "suse" ]; then
        zypper in -y ${DEPENDENCY_01}
        zypper in -y ${DEPENDENCY_02}
        ################
    elif [ "${LINUX_DISTRO}" = "void" ]; then
        xbps-install -S -y ${DEPENDENCY_01}
        xbps-install -S -y ${DEPENDENCY_02}
        ################
    elif [ "${LINUX_DISTRO}" = "slackware" ]; then
        slackpkg update
        slackpkg install ${DEPENDENCY_01}
        slackpkg install ${DEPENDENCY_02}
        #########################
    else
        apt update
        apt install -y ${DEPENDENCY_01} || port install ${DEPENDENCY_01} || guix package -i ${DEPENDENCY_01} || pkg install ${DEPENDENCY_01} || pkg_add ${DEPENDENCY_01} || pkgutil -i ${DEPENDENCY_01}
    fi
}
######################
tmoe_file_manager() {
    #START_DIR="/root"
    #FILE_EXT_01='tar.gz'
    #FILE_EXT_02='tar.xz'
    TMOE_TITLE="${FILE_EXT_01} & ${FILE_EXT_02} 文件选择Tmoe-linux管理器"
    if [ -z ${IMPORTANT_TIPS} ]; then
        MENU_01="请使用方向键和回车键进行操作"
    else
        MENU_01=${IMPORTANT_TIPS}
    fi
    ########################################
    #-bak_rootfs.tar.xz
    ###################
    #tmoe_file
    ###############
    tmoe_file "$TMOE_TITLE" "$START_DIR"

    EXIT_STATUS=$?
    if [ ${EXIT_STATUS} -eq 0 ]; then
        if [ "${SELECTION}" == "" ]; then
            echo "检测到您取消了操作,User Pressed Esc with No File Selection"
        else
            whiptail --msgbox "文件属性 :  $(ls -lh ${FILE_NAME})\n路径 : ${FILE_PATH}" 0 0
            TMOE_FILE_ABSOLUTE_PATH="${CURRENT_DIR}/${SELECTION}"
            #uncompress_tar_file
        fi
    else
        echo "检测到您${RED}取消了${RESET}${YELLOW}操作${RESET}，没有文件${BLUE}被选择${RESET},with No File ${BLUE}Selected.${RESET}"
        #press_enter_to_return
    fi
}
###########
where_is_start_dir() {
    if [ -d "${HOME}/sd" ]; then
        START_DIR="${HOME}/sd/Download"
    elif [ -d "/sdcard" ]; then
        START_DIR='/sdcard/'
    else
        START_DIR="$(pwd)"
    fi
    tmoe_file_manager
}
###################################
#兩處調用到gnome software,故將其置於env
install_gnome_software() {
    DEPENDENCY_01="gnome-software"
    DEPENDENCY_02=""
    beta_features_quick_install
}
########################
random_neko() {
    case "$(($RANDOM % 3 + 1))" in
    1) neko_01_blue ;;
    2) neko_02_blue ;;
    3 | *) neko_03_blue ;;
    esac
}
###########
neko_ascii_env() {
    if [ ! $(command -v lolcat) ] && [ ! -e /usr/games/lolcat ]; then
        case ${LINUX_DISTRO} in
        debian)
            apt install -y lolcat
            ;;
        arch) pacman -Syu lolcat ;;
        esac
    fi
    if [ -e /usr/games/lolcat ]; then
        CATCAT='/usr/games/lolcat'
    elif [ "$(command -v lolcat)" ]; then
        CATCAT='lolcat'
    else
        CATCAT='cat'
    fi
}
##################
neko_01_blue() {
    neko_ascii_env
    printf "$BLUE"
    ${CATCAT} <<-'EndOFneko'
		                                        
		                            .:7E        
		            .iv7vrrrrr7uQBBBBBBB:       
		           v17::.........:SBBBUg        
		        vKLi.........:. .  vBQrQ        
		   sqMBBBr.......... :i. .  SQIX        
		   BBQBBr.:...:....:. 1:.....v. ..      
		    UBBB..:..:i.....i YK:: ..:   i:     
		     7Bg.... iv.....r.ijL7...i. .Lu     
		  IB: rb...i iui....rir :Si..:::ibr     
		  J7.  :r.is..vrL:..i7i  7U...Z7i..     
		  ...   7..I:.: 7v.ri.755P1. .S  ::     
		    :   r:.i5KEv:.:.  :.  ::..X..::     
		   7is. :v .sr::.         :: :2. ::     
		   2:.  .u: r.     ::::   r: ij: .r  :  
		   ..   .v1 .v.    .   .7Qr: Lqi .r. i  
		   :u   .iq: :PBEPjvviII5P7::5Du: .v    
		    .i  :iUr r:v::i:::::.:.:PPrD7: ii   
		    :v. iiSrr   :..   s i.  vPrvsr. r.  
		     ...:7sv:  ..PL  .Q.:.   IY717i .7. 
		      i7LUJv.   . .     .:   YI7bIr :ur 
		     Y rLXJL7.:jvi:i:::rvU:.7PP XQ. 7r7 
		    ir iJgL:uRB5UPjriirqKJ2PQMP :Yi17.v 
		         :   r. ..      .. .:i  ...     
	EndOFneko
    printf "$RESET"
}
##############
neko_02_blue() {
    neko_ascii_env
    printf "$BLUE"
    ${CATCAT} <<-'EndOFneko'
	       DL.                           
	       QBBBBBKv:rr77ri:.             
	       gBBQdY7::::..::i7vv.          
	       UBd. . .:.........rBBBQBBBB5  
	       Pu  :..r......i:....BBBQBBB:  
	       ri.i:.j:...:. i7... uBBZrd:   
	 :     7.:7.7U.:..r: Yr:.. iQ1:qU    
	.Qi   .7.ii.X7:...L.:qr:...iB7ZQ     
	 .27. :r.r:L7i::.7r:vri:...rr  .     
	  v   ::.Yrviri:7v7v: ::...i.   i    
	      r:ir: r.iiiir..:7r...r   :P.2Y 
	      v:vi::.      :  ::. .qI7U1U :1 
	Qr    7.7.         :.i::. :Di:. i .v:
	v7..  s.r7.   ...   .:7i: rDi...r .. 
	 vi: .7.iDBBr  .r   .:.7. rPr:..r    
	 i   :virZBgi  :vrYJ1vYY .ruY:..i    
	     YrivEv. 7BBRBqj21I7 .77J:.:.PQ  
	    .1r:q.   rB52SKrj.:i i5isi.:i :.r
	    YvrY7    r.  . ru :: PIrj7.:r..v 
	   rSviYI..iuU .:.:i:.7.KPPiSr.:vr   
	  .u:Y:JQMSsJUv...   .rDE1P71:.7X7   
	  5  Ivr:QJ7JYvi....ir1dq vYv.7L.Y   
	  S  7Z  Qvr:.iK55SqS1PX  Xq7u2 :7   
	         .            i   7          
EndOFneko
    printf "$RESET"
}
###########
neko_03_blue() {
    neko_ascii_env
    printf "$BLUE"
    ${CATCAT} <<-'EndOFneko'
                     .::::..                
          ::::rrr7QQJi::i:iirijQBBBQB.      
          BBQBBBQBP. ......:::..1BBBB       
          .BuPBBBX  .........r.  vBQL  :Y.  
           rd:iQQ  ..........7L   MB    rr  
            7biLX .::.:....:.:q.  ri    .   
             JX1: .r:.r....i.r::...:.  gi5  
             ..vr .7: 7:. :ii:  v.:iv :BQg  
             : r:  7r:i7i::ri:DBr..2S       
          i.:r:. .i:XBBK...  :BP ::jr   .7. 
          r  i....ir r7.         r.J:   u.  
         :..X: .. .v:           .:.Ji       
        i. ..i .. .u:.     .   77: si   1Q  
       ::.. .r .. :P7.r7r..:iLQQJ: rv   ..  
      7  iK::r  . ii7r LJLrL1r7DPi iJ     r 
        .  ::.:   .  ri 5DZDBg7JR7.:r:   i. 
       .Pi r..r7:     i.:XBRJBY:uU.ii:.  .  
       QB rJ.:rvDE: .. ri uv . iir.7j r7.   
      iBg ::.7251QZ. . :.      irr:Iu: r.   
       QB  .:5.71Si..........  .sr7ivi:U    
       7BJ .7: i2. ........:..  sJ7Lvr7s    
        jBBdD. :. ........:r... YB  Bi      
           :7j1.                 :  :       
EndOFneko
    printf "$RESET"
}
############
modify_xsdl_conf() {
    source ${TMOE_TOOL_DIR}/gui/gui.sh -x
}
########
install_virtual_box() {
    source ${TMOE_TOOL_DIR}/virtualization/vbox.sh
}
#############
wine_menu() {
    source ${TMOE_TOOL_DIR}/virtualization/wine32.sh
}
###########
install_anbox() {
    source ${TMOE_TOOL_DIR}/virtualization/anbox.sh
}
###########
install_browser() {
    source ${TMOE_TOOL_DIR}/app/browser.sh
}
###########
explore_debian_opt_repo() {
    source ${TMOE_TOOL_DIR}/sources/debian-opt.sh
}
#################
install_filebrowser() {
    source ${TMOE_TOOL_DIR}/webserver/filebrowser.sh
}
##########
install_nginx_webdav() {
    source ${TMOE_TOOL_DIR}/webserver/nginx-webdav.sh
}
##########
add_debian_opt_gpg_key() {
    cd /etc/apt/trusted.gpg.d
    if [ ! -e "bintray-public.key.asc" ]; then
        aria2c --allow-overwrite=true -o bintray-public.key.asc 'https://bintray.com/user/downloadSubjectPublicKey?username=bintray'
        chmod a+r bintray-public.key.asc
    fi
    apt-key add bintray-public.key.asc
    echo -e "deb ${OPT_URL_01} buster main\n#deb ${OPT_URL_02} buster main" >${OPT_REPO_LIST}
    apt update
}
###########

install_container_and_virtual_machine() {
    source ${TMOE_TOOL_DIR}/virtualization/qemu-system.sh -m
}
#############
tmoe_education_app_menu() {
    source ${TMOE_TOOL_DIR}/app/education.sh
}
###########
install_pinyin_input_method() {
    source ${TMOE_TOOL_DIR}/app/input-method.sh
}
###########
network_manager_tui() {
    source ${TMOE_TOOL_DIR}/system/network.sh
}
##########
tmoe_system_app_menu() {
    source ${TMOE_TOOL_DIR}/system/sys-menu.sh
}
##########
where_is_tmoe_file_dir() {
    CURRENT_QEMU_ISO_FILENAME="$(echo ${CURRENT_QEMU_ISO} | awk -F '/' '{print $NF}')"
    if [ ! -z "${CURRENT_QEMU_ISO}" ]; then
        CURRENT_QEMU_ISO_FILEPATH="$(echo ${CURRENT_QEMU_ISO} | sed "s@${CURRENT_QEMU_ISO_FILENAME}@@")"
    fi

    if [ -d "${CURRENT_QEMU_ISO_FILEPATH}" ]; then
        START_DIR="${CURRENT_QEMU_ISO_FILEPATH}"
        tmoe_file_manager
    else
        where_is_start_dir
    fi
}
##############
uncompress_tar_gz_file() {
    echo '正在解压中...'
    if [ $(command -v pv) ]; then
        pv ${DOWNLOAD_FILE_NAME} | tar -pzx
    else
        tar -zpxvf ${DOWNLOAD_FILE_NAME}
    fi
}
###################
download_deb_comman_model_02() {
    cd /tmp/
    THE_LATEST_DEB_LINK="${REPO_URL}${THE_LATEST_DEB_VERSION}"
    echo ${THE_LATEST_DEB_LINK}
    aria2c --allow-overwrite=true -s 5 -x 5 -k 1M -o "${THE_LATEST_DEB_VERSION}" "${THE_LATEST_DEB_LINK}"
    apt show ./${THE_LATEST_DEB_VERSION}
    apt install -y ./${THE_LATEST_DEB_VERSION}
    rm -fv ${THE_LATEST_DEB_VERSION}
}
#########################
grep_deb_comman_model_02() {
    THE_LATEST_DEB_VERSION="$(curl -L ${REPO_URL} | grep '.deb' | grep "${GREP_NAME_01}" | grep "${GREP_NAME_02}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)"
    download_deb_comman_model_02
}
###################
grep_deb_comman_model_01() {
    THE_LATEST_DEB_VERSION="$(curl -L ${REPO_URL} | grep '.deb' | grep "${GREP_NAME}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)"
    download_deb_comman_model_02
}
###################
tmoe_debian_add_ubuntu_ppa_source() {
    non_debian_function
    if [ ! $(command -v add-apt-repository) ]; then
        apt update
        apt install -y software-properties-common
    fi
    TARGET=$(whiptail --inputbox "请输入ppa软件源,以ppa开头,格式为ppa:xxx/xxx\nPlease type the ppa source name,the format is ppa:xx/xx" 0 50 --title "ppa:xxx/xxx" 3>&1 1>&2 2>&3)
    if [ "$?" != "0" ]; then
        tmoe_sources_list_manager
    elif [ -z "${TARGET}" ]; then
        echo "请输入有效的名称"
        echo "Please enter a valid name."
    else
        add_ubuntu_ppa_source
    fi
}
####################
add_ubuntu_ppa_source() {
    if [ "$(echo ${TARGET} | grep 'sudo add-apt-repository')" ]; then
        TARGET="$(echo ${TARGET} | sed 's@sudo add-apt-repository@@')"
    elif [ "$(echo ${TARGET} | grep 'add-apt-repository ')" ]; then
        TARGET="$(echo ${TARGET} | sed 's@add-apt-repository @@')"
    fi
    add-apt-repository ${TARGET}
    if [ "$?" != "0" ]; then
        tmoe_sources_list_manager
    fi
    DEV_TEAM_NAME=$(echo ${TARGET} | cut -d '/' -f 1 | cut -d ':' -f 2)
    PPA_SOFTWARE_NAME=$(echo ${TARGET} | cut -d ':' -f 2 | cut -d '/' -f 2)
    if [ "${DEBIAN_DISTRO}" != 'ubuntu' ]; then
        get_ubuntu_ppa_gpg_key
    fi
    modify_ubuntu_sources_list_d_code
    apt update
    echo "添加软件源列表完成，是否需要执行${GREEN}apt install ${PPA_SOFTWARE_NAME}${RESET}"
    do_you_want_to_continue
    apt install ${PPA_SOFTWARE_NAME}
}
###########
get_ubuntu_ppa_gpg_key() {
    DESCRIPTION_PAGE="https://launchpad.net/~${DEV_TEAM_NAME}/+archive/ubuntu/${PPA_SOFTWARE_NAME}"
    cd /tmp
    aria2c --allow-overwrite=true -o .ubuntu_ppa_tmoe_cache ${DESCRIPTION_PAGE}
    FALSE_FINGERPRINT_LINE=$(cat .ubuntu_ppa_tmoe_cache | grep -n 'Fingerprint:' | awk '{print $1}' | cut -d ':' -f 1)
    TRUE_FINGERPRINT_LINE=$((${FALSE_FINGERPRINT_LINE} + 1))
    PPA_GPG_KEY=$(cat .ubuntu_ppa_tmoe_cache | sed -n ${TRUE_FINGERPRINT_LINE}p | cut -d '<' -f 2 | cut -d '>' -f 2)
    rm -f .ubuntu_ppa_tmoe_cache
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com ${PPA_GPG_KEY}
    #press_enter_to_return
    #tmoe_sources_list_manager
}
###################
check_ubuntu_ppa_list() {
    cd /etc/apt/sources.list.d
    GREP_NAME="${DEV_TEAM_NAME}-ubuntu-${PPA_SOFTWARE_NAME}"
    PPA_LIST_FILE=$(ls ${GREP_NAME}-* | head -n 1)
    CURRENT_UBUNTU_CODE=$(cat ${PPA_LIST_FILE} | grep -v '^#' | awk '{print $3}' | head -n 1)
}
#################
modify_ubuntu_sources_list_d_code() {
    check_ubuntu_ppa_list
    if [ "${DEBIAN_DISTRO}" = 'ubuntu' ] || grep -Eq 'sid|testing' /etc/issue; then
        TARGET_BLANK_CODE="${CURRENT_UBUNTU_CODE}"
    else
        TARGET_BLANK_CODE="bionic"
    fi

    TARGET_CODE=$(whiptail --inputbox "请输入您当前使用的debian系统对应的ubuntu版本代号,例如focal\n当前ppa软件源的ubuntu代号为${CURRENT_UBUNTU_CODE}\n若取消则不修改,若留空则设定为${TARGET_BLANK_CODE}\nPlease type the ubuntu code name.\nFor example,buster corresponds to bionic." 0 50 --title "Ubuntu code(groovy,focal,etc.)" 3>&1 1>&2 2>&3)
    if [ "$?" != "0" ]; then
        TARGET_CODE="${CURRENT_UBUNTU_CODE}"
    elif [ -z "${TARGET_CODE}" ]; then
        TARGET_CODE=${TARGET_BLANK_CODE}
    fi

    if [ ${TARGET_CODE} = ${CURRENT_UBUNTU_CODE} ]; then
        echo "您没有修改ubuntu code，当前使用Ubuntu ${TARGET_CODE}的ppa软件源"
    else
        sed -i "s@ ${CURRENT_UBUNTU_CODE}@ ${TARGET_CODE}@g" ${PPA_LIST_FILE}
        echo "已将${CURRENT_UBUNTU_CODE}修改为${TARGET_CODE},若更新错误，则请手动修改$(pwd)/${PPA_LIST_FILE}"
    fi
}
###################
fix_vnc_dbus_launch() {
    source ${TMOE_TOOL_DIR}/gui/gui.sh --fix-dbus
}
#################
which_vscode_edition() {
    source ${TMOE_TOOL_DIR}/code/vscode.sh
}
#################
#吾欲将其分离，立为独项
tmoe_aria2_manager() {
    bash ${TMOE_TOOL_DIR}/downloader/aria2.sh
}
#############
install_gnome_system_monitor() {
    DEPENDENCY_01=''
    DEPENDENCY_02="gnome-system-monitor"
    beta_features_quick_install
}
###############
install_typora() {
    DEPENDENCY_01="typora"
    DEPENDENCY_02=""
    #NON_DEBIAN='true'
    non_debian_function
    beta_features_quick_install
    cd /tmp
    GREP_NAME='typora'
    if [ "${ARCH_TYPE}" = "amd64" ]; then
        LATEST_DEB_REPO='http://mirrors.ustc.edu.cn/debiancn/debiancn/pool/main/t/typora/'
        download_debian_cn_repo_deb_file_model_01
        #aria2c --allow-overwrite=true -s 5 -x 5 -k 1M -o 'typora.deb' 'http://mirrors.ustc.edu.cn/debiancn/debiancn/pool/main/t/typora/typora_0.9.67-1_amd64.deb'
    elif [ "${ARCH_TYPE}" = "i386" ]; then
        LATEST_DEB_REPO='https://mirrors.tuna.tsinghua.edu.cn/deepin/pool/non-free/t/typora/'
        download_tuna_repo_deb_file_model_03
        #aria2c --allow-overwrite=true -s 5 -x 5 -k 1M -o 'typora.deb' 'https://mirrors.tuna.tsinghua.edu.cn/deepin/pool/non-free/t/typora/typora_0.9.22-1_i386.deb'
    else
        arch_does_not_support
    fi
    #apt show ./typora.deb
    #apt install -y ./typora.deb
    #rm -vf ./typora.deb
    beta_features_install_completed
}
################
chmod_4755_chrome_sandbox() {
    SANDBOX_FILE='/opt/electron/chrome-sandbox'
    chmod 4755 ${SANDBOX_FILE}
}
##############
download_the_latest_electron() {
    case ${LINUX_DISTRO} in
    debian)
        install_gpg
        if [ ! -e "${OPT_REPO_LIST}" ]; then
            add_debian_opt_gpg_key
        fi
        DEPENDENCY_01=''
        DEPENDENCY_02='electron'
        beta_features_quick_install
        ;;
    *)
        latest_electron
        download_electron
        if [ ! -e "/usr/bin/electron" ]; then
            ln -sf /opt/electron/electron /usr/bin/
        fi
        ;;
    esac
    chmod_4755_chrome_sandbox
    electron -v --no-sandbox | head -n 1 >${TMOE_LINUX_DIR}/electron_version.txt
}
##########
fix_fedora_electron_libxssl() {
    case ${LINUX_DISTRO} in
    redhat) dnf install -y libXScrnSaver || yum install -y libXScrnSaver ;;
    esac
}
##########
check_electron() {
    if [ ! -e "/opt/electron/electron" ]; then
        mkdir -p /opt
        fix_fedora_electron_libxssl
        download_the_latest_electron
    fi
    if [ ! $(command -v electron) ]; then
        chmod +x /opt/electron/electron
        ln -sf /opt/electron/electron /usr/bin
    fi
}
##########
install_electron_v8() {
    #v8不要创建soft link
    electron_v8_env
    if [ ! -e "${DOWNLOAD_PATH}/electron" ]; then
        fix_fedora_electron_libxssl
        download_electron
        chmod 4755 ${DOWNLOAD_PATH}/chrome-sandbox
    fi
}
##############
tenvideo_env() {
    DEPENDENCY_02='tenvideo-universal'
    TENTVIDEO_OPT='/opt/Tenvideo_universal'
    TENVIDEO_LNK="${APPS_LNK_DIR}/TencentVideo.desktop"
    TENVIDEO_GIT='https://gitee.com/ak2/tenvideo.git'
    TENVIDEO_FOLDER='.TENCENT_VIDEO_TMOE_TMEP_FOLDER'
    if [ -e "${TENTVIDEO_OPT}" ]; then
        echo "检测到${YELLOW}您已安装${RESET} ${GREEN}${DEPENDENCY_02} ${RESET}"
        echo "如需${RED}卸载${RESET}，请手动输${RED}rm -rv${RESET} ${BLUE}${TENTVIDEO_OPT} ${TENVIDEO_LNK}${RESET}"
        echo "请问您是否需要重装？"
        echo "Do you want to reinstall it?"
        do_you_want_to_continue
    fi
}
########
aria2c_download_normal_file_s3() {
    echo ${YELLOW}${DOWNLOAD_FILE_URL}${RESET}
    cd ${DOWNLOAD_PATH}
    #aria2c --allow-overwrite=true -s 3 -x 3 -k 1M "${DOWNLOAD_FILE_URL}"
    #此处用wget会自动转义url
    wget "${DOWNLOAD_FILE_URL}"
}
######################
aria2c_download_file_00() {
    if [ -z "${DOWNLOAD_PATH}" ]; then
        cd ~
    else
        if [ ! -e "${DOWNLOAD_PATH}" ]; then
            mkdir -p ${DOWNLOAD_PATH}
        fi
        cd ${DOWNLOAD_PATH}
    fi
}
###############
aria2c_download_file() {
    echo "${YELLOW}${THE_LATEST_ISO_LINK}${RESET}"
    do_you_want_to_continue
    aria2c_download_file_00
    aria2c --allow-overwrite=true -s 5 -x 5 -k 1M "${THE_LATEST_ISO_LINK}"
}
############
aria2c_download_file_no_confirm() {
    echo "${YELLOW}${ELECTRON_FILE_URL}${RESET}"
    aria2c_download_file_00
    aria2c --allow-overwrite=true -s 5 -x 5 -k 1M "${ELECTRON_FILE_URL}"
}
############
extract_electron() {
    if [ ! $(command -v unzip) ]; then
        ${TMOE_INSTALLATON_COMMAND} unzip
    fi
    unzip ${ELECTRON_ZIP_FILE}
    rm -fv ${ELECTRON_ZIP_FILE}
    chmod +x electron
}
#########
latest_electron() {
    ELECTRON_VERSION=$(curl -Lv "${ELECTRON_MIRROR_STATION}" | cut -d '=' -f 3 | cut -d '"' -f 2 | grep -E '^1|^2^|^3|^4|^5|^6|^7|^8|^9' | grep -Ev '^v|^1\.|^2\.|^3\.|^4\.|^5\.|^6\.|^7\.|^8\.' | tail -n 1 | cut -d '/' -f 1)
    DOWNLOAD_PATH="/opt/electron"
}
###########
download_electron() {
    case ${ARCH_TYPE} in
    amd64) ARCH_TYPE_02='x64' ;;
    arm64) ARCH_TYPE_02="${ARCH_TYPE}" ;;
    armhf) ARCH_TYPE_02='armv7l' ;;
    i386) ARCH_TYPE_02='ia32' ;;
    *) arch_does_not_support ;;
    esac
    ELECTRON_ZIP_FILE="electron-v${ELECTRON_VERSION}-linux-${ARCH_TYPE_02}.zip"
    ELECTRON_FILE_URL="${ELECTRON_MIRROR_STATION}/${ELECTRON_VERSION}/${ELECTRON_ZIP_FILE}"
    aria2c_download_file_no_confirm
    extract_electron
}
###########
electron_v8_env() {
    ELECTRON_VERSION='8.5.0'
    DOWNLOAD_PATH="/opt/electron-v8"
}
#########
extract_deb_file_01() {
    case "${BUSYBOX_AR}" in
    true) busybox ar xv ${THE_LATEST_DEB_FILE} ;;
    *) ar xv ${THE_LATEST_DEB_FILE} ;;
    esac
    if [ -e "data.tar.xz" ]; then
        DEB_FILE_TYPE='tar.xz'
    elif [ -e "data.tar.gz" ]; then
        DEB_FILE_TYPE='tar.gz'
    else
        DEB_FILE_TYPE='tar'
    fi
}
###########
extract_deb_file_02() {
    cd /
    case "${DEB_FILE_TYPE}" in
    tar.xz) tar -PpJxvf ${DOWNLOAD_PATH}/data.tar.xz ".${APPS_LNK_DIR}" ./opt ./usr/share/icons ;;
    tar.gz) tar -Ppzxvf ${DOWNLOAD_PATH}/data.tar.gz ".${APPS_LNK_DIR}" ./opt ./usr/share/icons ;;
    *) tar -Ppxvf ${DOWNLOAD_PATH}/data.* ".${APPS_LNK_DIR}" ./opt ./usr/share/icons ;;
    esac
    cd /tmp
    rm -rv ${DOWNLOAD_PATH}
}
#############
install_gpg() {
    if [ ! $(command -v gpg) ]; then
        DEPENDENCY_01=""
        DEPENDENCY_02="gpg"
        beta_features_quick_install
    fi
}
#########
install_java() {
    if [ ! $(command -v java) ]; then
        DEPENDENCY_01=''
        case "${LINUX_DISTRO}" in
        arch)
            DEPENDENCY_01='jre-openjdk'
            DEPENDENCY_02='jdk-openjdk'
            ;;
        debian | "")
            DEPENDENCY_01='default-jre'
            DEPENDENCY_02='default-jdk'
            ;;
        alpine)
            DEPENDENCY_01='openjdk11-jre'
            DEPENDENCY_02='openjdk11-jdk'
            ;;
        void)
            DEPENDENCY_01='openjdk11'
            DEPENDENCY_02='openjdk11-bin'
            ;;
        redhat)
            case ${REDHAT_DISTRO} in
            fedora)
                DEPENDENCY_01='java-latest-openjdk'
                DEPENDENCY_02='java-latest-openjdk-devel'
                ;;
            *)
                #java-11-openjdk-devel
                DEPENDENCY_02=$(yum search openjdk-devel 2>&1 | grep Develop | head -n 1 | awk '{print $1}' | cut -d '.' -f 1)
                ;;
            esac
            ;;
        *)
            DEPENDENCY_01='openjdk'
            DEPENDENCY_02='java'
            ;;
        esac
        beta_features_quick_install
    fi

    case "${LINUX_DISTRO}" in
    debian)
        if [ ! -e "/usr/share/doc/default-jdk" ]; then
            DEPENDENCY_01=''
            DEPENDENCY_02='default-jdk'
            beta_features_quick_install
        fi
        ;;
    esac
}
#######
check_zenity() {
    if [ ! $(command -v zenity) ]; then
        DEPENDENCY_01='zenity'
        DEPENDENCY_02=''
        beta_features_quick_install
    fi
}
###########
add_debian_old_source() {
    case ${DEBIAN_DISTRO} in
    ubuntu) ;;
    *)
        if ! grep -q '^deb.*buster' /etc/apt/sources.list; then
            echo 'deb https://mirrors.huaweicloud.com/debian/ buster main' >>/etc/apt/sources.list.d/tmoe_old_debian_source.list
            apt update
        fi
        ;;
    esac
}
##########
del_debian_old_source() {
    DEBIAN_OLD_SOURCE='/etc/apt/sources.list.d/tmoe_old_debian_source.list'
    if [ -e "${DEBIAN_OLD_SOURCE}" ]; then
        rm -f ${DEBIAN_OLD_SOURCE}
        apt update
    fi
}
###############
tmoe_apt_update() {
    case ${LINUX_DISTRO} in
    arch | fedora) ;;
    *) ${TMOE_UPDATE_COMMAND} 2>/dev/null ;;
    esac
}
############
check_zstd() {
    if [ ! $(command -v unzstd) ]; then
        echo "正在安装相关依赖..."
        echo "${GREEN}${TMOE_INSTALLATON_COMMAND}${RESET} ${BLUE}zstd${RESET}"
        tmoe_apt_update
        ${TMOE_INSTALLATON_COMMAND} zstd
        echo "如需卸载，请手动输${TMOE_REMOVAL_COMMAND} zstd"
    fi
}
##############
cat_icon_img() {
    if [ -e "${ICON_FILE}" ]; then
        if [ $(command -v catimg) ]; then
            catimg "${ICON_FILE}"
        else
            random_neko
        fi
    else
        random_neko
    fi
}
##############
do_you_want_to_upgrade_it() {
    UPGRADE_TIPS="您是否需要更新${GREP_NAME}?"
    if [ -e /usr/games/lolcat ]; then
        echo ${UPGRADE_TIPS} | /usr/games/lolcat -a -d 7
    elif [ "$(command -v lolcat)" ]; then
        echo ${UPGRADE_TIPS} | lolcat
    else
        echo ${UPGRADE_TIPS}
    fi
    do_you_want_to_continue
}
##################
do_you_want_to_upgrade_it_02() {
    UPGRADE_TIPS="您是否需要更新${DEPENDENCY_01}?"
    if [ -e /usr/games/lolcat ]; then
        echo ${UPGRADE_TIPS} | /usr/games/lolcat
    elif [ "$(command -v lolcat)" ]; then
        echo ${UPGRADE_TIPS} | lolcat
    else
        echo ${UPGRADE_TIPS}
    fi
}
##################
check_deb_version() {
    cat <<-ENDofTable
		╔═══╦══════════╦═══════════════════╦════════════════════
		║   ║          ║                   ║                    
		║   ║ software ║    ✨最新版本     ║   本地版本 🎪
		║   ║          ║  Latest version   ║  Local version     
		║---║----------║-------------------║--------------------
		║ 1 ║${GREP_NAME}                    ${LOCAL_OPT_APP_VERSION} 
		║   ║          ║${THE_LATEST_DEB_VERSION}

	ENDofTable
    echo "最新版链接为${BLUE}${THE_LATEST_DEB_URL}${RESET}"
}
################
install_tmoe_app_01() {
    random_neko
    echo "正在检测版本更新信息..."
    echo "若安装失败，则请前往官网手动下载安装。"
    echo "url: ${YELLOW}${OFFICIAL_URL}${RESET}"
    case ${DEPENDENCY_01} in
    vivaldi-stable | vivaldi | vivaldi-arm64) install_vivaldi_browser ;;
    browser360-cn-stable | browser360) install_360_browser ;;
    yozo-office) install_yozo_office ;;
    freeoffice) install_free_office ;;
    mitalk) install_mitalk ;;
    xunlei-bin | com.xunlei.download) install_thunder_bin ;;
    esac
}
###########
remove_tmoe_app_01() {
    echo "${RED}rm -v${RESET} ${BLUE}${LOCAL_APP_VERSION_TXT}${RESET};${RED}${TMOE_REMOVAL_COMMAND}${RESET} ${BLUE}${DEPENDENCY_01} ${DEPENDENCY_02}${RESET}"
    do_you_want_to_continue
    case ${GREP_NAME} in
    com.xunlei.download) remove_thunder_opt_app ;;
    *)
        rm -v ${LOCAL_APP_VERSION_TXT}
        ${TMOE_REMOVAL_COMMAND} ${DEPENDENCY_01} ${DEPENDENCY_02}
        ;;
    esac
}
###########
tmoe_app_menu_01() {
    check_opt_app_version
    #check_download_path
    RETURN_TO_WHERE='tmoe_app_menu_01'
    SOFTWARE=$(
        whiptail --title "${GREP_NAME}" --menu \
            "您想要对${GREP_NAME}小可爱做什么？" 0 50 0 \
            "1" "install/upgrade(安装/更新)" \
            "2" "remove(卸载${GREP_NAME})" \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            3>&1 1>&2 2>&3
    )
    case "${SOFTWARE}" in
    0 | "") ${RETURN_TO_MENU} ;;
    1) install_tmoe_app_01 ;;
    2) remove_tmoe_app_01 ;;
    esac
    #############################
    press_enter_to_return
    tmoe_app_menu_01
}
###########
lolcat_tmoe_tips_01() {
    if [ -e /usr/games/lolcat ]; then
        echo ${TMOE_TIPS_01} | /usr/games/lolcat -a -d 9
    elif [ "$(command -v lolcat)" ]; then
        echo ${TMOE_TIPS_01} | lolcat
    else
        echo ${TMOE_TIPS_01}
    fi
    case ${LINUX_DISTRO} in
    debian) ;;
    arch) echo "检测到您使用的是arch系发行版，将通过AUR来安装软件包" ;;
    redhat) echo "检测到您使用的是红帽系发行版，将为您下载rpm软件包" ;;
    esac
    #do_you_want_to_upgrade_it_02
    echo "您是否需要${GREEN}更新${RESET}${BLUE}${DEPENDENCY_01}${RESET}?"
}
###################
download_and_install_deb() {
    do_you_want_to_upgrade_it_02
    do_you_want_to_continue
    cd /tmp
    case ${LINUX_DISTRO} in
    debian | redhat) aria2c --allow-overwrite=true -s 5 -x 5 -k 1M -o "${THE_LATEST_DEB_FILE}" "${THE_LATEST_DEB_URL}" ;;
    esac
    case ${LINUX_DISTRO} in
    debian)
        apt show ./${THE_LATEST_DEB_FILE}
        apt install -y ./${THE_LATEST_DEB_FILE}
        ;;
    redhat) rpm -ivh ./${THE_LATEST_DEB_FILE} ;;
    arch | *) beta_features_quick_install ;;
    esac
    rm -v ./${THE_LATEST_DEB_FILE} 2>/dev/null
    echo ${THE_LATEST_DEB_VERSION} >${LOCAL_APP_VERSION_TXT}
    case ${LINUX_DISTRO} in
    arch) ;;
    *) beta_features_install_completed ;;
    esac
}
############
this_app_may_non_support_running_on_proot() {
    case ${TMOE_PROOT} in
    false) ;;
    true | no)
        echo "本软件可能不支持在proot容器环境中运行"
        echo "This application may not support running on a proot container."
        do_you_want_to_continue
        ;;
    esac
}
#############
download_and_cat_icon_img() {
    if [ ! -e "${TMOE_ICON_DIR}/${ICON_FILE_NAME}" ]; then
        mkdir -p ${TMOE_ICON_DIR}
        aria2c -d ${TMOE_ICON_DIR} -o ${ICON_FILE_NAME} ${ICON_URL}
    fi
    if [ $(command -v catimg) ]; then
        catimg "${TMOE_ICON_DIR}/${ICON_FILE_NAME}" 2>/dev/null
    fi
}
###########
restore_debian_gnu_libxcb_so() {
    case ${TMOE_PROOT} in
    true | false)
        case ${LINUX_DISTRO} in
        debian)
            GNU_LIBXCB="/usr/lib/$(uname -m)-linux-gnu/libxcb.so.1.1.0"
            ORIGINAL_LIBXCB_FILE="${TMOE_LINUX_DIR}/libxcb.so.1.1.0"
            if [ -e "${ORIGINAL_LIBXCB_FILE}" ]; then
                mv -f ${ORIGINAL_LIBXCB_FILE} ${GNU_LIBXCB}
            fi
            ;;
        esac
        ;;
    esac
}
###########
gnu_linux_env_02
