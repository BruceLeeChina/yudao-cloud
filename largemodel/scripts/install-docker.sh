#!/bin/bash
# Ubuntu 自动安装 Docker 和 Docker Compose（支持离线/在线）
set -e

# 检查系统架构和版本
ARCH=$(dpkg --print-architecture)
UBUNTU_CODENAME=$(lsb_release -cs)
if ! [[ "$ARCH" =~ ^(amd64|arm64)$ ]]; then
    echo "错误：仅支持 amd64/arm64 架构，当前架构：$ARCH" >&2
    exit 1
fi

# 清理旧版本（避免冲突）
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove -y "$pkg" >/dev/null 2>&1 || true
done

# 安装依赖
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg software-properties-common

# 添加 Docker 官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 添加 Docker 仓库
echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# 安装 Docker 引擎
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
sudo systemctl enable --now docker

# 安装 Docker Compose（最新稳定版）
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-linux-$ARCH" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# 配置用户权限（避免每次sudo）
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker "$USER"
newgrp docker <<EONG
echo "用户已加入 docker 组"
EONG

# 配置镜像加速器（国内环境）
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://registry.docker-cn.com", "https://mirror.baidubce.com"],
  "storage-driver": "overlay2"
}
EOF
sudo systemctl restart docker

# 验证安装
echo -e "\n✅ 安装完成！验证信息："
docker --version
docker-compose --version
echo "运行测试容器：sudo docker run --rm hello-world"