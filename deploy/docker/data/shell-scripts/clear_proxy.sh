#!/bin/bash

# ======================================
# Docker Proxy Cleanup Script
# 彻底清除所有Docker代理配置
# ======================================

# 清理 systemd 服务代理配置
echo "🧹 清理 systemd 服务代理配置..."
DOCKER_PROXY_DIR="/etc/systemd/system/docker.service.d"
DOCKER_PROXY_CONF="$DOCKER_PROXY_DIR/http-proxy.conf"

if [ -f "$DOCKER_PROXY_CONF" ]; then
    echo "🗑️ 删除代理配置文件: $DOCKER_PROXY_CONF"
    sudo rm -f "$DOCKER_PROXY_CONF"

    # 清理空目录
    if [ -z "$(ls -A $DOCKER_PROXY_DIR)" ]; then
        echo "🗑️ 删除空目录: $DOCKER_PROXY_DIR"
        sudo rmdir "$DOCKER_PROXY_DIR"
    fi
else
    echo "ℹ️ 未找到 systemd 代理配置文件"
fi

# 清理 daemon.json 中的代理配置
echo "🧹 清理 Docker daemon.json 代理配置..."
DOCKER_BUILDKIT_CONF="/etc/docker/daemon.json"

if [ -f "$DOCKER_BUILDKIT_CONF" ]; then
    echo "🔄 从 daemon.json 中移除代理配置..."

    # 使用 jq 安全移除代理配置
    if command -v jq &> /dev/null; then
        sudo jq 'del(.proxies)' "$DOCKER_BUILDKIT_CONF" | sudo tee "$DOCKER_BUILDKIT_CONF.tmp" > /dev/null
        sudo mv "$DOCKER_BUILDKIT_CONF.tmp" "$DOCKER_BUILDKIT_CONF"

        # 检查文件是否为空
        if [ "$(jq -e 'length == 0' $DOCKER_BUILDKIT_CONF)" == "true" ]; then
            echo "🗑️ daemon.json 为空，删除文件"
            sudo rm -f "$DOCKER_BUILDKIT_CONF"
        fi
    else
        echo "⚠️ jq 工具未安装，请手动编辑 $DOCKER_BUILDKIT_CONF 删除 proxies 部分"
    fi
else
    echo "ℹ️ 未找到 daemon.json 文件"
fi

# 清理用户级 Docker 代理配置
echo "🧹 清理用户级 Docker 代理配置..."
USER_CONFIG="$HOME/.docker/config.json"

if [ -f "$USER_CONFIG" ]; then
    echo "🔄 从用户配置中移除代理..."

    if command -v jq &> /dev/null; then
        jq 'del(.proxies)' "$USER_CONFIG" | tee "$USER_CONFIG.tmp" > /dev/null
        mv "$USER_CONFIG.tmp" "$USER_CONFIG"
    else
        echo "⚠️ jq 工具未安装，请手动编辑 $USER_CONFIG 删除 proxies 部分"
    fi
fi

# 重启 Docker 服务
echo "🔄 重启 Docker 服务..."
sudo systemctl daemon-reload
sudo systemctl restart docker

# 验证清理结果
echo "✅ 代理清理完成！验证结果："
echo "=============================="

# 检查 systemd 代理配置
echo "1. systemd 代理配置状态:"
if [ -f "$DOCKER_PROXY_CONF" ]; then
    echo "   ⚠️ 仍存在代理文件: $DOCKER_PROXY_CONF"
else
    echo "   ✅ 未检测到代理配置"
fi

# 检查 Docker 服务代理状态
echo "2. Docker 服务代理变量:"
sudo systemctl show docker --property Environment | grep -i proxy || echo "   ✅ 未检测到代理变量"

# 测试直连访问
echo "3. 网络连接测试:"
if sudo docker run --rm curlimages/curl -s -I https://www.google.com >/dev/null; then
    echo "   🌐 直连访问测试成功！"
else
    echo "   ❌ 直连访问测试失败，请检查网络"
fi

echo "=============================="
echo "🎉 Docker 代理已彻底清理完毕！"