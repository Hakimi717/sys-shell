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

# 检查BBR状态
bbr_status=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')

# 展示当前参数
echo -e "${Green}当前TCP拥塞控制算法:${Font} $bbr_status"
echo -e "${Green}当前默认队列算法:${Font} $(sysctl net.core.default_qdisc | awk '{print $3}')"
echo -e "${Green}最大TCP缓冲区大小:${Font} $(sysctl net.ipv4.tcp_mem | awk '{print $1, $2, $3}')"

# 如果未启用BBR，则启用它
if [ "$bbr_status" != "bbr" ]; then
    echo -e "${Green}正在启用BBR...${Font}"
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    sysctl -p

    # 再次检查BBR状态
    bbr_status=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
    if [ "$bbr_status" == "bbr" ]; then
        echo -e "${Green}BBR已成功启用.${Font}"
    else
        echo -e "${Red}BBR启用失败，请检查配置.${Font}"
    fi
else
    echo -e "${Green}BBR已启用.${Font}"
fi
