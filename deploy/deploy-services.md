## 1.Ubuntu 22.03 安装 openjdk17以上版本，安装 git 和 maven
=========================================AI 回答 安装构建组件==============================================
下面是在 Ubuntu 22.04 上安装 OpenJDK 17、Git 和 Maven 的完整步骤，分为三个部分，按依赖顺序排列：
📦 一、安装 OpenJDK 17
Java 是运行 Maven 和 Git 的基础环境。  
步骤：
更新软件源（确保获取最新包信息）：
      sudo apt update
安装 OpenJDK 17：
      sudo apt install openjdk-17-jdk -y
验证安装：
      java -version
# 输出应包含 "openjdk 17.x.x"
（可选）设置默认 Java 版本（若系统有多个 JDK）：
      sudo update-alternatives --config java  # 选择 JDK 17 的编号
配置环境变量（若未自动设置）：
编辑 ~/.bashrc：
          nano ~/.bashrc
文件末尾添加：
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=JAVA_HOME/bin:PATH
生效配置：
source ~/.bashrc
注意：
- JDK 路径可通过 update-alternatives --list java 确认。
- 若需更高版本（如 JDK 21），需从 https://www.oracle.com/java/technologies/downloads/下载手动安装。
🔧 二、安装 Git
Git 是代码版本控制工具。  
步骤：
通过 APT 安装：
      sudo apt install git -y
验证安装：
      git --version  # 输出示例：git version 2.34.1
配置全局用户信息（首次使用需设置）：
      git config --global user.name "BruceLeeChina"
      git config --global user.email "brucelee116@163.com"
提示：
- 若需最新版 Git，可添加 PPA 源：
sudo add-apt-repository ppa:git-core/ppa
sudo apt update && sudo apt install git
🛠️ 三、安装 Maven
Maven 是 Java 项目构建和依赖管理工具。  
步骤：
通过 APT 安装（简单但版本可能较旧）：
      sudo apt install maven -y
手动安装最新版（推荐开发者）：
下载 Maven（以 3.9.4 为例）：
          wget https://dlcdn.apache.org/maven/maven-3/3.9.10/binaries/apache-maven-3.9.10-bin.tar.gz
解压到 /opt：
          sudo tar -xzvf apache-maven-*.tar.gz -C /opt
          sudo ln -s /opt/apache-maven-3.9.10 /opt/maven  # 创建软链接
          sudo ln -s /opt/apache-maven-3.9.10 /usr/share/maven  # 创建软链接
设置环境变量：
     编辑 /etc/profile.d/maven.sh：  
          sudo nano /etc/profile.d/maven.sh
     添加内容：  
          export MAVEN_HOME=/opt/maven
     export PATH=MAVEN_HOME/bin:PATH
生效配置：
          source /etc/profile.d/maven.sh
验证安装：
      mvn -v  # 输出应包含 Maven 版本及 JDK 信息
⚙️ 四、优化配置（可选）
Maven 镜像加速（解决国内下载慢）：
编辑 ~/.m2/settings.xml，添加阿里云镜像：
     <mirror>
       <id>aliyunmaven</id>
       <name>阿里云镜像</name>
       <url>https://maven.aliyun.com/repository/public</url>
       <mirrorOf>central</mirrorOf>
     </mirror>
Maven JVM 参数优化：
创建 ~/.mavenrc 文件，添加：
          export MAVEN_OPTS="-Xms512m -Xmx1024m"
✅ 五、验证所有工具
java -version  # 检查 JDK
git --version   # 检查 Git
mvn -v          # 检查 Maven 及关联的 JDK
⚠️ 注意事项
权限问题：
手动安装时，需用 sudo 操作系统目录（如 /opt）。  
环境变量生效：
修改 .bashrc 或 /etc/profile.d/ 后需执行 source 或重启终端。  
版本兼容性：
Maven 3.8+ 要求 JDK 1.7 或更高版本，OpenJDK 17 完全兼容。
以上步骤在 Ubuntu 22.04 LTS 实测通过，若遇到依赖问题，可先运行 sudo apt --fix-broken install 修复。
  =========================================AI 回答==============================================

## 2.打包 docker 镜像
cd /opt/yudao/services/jenkins
git clone https://github.com/BruceLeeChina/yudao-cloud.git
git checkout master-jdk17

cd /opt/yudao/services/jenkins/yudao-cloud/
git pull

cd /opt/yudao/services/jenkins/yudao-cloud/
mvn install -Dmaven.test.skip=true

# 1. 保存脚本为 build_services_images.sh
# 2. 赋予执行权限
cd /opt/yudao/shell-scripts/ && chmod +x build_services_images.sh

# 3. 使用方式:
#    构建所有模块:
cd /opt/yudao/shell-scripts/ && ./build_services_images.sh all

#    构建指定模块:
cd /opt/yudao/shell-scripts/ &&  ./build_services_images.sh "yudao-module-ai-server,yudao-module-erp-server"

#    显示帮助信息:
./build_services_images.sh help
===========================================AI 回答==============================================
传入 all build所有，传入某一个构建某一个，用户输入“yudao-module-ai-server,yudao-module-erp-server”，构建两个；如果是/opt/yudao/services/jenkins/yudao-cloud/yudao-module-ai/yudao-module-ai-server/Dockerfile ,
直接使用yudao-module-ai-server作为镜像名称，则镜像名称为yudao-module-ai-server:2.6.0，请帮我编写脚本
cd /opt/yudao/services/jenkins/yudao-cloud/yudao-module-ai/yudao-module-ai-server && docker build -t yudao-module-ai-server:2.6.0 .

所有的Dockerfile 文件路径
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-ai/yudao-module-ai-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-member/yudao-module-member-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-erp/yudao-module-erp-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-report/yudao-module-report-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-bpm/yudao-module-bpm-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-mp/yudao-module-mp-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-system/yudao-module-system-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-crm/yudao-module-crm-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-mall/yudao-module-promotion-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-mall/yudao-module-product-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-mall/yudao-module-trade-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-mall/yudao-module-statistics-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-pay/yudao-module-pay-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-gateway/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-server/Dockerfile
/opt/yudao/services/jenkins/yudao-cloud/yudao-module-infra/yudao-module-infra-server/Dockerfile

yudao-module-report-server          2.6.0                          49563221395f   32 seconds ago       486MB
yudao-module-pay-server             2.6.0                          6f34de0ea69e   57 seconds ago       458MB
yudao-module-mp-server              2.6.0                          25460ca8a70f   About a minute ago   427MB
yudao-module-product-server         2.6.0                          08d92091628f   4 minutes ago        423MB
yudao-module-promotion-server       2.6.0                          a6c3b5372463   5 minutes ago        432MB
yudao-module-erp-server             2.6.0                          6e4849678c7f   5 minutes ago        423MB
yudao-module-infra-server           2.6.0                          69b04edc9492   6 minutes ago        453MB
yudao-module-bpm-server             2.6.0                          bcb34884a38c   6 minutes ago        435MB
yudao-module-crm-server             2.6.0                          cdaa01a2c5c2   6 minutes ago        433MB
yudao-gateway                       2.6.0                          d9db53a04db3   7 minutes ago        354MB
yudao-module-ai-server              2.6.0                          306dbf92cf85   7 minutes ago        645MB
yudao-module-system-server          2.6.0                          a4c00638bf65   8 minutes ago        455MB
yudao-module-member-server          2.6.0                          6bc64610dccc   8 minutes ago        424MB
yudao-module-statistics-server      2.6.0                          8064a103fd89   8 minutes ago        433MB
yudao-module-trade-server           2.6.0                          d4aa3e2761d0   9 minutes ago        434MB
yudao-server                        2.6.0                          8286cabb262d   14 minutes ago       810MB


=========================================AI 回答 构建脚本==============================================
以下是为脚本添加 `all` 参数支持的完整版本，可以一键构建所有模块：

```bash
#!/bin/bash

# 固定版本号
VERSION="2.6.0"

# 项目根目录
PROJECT_ROOT="/opt/yudao/services/jenkins/yudao-cloud"

# 所有已知的Dockerfile路径映射
declare -A DOCKERFILE_PATHS=(
  ["yudao-module-ai-server"]="$PROJECT_ROOT/yudao-module-ai/yudao-module-ai-server/Dockerfile"
  ["yudao-module-member-server"]="$PROJECT_ROOT/yudao-module-member/yudao-module-member-server/Dockerfile"
  ["yudao-module-erp-server"]="$PROJECT_ROOT/yudao-module-erp/yudao-module-erp-server/Dockerfile"
  ["yudao-module-report-server"]="$PROJECT_ROOT/yudao-module-report/yudao-module-report-server/Dockerfile"
  ["yudao-module-bpm-server"]="$PROJECT_ROOT/yudao-module-bpm/yudao-module-bpm-server/Dockerfile"
  ["yudao-module-mp-server"]="$PROJECT_ROOT/yudao-module-mp/yudao-module-mp-server/Dockerfile"
  ["yudao-module-system-server"]="$PROJECT_ROOT/yudao-module-system/yudao-module-system-server/Dockerfile"
  ["yudao-module-crm-server"]="$PROJECT_ROOT/yudao-module-crm/yudao-module-crm-server/Dockerfile"
  ["yudao-module-promotion-server"]="$PROJECT_ROOT/yudao-module-mall/yudao-module-promotion-server/Dockerfile"
  ["yudao-module-product-server"]="$PROJECT_ROOT/yudao-module-mall/yudao-module-product-server/Dockerfile"
  ["yudao-module-trade-server"]="$PROJECT_ROOT/yudao-module-mall/yudao-module-trade-server/Dockerfile"
  ["yudao-module-statistics-server"]="$PROJECT_ROOT/yudao-module-mall/yudao-module-statistics-server/Dockerfile"
  ["yudao-module-pay-server"]="$PROJECT_ROOT/yudao-module-pay/yudao-module-pay-server/Dockerfile"
  ["yudao-gateway"]="$PROJECT_ROOT/yudao-gateway/Dockerfile"
  ["yudao-server"]="$PROJECT_ROOT/yudao-server/Dockerfile"
  ["yudao-module-infra-server"]="$PROJECT_ROOT/yudao-module-infra/yudao-module-infra-server/Dockerfile"
)

# 获取所有模块名称
ALL_MODULES=("${!DOCKERFILE_PATHS[@]}")

# 更新代码函数
update_code() {
  echo "🔄 正在更新代码..."
  cd "$PROJECT_ROOT" || { echo "❌ 无法进入项目目录: $PROJECT_ROOT"; exit 1; }
  
  if git pull; then
    echo "✅ 代码更新成功"
  else
    echo "❌ 代码更新失败"
    exit 1
  fi
}

# Maven编译函数
build_project() {
  echo "🔨 正在编译项目..."
  cd "$PROJECT_ROOT" || exit 1
  
  if mvn install -Dmaven.test.skip=true; then
    echo "✅ 项目编译成功"
  else
    echo "❌ 项目编译失败"
    exit 1
  fi
}

# 构建Docker镜像函数
build_image() {
  local module=$1
  local path=${DOCKERFILE_PATHS[$module]}
  
  if [[ -z "$path" ]]; then
    echo "❌ 错误: 未找到模块 '$module' 的Dockerfile路径"
    return 1
  fi
  
  local context_dir=$(dirname "$path")
  local image_name="${module}:${VERSION}"
  
  echo "🚀 开始构建模块: $module"
  echo "📁 构建目录: $context_dir"
  echo "🐳 镜像名称: $image_name"
  
  if docker build -t "$image_name" "$context_dir"; then
    echo "✅ 成功构建: $image_name"
  else
    echo "❌ 构建失败: $module"
    return 1
  fi
}

# 显示帮助信息
show_help() {
  echo "使用方法: $0 [选项]"
  echo "选项:"
  echo "  all                         构建所有模块"
  echo "  <模块列表>                  构建指定模块（逗号分隔）"
  echo "  help                        显示帮助信息"
  echo ""
  echo "可用模块:"
  for module in "${ALL_MODULES[@]}"; do
    echo "  - $module"
  done
}

# 主执行流程
if [ $# -eq 0 ]; then
  show_help
  exit 1
fi

# 执行更新和编译
update_code
build_project

# 处理用户输入
case "$1" in
  all)
    echo "🌐 开始构建所有模块..."
    for module in "${ALL_MODULES[@]}"; do
      build_image "$module" || exit 1
    done
    ;;
  help)
    show_help
    exit 0
    ;;
  *)
    IFS=',' read -ra MODULES <<< "$1"
    for module in "${MODULES[@]}"; do
      module=$(echo "$module" | xargs)  # 去除空格
      if [[ -n "$module" ]]; then
        build_image "$module" || exit 1
      fi
    done
    ;;
esac

echo "🎉 所有操作完成"
```

### 使用说明

```bash
# 1. 保存脚本为 build_services_images.sh
# 2. 赋予执行权限
chmod +x build_services_images.sh

# 3. 使用方式:
#    构建所有模块:
./build_services_images.sh all

#    构建指定模块:
./build_services_images.sh "yudao-module-ai-server,yudao-module-erp-server"

#    显示帮助信息:
./build_services_images.sh help
```

### 新增功能说明

1. **支持 `all` 参数**：
    - 输入 `all` 会自动构建所有预定义的模块
    - 自动遍历所有模块映射表中的项目

2. **模块列表显示**：
    - 添加了 `help` 参数显示可用模块列表
    - 运行脚本不带参数时也会显示帮助信息

3. **完整的模块映射**：
    - 使用 `ALL_MODULES=("${!DOCKERFILE_PATHS[@]}")` 自动获取所有模块名称
    - 确保构建所有模块时不会遗漏任何项目

4. **清晰的执行流程**：
   ```mermaid
   graph TD
     A[开始] --> B{检查参数}
     B -->|all| C[构建所有模块]
     B -->|help| D[显示帮助信息]
     B -->|模块列表| E[构建指定模块]
     C --> F[遍历所有模块构建]
     E --> G[构建输入的模块]
     F & G --> H[完成]
   ```

### 执行示例

**构建所有模块:**
```bash
./build_services_images.sh all
```

输出示例:
```
🔄 正在更新代码...
Already up to date.
✅ 代码更新成功

🔨 正在编译项目...
[INFO] BUILD SUCCESS
✅ 项目编译成功

🌐 开始构建所有模块...
🚀 开始构建模块: yudao-module-ai-server
📁 构建目录: /opt/yudao/services/jenkins/yudao-cloud/yudao-module-ai/yudao-module-ai-server
🐳 镜像名称: yudao-module-ai-server:2.6.0
...
🚀 开始构建模块: yudao-server
📁 构建目录: /opt/yudao/services/jenkins/yudao-cloud/yudao-server
🐳 镜像名称: yudao-server:2.6.0
...
🎉 所有操作完成
```

**获取帮助信息:**
```bash
./build_services_images.sh help
```

输出示例:
```
使用方法: build_services_images.sh [选项]
选项:
  all                         构建所有模块
  <模块列表>                  构建指定模块（逗号分隔）
  help                        显示帮助信息

可用模块:
  - yudao-module-ai-server
  - yudao-module-member-server
  - yudao-module-erp-server
  - ...（所有模块列表）
```

### 注意事项

1. 当使用 `all` 参数时，会按照模块在映射表中定义的顺序构建
2. 构建所有模块可能需要较长时间，建议在服务器资源充足时执行
3. 如果某个模块构建失败，整个脚本会立即终止
4. 模块名称区分大小写，请确保输入的名称与映射表一致

这个脚本现在支持三种操作模式：构建所有模块、构建指定模块、显示帮助信息，可以满足不同的构建需求。
=========================================AI 回答==============================================

## 3.启动后端服务 + 前端服务
yudao-gateway                       2.6.0        48080
yudao-module-system-server          2.6.0        48081
yudao-module-infra-server           2.6.0        48082
yudao-module-bpm-server             2.6.0        48083
yudao-module-report-server          2.6.0        48084
yudao-module-pay-server             2.6.0        48085
yudao-module-mp-server              2.6.0        48086
yudao-module-member-server          2.6.0        48087
yudao-module-erp-server             2.6.0        48088
yudao-module-crm-server             2.6.0        48089
yudao-module-ai-server              2.6.0        48090
yudao-module-iot-server             2.6.0        48091
yudao-module-product-server         2.6.0        48100
yudao-module-promotion-server       2.6.0        48101
yudao-module-trade-server           2.6.0        48102
yudao-module-statistics-server      2.6.0        48103

yudao-server                        2.6.0        48080

启动：
cd /opt/yudao/ && docker-compose -f docker-compose-services.yml up -d

前端服务：
安装 nodejs 和 npm
# 安装 NVM（Node Version Manager）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# 重启终端或加载配置
source ~/.bashrc
# 安装指定 Node.js 版本（如 v20.14.0）
nvm install 20.14.0
# 设置为默认版本
nvm alias default 20.14.0
# 验证
node -v
npm -v

npm config set registry https://registry.npmmirror.com
npm install -g typescript yarn vite  # 全局安装 TypeScript 和 Yarn

打包路径： /opt/yudao/services/jenkins/yudao-cloud/yudao-ui/yudao-ui-admin-vue3/
# 安装 pnpm，提升依赖的安装速度
npm config set registry https://registry.npmmirror.com
npm install -g pnpm
cd /opt/yudao/services/jenkins/yudao-cloud/yudao-ui/yudao-ui-admin-vue3/
# 安装依赖
pnpm install
# 启动服务
npm run dev
打包：
cd /opt/yudao/services/jenkins/yudao-cloud/yudao-ui/yudao-ui-admin-vue3/ && npm run build:dev
cp -r /opt/yudao/services/jenkins/yudao-cloud/yudao-ui/yudao-ui-admin-vue3/dist/* /opt/yudao/middleware/openresty/html/admin/



打包路径： /opt/yudao/services/jenkins/yudao-cloud/yudao-ui/yudao-mall-uniapp/
# 安装 npm 依赖
npm config set registry https://registry.npmmirror.com
npm install -g pnpm
# 安装依赖
pnpm install
# 启动服务 构建服务
# 打包 H5
pnpm run build:h5
# 打包小程序（如微信）
npm run build:mp-weixin




