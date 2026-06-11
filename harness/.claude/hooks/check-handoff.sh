#!/bin/bash
# check-handoff.sh v2 — 工作台闸(I4,机器闸层②)
# Stop hook:覆写信号在场时机械核 promotion 凭证;平时不索债。
#
# 判定(spec §3.1 I4,2026-06-10-context-layer-design.md):
#   1. handoff 不存在 且 有活跃 plan → exit 2 "先建台账"(既有行为保留);两者都无 → exit 0
#   2. 覆写信号 := 最新 docs/completed/handoff-*.md 的 mtime 在 60 分钟内(超窗不硬核,B19 显式残留缺口)
#   3. 信号在场 → promotion 行 C1 整行文法校验(与 structured-handoff SKILL/模板三处同文法)
#      + 锚点抽查(test -f && test -s)+ references/ 登记交叉核(带日期前缀才查目录卡,标准件豁免)
#      + 空账判定(归档件暂存区 "- 无" 或无暂存节(旧格式 B9)才合法)+ skipped 回收点 test -f
#      + 阻塞(理由非空)= 合法中间态放行(exit 0 + stderr 提示)
#   4. 无信号 → 24h 软提醒(台账停更 >24h 且其后有 commit 且近 7 天有 plan → stderr,exit 0);
#      其余静默 exit 0(暂存有条目平时不索债)。原 10 分钟硬闸废除(D8 裁决)。
#
# 协议(Claude Code Stop hook):
#   stdin JSON(stop_hook_active 安全带);exit 0=放行 / exit 2=阻断 + stderr 引导(哪条不合+怎么修)
#   手工模式契约:stdin 为 {} 或解析失败 → 不得静默 exit 0,全部检查照跑(echo '{}' | bash 本脚本)
#   降级协议(exit 0 + stderr 一行痕迹)仅限环境工具缺失,沿用 check-context-chain.sh:5-10
#
# 设计硬前提:
#   - POSIX awk(禁 gawk 三参数 match);LF 行尾(.gitattributes *.sh eol=lf)
#   - 中文 grep:统一 LC_ALL=C.UTF-8(无则 C),防字节级误匹配
#   - 双层探测(M15 范式):docs/ 或 harness/docs/,cd 进 WORK_DIR 后锚点按 docs/... 相对解析
#   - 全角 token → 文法不命中 exit 2 + stderr 提示「全角」(meta-finishing-rules.md:116 同教训)

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
    echo "⚠️ jq 缺失,check-handoff.sh 降级跳过" >&2
    exit 0
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
else exit 0; fi   # 无 docs/ → 无台账也无 plan,放行
cd "$WORK_DIR" 2>/dev/null || exit 0

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
    # C1 整行校验 ERE(契约源: .claude/skills/structured-handoff/SKILL.md C1 块,三处同文法)
    GRAMMAR='^promotion: (未核|已核\(上架: [^;]+; 弃置: [0-9]+ 条\)|skipped\(理由: [^;]+; 回收: [^)]+\)|阻塞\(理由: [^)]+\))$'

    PROMO=$(grep -m1 -E '^promotion:' "$HANDOFF" 2>/dev/null | tr -d '\r')

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
            reclaim="${body#*回收: }"
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
                if [ "$DISCARD" -eq 0 ] 2>/dev/null; then
                    if awk '
                        { sub(/\r$/, "") }
                        /^## 待晋升暂存/ { f=1; next }
                        /^## / { f=0 }
                        f && /^- / && $0 != "- 无" { found=1; exit }
                        END { exit found ? 0 : 1 }
                    ' "$LATEST_ARCHIVE" 2>/dev/null; then
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
                case "$p" in
                    *references/*)
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
    if command -v git >/dev/null 2>&1 \
       && [ -n "$(git log -1 --since="@$HANDOFF_MTIME" --format=%H 2>/dev/null)" ] \
       && [ -n "$(find docs/superpowers/plans -name '*.md' -mtime -7 2>/dev/null | head -1)" ]; then
        echo "软提醒(不阻断):docs/active/handoff.md 已超过 24 小时未更新,其后有新 commit 且近 7 天有活跃 plan — 适时运行 /structured-handoff 更新交接。" >&2
    fi
fi

exit 0
