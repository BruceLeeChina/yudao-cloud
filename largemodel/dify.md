## ################################### 智能体应用平台 https://github.com/langgenius/dify.git ###################################

cd docker
cp .env.example .env
#docker compose up -d

docker-compose -f docker-compose.yaml -p dify up -d

http://192.168.56.17:8080