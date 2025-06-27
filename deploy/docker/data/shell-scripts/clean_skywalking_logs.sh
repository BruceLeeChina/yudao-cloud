#!/bin/bash

# 创建日志清理脚本
sudo tee /usr/local/bin/clean_skywalking_logs.sh > /dev/null <<'EOF'
#!/bin/bash

# 配置参数
LOG_DIR="/opt/yudao/middleware/skywalking/skywalking-agent/logs"
MAX_AGE_HOURS=3  # 删除3小时前的日志
LOG_FILE="/var/log/skywalking_clean.log"

# 创建日志目录（如果不存在）
mkdir -p $(dirname "$LOG_FILE")
touch "$LOG_FILE"

# 记录开始时间
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始清理SkyWalking日志" >> "$LOG_FILE"

# 检查日志目录是否存在
if [ ! -d "$LOG_DIR" ]; then
    echo "错误：日志目录 $LOG_DIR 不存在" >> "$LOG_FILE"
    exit 1
fi

# 执行清理操作
find "$LOG_DIR" -type f -mmin +$((MAX_AGE_HOURS * 60)) -print -delete 2>&1 | tee -a "$LOG_FILE"

# 记录完成状态
FILE_COUNT=$(find "$LOG_DIR" -type f | wc -l)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 清理完成。当前剩余文件: $FILE_COUNT" >> "$LOG_FILE"
EOF

# 设置脚本权限
sudo chmod +x /usr/local/bin/clean_skywalking_logs.sh

# 创建系统服务（确保重启后自动运行）
sudo tee /etc/systemd/system/skywalking-clean.service > /dev/null <<EOF
[Unit]
Description=SkyWalking Log Cleaner Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/clean_skywalking_logs.sh

[Install]
WantedBy=multi-user.target
EOF

# 创建定时器
sudo tee /etc/systemd/system/skywalking-clean.timer > /dev/null <<EOF
[Unit]
Description=Run SkyWalking log cleaner every 3 hours

[Timer]
OnCalendar=*-*-* 0/3:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# 启用并启动服务
sudo systemctl daemon-reload
sudo systemctl enable skywalking-clean.timer
sudo systemctl start skywalking-clean.timer

# 创建日志轮转配置
sudo tee /etc/logrotate.d/skywalking-clean > /dev/null <<EOF
/var/log/skywalking_clean.log {
    weekly
    missingok
    rotate 4
    compress
    delaycompress
    notifempty
    create 0640 root root
}
EOF

# 验证设置
echo "安装完成！验证设置："
echo "1. 手动测试脚本: sudo /usr/local/bin/clean_skywalking_logs.sh"
echo "2. 查看执行日志: tail -f /var/log/skywalking_clean.log"
echo "3. 查看定时器状态: systemctl list-timers | grep skywalking"
echo "4. 下次执行时间: systemctl status skywalking-clean.timer"