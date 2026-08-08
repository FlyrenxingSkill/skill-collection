# skill-collection

聚合仓 **只引用** [FlyrenxingSkill](https://github.com/FlyrenxingSkill) 下各仓库（git submodule）。  
父仓几乎只有：`README` / `AGENTS.md` / `scripts/` / `.gitmodules` + 各子模块指针。

本机真源：**`~/.agents/skills`**

运维给 Agent 的入口 skill：**[skill-hub](https://github.com/FlyrenxingSkill/skill-hub)**（本仓 submodule `skill-hub/`）。  
日常对话提「同步 skill / 新建 skill / 新助手」时应加载 skill-hub。

---

## 新机器 / 新助手：安装检查清单

按顺序执行（读完应能独立装好）：

```bash
# 1) 克隆聚合仓（含所有 skill 子模块）
git clone --recurse-submodules \
  https://github.com/FlyrenxingSkill/skill-collection.git \
  ~/.agents/skills

# 2) pull 时自动更新子模块 + 软链（推荐）
bash ~/.agents/skills/scripts/install-git-hooks.sh

# 3) 立刻链到当前机器上的各助手目录
bash ~/.agents/skills/scripts/link-agents.sh
# 或一条龙：
# bash ~/.agents/skills/scripts/sync.sh
```

检查：

```bash
test -f ~/.agents/skills/skill-hub/SKILL.md && echo "skill-hub OK"
test -f ~/.grok/skills/skill-hub/SKILL.md && echo "grok linked OK"   # 若使用 Grok
git -C ~/.agents/skills submodule status
```

私有子模块（`wechat-export`）需要 GitHub 登录且对 org 有读权限。

### 以后日常

```bash
~/.agents/skills/scripts/sync.sh
```

---

## 为什么本地会看到二进制？

`wechat-export/bin/*` 属于子模块 **wechat-export 仓库**，不是聚合仓再拷一份。  
不需要：`git submodule deinit -f wechat-export`。

## 布局（扁平）

| 路径 | 说明 |
|------|------|
| `skill-hub` | 本聚合仓的运维 skill |
| `hass-cli` / `reminders` / `apple-music-dl` / `wechat-export` | 薄 skill（根目录 `SKILL.md`） |
| `tgctl` | 完整工程；入口 `tgctl/skills/tgctl/` |
| `wechat-memory` | 完整工程；入口 `wechat-memory/skills/wechat-rag/` |

`link-agents.sh` 发现顶层 `*/SKILL.md` 与 monorepo `*/skills/*/SKILL.md`，并软链到 Grok / Codex / Hermes / Claude / Cursor 等。

## 新增 skill

见 **skill-hub**（`skill-hub/SKILL.md`），摘要：

1. `gh repo create FlyrenxingSkill/<name> …` + 推送 `SKILL.md`  
2. `git submodule add … <name>` → push 聚合仓  
3. `scripts/sync.sh`  

## 脚本

| 脚本 | 作用 |
|------|------|
| `scripts/sync.sh` | pull + submodule `--remote` + link |
| `scripts/link-agents.sh` | 仅软链（含新建 skill 名） |
| `scripts/install-git-hooks.sh` | `git pull` 后自动 submodule + link |

## Agent 约定

提到任意 skill 或本聚合仓时：优先 `bash ~/.agents/skills/scripts/sync.sh`，再读对应 `SKILL.md`；管仓操作用 **skill-hub**。
