# 设置Clash代理地址和端口
PROXY_HOST="192.168.56.1"
PROXY_PORT="7890"

# Docker代理配置文件路径
DOCKER_PROXY_DIR="/etc/systemd/system/docker.service.d"
DOCKER_PROXY_CONF="$DOCKER_PROXY_DIR/http-proxy.conf"

# 为Docker服务设置代理
echo "Configuring Docker proxy..."
sudo mkdir -p "$DOCKER_PROXY_DIR"
sudo bash -c "cat > $DOCKER_PROXY_CONF" << EOL
[Service]
Environment="HTTP_PROXY=http://$PROXY_HOST:$PROXY_PORT"
Environment="HTTPS_PROXY=http://$PROXY_HOST:$PROXY_PORT"
Environment="NO_PROXY=localhost,127.0.0.1"
EOL

# 重启Docker服务以应用代理设置
echo "Restarting Docker service..."
sudo systemctl daemon-reload
sudo systemctl restart docker

# 为Docker Build设置代理（影响docker build命令）
DOCKER_BUILDKIT_CONF="/etc/docker/daemon.json"
if [ ! -f "$DOCKER_BUILDKIT_CONF" ]; then
    echo "Creating Docker daemon.json for build proxy..."
    sudo bash -c "cat > $DOCKER_BUILDKIT_CONF" << EOL
{
  "proxies": {
    "default": {
      "httpProxy": "http://$PROXY_HOST:$PROXY_PORT",
      "httpsProxy": "http://$PROXY_HOST:$PROXY_PORT",
      "noProxy": "localhost,127.0.0.1"
    }
  }
}
EOL
else
    echo "Docker daemon.json already exists. Please manually update it if needed."
fi

# 测试代理是否生效
echo "Testing proxy connection in Docker..."
if sudo docker run --rm curlimages/curl -s -I https://www.google.com >/dev/null; then
    echo "Docker proxy is working!"
else
    echo "Docker proxy connection failed. Please check Clash settings or network configuration."
fi