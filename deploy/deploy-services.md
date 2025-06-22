## 1.Ubuntu 22.03 安装 openjdk17以上版本，安装 git 和 maven

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

## 2.打包 docker 镜像
cd /opt/yudao/services/jenkins
git clone https://github.com/BruceLeeChina/yudao-cloud.git
git checkout master-jdk17

