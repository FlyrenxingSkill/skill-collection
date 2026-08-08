# skill-collection

Flyrenxing 的 **Agent Skill 聚合仓**（唯一本机真源：`~/.agents/skills`）。

组织：[FlyrenxingSkill](https://github.com/FlyrenxingSkill)

## 最终模型（请按这个用）

```text
改某个 skill 仓 → 聚合仓 submodule 指针更新并 push
                    ↓
各机器:  git pull  （hooks）或  ./scripts/sync.sh
                    ↓
  submodule 全更新 + 自动软链到每个助手
```

- **更新已有 skill**：在对应 `FlyrenxingSkill/*` 仓提交；聚合仓 `git submodule update --remote` 后 commit push；各机 pull 即全部到手。
- **新建 skill**：加入组织仓 + 本仓 submodule（或 monorepo 别名）并 push；各机 pull 后 **hooks 自动** `link-agents.sh`，无需手链。

### 推荐命令

```bash
# 日常（推荐，一条龙）
~/.agents/skills/scripts/sync.sh

# 或装过 hooks 后
cd ~/.agents/skills && git pull
```

首次 clone 后务必：

```bash
git clone --recurse-submodules https://github.com/FlyrenxingSkill/skill-collection.git ~/.agents/skills
~/.agents/skills/scripts/install-git-hooks.sh
~/.agents/skills/scripts/link-agents.sh
```

## 两类条目

| 类型 | 布局 | 例子 |
|------|------|------|
| 薄 skill | 顶层 submodule，根目录 `SKILL.md` | `hass-cli`, `reminders` |
| 完整工程 | `projects/<name>/` 整仓 submodule + 顶层 **别名** 指向 `.../skills/<skill>` | `projects/tgctl` + `tgctl`；`wechat-memory` + `wechat-rag` |

Agent 只认顶层带 `SKILL.md` 的名字；工程代码在 monorepo 里。

## 清单

| 入口 | 仓库 / 指向 |
|------|-------------|
| `hass-cli` | [FlyrenxingSkill/hass-cli](https://github.com/FlyrenxingSkill/hass-cli) |
| `apple-music-dl` | [FlyrenxingSkill/apple-music-dl](https://github.com/FlyrenxingSkill/apple-music-dl) |
| `reminders` | [FlyrenxingSkill/reminders](https://github.com/FlyrenxingSkill/reminders) |
| `wechat-export` | [FlyrenxingSkill/wechat-export](https://github.com/FlyrenxingSkill/wechat-export) private |
| `tgctl` | → `projects/tgctl/skills/tgctl`（整仓 [tgctl](https://github.com/FlyrenxingSkill/tgctl)） |
| `wechat-rag` | → `wechat-memory/skills/wechat-rag`（整仓 [wechat-memory](https://github.com/FlyrenxingSkill/wechat-memory)） |
| `wechat-memory` | 完整工程 submodule（开发用） |

## 新增 skill 流程

### 薄 skill

```bash
# 1) 组织下建仓，根目录 SKILL.md
# 2) 聚合仓：
cd ~/.agents/skills
git submodule add https://github.com/FlyrenxingSkill/<name>.git <name>
git commit -m "Add skill <name>" && git push
# 3) 本机（或他人 pull + hooks）
./scripts/sync.sh
```

### 完整工程 + skill 切片

```bash
git submodule add https://github.com/FlyrenxingSkill/<project>.git projects/<project>
ln -sfn projects/<project>/skills/<skill-name> <skill-name>
git add projects/<project> <skill-name> .gitmodules
git commit -m "Add monorepo <project> + alias <skill-name>" && git push
./scripts/sync.sh
```

## 多助手 / CC Switch

- 软链目标含 Grok、Codex、Hermes、Claude、Cursor、Buzz、`~/.cc-switch/skills`（若存在）。
- **SSOT 只有本仓**；不要在 CC Switch 再维护第二份内容。
- Grok 自带 skill（`help` 等）是真目录，脚本会 **跳过** 非软链路径，不会覆盖。

## Agent 约定

提到 skill 时先：

```bash
~/.agents/skills/scripts/sync.sh
# 或
cd ~/.agents/skills && git pull && git submodule update --init --recursive --remote
# （hooks 会 link）
```

再读 `~/.agents/skills/<name>/SKILL.md`。
