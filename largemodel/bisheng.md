## ######################### 开源 LLM应用开发平台  https://github.com/dataelement/bisheng.git ######################################

这是使用 `bisheng` 仓库部署和测试的平台，详细步骤如下：

---

## 📦 1. 克隆代码

```bash
git clone https://github.com/dataelement/bisheng.git
cd bisheng
```

这是官方推荐的获取方式 ([trendshift.io][1])。

---

## 🐳 2. 使用 Docker Compose 快速部署

进入 Docker 目录并启动服务：

```bash
cd docker
docker-compose -f docker-compose.yml -p bisheng up -d
```

该配置默认会部署：

* BISHENG 平台后台
* Elasticsearch
* Milvus
* OnlyOffice 等组件&#x20;

---

## 🌐 3. 访问 Web UI 与注册

* 打开浏览器，访问 `http://192.168.56.17:3001`。
* 首次注册的用户将成为系统管理员 ([trendshift.io][1])。

docker exec -it bisheng-mysql /bin/bash
mysql -u root -p
-- 允许 root 从任何主机访问
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '1234';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
---

## 🎯 4. 测试使用功能

进入后台后，你可以测试以下功能模块：

1. **GenAI workflow**：创建 prompt → 运行模型 → 查看生成结果
2. **RAG（检索增强生成）**：上传文档、建立索引、输入问题进行回答
3. **Agent 管理**：体验内置对话 agent、配置对话参数
4. **模型管理**：上传模型 checkpoint、测试推理服务
5. **数据集 & SFT**：上传微调数据，训练小样本任务
6. **监控 & 日志**：查看系统健康指标和调用日志

这些功能在仓库主页有简述 ([github.com][2])。

---

## 🧪 5. 本地开发测试

如果不想用 Docker，也可以：

```bash
# 安装依赖
pip install bisheng
# 启动服务
bisheng-rt serve
```

这会以组件化方式启动推理后端服务，你可以通过 HTTP 或 gRPC 方式对接测试 ([github.com][3])。

---

## ✅ 总结部署流程

| 步骤   | 内容                     |
| ---- | ---------------------- |
| 克隆代码 | `git clone`            |
| 启动   | `docker compose up -d` |
| 访问   | 浏览器打开 `:3001`          |
| 功能测试 | Workflow、RAG、Agent、监控等 |

---

## 👍 下一步建议

* 查看 `docker/docker-compose.yml`，了解各服务端口、持久化路径。
* 查看官方文档中的 “Self‑hosting” 指南，深入配置 ([trendshift.io][1])。
* 若你遇到部署过程中报错（如端口冲突、组件启动失败等），可以贴出错误日志，我帮你分析！

如果你想快速部署在云服务器，也可以告诉我操作系统、目标环境，我可以写出更详细的方案。

[1]: https://trendshift.io/admin/repository/ask-ai/717?utm_source=chatgpt.com "Trendshift - Ask AI"
[2]: https://github.com/dataelement/bisheng?utm_source=chatgpt.com "BISHENG is an open LLM devops platform for next generation ..."
[3]: https://github.com/dataelement/bisheng-rt?utm_source=chatgpt.com "dataelement/bisheng-rt: bisheng model services backend - GitHub"



##  ############################################# Docker 代理问题解决  ##########################################################
这个错误表明您的 Docker 守护程序在尝试连接到 Docker Hub 时遇到了 DNS 解析问题。尽管您已经配置了代理和 DNS 设置，但问题仍然存在。让我们一步步解决这个问题：

### 解决方案

#### 1. **验证代理设置**
您的代理配置看起来是正确的，但让我们确认代理服务器是否正常工作：

```bash
# 测试代理服务器是否可用
curl -x http://172.24.96.1:7890 https://registry-1.docker.io/v2/ -I
```

如果返回 `401 Unauthorized`，表示代理工作正常（因为 Docker Hub 需要认证）。如果失败，请检查您的代理服务器。
Docker 中央仓库 需要登录 用户名 kerrylee116 电脑密码：xxxxxxxx@

#### 2. **修复 DNS 配置**
在 WSL 环境中，DNS 解析可能有问题。尝试以下方法：

```bash
# 创建或编辑 resolv.conf
sudo tee /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 208.67.222.222
EOF

# 防止 WSL 自动覆盖 DNS 设置
sudo chattr +i /etc/resolv.conf
```

#### 3. **配置 Docker 使用系统代理**
除了 `~/.docker/config.json`，还需要在系统层面配置代理：

```bash
# 创建 Docker 服务目录
sudo mkdir -p /etc/systemd/system/docker.service.d

# 创建代理配置文件
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://172.24.96.1:7890"
Environment="HTTPS_PROXY=http://172.24.96.1:7890"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF
```

#### 4. **完全重启 Docker 服务**
```bash
# 重新加载配置并重启 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# 检查 Docker 服务状态
sudo systemctl status docker
```

#### 5. **测试 Docker 连接**
```bash
# 测试连接 Docker Hub
docker run --rm curlimages/curl curl -I https://registry-1.docker.io/v2/

# 尝试拉取镜像
docker pull mysql:8.0
```

### 备选方案：直接使用镜像加速器

如果代理问题无法解决，可以使用 Docker 镜像加速器：

```bash
# 编辑 Docker 配置文件
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://dockerproxy.cn",
    "https://docker.rainbond.cc",
    "https://docker.udayun.com",
    "https://docker.211678.top",
    "https://pus5qjhn.mirror.aliyuncs.com"
  ],
  "dns": ["8.8.8.8", "1.1.1.1"]
}
EOF

# 重启 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# 尝试拉取镜像
docker pull mysql:8.0
```

### 如果仍然失败：手动下载镜像

如果以上方法都失败，可以尝试在另一台能访问 Docker Hub 的机器上下载镜像，然后导出导入：

1. **在能访问的机器上：**
   ```bash
   docker pull mysql:8.0
   docker save -o mysql_8.0.tar mysql:8.0
   ```

2. **将文件传输到当前机器：**
   ```bash
   scp mysql_8.0.tar user@your-machine:/path/
   ```

3. **在当前机器上导入：**
   ```bash
   docker load -i mysql_8.0.tar
   ```

### 网络诊断命令

如果问题仍然存在，使用这些命令诊断：

```bash
# 检查 DNS 解析
nslookup registry-1.docker.io

# 测试到 Docker Hub 的连通性
telnet registry-1.docker.io 443

# 检查 Docker 日志
journalctl -u docker.service -n 100

# 检查代理是否被使用
docker info | grep -i proxy
```

### 常见问题原因

1. **WSL 网络问题**：WSL 有时与主机网络连接不稳定
2. **代理配置错误**：代理服务器可能不支持 HTTPS 或需要认证
3. **DNS 污染**：某些网络环境可能干扰 DNS 解析
4. **防火墙限制**：主机防火墙可能阻止了 Docker 的网络访问

尝试这些解决方案后，您应该能够成功拉取 Docker 镜像。如果问题仍然存在，请提供以下信息：
1. `docker info` 的输出
2. `cat /etc/resolv.conf` 的输出
3. `curl -v https://registry-1.docker.io/v2/` 的输出