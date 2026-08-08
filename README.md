# skill-collection

Flyrenxing 的 **Agent Skill 引用仓 / 集合仓**。

- 组织：[FlyrenxingSkill](https://github.com/FlyrenxingSkill)
- 每个独立 skill 是组织下的单独仓库；本仓用 **git submodule** 引用它们。
- 本机约定：clone 到 **`~/.agents/skills`**，其它助手目录软链到此处。

## 给 Agent 的硬性约定（请遵守）

**只要用户提到了某个 skill（名称、用途、或「用 xxx skill」），先尝试从本集合更新，再执行：**

```bash
# 在 ~/.agents/skills（本仓）内
git pull --rebase --autostash
git submodule update --init --recursive --remote
# 若只更新某一个 skill：
# git submodule update --init --remote <skill-name>
```

若 pull/submodule 失败：说明权限或网络问题，告知用户；**不要假装 skill 已是最新**。

私有 skill（如 `wechat-export`）需要本机 `gh auth` / SSH 对 org 有读权限。

## 目录结构

每个 submodule 目录名 = skill 名，内含 `SKILL.md`（Agent 发现入口）。

| Skill | 仓库 | 可见性 | 说明 |
|-------|------|--------|------|
| `hass-cli` | [FlyrenxingSkill/hass-cli](https://github.com/FlyrenxingSkill/hass-cli) | public | Home Assistant via hass-cli |
| `apple-music-dl` | [FlyrenxingSkill/apple-music-dl](https://github.com/FlyrenxingSkill/apple-music-dl) | public | Apple Music 下载 |
| `tgctl` | [FlyrenxingSkill/tgctl](https://github.com/FlyrenxingSkill/tgctl) | public | Telegram 账号整理 |
| `wechat-rag` | [FlyrenxingSkill/wechat-rag](https://github.com/FlyrenxingSkill/wechat-rag) | public | 微信记忆库 RAG |
| `wechat-export` | [FlyrenxingSkill/wechat-export](https://github.com/FlyrenxingSkill/wechat-export) | **private** | 本机微信导出 |
| `reminders` | [FlyrenxingSkill/reminders](https://github.com/FlyrenxingSkill/reminders) | public | macOS 提醒事项 CLI |

## 本机安装

```bash
# 首次（含私有仓需已登录 gh / SSH）
git clone --recurse-submodules https://github.com/FlyrenxingSkill/skill-collection.git ~/.agents/skills

# 或已有空目录
cd ~/.agents/skills
git pull
git submodule update --init --recursive
```

### 其它助手目录 → 软链到本仓

各工具对「用户 skills」路径不同；**内容只维护这一份 git**。

```bash
# 示例：Grok 用户 skills 里为每个 skill 建软链（保留 Grok 自带 skill）
# ln -sfn ~/.agents/skills/hass-cli ~/.grok/skills/hass-cli
```

一键脚本见 [`scripts/link-agents.sh`](scripts/link-agents.sh)。

## 新增 skill

1. 在组织下建仓：`FlyrenxingSkill/<name>`，根目录放 `SKILL.md`
2. 加入本集合：

```bash
git submodule add https://github.com/FlyrenxingSkill/<name>.git <name>
git commit -m "Add skill <name>"
git push
```

3. 各机器：`git pull && git submodule update --init --remote`

## 与旧 FlyRenxing/* 工程的关系

完整 CLI/应用仍可在 `FlyRenxing/<project>`；**Agent 只读的 skill 包**以本组织仓为准。旧仓 `skills/` 目录可改为指向本组织或逐步弃用重复内容。
