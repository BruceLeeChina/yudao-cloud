## 1.启动所有中间件
安装docker
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
docker --version
sudo ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose
docker-compose --version

mkdir -p /opt/yudao
# yudao-cloud\deploy\docker\data 上传到 /opt/yudao
sudo chmod -R 775 /opt/yudao
sudo chmod -R 777 /opt/yudao/middleware/rocketmq/
sudo ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

# 设置外网代理 如果不需要代理，可以不执行，导入镜像 cd /opt/yudao/images/ && for file in *.tar; do docker load -i "$file"; done
# setup_proxy.sh
# clear_proxy.sh
# sudo dnf install jq

[//]: # (cd /opt/yudao/ && docker-compose up -d)
cd /opt/yudao/ && docker-compose -f docker-compose-middleware.yml up -d


# mysql脚本：初始执行 root 密码：yudao2025@mall
-- 创建nacos数据库[1,8](@ref)
CREATE DATABASE IF NOT EXISTS `nacos`
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
-- 创建nacos用户并授权[2,4](@ref)
CREATE USER IF NOT EXISTS 'nacos'@'%'
IDENTIFIED WITH mysql_native_password BY 'yudao2025@mall';
GRANT ALL PRIVILEGES ON `nacos`.*
TO 'nacos'@'%' WITH GRANT OPTION;

-- 创建xxl_job数据库[1,8](@ref)
CREATE DATABASE IF NOT EXISTS `xxl_job`
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
-- 创建xxl_job用户并授权[2,4](@ref)
CREATE USER IF NOT EXISTS 'xxljob'@'%'
IDENTIFIED WITH mysql_native_password BY 'yudao2025@mall';
GRANT ALL PRIVILEGES ON `xxl_job`.*
TO 'xxljob'@'%' WITH GRANT OPTION;

-- 创建ruoyi-vue-pro数据库[1,8](@ref)
CREATE DATABASE IF NOT EXISTS `ruoyi-vue-pro`
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
-- 创建root用户并授权[2,4](@ref)
CREATE USER IF NOT EXISTS 'yudao'@'%'
IDENTIFIED WITH mysql_native_password BY 'yudao2025@mall';
GRANT ALL PRIVILEGES ON `ruoyi-vue-pro`.*
TO 'yudao'@'%' WITH GRANT OPTION;

-- 刷新权限[1,4](@ref)
FLUSH PRIVILEGES;

执行sql脚本：
/opt/yudao/deploy/docker/data/nacos/nacos.sql
/opt/yudao/deploy/docker/data/xxljob/xxljob.sql

# 检查所有中间件启动情况
grafana/grafana:12.0.1                     0.0.0.0:3000->3000/tcp                                                                                       mw-grafana
provectuslabs/kafka-ui:v0.7.2              0.0.0.0:9094->8080/tcp                                                                                       mw-kafka-ui
xuxueli/xxl-job-admin:3.1.0                0.0.0.0:8180->8080/tcp                                                                                       mw-xxljob
nacos/nacos-server:v3.0.1                  0.0.0.0:8848->8848/tcp, 0.0.0.0:9848-9849->9848-9849/tcp, 0.0.0.0:18848->8080/tcp                            mw-nacos
mysql:5.7.44                               0.0.0.0:3306->3306/tcp, 33060/tcp                                                                            mw-mysql
apache/skywalking-oap-server:10.2.0        0.0.0.0:11800->11800/tcp, 1234/tcp, 0.0.0.0:12800->12800/tcp                                                 mw-skywalking-oap
elasticsearch:7.17.28                      0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp                                                               mw-elasticsearch
apache/skywalking-ui:10.2.0                0.0.0.0:18080->8080/tcp                                                                                      mw-skywalking-ui
kibana:7.17.28                             0.0.0.0:5601->5601/tcp                                                                                       mw-kibana
mongo:4.4.29                               0.0.0.0:27017->27017/tcp                                                                                     mw-mongodb
bitnami/kafka:4.0.0                        0.0.0.0:9092-9093->9092-9093/tcp                                                                             mw-kafka
postgres:17.5                              0.0.0.0:5432->5432/tcp                                                                                       mw-postgresql
openresty/openresty:1.25.3.2-4-jammy-amd64 0.0.0.0:80->80/tcp                                                                                           mw-openresty
bladex/sentinel-dashboard:1.8.8            8719/tcp, 0.0.0.0:8858->8858/tcp                                                                             mw-sentinel
onlyoffice/documentserver:8.3.3            0.0.0.0:9997->80/tcp, 0.0.0.0:9443->443/tcp                                                                  mw-onlyoffice
redis:8.0.1                                0.0.0.0:6379->6379/tcp                                                                                       mw-redis
minio/minio:RELEASE.2025-05-24T17-08-30Z   0.0.0.0:9000-9001->9000-9001/tcp                                                                             mw-minio
seataio/seata-server:1.8.0.2               0.0.0.0:7091->7091/tcp, 0.0.0.0:8091->8091/tcp                                                               mw-seata
apacherocketmq/rocketmq-dashboard:2.0.1    0.0.0.0:8980->8080/tcp                                                                                        mw-rocketmq-dashboard
apache/rocketmq:5.3.3                      10909/tcp, 0.0.0.0:9876->9876/tcp, 10911-10912/tcp                                                            mw-rocketmq-namesrv
rabbitmq:4.1.0-management                  4369/tcp, 5671/tcp, 0.0.0.0:5672->5672/tcp, 15671/tcp, 15691-15692/tcp, 25672/tcp, 0.0.0.0:15672->15672/tcp   mw-rabbitmq
tdengine/tdengine:3.3.6.9                  0.0.0.0:6030->6030/tcp, 0.0.0.0:6041->6041/tcp                                                                mw-tdengine




中间件名称：              用户名       密码                    访问地址：     
mw-kafka-ui                                                     http://192.168.56.14:9094
mw-xxljob                    admin       123456                 http://192.168.56.14:8180/xxl-job-admin                                                    
mw-nacos                     nacos       nacos                  http://192.168.56.14:8848/nacos (新版本访问 地址 http://192.168.56.14:18848 )                                                
mw-mysql                     root        yudao2025@mall         192.168.56.14:3306                                                    
mw-skywalking-oap                                                                                        
mw-elasticsearch             elastic     yudao2025@mall         http://192.168.56.14:9200/                                                                 
mw-skywalking-ui                                                http://192.168.56.14:18080                                        
mw-kibana                    elastic     yudao2025@mall         http://192.168.56.14:5601                                 
mw-mongodb                   admin       yudao2025mall          192.168.56.14:27017                                  
mw-kafka                                                        192.168.56.14:9092                              
mw-postgresql                yudao       yudao2025@mall         192.168.56.14:5432                                                                        
mw-openresty                                                    http://192.168.56.14/                                                                       
mw-sentinel                 sentinel     sentinel               http://192.168.56.14:8858                                   
mw-onlyoffice                                                   http://192.168.56.14:9997                                     
mw-redis                                 yudao2025@mall         192.168.56.14:6379                                               
mw-minio                    minio        yudao2025@mall         http://192.168.56.14:9001                                                   
mw-seata                    seata        seata                  http://192.168.56.14:7091
mw-rocketmq                 admin        admin                  http://192.168.56.14:8980
mw-rabbitmq                 yudao       yudao2025@mall          http://192.168.56.14:15672
mw-tdengine                 root        taosdata                192.168.56.14:6041
mw-grafana                  admin       admin123@mall           http://192.168.56.14:3000

## 2.所有服务启动
# 执行所有业务SQL
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\ai.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\bpm.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\crm.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\erp.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\infra.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\iot.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\mall.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\member.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\mp.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\pay.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\quartz.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\report.sql
D:\workspace\yudao-cloud\deploy\sql\mysql\2025-05-27\system.sql

服务启动不依赖：
docker stop  mw-rocketmq-broker
docker stop  mw-rocketmq-namesrv
docker stop  mw-skywalking-oap
docker stop  mw-kafka-ui
docker stop  mw-rocketmq-dashboard
docker stop  mw-skywalking-ui
docker stop  mw-sentinel
docker stop  mw-elasticsearch
docker stop  mw-rabbitmq
docker stop  mw-postgresql
