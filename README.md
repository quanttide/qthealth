# qthealth — 量潮健康

量潮健康：健康管理领域的应用仓库（三端骨架）。

## 结构

```
src/
├── cli/       Rust CLI（qthealth-cli：health 状态检查）
├── provider/  Go 服务端（HTTP API：/health、/api/status）
├── studio/    Flutter 客户端（量潮健康工作台）
└── site/      React + Vite 官网（量潮健康展示）
```

## 四端状态

| 端 | 技术 | 状态 |
|----|------|------|
| cli | Rust | 骨架（health 命令占位） |
| provider | Go | 骨架（/health + /api/status） |
| studio | Flutter | 骨架（服务状态页） |
| site | React + Vite | 骨架（量潮健康首页） |

## 验证

```sh
cd src/cli && cargo build && cargo run -- health
cd src/provider && go build ./... && go vet ./...
cd src/studio && flutter analyze && flutter test
cd src/site && npm run build
```
