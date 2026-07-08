# Alpine 3.22 运行时模板

该模板提供一个基于 Alpine 3.22 的最小化**操作系统运行时**。
适用于需要轻量 Linux 基础环境，并在其上自行安装语言、框架或业务依赖的场景。

## 运行时概览

- 系统版本：`Alpine 3.22`
- 基础运行时镜像：`alpine-3.22`
- 包管理器：`apk`
- 启动脚本：`entrypoint.sh`
- 默认服务端口：`8080`

## Alpine 注意事项

Alpine 使用 musl libc，而不是 glibc。大多数 shell 工具和依赖安装可以直接通过 `apk` 正常使用，但某些预编译 Linux 二进制或原生扩展可能默认面向 glibc 系发行版。遇到这种情况时，优先使用 Alpine 官方软件包，或先确认二进制兼容性再用于生产。

## 模板文件

- `entrypoint.sh`：生成静态 `index.html` 并启动轻量 HTTP 服务

## 在 DevBox 中运行

以下命令在 `/home/devbox/project` 目录执行。

```bash
bash entrypoint.sh
```

行为说明：
- 支持通过 `PORT` 环境变量覆盖端口，默认值为 `8080`。
- 默认从 `/home/devbox/project/www` 目录提供静态内容。
- 优先使用 `busybox httpd`，不可用时回退到 `python3 -m http.server`。

## 验证服务

```bash
curl http://127.0.0.1:8080
```

预期输出：

```text
Hello, World!
```

## 包管理

使用 `apk` 安装业务依赖：

```bash
sudo apk add --no-cache which
```

## 自定义建议

- 可将 `entrypoint.sh` 替换为你的进程启动脚本。
- 使用 `apk` 在该 Alpine 基础镜像中安装业务依赖。
- 保持容器暴露端口与服务监听端口一致。
