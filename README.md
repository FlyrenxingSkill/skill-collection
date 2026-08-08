# skill-collection

Flyrenxing 的 **Agent Skill 引用仓**。

- 组织：[FlyrenxingSkill](https://github.com/FlyrenxingSkill)
- 本机唯一真源：`~/.agents/skills`（clone 本仓，含 submodule）
- **不要**把 Grok/Codex 自带 skill 拷进本仓

## 两类条目

| 类型 | 例子 | 形态 |
|------|------|------|
| **薄 skill 包** | `hass-cli`, `reminders` | 根目录即 `SKILL.md` 的独立仓 |
| **完整工程 + 入口别名** | `wechat-memory` + `wechat-rag` | submodule 是**整仓**；`wechat-rag` 是指向 `wechat-memory/skills/wechat-rag` 的 **git 符号链接**（给 Agent 扁平发现用） |

## Agent 约定：提到 skill 就 pull

```bash
cd ~/.agents/skills
git pull --rebase --autostash
git submodule update --init --recursive --remote
```

然后读 `~/.agents/skills/<name>/SKILL.md`。

### pull 之后要不要重新软链？

**一般不要。** submodule 在原地更新，已有路径与符号链接仍有效。

只有这些情况才跑 `scripts/link-agents.sh`：

- 第一次安装
- 集合里**新增**了 skill / monorepo 别名
- 换了新助手目录

## 多助手如何挂接（避免「逐个软链」误解）

目标：助手只**看见** skill，不复制内容。

推荐（SSOT 仍是本仓）：

1. 本仓：`~/.agents/skills` = 本 git
2. 各助手：对**每个**本仓里带 `SKILL.md` 的路径做软链（脚本一次搞定）
3. Grok 自带 skill（`help` / `check-work` 等）留在 `~/.grok/skills/` 真目录，**不要**整目录替换成指向本仓（会冲掉自带 skill）

### 和 CC Switch 的关系

[CC Switch](https://github.com/farion1231/cc-switch) 的 skill SSOT 默认是 `~/.cc-switch/skills/`，再软链到各 CLI。

- **能解决**：多 CLI 一键装 skill、统一开关、GUI 管理
- **不能替代**：本仓的 **git submodule 版本真相**；`git pull` 工作流仍要有一处真源
- **若用 CC Switch**：二选一，避免双真源  
  - A）以本仓为真源：把 CC Switch 的 skills 目录指到 / 同步自 `~/.agents/skills`（或只让它管理「非本集合」的第三方 skill）  
  - B）以 CC Switch 为真源：放弃本仓 submodule 模型（不推荐，丢 monorepo 引用能力）

结论：**工程/monorepo 引用继续用 skill-collection；多助手 GUI 同步可选用 CC Switch，但 SSOT 只留一处。**

## 当前清单

| 路径 | 仓库 | 说明 |
|------|------|------|
| `hass-cli` | [FlyrenxingSkill/hass-cli](https://github.com/FlyrenxingSkill/hass-cli) | 薄 skill |
| `apple-music-dl` | [FlyrenxingSkill/apple-music-dl](https://github.com/FlyrenxingSkill/apple-music-dl) | 薄 skill |
| `tgctl` | [FlyrenxingSkill/tgctl](https://github.com/FlyrenxingSkill/tgctl) | 薄 skill（完整 CLI 仍可另仓，见下） |
| `reminders` | [FlyrenxingSkill/reminders](https://github.com/FlyrenxingSkill/reminders) | 薄 skill |
| `wechat-export` | [FlyrenxingSkill/wechat-export](https://github.com/FlyrenxingSkill/wechat-export) | private 薄/工具 skill |
| `wechat-memory` | [FlyrenxingSkill/wechat-memory](https://github.com/FlyrenxingSkill/wechat-memory) | **完整工程** |
| `wechat-rag` | → `wechat-memory/skills/wechat-rag` | 别名，非独立内容 |

已废弃独立切片仓：`FlyrenxingSkill/wechat-rag`（内容已并入 monorepo；将 archive）。

## 安装

```bash
git clone --recurse-submodules https://github.com/FlyrenxingSkill/skill-collection.git ~/.agents/skills
~/.agents/skills/scripts/link-agents.sh   # 仅首次 / 新增 skill 后
```

## 新增 monorepo 型 skill

1. 完整代码放组织仓：`FlyrenxingSkill/<project>`
2. skill 包放在仓内例如 `skills/<skill-name>/SKILL.md`
3. 本集合：

```bash
git submodule add https://github.com/FlyrenxingSkill/<project>.git <project>
ln -sfn <project>/skills/<skill-name> <skill-name>
git add <project> <skill-name> .gitmodules
git commit -m "Add monorepo <project> + alias <skill-name>"
git push
```

4. 各机器：`git pull && git submodule update --init --recursive`；若有新别名再跑 `link-agents.sh`
