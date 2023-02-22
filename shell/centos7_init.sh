#!/bin/bash

# 优化yum源
echo "优化yum源"
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache

# 调整文件打开数
echo "调整文件打开数"
echo "*       soft    nofile  65535" >> /etc/security/limits.conf
echo "*       hard    nofile  65535" >> /etc/security/limits.conf

# 关闭不必要的服务
echo "关闭不必要的服务"
systemctl stop postfix
systemctl disable postfix

# 关闭SELinux
echo "关闭SELinux"
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

# 调整系统内核参数
echo "调整系统内核参数"
cat << EOF >> /etc/sysctl.conf
# 禁用IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
# 禁用ICMP Redirect
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
# 启用SYN Cookie
net.ipv4.tcp_syncookies = 1
# 增加连接跟踪表大小
net.netfilter.nf_conntrack_max = 655350
EOF

#########
# 调整系统内核参数
echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_time = 300" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_tw_buckets = 36000" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 1024 65000" >> /etc/sysctl.conf
sysctl -p

# 防止洪水攻击
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 1024" >> /etc/sysctl.conf
echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syn_retries = 2" >> /etc/sysctl.conf
sysctl -p
#########

sysctl -p

# 防止洪水攻击
echo "防止洪水攻击"
firewall-cmd --add-rich-rule='rule protocol value="tcp" limit value="10/second" accept' --permanent
firewall-cmd --add-rich-rule='rule protocol value="udp" limit value="10/second" accept' --permanent
firewall-cmd --reload

# 优化SSH连接安全性
echo "优化SSH连接安全性"
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/^#UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config
systemctl restart sshd
