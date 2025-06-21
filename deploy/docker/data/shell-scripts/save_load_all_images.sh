#!/bin/bash
# 保存所有镜像为独立文件，文件名格式：镜像名_标签.tar（自动处理特殊字符）
docker images --format "{{.Repository}} {{.Tag}}" | while read -r repo tag; do
  # 跳过标签为 <none> 的镜像
  if [[ "$tag" == "<none>" ]]; then
    continue
  fi

  # 处理镜像名中的特殊字符（如 / 和 : 替换为 _）
  filename=$(echo "${repo}:${tag}" | sed 's/[\/:]/_/g').tar

  # 保存镜像到文件
  docker save -o "$filename" "${repo}:${tag}"
  echo "已保存: ${repo}:${tag} => $filename"
done
echo "所有镜像已保存完成！"

# 使用方法
#chmod +x save_images.sh  # 添加执行权限
#./save_images.sh         # 执行脚本
# 恢复脚本
#cd /opt/yudao/images/ && for file in *.tar; do docker load -i "$file"; done

