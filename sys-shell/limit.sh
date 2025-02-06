#!/bin/bash

# 颜色定义
Green="\033[36m"
Font="\033[0m"
Red="\033[31m"

# root权限检查
root_need() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${Red}错误:此脚本必须以根目录运行!${Font}"
        exit 1
    fi
}

# 检测 OpenVZ
ovz_no() {
    if [[ -d "/proc/vz" ]]; then
        echo -e "${Red}错误:您的VPS基于OpenVZ,不支持!${Font}"
        exit 1
    fi
}

# 查看最大可设置的文件描述符限制
get_max_nofile() {
    max_limit=$(cat /proc/sys/fs/file-max)
    echo -e "${Green}当前系统最大可设置的文件描述符限制为: $max_limit${Font}"
}

# 设置文件描述符限制
set_nofile_limit() {
    default_limit=65535
    echo -e "${Green}请输入需要设置的文件描述符限制（最小设置为 $default_limit，直接回车将使用默认值）${Font}"
    read -p "请输入文件描述符限制: " limit

    # 如果没有输入，使用默认值
    if [[ -z "$limit" ]]; then
        limit=$default_limit
    fi

    # 检查输入的最小值
    if [[ $limit -lt 65535 ]]; then
        echo -e "${Red}错误: 文件描述符限制的最小值为 65535！${Font}"
        exit 1
    fi

    # 更新 limits.conf
    echo "* soft nofile $limit" >> /etc/security/limits.conf
    echo "* hard nofile $limit" >> /etc/security/limits.conf

    echo -e "${Green}配置已更新！当前设置为：${Font}"
    echo -e "${Green}soft nofile: $limit${Font}"
    echo -e "${Green}hard nofile: $limit${Font}"
    echo -e "${Green}请重启系统或注销并重新登录以使更改生效。${Font}"
}

# 主菜单
main() {
    root_need
    ovz_no
    clear
    echo -e "———————————————————————————————————————"
    echo -e "${Green}Linux 文件描述符限制设置脚本${Font}"
    get_max_nofile  # 查看最大可设置的值
    set_nofile_limit  # 直接调用设置文件描述符限制的函数
}

main
