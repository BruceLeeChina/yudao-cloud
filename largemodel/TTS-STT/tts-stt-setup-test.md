############## TTS https://github.com/2noise/ChatTTS.git  / https://github.com/jianchang512/ChatTTS-ui.git    #######################################
在 VirtualBox 中的 Ubuntu 虚拟机通过 Docker 安装和测试 ChatTTS 的完整指南如下：

### 前提条件
1. VirtualBox 虚拟机已启用 **3D 加速**（设置 → 显示 → 勾选"启用 3D 加速"，显存 ≥128MB）
2. Ubuntu 虚拟机分配资源建议：**4核CPU/8GB内存/20GB存储**
3. 确保虚拟机有网络连接

启动和访问：
# 测试基础 CUDA 容器
git clone https://github.com/2noise/ChatTTS
cd ChatTTS
pip install --upgrade -r requirements.txt
python examples/web/webui.py

访问：
http://127.0.0.1:8080/



############## STT https://github.com/openai/whisper.git         #######################################
## 1. docker 安装测试 whisper
# VirtualBox Ubuntu 中通过 Docker 安装测试 Whisper 语音识别

下面是在 VirtualBox Ubuntu 虚拟机中安装和测试 Whisper 语音识别模型的完整指南：

## 系统准备

### 1. 确保虚拟机配置
- 分配至少 **4GB RAM**
- 分配至少 **20GB 硬盘空间**
- 启用 **3D 加速**（VirtualBox 设置 > 显示 > 启用 3D 加速）

### 2. 安装必要依赖
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose ffmpeg
sudo usermod -aG docker $USER
newgrp docker  # 刷新用户组
```

## 安装 Whisper 的 Docker 方案

### 方案一：使用官方社区镜像（推荐）
```bash
# 拉取镜像（约 1.5GB）
docker pull onerahmet/openai-whisper-asr-webservice:latest

# 启动容器（使用 base 模型）
docker run -d --name whisper \
  -p 8000:9000 \
  -e ASR_MODEL=base \
  onerahmet/openai-whisper-asr-webservice
```

## 测试 Whisper
http://192.168.56.16:8000