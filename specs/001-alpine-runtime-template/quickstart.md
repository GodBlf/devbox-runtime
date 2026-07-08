# Quickstart: Validate Alpine Runtime Template

## Prerequisites

- Docker with buildx support.
- Repository root as current working directory.
- Access to build or pull the DevBox tooling image used by existing OS runtime builds.
- Optional remote validation host: `root@192.168.10.230`.
- For full release validation, access to a real DevBox environment where templates can be selected and created.

Use this baseline unless product confirms another Alpine release before implementation:

```bash
export TAG=alpine-test
export OWNER=labring-actions
export ALPINE_RUNTIME=operating-systems/alpine/3.22
```

## 1. Static Source Checks

```bash
test -f base-images/operating-systems/alpine/3.22/Dockerfile
test -f base-images/operating-systems/alpine/3.22/build.sh
test -f runtime-images/operating-systems/alpine/3.22/Dockerfile
test -f runtime-images/operating-systems/alpine/3.22/build.sh
test -f runtime-images/operating-systems/alpine/3.22/project-template/README.zh_CN.md
test -f runtime-images/operating-systems/alpine/3.22/project-template/README.en_US.md
test -f runtime-images/operating-systems/alpine/3.22/project-template/entrypoint.sh
test -f tests/runtime-smoke/operating-systems/alpine/3.22/smoke.sh
grep -n "operating-systems/alpine/3.22" tests/runtime-conformance/run.sh
```

Expected outcome:

- All files exist.
- Conformance registration includes `operating-systems/alpine/3.22`.
- Alpine cannot fall through to the unregistered-runtime failure.

## 2. Plan Runtime Build and Conformance

```bash
python3 .github/scripts/runtime-build.py plan-build \
  --target-kind operating-systems \
  --target-name alpine/3.22 \
  --target-build-type runtime-images \
  --include-prerequisites true
```

```bash
python3 .github/scripts/runtime-conformance.py plan \
  --tag "$TAG" \
  --kind operating-systems \
  --name alpine/3.22 \
  --l10n both \
  --arch amd64
```

Expected outcome:

- Build plan resolves Alpine runtime and its base-image prerequisite.
- Conformance plan contains `runtime-images/operating-systems/alpine/3.22/Dockerfile`.
- `runtime_count=1`.
- `job_count=2` for `en_US` and `zh_CN` on `amd64`.

## 3. Build Images

Build `en_US`:

```bash
docker buildx build --load \
  --platform linux/amd64 \
  -t ghcr.io/${OWNER}/devbox-base-images/alpine-3.22:${TAG}-en-us \
  --build-arg L10N=en_US \
  --build-arg TARGETARCH=amd64 \
  base-images/operating-systems/alpine/3.22

docker buildx build --load \
  --platform linux/amd64 \
  -t ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-en-us \
  --build-arg L10N=en_US \
  --build-arg L10N_NORMALIZED=en-us \
  --build-arg OS_IMAGE_VERSION=${TAG}-en-us \
  runtime-images/operating-systems/alpine/3.22
```

Build `zh_CN`:

```bash
docker buildx build --load \
  --platform linux/amd64 \
  -t ghcr.io/${OWNER}/devbox-base-images/alpine-3.22:${TAG}-zh-cn \
  --build-arg L10N=zh_CN \
  --build-arg TARGETARCH=amd64 \
  base-images/operating-systems/alpine/3.22

docker buildx build --load \
  --platform linux/amd64 \
  -t ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-zh-cn \
  --build-arg L10N=zh_CN \
  --build-arg L10N_NORMALIZED=zh-cn \
  --build-arg OS_IMAGE_VERSION=${TAG}-zh-cn \
  runtime-images/operating-systems/alpine/3.22
```

Expected outcome:

- All four builds succeed.
- `docker images | grep alpine-3.22` shows both base and runtime images for both locales.

## 4. Direct Runtime Checks

```bash
docker run --rm \
  --entrypoint /bin/bash \
  ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-en-us \
  -lc '
    set -e
    cat /etc/os-release
    grep -qi "alpine" /etc/os-release
    grep -Eq "VERSION_ID=\"?3[.]22\"?" /etc/os-release
    id devbox
    test -d /home/devbox/project
    test -f /home/devbox/project/README.md
    test -f /home/devbox/project/entrypoint.sh
    command -v apk
    command -v busybox
    command -v bash
    command -v sudo
    command -v curl
    command -v wget
    command -v git
    command -v python3
    test -x /usr/sbin/sshd
    /usr/sbin/sshd -T | grep -qx "allowtcpforwarding yes"
  '
```

Run an equivalent check against the `zh_CN` runtime and confirm the starter README is the Chinese variant.

Expected outcome:

- Alpine identity and selected release are correct.
- Required user, workspace, commands, package manager, and sshd are present.
- sshd allows TCP forwarding.

## 5. Smoke Tests

```bash
docker run --rm \
  -e L10N=en_US \
  -e SMOKE_DEBUG=1 \
  --entrypoint /bin/bash \
  -v "$PWD/tests/runtime-smoke/operating-systems/alpine/3.22:/tests:ro" \
  ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-en-us \
  -lc "cp /tests/smoke.sh /tmp/smoke.sh && chmod +x /tmp/smoke.sh && su - devbox -c '/tmp/smoke.sh'"

docker run --rm \
  -e L10N=zh_CN \
  -e SMOKE_DEBUG=1 \
  --entrypoint /bin/bash \
  -v "$PWD/tests/runtime-smoke/operating-systems/alpine/3.22:/tests:ro" \
  ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-zh-cn \
  -lc "cp /tests/smoke.sh /tmp/smoke.sh && chmod +x /tmp/smoke.sh && su - devbox -c '/tmp/smoke.sh'"
```

Expected outcome:

- Both smoke runs end with `ok`.

## 6. Runtime Conformance

```bash
docker run --rm \
  --entrypoint /bin/bash \
  -e L10N=en_US \
  -e RUNTIME_PATH=operating-systems/alpine/3.22 \
  -e RUNTIME_DOCKERFILE=runtime-images/operating-systems/alpine/3.22/Dockerfile \
  -e RUNTIME_IMAGE=ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-en-us \
  -e CONFORMANCE_ARCH=amd64 \
  -e CONFORMANCE_DEBUG=1 \
  -v "$PWD:/repo:ro" \
  ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-en-us \
  -lc "bash /repo/tests/runtime-conformance/run.sh"

docker run --rm \
  --entrypoint /bin/bash \
  -e L10N=zh_CN \
  -e RUNTIME_PATH=operating-systems/alpine/3.22 \
  -e RUNTIME_DOCKERFILE=runtime-images/operating-systems/alpine/3.22/Dockerfile \
  -e RUNTIME_IMAGE=ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-zh-cn \
  -e CONFORMANCE_ARCH=amd64 \
  -e CONFORMANCE_DEBUG=1 \
  -v "$PWD:/repo:ro" \
  ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-zh-cn \
  -lc "bash /repo/tests/runtime-conformance/run.sh"
```

Expected outcome:

- Both runs end with `conformance ok`.
- No run reports `no conformance checks registered for operating-systems/alpine/3.22`.

## 7. s6 and sshd Startup

```bash
docker run -d --name alpine-runtime-test \
  -p 22322:22 \
  ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-en-us

docker ps | grep alpine-runtime-test
docker logs alpine-runtime-test
docker exec alpine-runtime-test ps -ef
docker exec alpine-runtime-test /usr/sbin/sshd -T | grep -E 'allowtcpforwarding|passwordauthentication|pubkeyauthentication'
docker rm -f alpine-runtime-test
```

Expected outcome:

- Container remains running.
- s6-managed services and sshd are active.
- sshd configuration matches the runtime contract.

## 8. Package Manager and Compatibility Checks

```bash
docker run --rm \
  --entrypoint /bin/bash \
  ghcr.io/${OWNER}/devbox-runtime-images/alpine-3.22:${TAG}-en-us \
  -lc '
    set -e
    apk --version
    apk info | grep -E "gcompat|libstdc\\+\\+|libgcc|openssh|bash|sudo"
    command -v tar
    command -v gzip
    command -v unzip
    command -v curl
    command -v wget
    command -v git
    command -v ssh
    command -v sshd || command -v /usr/sbin/sshd
  '
```

Expected outcome:

- Alpine package manager works.
- Compatibility and access prerequisites are installed.

## 9. Real DevBox Validation

Validate in the product environment before release:

- Alpine appears in the DevBox template catalog.
- Selecting Alpine creates a DevBox successfully.
- First startup does not crash-loop.
- Web terminal opens.
- SSH connects.
- `/home/devbox/project` is writable.
- `apk add` works for a small package.
- Starter README language matches the selected locale.
- VS Code Server-style access has an explicit result: pass, limitation, or product-approved exception.

Expected outcome:

- Release is allowed only when required access paths pass or product approves a documented limitation.

## 10. Optional Arm64 Release Matrix

When CI resources support it, run conformance with:

```text
tag: alpine-test
kind: operating-systems
name: alpine/3.22
l10n: both
arch: both
```

Expected outcome:

- `en_US` and `zh_CN` pass on both `amd64` and `arm64`.
