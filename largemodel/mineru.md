########  PDF/PNG 文档提取 https://github.com/opendatalab/MinerU.git ########
## 1. 安装部署
apt update
snap install astral-uv  --classic
uv venv
# 1. 激活之前创建的虚拟环境
source .venv/bin/activate
uv pip install -U "mineru[core]"
# 更新包列表
apt update
# 安装 OpenGL 和图形库依赖
apt install -y libgl1-mesa-glx libglib2.0-0 libsm6 libxrender1 libxext6
# 查找 libGL.so.1 文件
find /usr -name 'libGL.so.1' 2>/dev/null
# 应该返回类似结果：
# /usr/lib/x86_64-linux-gnu/libGL.so.1
mineru -p /root/01-test1.pdf -o /root
mineru -p /root/2025最新Java路线图.jpg -o /root
history

## 2. 使用 测试


