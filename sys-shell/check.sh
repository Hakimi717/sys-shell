#!/bin/bash

# 颜色定义
Green="\033[32m"
Yellow="\033[33m"
Red="\033[31m"
Font="\033[0m"

# 获取当前时间
get_current_time() {
    date +"%Y-%m-%d %H:%M:%S"
}

# 获取内核版本
check_kernel() {
    echo -e "${Green}--------------- 系统内核版本 ---------------${Font}"
    kernel_version=$(uname -r)
    echo -e "${Green}内核版本: ${Font}$kernel_version"
}

# 获取操作系统版本
check_os_version() {
    echo -e "${Green}--------------- 操作系统版本 ---------------${Font}"
    os_version=$(lsb_release -a 2>/dev/null | grep 'Description' | cut -f2-)
    echo -e "${Green}操作系统: ${Font}$os_version"
}

# 获取时区
check_timezone() {
    echo -e "${Green}--------------- 时区设置 ---------------${Font}"
    timezone=$(timedatectl show --property=Timezone --value)
    echo -e "${Green}当前时区: ${Font}$timezone"
}

# 获取公网 IP
check_public_ip() {
    echo -e "${Green}--------------- 公网 IP ---------------${Font}"
    public_ip=$(curl -s ifconfig.me)
    echo -e "${Green}公网 IP: ${Font}$public_ip"
}

# 获取内网 IP
check_internal_ip() {
    echo -e "${Green}--------------- 内网 IP ---------------${Font}"
    internal_ip=$(hostname -I | awk '{print $1}')
    echo -e "${Green}内网 IP: ${Font}$internal_ip"
}

# 获取 IPv6 地址
check_ipv6() {
    echo -e "${Green}--------------- IPv6 地址 ---------------${Font}"
    ipv6=$(ip -6 addr show | grep -oP '(?<=inet6\s)[\da-f:]+')
    echo -e "${Green}IPv6 地址: ${Font}${ipv6:-未配置}"
}

# 获取镜像源
check_mirror() {
    echo -e "${Green}--------------- 镜像源 ---------------${Font}"
    if [[ -f /etc/apt/sources.list ]]; then
        echo -e "${Green}APT 镜像源:${Font}"
        cat /etc/apt/sources.list | grep -v '^#' | grep -v '^$'
    fi

    if [[ -f /etc/yum.repos.d/CentOS-Base.repo ]]; then
        echo -e "${Green}YUM 镜像源:${Font}"
        cat /etc/yum.repos.d/CentOS-Base.repo | grep -E '^[^#]' | grep 'baseurl'
    fi
}

# 获取 CPU 信息
check_cpu() {
    echo -e "${Green}--------------- CPU 信息 ---------------${Font}"
    cpu_info=$(lscpu | grep 'Model name' | awk -F: '{print $2}' | xargs)
    cpu_cores=$(lscpu | grep '^CPU\(s\):' | awk '{print $2}')
    echo -e "${Green}CPU型号: ${Font}$cpu_info"
    echo -e "${Green}CPU核数: ${Font}$cpu_cores"
}

# 获取内存信息
check_memory() {
    echo -e "${Green}--------------- 内存信息 ---------------${Font}"
    mem_total=$(free -m | awk '/Mem/{print $2}')
    echo -e "${Green}总内存: ${Font}${mem_total} MB"
}

# 获取磁盘信息
check_disk() {
    echo -e "${Green}--------------- 磁盘信息 ---------------${Font}"
    disk_info=$(df -h --total | grep 'total')
    echo -e "${Green}磁盘总大小: ${Font}${disk_info}"
}

# 检查系统负载
check_load() {
    echo -e "${Green}--------------- 系统负载 ---------------${Font}"
    load_average=$(uptime | awk '{print $8, $9, $10}')
    echo -e "${Green}负载平均值: ${Font}$load_average"
}

# 检查 Swap 状态
check_swap() {
    echo -e "${Green}--------------- Swap 状态 ---------------${Font}"
    if swapon --show=NAME | grep -q 'swap'; then
        swap_size=$(free -m | awk '/Swap/{print $2}')
        echo -e "${Green}Swap 已开启，大小: ${Font}${swap_size} MB"
    else
        echo -e "${Red}Swap 未开启${Font}"
    fi
}

# 检查 BBR 状态
check_bbr() {
    echo -e "${Green}--------------- BBR 状态 ---------------${Font}"
    bbr_status=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
    if [[ "$bbr_status" == "bbr" ]]; then
        echo -e "${Green}BBR 已开启${Font}"
    else
        echo -e "${Red}BBR 未开启${Font}"
    fi
}

# 检查常用系统优化参数
check_optimizations() {
    echo -e "${Green}--------------- 系统优化参数 ---------------${Font}"
    params=("net.ipv4.tcp_max_syn_backlog" "net.core.somaxconn" "vm.swappiness" "fs.file-max")
    for param in "${params[@]}"; do
        value=$(sysctl $param 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            echo -e "${Green}$param: ${Font}${value#*:}"
        else
            echo -e "${Red}$param: 未配置${Font}"
        fi
    done
}

# 检查系统运行时间
check_uptime() {
    echo -e "${Green}--------------- 系统运行时间 ---------------${Font}"
    uptime_info=$(uptime -p)
    echo -e "${Green}系统运行时间: ${Font}$uptime_info"
}

# 检查当前时间
check_current_time() {
    echo -e "${Green}--------------- 当前时间 ---------------${Font}"
    current_time=$(get_current_time)
    echo -e "${Green}当前时间: ${Font}$current_time"
}

# 获取结束时间
end_time=$(get_current_time)

# 主函数
main() {
    clear
    echo -e "${Green}=================== 系统配置检测脚本 ===================${Font}"

    check_current_time
    echo
    check_kernel
    echo
    check_os_version
    echo
    check_timezone
    echo
    check_public_ip
    echo
    check_internal_ip
    echo
    check_ipv6
    echo
    check_mirror
    echo
    check_cpu
    echo
    check_memory
    echo
    check_disk
    echo
    check_load
    echo
    check_swap
    echo
    check_bbr
    echo
    check_optimizations
    echo
    check_uptime

    echo -e "${Green}=========================================================${Font}"
    echo -e "${Green}脚本结束时间: ${Font}$end_time"
}

main
