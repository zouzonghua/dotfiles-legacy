# #!/bin/bash
# C_NORMAL=${1:-"colour121"}
# C_WARN=${2:-"colour220"} # C_CRIT=${3:-"colour197"}
# 
# if [[ "$OSTYPE" == "darwin"* ]]; then
#     MEM_TOTAL_GB=$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024}')
#     PAGE_SIZE=$(vm_stat | grep "page size of" | awk '{print $8}')
#     PAGES_USED=$(vm_stat | awk '/Pages active/ {print $3} /Pages speculative/ {print $3} /Pages wired down/ {print $3} /Pages occupied by compressor/ {print $3}' | sed 's/\.//' | awk '{s+=$1} END {print s}')
#     MEM_USED_GB=$(awk -v p="$PAGES_USED" -v s="$PAGE_SIZE" 'BEGIN {print (p*s)/1024/1024/1024}')
# else
#     MEM_TOTAL_GB=$(free -g | awk '/^Mem:/{print $2}')
#     MEM_USED_GB=$(free -g | awk '/^Mem:/{print $3}')
# fi
# 
# PCT=$(awk -v u="$MEM_USED_GB" -v t="$MEM_TOTAL_GB" 'BEGIN {printf "%.0f", (u/t)*100}')
# PCT_STR=$(awk -v u="$MEM_USED_GB" -v t="$MEM_TOTAL_GB" 'BEGIN {printf "%.1f", (u/t)*100}')
# 
# if [ "$PCT" -gt 85 ]; then COLOR="colour${C_CRIT#colour}"; elif [ "$PCT" -gt 60 ]; then COLOR="colour${C_WARN#colour}"; else COLOR="colour${C_NORMAL#colour}"; fi
# 
# #echo "#[fg=$COLOR,bold]MEM: ${PCT_STR}%#[default]"
# echo "#[fg=$COLOR]MEM: ${PCT_STR}%#[default]"

#!/bin/bash
# 接收 256 色参数
normalize_color() {
    local c="$1"
    c="${c#colour}"
    echo "$c"
}

C_NORMAL=$(normalize_color "${1:-76}")
C_WARN=$(normalize_color "${2:-142}")
C_CRIT=$(normalize_color "${3:-160}")

if [[ "$OSTYPE" == "darwin"* ]]; then
    # 1. 获取总内存与页面大小
    MEM_TOTAL_BYTES=$(sysctl -n hw.memsize)
    VM_STATS=$(vm_stat)
    PAGE_SIZE=$(echo "$VM_STATS" | awk '/page size of/ {print $8}')
    
    # 2. 提取 htop 逻辑中的核心页面 (注意：vm_stat 输出带点，需要 sed 去除)
    ACTIVE=$(echo "$VM_STATS" | awk '/Pages active/ {print $3}' | sed 's/\.//')
    INACTIVE=$(echo "$VM_STATS" | awk '/Pages inactive/ {print $3}' | sed 's/\.//')
    SPECULATIVE=$(echo "$VM_STATS" | awk '/Pages speculative/ {print $3}' | sed 's/\.//')
    WIRED=$(echo "$VM_STATS" | awk '/Pages wired down/ {print $4}' | sed 's/\.//')
    PURGEABLE=$(echo "$VM_STATS" | awk '/Pages purgeable/ {print $3}' | sed 's/\.//')
    # File-backed pages 对应 htop 中的 external 页面
    EXTERNAL=$(echo "$VM_STATS" | awk '/File-backed pages/ {print $3}' | sed 's/\.//')

    PAGE_SIZE=${PAGE_SIZE:-4096}
    ACTIVE=${ACTIVE:-0}
    INACTIVE=${INACTIVE:-0}
    SPECULATIVE=${SPECULATIVE:-0}
    WIRED=${WIRED:-0}
    PURGEABLE=${PURGEABLE:-0}
    EXTERNAL=${EXTERNAL:-0}
    
    # 3. 按照 htop 源码逻辑计算 Used
    # 逻辑：Used = Active + Inactive + Speculative + Wired - Purgeable - External
    # (根据你的结论，compressor 在最后被扣除，等同于不加 compressor)
    USED_PAGES=$(awk -v a="$ACTIVE" -v i="$INACTIVE" -v s="$SPECULATIVE" -v w="$WIRED" -v p="$PURGEABLE" -v e="$EXTERNAL" \
                'BEGIN {print a + i + s + w - p - e}')
    
    TOTAL_PAGES=$(awk -v t="$MEM_TOTAL_BYTES" -v p="$PAGE_SIZE" 'BEGIN {print t / p}')
    
    PCT=$(awk -v u="$USED_PAGES" -v t="$TOTAL_PAGES" 'BEGIN {printf "%.0f", (u/t)*100}')
    PCT_STR=$(awk -v u="$USED_PAGES" -v t="$TOTAL_PAGES" 'BEGIN {printf "%.1f", (u/t)*100}')
else
    # Linux 逻辑：MemTotal - MemAvailable (与 htop 源码一致)
    MEM_TOTAL_BYTES=$(awk '/MemTotal/ {print $2 * 1024}' /proc/meminfo)
    MEM_AVAIL_BYTES=$(awk '/MemAvailable/ {print $2 * 1024}' /proc/meminfo)
    MEM_USED_BYTES=$(awk -v t="$MEM_TOTAL_BYTES" -v a="$MEM_AVAIL_BYTES" 'BEGIN {print t - a}')
    
    PCT=$(awk -v u="$MEM_USED_BYTES" -v t="$MEM_TOTAL_BYTES" 'BEGIN {printf "%.0f", (u/t)*100}')
    PCT_STR=$(awk -v u="$MEM_USED_BYTES" -v t="$MEM_TOTAL_BYTES" 'BEGIN {printf "%.1f", (u/t)*100}')
fi

# 4. 颜色判定
if [ "$PCT" -gt 80 ]; then COLOR=$C_CRIT; elif [ "$PCT" -gt 50 ]; then COLOR=$C_WARN; else COLOR=$C_NORMAL; fi

echo "#[fg=colour${COLOR}]MEM: ${PCT_STR}%#[default]"
