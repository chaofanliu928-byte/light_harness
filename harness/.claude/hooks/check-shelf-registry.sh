#!/bin/bash
# check-shelf-registry.sh — 落库登记软闸(I5)
# Stop hook:每次 Stop 扫 docs/references/ 带日期前缀留痕件与目录卡比对,未登记 stderr 点名提醒。
#
# 问题:落库不登记只能 git 考古发现。本 hook 是软的一道;硬兜底在 check-handoff.sh
#   覆写交叉核(I4),软硬两道时点分明 — 本 hook **永不阻断**(无任何阻断退出码路径,只 exit 0)。
#
# 口径(spec 2026-06-10-context-layer-design.md,批1b 任务10):
#   1. 扫描:docs/references/ 顶层 YYYY-MM-DD- 前缀的 .md/.html(非 README);
#      无前缀标准件豁免(下游装机零告警)
#   2. 比对:逐文件 grep -F 文件名 于 docs/references/README.md;未命中 → stderr 一行点名,exit 0
#   3. 目录卡缺失:仅当存在日期前缀留痕件时提示「建目录卡」+ 内嵌最小模板;
#      无留痕件(或 references/ 不存在)→ 静默 exit 0
#
# 协议(Claude Code Stop hook):
#   stdin JSON(stop_hook_active 安全带);永远 exit 0=放行(软提醒走 stderr,不阻断)
#   手工模式契约:stdin 为 {} 或解析失败 → 不得静默 exit 0,扫描照跑(echo '{}' | bash 本脚本)
#   降级协议(exit 0 + stderr 一行痕迹)仅限环境工具缺失,沿 check-context-chain.sh 工具缺失降级协议(同 hook 族同协议)
#
# 设计硬前提:
#   - LF 行尾(.gitattributes *.sh eol=lf)
#   - 中文 grep:统一 LC_ALL=C.UTF-8(无则 C),防字节级误匹配
#   - 双层探测(M15 范式):docs/ 或 harness/docs/,与 check-handoff.sh 双层探测段逐字同构
#
# 命名:无点名排除 → 分发下游(下游是主战场)。
#       落 .claude/hooks/ → credentials.conf 自动纳凭证义务(改本 hook 须 audit 凭证)。

set -u

# 中文 grep/awk 字节纪律:优先 C.UTF-8(含 C.utf8 拼写),无则 C(UTF-8 自同步,定串匹配等效安全)
_loc=$(locale -a 2>/dev/null | grep -i -m1 -E '^C\.(UTF-?8)$')
if [ -n "$_loc" ]; then export LC_ALL="$_loc"; else export LC_ALL=C; fi

INPUT=$(cat)

# ============================================================================
# 0. 防死循环安全带 + 依赖降级(仅工具缺失可降级,stdin 形态不豁免)
# ============================================================================
if command -v jq >/dev/null 2>&1; then
    if [ "$(echo "$INPUT" | jq -r '.stop_hook_active' 2>/dev/null)" = "true" ]; then
        exit 0
    fi
else
    echo "⚠️ jq 缺失,check-shelf-registry.sh 降级跳过" >&2
    exit 0
fi

for t in grep find; do
    if ! command -v "$t" >/dev/null 2>&1; then
        echo "⚠️ $t 缺失,check-shelf-registry.sh 降级跳过" >&2
        exit 0
    fi
done

# ============================================================================
# 1. 双层探测(M15 范式):定位 WORK_DIR 并 cd 进去,登记比对按 docs/... 相对解析
# ============================================================================
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
if   [ -d "$PROJECT_DIR/harness/docs" ]; then WORK_DIR="$PROJECT_DIR/harness"
elif [ -d "$PROJECT_DIR/docs" ];         then WORK_DIR="$PROJECT_DIR"
else exit 0; fi   # 无 docs/ → 无 references/ 可扫,放行
cd "$WORK_DIR" 2>/dev/null || exit 0

REF="docs/references"
CARD="$REF/README.md"

# ============================================================================
# 2. references/ 不存在 → 静默放行(零打扰)
# ============================================================================
[ -d "$REF" ] || exit 0

# ============================================================================
# 3. 收集带日期前缀留痕件(顶层 .md/.html;README 与无前缀标准件豁免)
#    前缀 ERE 全 ASCII,C locale 下对 CJK 文件名无字节假阳性
# ============================================================================
TRACE=$(find "$REF" -maxdepth 1 -type f \( -name '*.md' -o -name '*.html' \) 2>/dev/null \
    | while IFS= read -r f; do
          fn="${f##*/}"
          [ "$fn" = "README.md" ] && continue
          if printf '%s\n' "$fn" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}-'; then
              printf '%s\n' "$fn"
          fi
      done)

[ -z "$TRACE" ] && exit 0   # 无留痕件 → 静默(标准件豁免,下游装机零告警)

# ============================================================================
# 4. 目录卡缺失 → 提示建卡 + 内嵌最小模板(逐字 = 规矩头一行 + 表头两行);不阻断
# ============================================================================
if [ ! -f "$CARD" ]; then
    {
        echo "⚠️ 落库登记软提醒(不阻断):$REF/ 有带日期前缀留痕件但缺目录卡 $CARD — 请建目录卡并逐件登记,最小模板:"
        echo "## 目录卡(落库即登记:写入本目录的同一批动作里在下表加一行)"
        echo "| 日期 | 文件 | 一句话 | 核验等级 |"
        echo "|---|---|---|---|"
        echo "待登记留痕件: $(printf '%s' "$TRACE" | tr '\n' ' ')"
    } >&2
    exit 0
fi

# ============================================================================
# 5. 逐文件 grep -F 比对目录卡;未登记 → stderr 一行点名;永远 exit 0
# ============================================================================
UNREG=""
while IFS= read -r fn; do
    [ -z "$fn" ] && continue
    if ! grep -Fq -- "$fn" "$CARD" 2>/dev/null; then
        UNREG="$UNREG $fn"
    fi
done <<EOF
$TRACE
EOF

if [ -n "$UNREG" ]; then
    echo "⚠️ 落库未登记软提醒(不阻断):以下留痕件未在目录卡 $CARD 登记 —${UNREG};落库即登记:在目录卡表加一行 | <日期> | <文件> | <一句话> | <核验等级或\"—\"> |。" >&2
fi

exit 0
