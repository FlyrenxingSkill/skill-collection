# skill-collection

聚合仓 **只引用** 组织 [FlyrenxingSkill](https://github.com/FlyrenxingSkill) 下的仓库（git submodule）。  
父仓本身几乎只有：`README` / `AGENTS.md` / `scripts/` / `.gitmodules`。

本机：`~/.agents/skills`

## 为什么本地会看到二进制？

`wechat-export/bin/*`（约 17MB）来自子模块 **wechat-export 仓库自己的内容**，不是聚合仓「又拷了一份」。

- 聚合仓 git 历史里只有 submodule 的 **commit 指针**
- `git submodule update` 时按指针去 clone/checkout 子仓，子仓里有 bin 就会出现在工作树
- 不需要该 skill：`git submodule deinit -f wechat-export`

## 布局：扁平，没有 projects/

每个子模块路径 = 仓库名，直接引用对应 skill/工程仓：

| 路径 | 仓库 | Agent 入口 |
|------|------|------------|
| `hass-cli` | FlyrenxingSkill/hass-cli | `hass-cli/SKILL.md` |
| `apple-music-dl` | …/apple-music-dl | 根 SKILL.md |
| `reminders` | …/reminders | 根 SKILL.md |
| `wechat-export` | …/wechat-export | 根 SKILL.md（bin 在子仓内） |
| `tgctl` | …/tgctl | **整仓** · `tgctl/skills/tgctl/SKILL.md` |
| `wechat-memory` | …/wechat-memory | **整仓** · `wechat-memory/skills/wechat-rag/SKILL.md` |

`link-agents.sh` 自动发现：

1. 顶层 `*/SKILL.md`
2. monorepo `*/skills/*/SKILL.md`  
并软链到各助手（如 `wechat-rag`、`tgctl`）。

因此 monorepo **就是单独一个顶层子模块**，不必再包一层 `projects/`，也不必在聚合仓里再做别名软链。

## 同步

```bash
~/.agents/skills/scripts/sync.sh
# 首次 clone 后：
# scripts/install-git-hooks.sh
```

## 新增

```bash
git submodule add https://github.com/FlyrenxingSkill/<name>.git <name>
git commit -m "Add <name>" && git push
./scripts/sync.sh
```
