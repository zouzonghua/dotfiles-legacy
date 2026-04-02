#!/bin/bash
# 接收参数: $1=正常, $2=警告, $3=高压 (均为 256 色代号)
normalize_color() {
    local c="$1"
    c="${c#colour}"
    echo "$c"
}

C_NORMAL=$(normalize_color "${1:-76}")
C_WARN=$(normalize_color "${2:-142}")
C_CRIT=$(normalize_color "${3:-160}")

# 获取核心数与负载
if [[ "$OSTYPE" == "darwin"* ]]; then
    CPUS=$(sysctl -n hw.ncpu)
    LOADS=$(uptime | awk -F'load averages: ' '{print $2}' | sed 's/,//g')
else
    CPUS=$(nproc)
    LOADS=$(uptime | awk -F'load average: ' '{print $2}' | sed 's/,//g')
fi

# 计算 1 分钟负载百分比
CPUS=${CPUS:-1}
L1=$(echo $LOADS | awk '{print $1}')
PCT_VAL=$(awk -v l="$L1" -v c="$CPUS" 'BEGIN {printf "%.0f", (l/c)*100}')

# 颜色判定
if [ "$PCT_VAL" -gt 80 ]; then
    COLOR=$C_CRIT
elif [ "$PCT_VAL" -gt 50 ]; then
    COLOR=$C_WARN
else
    COLOR=$C_NORMAL
fi

# 格式化输出
CPU_STR=$(echo "$LOADS" | awk -v cpus="$CPUS" '{printf "%.1f%% %.1f%% %.1f%%", $1/cpus*100, $2/cpus*100, $3/cpus*100}')

# 适配 Terminal.app 的输出格式
echo "#[fg=colour${COLOR}]CPU: ${CPU_STR}#[default]"
