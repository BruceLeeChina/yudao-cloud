######## OpenHands 一个由 AI 驱动的软件开发智能体平台 类cursor https://github.com/All-Hands-AI/OpenHands.git ########
## 1. 安装部署
docker pull docker.all-hands.dev/all-hands-ai/runtime:0.47-nikolaik
docker run -it --rm --pull=always     -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.47-nikolaik     -e LOG_ALL_EVENTS=true     -v /var/run/docker.sock:/var/run/docker.sock     -v ~/.openhands:/.openhands     -p 3000:3000     --add-host host.docker.internal:host-gateway     --name openhands-app     docker.all-hands.dev/all-hands-ai/openhands:0.47

## 2. 使用 测试


