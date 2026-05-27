# 2026-MCM-C 本地开发命令集
# 使用 `just <命令>` 运行；运行 `just` 或 `just default` 查看所有命令

# 默认命令：列出所有可用命令
default:
    @just --list

# 安装依赖（使用 uv 同步 lock 文件）
install:
    uv sync

# 本地预览文档（默认端口 8000）
serve:
    uv run mkdocs serve

# 指定端口本地预览，例如 `just serve-on 8080`
serve-on port="8000":
    uv run mkdocs serve -a 127.0.0.1:{{port}}

# 构建静态站点到 site/ 目录
build:
    uv run mkdocs build

# 严格模式构建：将所有警告视为错误（CI 等价检查）
build-strict:
    uv run mkdocs build --strict

# 清理构建产物
clean:
    rm -rf site/

# 列出 docs/ 下的 Markdown 文件及行数
list-docs:
    @find docs -name '*.md' -type f -exec wc -l {} +

# 检查所有 Markdown 文件中是否存在死链（简单 grep TODO/FIXME）
check-todo:
    @grep -rn -E "TODO|FIXME|XXX" docs/ || echo "未发现 TODO/FIXME"

# 显示项目状态
status:
    @echo "=== Git 状态 ==="
    @git status -s
    @echo ""
    @echo "=== 最近 5 次提交 ==="
    @git log --oneline -5

# 一键校验：清理 + 严格构建
check: clean build-strict
    @echo "✓ 文档构建通过"
