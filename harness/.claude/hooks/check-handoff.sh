#!/bin/bash
# check-handoff.sh v3 — 工作台闸(I4,机器闸层②)双模式(C 案追记③,2026-06-12 起)
#
# 模式 1(无参数)— Stop 执法(自动模式):覆写信号在场时机械核 promotion 凭证;平时不索债。
#   判定(spec §3.1 I4,2026-06-10-context-layer-design.md):
#   1. handoff 不存在 且 有活跃 plan → exit 2 "先建台账"(既有行为保留);两者都无 → exit 0
#   2. 覆写信号 := 最新 docs/completed/handoff-*.md 的 mtime 在 60 分钟内
#      (60 分钟窗仅作自动模式**限噪器**保留 — Stop 每次会话末都触发,无窗会对历史归档反复索债;
#       超窗不硬核(B19)由模式 2 开场对账兜)
#   3. 信号在场 → promotion 行 C1 整行文法校验(与 structured-handoff SKILL/模板三处同文法)
#      + 锚点抽查(test -f && test -s)+ references/ 登记交叉核(带日期前缀才查目录卡,标准件豁免)
#      + 空账判定(归档件暂存区 "- 无" 或无暂存节(旧格式 B9)才合法)+ skipped 回收点 test -f
#      + 阻塞(理由非空)= 合法中间态放行(exit 0 + stderr 提示)
#   4. 无信号 → 24h 软提醒(台账停更 >24h 且其后有 commit 且近 7 天有 plan → stderr,exit 0);
#      其余静默 exit 0(暂存有条目平时不索债)。原 10 分钟硬闸废除(D8 裁决)。
#
# 模式 2(--reconcile)— 开场对账(工具箱,手工命令): bash check-handoff.sh --reconcile
#   纯状态判据,无任何时间推断(不看 mtime/时钟/窗口)— 全时核台账凭证:
#   promotion 行同一 GRAMMAR 文法核 → 按状态分流:
#     未核 × 归档件存在 → 状态告警"上次覆写可能未走门禁";未核 × 无归档件 → 新台账合法
#     已核 × 无归档件 → 状态告警"凭证不自洽"(已核蕴含归档已发生 — 上一条的对偶判据)
#     已核 → 锚点抽查 + 登记交叉核 + 空账判定(B9 兼容)全时执行,不看窗口
#     skipped → 回收点 test -f;阻塞 → 提示先解除再开新工作
#   归档件选取按文件名字典序取最大(名内含时间戳,真·零时钟;fresh clone 后 mtime
#   同刻,ls -t 不确定);Stop 分支仍用 mtime 选取(窗口限噪器领地,不动)
#   恒输出一行状态结论(防空转不可见)+ 恒 exit 0(输出给 AI 读,处置靠 AI,不阻断)。
#   依据:docs/decisions/2026-06-11-session-chain-reconciliation.md 追记③
#   ("覆写未走门禁"的直接状态判据 = promotion=未核 × 归档件存在,不依赖时钟)。
#
# 协议(Claude Code Stop hook,模式 1):
#   stdin JSON(stop_hook_active 安全带);exit 0=放行 / exit 2=阻断 + stderr 引导(哪条不合+怎么修)
#   手工模式契约:stdin 为 {} 或解析失败 → 不得静默 exit 0,全部检查照跑(echo '{}' | bash 本脚本)
#   降级协议(exit 0 + stderr 一行痕迹)仅限环境工具缺失,沿 check-context-chain.sh 工具缺失降级协议(同 hook 族同协议)
#
# 设计硬前提:
#   - POSIX awk(禁 gawk 三参数 match);LF 行尾(.gitattributes *.sh eol=lf)
#   - 中文 grep:统一 LC_ALL=C.UTF-8(无则 C),防字节级误匹配
#   - 双层探测(M15 范式):docs/ 或 harness/docs/,cd 进 WORK_DIR 后锚点按 docs/... 相对解析
#   - 全角 token → 文法不命中 exit 2 + stderr 提示「全角」(半角纪律,权威住 structured-handoff SKILL;沿 2026-04-28 C3 Y3 教训)

set -u

# 中文 grep/awk 字节纪律:优先 C.UTF-8(含 C.utf8 拼写),无则 C(UTF-8 自同步,定串匹配等效安全)
_loc=$(locale -a 2>/dev/null | grep -i -m1 -E '^C\.(UTF-?8)$')
if [ -n "$_loc" ]; then export LC_ALL="$_loc"; else export LC_ALL=C; fi

# ============================================================================
# 0a. 参数判定(--reconcile 模式开关)
# ============================================================================
# 必须在 INPUT=$(cat) 之前:对账是手工命令,不读 stdin;若先 cat,
# 交互终端跑 --reconcile 会在 cat 上挂死。set -u 下用 ${1:-} 取参。
# (与 check-audit-coverage.sh §0a 同款范式)

RECONCILE=0
if [ "${1:-}" = "--reconcile" ]; then
    RECONCILE=1
fi

# ============================================================================
# 0. 防死循环安全带 + 依赖降级(仅工具缺失可降级,stdin 形态不豁免;
#    仅 Stop 模式读 stdin — --reconcile 不读、无 stop_hook_active 语义)
# ============================================================================
if [ "$RECONCILE" -eq 0 ]; then
    INPUT=$(cat)

    if command -v jq >/dev/null 2>&1; then
        if [ "$(echo "$INPUT" | jq -r '.stop_hook_active' 2>/dev/null)" = "true" ]; then
            exit 0
        fi
    else
        echo "⚠️ jq 缺失,check-handoff.sh 降级跳过" >&2
        exit 0
    fi
fi

for t in grep awk find stat date; do
    if ! command -v "$t" >/dev/null 2>&1; then
        echo "⚠️ $t 缺失,check-handoff.sh 降级跳过" >&2
        exit 0
    fi
done

# ============================================================================
# 1. 双层探测(M15 范式):定位 WORK_DIR 并 cd 进去,锚点/指针按 docs/... 相对解析
# ============================================================================
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
if   [ -d "$PROJECT_DIR/harness/docs" ]; then WORK_DIR="$PROJECT_DIR/harness"
elif [ -d "$PROJECT_DIR/docs" ];         then WORK_DIR="$PROJECT_DIR"
else   # 无 docs/ → 无台账也无 plan,放行(对账模式恒输出一行结论,防空转不可见)
    [ "$RECONCILE" -eq 1 ] && echo "台账对账:未找到 docs/ 目录(无台账可核)。" >&2
    exit 0
fi
if ! cd "$WORK_DIR" 2>/dev/null; then
    [ "$RECONCILE" -eq 1 ] && echo "台账对账:无法进入 $WORK_DIR(目录不可达)。" >&2
    exit 0
fi

HANDOFF="docs/active/handoff.md"
NOW=$(date +%s)

# GNU/BSD stat 兼容(沿用旧 check-handoff.sh 范式)
file_mtime() {
    if stat --version >/dev/null 2>&1; then
        stat -c %Y "$1" 2>/dev/null    # GNU (Linux)
    else
        stat -f %m "$1" 2>/dev/null    # BSD (macOS)
    fi
}

trim() {  # 去首尾空白
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# 整行校验 ERE(文法契约: .claude/skills/structured-handoff/SKILL.md「promotion 声明文法」节,三处同文法;
# Stop 执法与 --reconcile 对账共用同一条,不另造文法)
GRAMMAR='^promotion: (未核|已核\(上架: [^;]+; 弃置: [0-9]+ 条\)|skipped\(理由: [^;]+; 回收: [^)]+\)|阻塞\(理由: [^)]+\))$'

# 空账判定共用核(Stop 与 --reconcile 同口径):归档件暂存区有真实条目则返回 0;
# "- 无" / 无 "## 待晋升暂存" 节(旧格式 B9)返回 1(空账形合法)
archive_staging_has_entries() {
    awk '
        { sub(/\r$/, ""); sub(/[[:space:]]+$/, "") }
        /^## 待晋升暂存/ { f=1; next }
        /^## / { f=0 }
        f && /^- / && $0 != "- 无" { found=1; exit }
        END { exit found ? 0 : 1 }
    ' "$1" 2>/dev/null
}

# ============================================================================
# 1.5. 对账模式分支(--reconcile)— 开场对账(C 案追记③,工具箱)
# ============================================================================
# 纯状态判据,无任何时间推断(不看 mtime/时钟/60 分钟窗);
# 复用 Stop 执法的同一 GRAMMAR / trim / 空账判定 / 锚点抽查与登记交叉核口径;
# 恒输出一行状态结论(防空转不可见,与 check-audit-coverage --reconcile"账齐带计数"同理)
# + 恒 exit 0(工具箱:输出给 AI 读,处置靠 AI;本分支不得有任何 exit 2)。

if [ "$RECONCILE" -eq 1 ]; then
    if [ ! -f "$HANDOFF" ]; then
        echo "台账对账:$HANDOFF 不存在(无台账可核)— 开新工作先建台账(模板: .claude/skills/structured-handoff/handoff-template.md,或运行 /structured-handoff)。" >&2
        exit 0
    fi

    # 归档件选取按文件名字典序取最大(审查 Minor-2):归档名 handoff-YYYYmmdd-HHMMSS.md
    # 自带时间戳,名序即时序 — 真·零时钟;fresh clone 后所有 mtime 同刻,ls -t 选择不确定。
    # (Stop 分支仍用 ls -t:那是 60 分钟窗限噪器的领地,行为不动)
    LATEST_ARCHIVE=$(ls docs/completed/handoff-*.md 2>/dev/null | sort | tail -1)
    PROMO=$(grep -m1 -E '^promotion:' "$HANDOFF" 2>/dev/null | tr -d '\r')

    if [ "$(grep -c -E '^promotion:' "$HANDOFF" 2>/dev/null)" -gt 1 ]; then
        echo "台账对账:检测到多条 promotion 行,以首行为准——请删除多余行(常见成因:追加了新行而未编辑原行)。" >&2
    fi

    if [ -z "$PROMO" ]; then
        {
            echo "台账对账:promotion 行缺失 — 文法不合。"
            echo "修法:按 /structured-handoff「promotion 声明文法」在 docs/active/handoff.md 补写:"
            echo "  promotion: 未核  # 或 已核(上架: <路径>...; 弃置: <N> 条) / skipped(理由: <非空>; 回收: <归档件>) / 阻塞(理由: <非空>)"
            if grep -q 'promotion' "$HANDOFF" 2>/dev/null; then
                echo "注意:台账里有疑似 promotion 字样但行首格式不命中 — 检查全角冒号/行首空格(token 必须全半角)。"
            fi
        } >&2
        exit 0
    fi

    if ! printf '%s' "$PROMO" | grep -Eq "$GRAMMAR"; then
        {
            echo "台账对账:promotion 行文法不合 — 现行: $PROMO"
            echo "修法:按 /structured-handoff「promotion 声明文法」改写(合法四态:未核 / 已核(上架: ...; 弃置: <N> 条) / skipped(理由: ...; 回收: ...) / 阻塞(理由: ...))。"
            if printf '%s' "$PROMO" | grep -q -F -e '（' -e '）' -e '：' -e '；' -e '，'; then
                echo "检测到全角符号 — 文法 token ( ) : ; , 必须全半角,请改为半角(检查全角)。"
            fi
        } >&2
        exit 0
    fi

    # ========================================================================
    # 活跃任务索引结构核(--reconcile 追加段,Task 2 — 恒 exit 0 全软提醒)
    # 核①:机读表头存在性 + 半角文法 ERE
    # 核②:挂起行复活触发器列非空(awk -F'|' section 窗内扫)
    # ========================================================================

    # 核①:取 ## 活跃任务索引 段标题下一非空行作为机读表头
    _ATI_HEADER=$(awk '
        { sub(/\r$/, "") }
        /^## 活跃任务索引/ { in_sec=1; next }
        in_sec && /^[[:space:]]*$/ { next }
        in_sec { print; exit }
    ' "$HANDOFF" 2>/dev/null)

    if [ -z "$_ATI_HEADER" ]; then
        echo "活跃任务索引机读表头缺失 — 请在 ## 活跃任务索引 段标题下补写机读表头(格式: 活跃任务: N(进行中 X / 挂起 Y))。" >&2
    elif printf '%s' "$_ATI_HEADER" | grep -qE '^活跃任务: [0-9]+\(进行中 [0-9]+ / 挂起 [0-9]+\)$'; then
        : # 核①通过
    elif printf '%s' "$_ATI_HEADER" | grep -qF -e '（' -e '）' -e '：'; then
        echo "检测到全角符号 — 活跃任务索引机读表头 token 必须半角(: ( ) / 须为半角);现行: $_ATI_HEADER" >&2
    else
        echo "机读表头文法不合 — 现行: $_ATI_HEADER(期望格式: 活跃任务: N(进行中 X / 挂起 Y))。" >&2
    fi

    # 核②:挂起行复活触发器列非空(awk section 窗:## 活跃任务索引 开窗、遇下一 ## 关窗)
    awk -F'|' '
        { sub(/\r$/, "") }
        /^## 活跃任务索引/ { in_sec=1; next }
        in_sec && /^## / { in_sec=0 }
        in_sec {
            # 跳过表头行、分隔行、占位行
            status = $2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
            if (status == "状态" || status ~ /^[-|]+$/ || status == "(无活跃任务)") next
            if (status == "挂起") {
                trigger = $4; gsub(/^[[:space:]]+|[[:space:]]+$/, "", trigger)
                task = $3; gsub(/^[[:space:]]+|[[:space:]]+$/, "", task)
                if (trigger == "" || trigger == "—") {
                    print "挂起行触发器为空: " task
                }
            }
        }
    ' "$HANDOFF" >&2

    case "$PROMO" in
        "promotion: 未核")
            # 状态判据(追记③):未核 × 归档件存在 = 上次覆写可能未走门禁(不依赖时钟)
            if [ -n "$LATEST_ARCHIVE" ]; then
                echo "台账对账:状态告警 — 上次覆写可能未走门禁(promotion=未核但归档件存在: $LATEST_ARCHIVE)——按 /structured-handoff 补清账。" >&2
            else
                echo "台账对账:promotion=未核且无归档件 — 新台账合法,无欠账。" >&2
            fi
            exit 0
            ;;

        "promotion: 阻塞("*)
            body="${PROMO#promotion: 阻塞(理由: }"
            reason=$(trim "${body%)}")
            if [ -z "$reason" ]; then
                echo "台账对账:promotion=阻塞 但理由空白 — 不合形;补非空理由: promotion: 阻塞(理由: <为什么阻塞/等谁拍板>)。" >&2
            else
                echo "台账对账:promotion=阻塞(理由: $reason)— 上次留了阻塞,先解除再开新工作(解除后重走晋升门禁改写为 已核/skipped)。" >&2
            fi
            exit 0
            ;;

        "promotion: skipped("*)
            body="${PROMO#promotion: skipped(理由: }"
            reason=$(trim "${body%%;*}")
            reclaim="${body#*; 回收: }"   # 完整分隔符 "; 回收: ":理由段按文法不含分号,该分隔符不会出现在理由内
            reclaim=$(trim "${reclaim%)}")
            if [ -z "$reason" ]; then
                echo "台账对账:promotion=skipped 但理由空白 — 不合形;补非空理由: promotion: skipped(理由: <非空>; 回收: <归档件路径>)。" >&2
                exit 0
            fi
            if [ ! -f "$reclaim" ]; then
                echo "台账对账:promotion=skipped 但回收点不存在: $reclaim(test -f 失败)— 修正为真实归档件路径(docs/completed/handoff-*.md)。" >&2
                exit 0
            fi
            echo "台账对账:promotion=skipped;回收点在($reclaim)— 通过(欠的清账记得找回)。" >&2
            exit 0
            ;;

        "promotion: 已核("*)
            # 对偶状态判据(审查 Minor-3,与「未核×归档存在」对偶):已核蕴含固定序①归档已发生,
            # 无归档件 = 凭证不自洽(可能绕过 skill 手写声明,或归档件被删)
            if [ -z "$LATEST_ARCHIVE" ]; then
                echo "台账对账:状态告警 — 凭证不自洽(promotion=已核但 docs/completed/ 无归档件)——可能绕过 skill 手写声明或归档被删;按 /structured-handoff 重新走门禁。" >&2
                exit 0
            fi

            body="${PROMO#promotion: 已核(上架: }"
            SHELF=$(trim "${body%%;*}")
            rest="${body#*弃置: }"
            DISCARD=$(trim "${rest%% 条)*}")

            if [ "$SHELF" = "无" ]; then
                # 空账判定全时执行(不看窗口);弃置 ≥1 = 全弃置,合法
                if [ "$DISCARD" -eq 0 ] 2>/dev/null && [ -n "$LATEST_ARCHIVE" ] && archive_staging_has_entries "$LATEST_ARCHIVE"; then
                    echo "台账对账:状态告警 — promotion 写空账形(上架: 无; 弃置: 0 条)但最新归档件($LATEST_ARCHIVE)暂存区有条目,零账不实——重走 /structured-handoff 清账逐条裁决。" >&2
                else
                    echo "台账对账:promotion=已核;上架=无(空账/全弃置)核对通过(归档件暂存区无真实条目或旧格式视同空)。" >&2
                fi
                exit 0
            fi

            # 锚点抽查 + 登记交叉核(与 Stop 同口径,全时执行;缺项点名不阻断)
            R_N=0
            R_FAILED=0
            set -f
            OLDIFS=$IFS; IFS=','
            for p in $SHELF; do
                p=$(trim "$p")
                [ -z "$p" ] && continue
                R_N=$((R_N + 1))
                if [ ! -f "$p" ]; then
                    echo "台账对账:已核声明的上架锚点不存在: $p(test -f 失败)— 确认文件已实际写入(路径以 docs/... 相对仓库写)或修正声明路径。" >&2
                    R_FAILED=1
                    continue
                fi
                if [ ! -s "$p" ]; then
                    echo "台账对账:已核声明的上架锚点为空文件: $p(test -s 失败)— 空壳不算上架凭证,补齐内容或改走弃置/顺延。" >&2
                    R_FAILED=1
                    continue
                fi
                # references/ 登记交叉核:带日期前缀的留痕件必须在目录卡有行;无前缀标准件豁免(4.1.7)
                case "$p" in
                    docs/references/*)
                        fn="${p##*/}"
                        if printf '%s' "$fn" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}-'; then
                            if ! grep -Fq -- "$fn" docs/references/README.md 2>/dev/null; then
                                echo "台账对账:上架锚点 $p 落库未登记 — 目录卡 docs/references/README.md 无 \"$fn\" 登记行,补一行登记(落库即登记)。" >&2
                                R_FAILED=1
                            fi
                        fi
                        ;;
                esac
            done
            IFS=$OLDIFS
            set +f

            if [ "$R_FAILED" -eq 0 ]; then
                echo "台账对账:promotion=已核;文法/锚点($R_N 项)/登记交叉核通过。" >&2
            else
                echo "台账对账:promotion=已核 但凭证有缺(见上方点名)— 补齐后重跑本命令复核。" >&2
            fi
            exit 0
            ;;
    esac

    echo "台账对账:promotion 状态未识别(防御分支,文法已穷举四态不应到达): $PROMO" >&2
    exit 0
fi

# ============================================================================
# 2. 存在性检查(既有行为保留):无台账 + 有活跃 plan → 先建台账
# ============================================================================
if [ ! -f "$HANDOFF" ]; then
    if ls docs/superpowers/plans/*.md >/dev/null 2>&1; then
        {
            echo "存在活跃计划(docs/superpowers/plans/)但无工作台台账 — Stop 已阻断。"
            echo "修法:先创建 docs/active/handoff.md 记录当前进度"
            echo "(模板: .claude/skills/structured-handoff/handoff-template.md,或运行 /structured-handoff)。"
        } >&2
        exit 2
    fi
    exit 0
fi

# ============================================================================
# 3. 覆写信号探测:最新 docs/completed/handoff-*.md 的 mtime 在 60 分钟内
#    (超窗后不再硬核 promotion — B19 显式残留缺口,审查兜)
# ============================================================================
SIGNAL=0
LATEST_ARCHIVE=$(ls -t docs/completed/handoff-*.md 2>/dev/null | head -1)
if [ -n "$LATEST_ARCHIVE" ]; then
    ARCH_MTIME=$(file_mtime "$LATEST_ARCHIVE")
    if [ -n "$ARCH_MTIME" ] && [ $((NOW - ARCH_MTIME)) -le 3600 ]; then
        SIGNAL=1
    fi
fi

# ============================================================================
# 4. 信号在场 → 机械核 promotion 凭证(文法 + 锚点 + 登记交叉核)
# ============================================================================
if [ "$SIGNAL" = 1 ]; then
    # 整行校验 ERE:共用 GRAMMAR(定义见 §1.5 前,与 --reconcile 同一条)

    PROMO=$(grep -m1 -E '^promotion:' "$HANDOFF" 2>/dev/null | tr -d '\r')

    # 多条 promotion 行诊断(现实失败模式:AI 追加新行而未编辑原行)— 只补诊断,阻断方向不变
    if [ "$(grep -c -E '^promotion:' "$HANDOFF" 2>/dev/null)" -gt 1 ]; then
        echo "检测到多条 promotion 行,以首行为准——请删除多余行(常见成因:追加了新行而未编辑原行)。" >&2
    fi

    if [ -z "$PROMO" ]; then
        {
            echo "覆写信号在场(最新归档件 $LATEST_ARCHIVE 在 60 分钟内)但台账缺 promotion 行 — Stop 已阻断。"
            echo "修法:走晋升门禁(/structured-handoff 清账流程),在 docs/active/handoff.md 写:"
            echo "  promotion: 已核(上架: <路径>[, <路径>]...; 弃置: <N> 条)  # 或 skipped(理由+回收点)/阻塞(理由)"
            if grep -q 'promotion' "$HANDOFF" 2>/dev/null; then
                echo "注意:台账里有疑似 promotion 字样但行首格式不命中 — 检查全角冒号/行首空格(token 必须全半角)。"
            fi
        } >&2
        exit 2
    fi

    if ! printf '%s' "$PROMO" | grep -Eq "$GRAMMAR"; then
        {
            echo "覆写信号在场但 promotion 行文法不合 — Stop 已阻断。"
            echo "现行: $PROMO"
            echo "合法文法(C1,空话格式无路径段即不合法):"
            echo "  promotion: 未核"
            echo "  promotion: 已核(上架: <路径>[, <路径>]...; 弃置: <N> 条)   # 上架段可为字面 \"无\""
            echo "  promotion: skipped(理由: <非空>; 回收: <归档件路径>)"
            echo "  promotion: 阻塞(理由: <非空>)"
            if printf '%s' "$PROMO" | grep -q -F -e '（' -e '）' -e '：' -e '；' -e '，'; then
                echo "检测到全角符号 — 文法 token ( ) : ; , 必须全半角,请改为半角(检查全角)。"
            fi
        } >&2
        exit 2
    fi

    case "$PROMO" in
        "promotion: 未核")
            {
                echo "覆写信号在场但 promotion 仍为 未核(疑似绕过晋升门禁手工覆写)— Stop 已阻断。"
                echo "修法:走 /structured-handoff 晋升门禁逐条裁决暂存条目,改写 promotion 为 已核(...);"
                echo "或顺延: promotion: skipped(理由: <非空>; 回收: $LATEST_ARCHIVE)。"
            } >&2
            exit 2
            ;;

        "promotion: 阻塞("*)
            body="${PROMO#promotion: 阻塞(理由: }"
            reason=$(trim "${body%)}")
            if [ -z "$reason" ]; then
                {
                    echo "promotion 阻塞态理由空白 — Stop 已阻断。"
                    echo "修法:阻塞必须带非空理由: promotion: 阻塞(理由: <为什么阻塞/等谁拍板>)。"
                } >&2
                exit 2
            fi
            echo "清账阻塞/待拍板中(promotion: 阻塞)— 合法中间态放行;阻塞解除后重走晋升门禁改写为 已核/skipped。" >&2
            exit 0
            ;;

        "promotion: skipped("*)
            body="${PROMO#promotion: skipped(理由: }"
            reason=$(trim "${body%%;*}")
            reclaim="${body#*; 回收: }"   # 完整分隔符 "; 回收: ":理由段按文法不含分号,该分隔符不会出现在理由内
            reclaim=$(trim "${reclaim%)}")
            if [ -z "$reason" ]; then
                {
                    echo "promotion skipped 理由空白 — Stop 已阻断。"
                    echo "修法:skipped 必须带非空理由: promotion: skipped(理由: <非空>; 回收: <归档件路径>)。"
                } >&2
                exit 2
            fi
            if [ ! -f "$reclaim" ]; then
                {
                    echo "promotion skipped 的回收点不存在: $reclaim(test -f 失败)— Stop 已阻断。"
                    echo "修法:回收点必须指向真实归档件(docs/completed/handoff-*.md),最新为 $LATEST_ARCHIVE。"
                } >&2
                exit 2
            fi
            exit 0
            ;;

        "promotion: 已核("*)
            body="${PROMO#promotion: 已核(上架: }"
            SHELF=$(trim "${body%%;*}")
            rest="${body#*弃置: }"
            DISCARD=$(trim "${rest%% 条)*}")

            if [ "$SHELF" = "无" ]; then
                # 空账形 已核(上架: 无; 弃置: 0 条):当且仅当最新归档件暂存区为 "- 无" 才合法;
                # 归档件无 "## 待晋升暂存" 节(旧格式,B9)视同 "- 无";弃置 ≥1 = 全弃置,合法
                # (判定核共用 archive_staging_has_entries,定义见 §1.5 前)
                if [ "$DISCARD" -eq 0 ] 2>/dev/null; then
                    if archive_staging_has_entries "$LATEST_ARCHIVE"; then
                        {
                            echo "promotion 写空账形(上架: 无; 弃置: 0 条)但最新归档件($LATEST_ARCHIVE)暂存区有条目 — 暂存有条目却记零账,Stop 已阻断。"
                            echo "修法:重走 /structured-handoff 清账逐条裁决(上架/弃置);或顺延: promotion: skipped(理由: <非空>; 回收: $LATEST_ARCHIVE)。"
                        } >&2
                        exit 2
                    fi
                fi
                exit 0   # 空账合法 / 全弃置(弃置 ≥1)合法;上架为 "无" 跳过锚点抽查
            fi

            # 锚点抽查:上架段按 ", " 切分;每路径 test -f && test -s(相对 WORK_DIR 的 docs/... 基准)
            set -f
            OLDIFS=$IFS; IFS=','
            for p in $SHELF; do
                p=$(trim "$p")
                [ -z "$p" ] && continue
                if [ ! -f "$p" ]; then
                    {
                        echo "promotion 已核声明的上架锚点不存在: $p(test -f 失败)— Stop 已阻断。"
                        echo "修法:确认文件已实际写入(路径以 docs/... 相对仓库写),或修正 promotion 声明路径。"
                    } >&2
                    exit 2
                fi
                if [ ! -s "$p" ]; then
                    {
                        echo "promotion 已核声明的上架锚点为空文件: $p(test -s 失败)— 空壳不算上架凭证,Stop 已阻断。"
                        echo "修法:补齐文件内容,或从声明中移除该路径并改走弃置/顺延。"
                    } >&2
                    exit 2
                fi
                # references/ 登记交叉核:带日期前缀的留痕件必须在目录卡有行;无前缀标准件豁免(4.1.7)
                # 精确前缀 docs/references/*(锚点已统一 docs/... 相对路径;子串 *references/* 会误伤 docs/preferences/)
                case "$p" in
                    docs/references/*)
                        fn="${p##*/}"
                        if printf '%s' "$fn" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}-'; then
                            if ! grep -Fq -- "$fn" docs/references/README.md 2>/dev/null; then
                                {
                                    echo "上架锚点 $p 落库未登记:目录卡 docs/references/README.md 无 \"$fn\" 登记行 — Stop 已阻断。"
                                    echo "修法:落库即登记 — 在目录卡条目表加一行: | $(date +%Y-%m-%d) | $fn | <一句话> | — |(目录卡缺失则先按表头自建)。"
                                } >&2
                                exit 2
                            fi
                        fi
                        ;;
                esac
            done
            IFS=$OLDIFS
            set +f
            exit 0
            ;;
    esac
    exit 0   # 不可达(文法已穷举四态);防御性放行
fi

# ============================================================================
# 5. 无覆写信号 → 24h 软提醒(原 10 分钟硬闸废除,D8 裁决);其余静默放行
#    条件:台账停更 >24h 且 其后存在新 commit 且 plans/ 近 7 天有活动 → stderr 提醒,exit 0
# ============================================================================
HANDOFF_MTIME=$(file_mtime "$HANDOFF")
if [ -n "$HANDOFF_MTIME" ] && [ $((NOW - HANDOFF_MTIME)) -gt 86400 ]; then
    if ! command -v git >/dev/null 2>&1; then
        echo "⚠️ git 缺失,check-handoff.sh 24h 软提醒降级跳过" >&2
    elif [ -n "$(git log -1 --since="@$HANDOFF_MTIME" --format=%H 2>/dev/null)" ] \
         && [ -n "$(find docs/superpowers/plans -name '*.md' -mtime -7 2>/dev/null | head -1)" ]; then
        echo "软提醒(不阻断):docs/active/handoff.md 已超过 24 小时未更新,其后有新 commit 且近 7 天有活跃 plan — 适时运行 /structured-handoff 更新交接。" >&2
    fi
fi

exit 0
