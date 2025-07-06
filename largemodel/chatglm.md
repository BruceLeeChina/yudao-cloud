## ################################### CHATGLM ChatGLM-6B 是一个开源的、支持中英双语的对话语言模型 https://github.com/THUDM/ChatGLM-6B.git ######################################################
## ################################### CHATGLM   一种利用 langchain 思想实现的基于本地知识库的问答应用，目标期望建立一套对中文场景与开源模型支持友好、可离线运行的知识库问答解决方案 https://github.com/chatchat-space/Langchain-Chatchat.git ######################################################
1.windows 安装 wsl 
wsl --install 
安装指定版本：
wsl --install -d Ubuntu-22.04
查看：
wsl --list --all
设置默认版本:
wsl --set-default Ubuntu
进入某个ubuntu：
wsl -d Ubuntu
查看Ubuntu版本
wsl -l -v

2.ubuntu 安装 python3.10
用户名密码： root 123456/ test 123456
查看ubuntu版本
cat /etc/os-release
sudo apt update && sudo apt upgrade -y
sudo apt install python3 python3-pip -y
python3 --version
pip3 --version

虚拟环境：
sudo apt update && sudo apt upgrade -y
sudo apt install wget bzip2 -y
wget https://repo.anaconda.com/miniconda/Anaconda3-2025.06-0-Linux-x86_64.sh
chmod +x Anaconda3-2025.06-0-Linux-x86_64.sh
bash Anaconda3-2025.06-0-Linux-x86_64.sh
source ~/.bashrc
conda --version
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --set show_channel_urls yes

# 创建虚拟环境并安装依赖
conda create -n chatglm3 python=3.10 -y
conda activate chatglm3
pip install -r requirements.txt
conda deactivate


3.安装依赖包
pip install -r requirements.txt

3.下载模型
ChatGLM3 项目下
git clone https://huggingface.co/THUDM/chatglm3-6b
模型目录：
ChatGLM3\chatglm3-6b

修改代码：basic_demo\web_demo_gradio.py
MODEL_PATH = os.environ.get('MODEL_PATH', '../chatglm3-6b')
#MODEL_PATH = 'chatglm3-6b'
TOKENIZER_PATH = os.environ.get("TOKENIZER_PATH", MODEL_PATH)
demo.queue()
demo.launch(server_name="0.0.0.0", server_port=7870, inbrowser=True, share=False)

启动：
cd basic_demo
python web_demo_gradio.py

http://127.0.0.1:7870/

问题处理：
pip install peft==0.4.0




## #################################### AI 教程 #####################################################################
以下是在 Windows WSL Ubuntu 环境中部署和测试 ChatGLM3-6B 模型的详细步骤：

---

### 环境准备
1. **启用 WSL 并安装 Ubuntu**
    - 以管理员身份打开 PowerShell：
      ```powershell
      wsl --install -d Ubuntu-22.04
      ```
    - 安装完成后启动 Ubuntu 终端

2. **更新系统**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. **安装 Python 3.10+**
   ```bash
   sudo apt install python3-pip python3.10-venv -y
   ```

---

### 部署 ChatGLM3-6B
1. **创建项目目录**
   ```bash
   mkdir ~/chatglm3 && cd ~/chatglm3
   ```

2. **安装 CUDA 工具包 (GPU 加速推荐)**
   ```bash
   wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
   sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
   sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/3bf863cc.pub
   sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/ /"
   sudo apt install cuda-toolkit-12-2 -y
   ```

3. **设置虚拟环境**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```

4. **安装 PyTorch**
   ```bash
   pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
   ```

5. **克隆 ChatGLM3 仓库**
   ```bash
   git clone https://github.com/THUDM/ChatGLM3
   cd ChatGLM3
   ```

6. **安装依赖库**
   ```bash
   pip install -r requirements.txt
   pip install gradio mdtex2html
   ```

7. **下载模型 (二选一)**
    - **选项1：Hugging Face 下载**
      ```bash
      apt install git-lfs
      git lfs install
      git clone https://huggingface.co/THUDM/chatglm3-6b ./model
      ```
    - **选项2：手动下载**
      从 [Hugging Face](https://huggingface.co/THUDM/chatglm3-6b) 下载模型文件到 `ChatGLM3/model/` 目录

---

### 修改配置文件
1. **编辑 web_demo_gradio.py**
   ```bash
   nano basic_demo/web_demo_gradio.py
   ```
    - 修改模型路径（约第10行）：
      ```python
      # 原始代码
      tokenizer = AutoTokenizer.from_pretrained("THUDM/chatglm3-6b", trust_remote_code=True)
      model = AutoModel.from_pretrained("THUDM/chatglm3-6b", trust_remote_code=True).cuda()
      
      # 改为本地路径
      tokenizer = AutoTokenizer.from_pretrained("./model", trust_remote_code=True)
      model = AutoModel.from_pretrained("./model", trust_remote_code=True).cuda()
      ```
    - 修改共享配置（约第70行）：
      ```python
      demo.queue().launch(share=True, server_name="0.0.0.0")
      ```

---

### 启动 Web Demo
1. **运行应用**
   ```bash
   cd basic_demo
   python web_demo_gradio.py
   ```

2. **访问测试**
    - 在 WSL 终端中会出现类似输出：
      ```
      Running on local URL:  http://0.0.0.0:7860
      Running on public URL: https://xxxx.gradio.live
      ```
    - **从 Windows 访问**：在浏览器中打开 `http://localhost:7860`
    - **从局域网访问**：使用生成的 `gradio.live` 链接

---

### 测试验证
1. **功能测试**
    - 在 Web 界面输入问题 (e.g. "你好")
    - 应看到类似回复："你好👋！我是人工智能助手 ChatGLM3-6B..."

2. **性能检查**
    - 首次加载需 2-5 分钟（需下载 tokenizer 缓存）
    - 后续响应应在 3-10 秒内完成

---

### 常见问题解决
1. **CUDA 内存不足**
   ```python
   # 修改模型加载方式
   model = AutoModel.from_pretrained("./model", trust_remote_code=True).quantize(4).cuda()
   ```

2. **端口占用错误**
   ```bash
   python web_demo_gradio.py --server-port 8080
   ```

3. **缺少依赖**
   ```bash
   # 常见缺失库
   sudo apt install libgl1-mesa-glx -y
   ```

---

> **注意**：模型需要至少 13GB 可用内存，首次运行会自动下载约 2GB 的额外文件。完整过程需 30-60 分钟（取决于网络和硬件）。

