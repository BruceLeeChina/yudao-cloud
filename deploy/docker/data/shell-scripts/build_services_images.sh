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