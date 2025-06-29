
模拟数据：/opt/module/applog 配置文件 application.yml 
lg.sh test 100

服务启动情况验证：
## 1.hadoop  hdp.sh start / hdp.sh stop
三台服务器HDFS  服务器用户名密码： root/123456 atguigu/123456
IP      192.168.56.100      192.168.56.101                  192.168.56.102
HOST    hadoop100 			hadoop101					    hadoop102
HDFS	NameNode、DataNode	DataNode					    SecondaryNameNode
YARN	NodeManager			ResourceManager、NodeManager	NodeManager

Web端查看HDFS的Web页面：http://192.168.56.100:9870/
Web端查看SecondaryNameNode：http://192.168.56.102:9868/status.html

## 2.zookeeper  zk.sh start / zk.sh stop
	        服务器hadoop100	服务器hadoop101	服务器hadoop102
Zookeeper	Zookeeper	    Zookeeper	    Zookeeper
测试启动：
/opt/module/zookeeper/bin/zkCli.sh
查看版本：version

## 3.kafka  kf.sh start / kf.sh stop
hadoop100	hadoop101	hadoop102
zk	        zk	        zk
kafka	    kafka	    kafka

测试启动： 192.168.56.100:9092
/opt/module/kafka/bin/kafka-topics.sh --bootstrap-server hadoop100:9092 --list

## 4.flume采集日志 /opt/module/flume/ f1.sh start / f1.sh stop
测试： 192.168.56.102 启动一个Kafka的Console-Consumer
cd /opt/module/kafka/ && bin/kafka-console-consumer.sh --bootstrap-server hadoop100:9092 --topic topic_log
生成数据：
lg.sh test 100
观察Kafka消费者是否能消费到数据

## 5.Mysql连接测试 192.168.56.100:3306  用户名：root 密码：000000 改为新密码：root123
sudo grep 'temporary password' /var/log/mysqld.log
sudo mysql_secure_installation
mysql -u root -p
# 输入临时密码，按提示重置root密码（需满足复杂度要求）;选择是否移除匿名用户、禁止远程root登录等（建议全部选Y

## 6.MaxWell  mxw.sh start / mxw.sh stop
启动报错：TRUNCATE TABLE maxwell.positions;
测试： 
修改：bigdata/config/offline-application.yml 替换 /opt/module/applog/application.yml，修改mock_date为最新
启动启动Zookeeper、Kafka集群及Maxwell、kafka db消费：待观察
cd /opt/module/kafka/ && bin/kafka-console-consumer.sh --bootstrap-server hadoop100:9092 --topic topic_db
生成模拟数据： lg.sh

## 7.flume读取kafka log 数据到 HDFS /opt/module/flume/ f2.sh start / f2.sh stop
配置文件 bigdata/config/kafka_to_hdfs_log.conf 拷贝到 /opt/module/flume/job/kafka_to_hdfs_log.conf
1）启动Zookeeper、Kafka、HDFS
2）启动日志采集Flume
f1.sh start
3）启动hadoop102的日志消费Flume
f2.sh start
4）生成模拟数据
lg.sh 
5）观察HDFS是否出现数据
http://192.168.56.100:9870/explorer.html#/origin_data/gmall/log/topic_log

## 8.DataX全量同步（sqoop也是全量同步工具） 
/opt/module/gen_datax_config 配置生成 配置文件：/opt/module/gen_datax_config/configuration.properties
cd /opt/module/gen_datax_config && java -jar datax-config-generator-1.0-SNAPSHOT-jar-with-dependencies.jar
结果目录：/opt/module/datax/job/import/

自检：python /opt/module/datax/bin/datax.py /opt/module/datax/job/job.json
测试DataX:
1）创建目标路径
由于DataX同步任务要求目标路径提前存在，故需手动创建路径，当前activity_info表的目标路径应为/origin_data/gmall/db/activity_info_full/2025-05-16。
hadoop fs -mkdir -p /origin_data/gmall/db/activity_info_full/2025-06-29
2）执行DataX同步命令
python /opt/module/datax/bin/datax.py -p"-Dtargetdir=/origin_data/gmall/db/activity_info_full/2025-06-29" /opt/module/datax/job/import/gmall.activity_info.json
3）观察同步结果
观察HFDS目标路径是否出现数据。
http://192.168.56.100:9870/explorer.html#/origin_data/gmall/db/activity_info_full/2025-06-29

全量数据同步：
mysql_to_hdfs_full.sh all 2025-06-29

## 9.flume读取kafka db 数据到 HDFS /opt/module/flume/ f3.sh start / f3.sh stop
消费数据测试：
192.168.56.102 配置文件 /opt/module/flume/job/kafka_to_hdfs_db.conf
（1）启动Zookeeper、Kafka集群及Maxwell
（2）启动hadoop102的Flume
/opt/module/flume/bin/flume-ng agent -n a1 -c conf/ -f /opt/module/flume/job/kafka_to_hdfs_db.conf
（3）生成模拟数据
确保Maxwell正在运行，而后生成数据。
lg.sh
（4）观察HDFS目标路径
http://192.168.56.100:9870/explorer.html#/origin_data/gmall/db/payment_info_inc

增量表首日全量同步：
/home/atguigu/bin/mysql_to_kafka_inc_init.sh
（1）清理历史数据
为方便查看结果，现将HDFS上之前同步的增量表数据删除。
hadoop fs -ls /origin_data/gmall/db | grep _inc | awk '{print $8}' | xargs hadoop fs -rm -r -f
（2）执行同步脚本
mysql_to_kafka_inc_init.sh all 
（3）检查同步结果
观察HDFS上是否重新出现增量表数据。
http://192.168.56.100:9870/explorer.html#/origin_data/gmall/db

## 10. 集群启停 /home/atguigu/bin
cluster.sh start
cluster.sh stop

## 11. Hive /opt/module/hive
解决日志jar冲突：
cd /opt/module/hive/lib && mv log4j-slf4j-impl-2.17.1.jar log4j-slf4j-impl-2.17.1.jar.bak
添加mysql驱动包：
cp /opt/software/mysql/mysql-connector-j-8.0.31.jar /opt/module/hive/lib/
Hive配置：
cd $HIVE_HOME/conf && vi hive-site.xml

Mysql准备：
1）登陆MySQL
mysql -uroot -proot123
2）新建Hive元数据库
mysql> create database metastore;
3）初始化Hive元数据库 主机执行
schematool -initSchema -dbType mysql -verbose
4）修改元数据库字符集
Hive元数据库的字符集默认为Latin1，由于其不支持中文字符，所以建表语句中如果包含中文注释，会出现乱码现象。如需解决乱码问题，须做以下修改。
修改Hive元数据库中存储注释的字段的字符集为utf-8。
（1）字段注释
mysql> use metastore;
mysql> alter table COLUMNS_V2 modify column COMMENT varchar(256) character set utf8;
（2）表注释
mysql> alter table TABLE_PARAMS modify column PARAM_VALUE mediumtext character set utf8;
4）退出mysql
mysql> quit;

启动Hive：
hive
hive> show databases;

## 12.Hive on Spark
Hive引擎简介：
Hive引擎包括：默认MR、Tez、Spark。
Hive on Spark：Hive既作为存储元数据又负责SQL的解析优化，语法是HQL语法，执行引擎变成了Spark，Spark负责采用RDD执行。
Spark on Hive : Hive只作为存储元数据，Spark负责SQL解析优化，语法是Spark SQL语法，Spark负责采用RDD执行。

向HDFS上传Spark纯净版jar包 
hadoop fs -mkdir /spark-history
hadoop fs -put /opt/module/spark/jars/* /spark-jars
查看：
http://192.168.56.100:9870/explorer.html#/spark-jars

Hive on Spark测试：
（1）启动hive客户端
hive
（2）创建一张测试表
hive (default)> create database gmall;
hive (default)> use gmall;
hive (default)> create table student(id int, name string);
（3）通过insert测试效果
hive (default)> insert into table student values(1,'abc');
如下结果表明成功：
--------------------------------------------------------------------------------------
          STAGES   ATTEMPT        STATUS  TOTAL  COMPLETED  RUNNING  PENDING  FAILED
--------------------------------------------------------------------------------------
          STAGES   ATTEMPT        STATUS  TOTAL  COMPLETED  RUNNING  PENDING  FAILED
--------------------------------------------------------------------------------------
Stage-0 ........         0      FINISHED      1          1        0        0       0
--------------------------------------------------------------------------------------
          STAGES   ATTEMPT        STATUS  TOTAL  COMPLETED  RUNNING  PENDING  FAILED
--------------------------------------------------------------------------------------
Stage-0 ........         0      FINISHED      1          1        0        0       0
Stage-1 ........         0      FINISHED      1          1        0        0       0  JobMonitor (SessionState.java:logInfo(1176)) - 2025-06-29 12:54:37,807 S--------------------------------------------------------------------------------------
STAGES: 02/02    [==========================>>] 100%  ELAPSED TIME: 6.09 s

## 13. Yarn环境配置
hadoop100的/opt/module/hadoop/etc/hadoop/capacity-scheduler.xml
stop-yarn.sh
start-yarn.sh

## 14. 数仓开发工具可选用DBeaver或者DataGrip。两者都需要用到JDBC协议连接到Hive，故需要启动HiveServer2
hiveserver2
连接 IP:192.168.56.100 端口:10000  用户名：atguigu 密码：atguigu

## 15.开发模拟数据
模拟数据准备
通常企业在开始搭建数仓时，业务系统中会存在历史数据，一般是业务数据库存在历史数据，而用户行为日志无历史数据。假定数仓上线的日期为2022-06-08，为模拟真实场景，需准备以下数据。
注：在执行以下操作之前，先将HDFS上/origin_data路径下之前的数据删除。
1）启动采集通道
命令如下。
cluster.sh start
停止Maxwell。
mxw.sh stop
停止Maxwell
2）数据准备
（1）生成模拟数据
① 修改hadoop100节点的/opt/module/applog/application.yml文件，将mock.date，mock.clear，mock.clear.user，mock.new.user，mock.log.db.enable五个参数调整为如下的值。
#业务日期
mock.date: "2025-06-25"
#是否重置业务数据
mock.clear.busi: 1
#是否重置用户数据
mock.clear.user: 1
# 批量生成新用户数量
mock.new.user: 100
# 日志是否写入数据库一份  写入z_log表中
mock.log.db.enable: 0
② 执行数据生成脚本，生成第一天2025-06-25的历史数据。
lg.sh
③ 修改/opt/module/applog/application.properties文件，将mock.date、mock.clear，mock.clear.user，mock.new.user四个参数调整为如图所示的值。
#业务日期
mock.date: "2025-06-26"
#是否重置业务数据
mock.clear.busi: 0
#是否重置用户数据
mock.clear.user: 0
# 批量生成新用户
mock.new.user: 0
④ 执行数据生成脚本，生成第二天2025-06-26的历史数据。
lg.sh
⑤ 之后只修改/opt/module/applog/application.properties文件中的mock.date参数，依次改为2022-06-27，2022-06-28，并分别生成对应日期的数据。
⑥ 删除/origin_data/gmall/log目录，将⑤中提到的参数修改为2025-06-29，并生成当日模拟数据。
（2）全量表同步
① 执行全量表同步脚本
mysql_to_hdfs_full.sh all 2025-06-29
② 观察HDFS上是否出现全量表数据
（3）增量表首日全量同步
① 清除Maxwell断点记录
由于Maxwell支持断点续传，而上述重新生成业务数据的过程，会产生大量的binlog操作日志，这些日志我们并不需要。故此处需清除Maxwell的断点记录，令其从binlog最新的位置开始采集。
清空Maxwell数据库，相当于初始化Maxwell。
mysql> 
drop table maxwell.bootstrap;
drop table maxwell.columns;
drop table maxwell.databases;
drop table maxwell.heartbeats;
drop table maxwell.positions;
drop table maxwell.schemas;
drop table maxwell.tables;
② 修改Maxwell配置文件中的mock_date参数
vi /opt/module/maxwell/config.properties
mock_date=2025-06-29
③ 启动Maxwell
mxw.sh start
④ 执行增量表首日全量同步脚本
mysql_to_kafka_inc_init.sh all
⑤ 观察HDFS上是否出现增量表数据
http://192.168.56.100:9870/explorer.html#/origin_data/gmall/db

## 16. ODS/DWD/DIM/DWS/ADS 数据装载与计算
建库语句和建表语句、定期执行脚本

## 17. 数据导出
DataX --> Mysql

## 18. DolphinScheduler 部署任务调度









