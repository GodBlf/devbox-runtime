# Alpine 3.22 Runtime Template

This template provides a minimal **operating-system runtime** based on Alpine 3.22.
Use it when you need a small Linux base and full control of your language, framework, or application stack.

## Runtime Summary

- OS version: `Alpine 3.22`
- Base runtime image: `alpine-3.22`
- Package manager: `apk`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Alpine Notes

Alpine uses musl libc rather than glibc. Most shell tools and package installs work normally through `apk`, but some prebuilt Linux binaries or native extensions may expect a glibc-based distribution. When that happens, prefer Alpine packages or verify compatibility before using the binary in production.

## Template Files

- `entrypoint.sh`: creates a static `index.html` and starts a lightweight HTTP server

## Run in DevBox

Run commands from `/home/devbox/project`.

```bash
bash entrypoint.sh
```

Behavior:
- Uses `PORT` environment variable when provided, defaults to `8080`.
- Serves files from `/home/devbox/project/www`.
- Prefers `busybox httpd` and falls back to `python3 -m http.server` when that applet is unavailable.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Package Management

Use `apk` to install application dependencies:

```bash
sudo apk add --no-cache which
```

## Customization

- Replace `entrypoint.sh` with your own process startup script.
- Use `apk` to install application dependencies in this Alpine base.
- Align container exposed ports with your service port.
