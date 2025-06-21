#!/bin/bash

# 检查root权限
if [ "$(id -u)" != "0" ]; then
   echo "此脚本需要以root权限运行！"
   exit 1
fi

echo "正在执行Ubuntu系统优化..."

# =================================================================
# 1. 关闭SELinux (Ubuntu默认未安装)
# =================================================================
echo "步骤1: 禁用SELinux"
if [ -f /etc/selinux/config ]; then
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    echo "SELinux已禁用，重启后生效"
else
    echo "未检测到SELinux，跳过"
fi

# =================================================================
# 2. 关闭防火墙
# =================================================================
echo "步骤2: 禁用防火墙"
systemctl stop ufw 2>/dev/null
systemctl disable ufw 2>/dev/null
echo "防火墙(ufw)已关闭"

# =================================================================
# 3. 修改文件数量限制
# =================================================================
echo "步骤3: 修改系统文件限制"

# 备份原文件
cp /etc/security/limits.conf /etc/security/limits.conf.bak

# 设置新限制
cat >> /etc/security/limits.conf <<EOF
* soft nofile 65535
* hard nofile 65535
* soft nproc  65535
* hard nproc  65535
root soft nofile unlimited
root hard nofile unlimited
EOF

# 修改系统级限制
echo "fs.file-max = 1000000" >> /etc/sysctl.conf
echo "fs.nr_open = 1000000" >> /etc/sysctl.conf

# 立即生效
sysctl -p >/dev/null

echo "文件限制已修改："
ulimit -n

# =================================================================
# 4. 修改用户进程限制 (可选)
# =================================================================
echo "步骤4: 修改用户进程限制"
if ! grep -q "session required pam_limits.so" /etc/pam.d/common-session; then
    echo "session required pam_limits.so" >> /etc/pam.d/common-session
fi

# =================================================================
# 完成
# =================================================================
echo "----------------------------------------------"
echo "优化完成！建议重启系统使所有更改生效。"
echo "验证命令:"
echo "  文件限制: ulimit -n"
echo "  防火墙状态: ufw status"
echo "  当前文件句柄: cat /proc/sys/fs/file-nr"
echo "----------------------------------------------"