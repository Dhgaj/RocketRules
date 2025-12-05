#!/bin/bash

# 定义要排序的文件列表
FILES=("direct.list" "proxy.list" "reject.list")

# 切换到 Rules 目录
cd "$(dirname "$0")/../Rules" || exit

for FILE_PATH in "${FILES[@]}"; do
    # 检查文件是否存在
    if [ ! -f "$FILE_PATH" ]; then
        echo "警告：文件 '$FILE_PATH' 未找到，跳过。"
        continue
    fi

    # 使用 sort 命令对文件内容进行排序，并覆盖原文件
    echo "正在处理文件: $FILE_PATH"

    # 找出并显示重复的规则
    DUPLICATES=$(sort "$FILE_PATH" | uniq -d)
    if [ -n "$DUPLICATES" ]; then
        echo "以下规则在 '$FILE_PATH' 中是重复的，将被移除："
        echo "$DUPLICATES"
    else
        echo "在 '$FILE_PATH' 中未发现重复规则。"
    fi

    # 提取 DOMAIN 规则，排序并去重
    grep "^DOMAIN," "$FILE_PATH" | sort -u > "${FILE_PATH}.domain.tmp"
    # 提取 DOMAIN-SUFFIX 规则，排序并去重
    grep "^DOMAIN-SUFFIX," "$FILE_PATH" | sort -u > "${FILE_PATH}.suffix.tmp"
    # 提取其他规则（如果存在），排序并去重
    grep -v -e "^DOMAIN," -e "^DOMAIN-SUFFIX," "$FILE_PATH" | sort -u > "${FILE_PATH}.other.tmp"

    # 将排序后的内容写回原文件，先 DOMAIN，再 DOMAIN-SUFFIX，最后其他
    cat "${FILE_PATH}.domain.tmp" > "$FILE_PATH"
    cat "${FILE_PATH}.suffix.tmp" >> "$FILE_PATH"
    cat "${FILE_PATH}.other.tmp" >> "$FILE_PATH"

    # 清理临时文件
    rm "${FILE_PATH}.domain.tmp" "${FILE_PATH}.suffix.tmp" "${FILE_PATH}.other.tmp"

    echo "文件 '$FILE_PATH' 已成功排序和去重。"
done

echo "所有指定规则文件已处理完成。"
