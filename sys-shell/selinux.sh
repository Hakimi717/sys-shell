#!/bin/bash

# 颜色定义
Green="\033[32m"
Red="\033[31m"
Font="\033[0m"

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${Red}错误: 此脚本必须以root权限运行!${Font}"
    exit 1
fi

# 显示当前SELinux状态
current_status=$(getenforce)

# 开始菜单
echo -e "———————————————————————————————————————"
echo -e "${Green}SELinux 管理脚本${Font}"
echo -e "${Green}当前状态: ${Font}$current_status"
echo -e "${Green}1、开启SELinux${Font}"
echo -e "${Green}2、关闭SELinux${Font}"
echo -e "———————————————————————————————————————"

# 用户输入
while true; do
    read -p "请输入数字 [1-2]:" num
    case "$num" in
        1)
            echo -e "${Green}正在开启SELinux...${Font}"
            setenforce 1
            sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
            echo -e "${Green}SELinux已成功开启.${Font}"
            break
            ;;
        2)
            echo -e "${Green}正在关闭SELinux...${Font}"
            setenforce 0
            sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
            echo -e "${Green}SELinux已成功关闭.${Font}"
            break
            ;;
        *)
            echo -e "${Red}请输入正确的数字 [1-2]${Font}"
            ;;
    esac
done
