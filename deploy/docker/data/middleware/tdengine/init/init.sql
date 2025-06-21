-- 创建 ruoyi_vue_pro 数据库
CREATE DATABASE IF NOT EXISTS ruoyi_vue_pro
KEEP 3650  -- 数据保留3650天
BUFFER 256 -- 内存块大小256MB
WAL_LEVEL 1; -- 写日志级别1

-- 设置默认数据库
USE ruoyi_vue_pro;

-- 可选：创建示例表
CREATE TABLE IF NOT EXISTS device_metrics (
  ts TIMESTAMP,
  device_id NCHAR(64),
  temperature FLOAT,
  humidity INT,
  location NCHAR(255)
);