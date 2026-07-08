# Contract: Alpine Runtime Template

## Purpose

This contract defines the observable behavior required for the Alpine operating-system runtime template. It is used by implementation, smoke tests, conformance tests, and release validation.

## Source Layout Contract

The feature must provide these files:

```text
base-images/operating-systems/alpine/3.22/Dockerfile
base-images/operating-systems/alpine/3.22/build.sh
runtime-images/operating-systems/alpine/3.22/Dockerfile
runtime-images/operating-systems/alpine/3.22/build.sh
runtime-images/operating-systems/alpine/3.22/project-template/README.en_US.md
runtime-images/operating-systems/alpine/3.22/project-template/README.zh_CN.md
runtime-images/operating-systems/alpine/3.22/project-template/entrypoint.sh
tests/runtime-smoke/operating-systems/alpine/3.22/smoke.sh
```

The feature must update these shared validation surfaces:

```text
tests/runtime-conformance/run.sh
tests/runtime-conformance/README.md
```

The feature may update these shared tooling surfaces when Alpine compatibility requires it:

```text
tooling/scripts/install-base-pkg-apk.sh
tooling/scripts/cleanup.sh
tooling/scripts/configure-user.sh
tooling/scripts/configure-login.sh
tooling/scripts/configure-l10n.sh
tooling/scripts/svc/configure-sshd.sh
```

## Image Identity Contract

An Alpine runtime image must satisfy:

- `/etc/os-release` identifies Alpine.
- `/etc/os-release` reports the selected Alpine release, default `3.22`.
- Runtime image name follows the existing operating-system convention: `alpine-3.22`.
- Runtime path is `operating-systems/alpine/3.22`.
- Workdir is `/home/devbox/project`.

## User and Workspace Contract

An Alpine runtime image must satisfy:

- User `devbox` exists.
- `/home/devbox/project` exists.
- User `devbox` can write to `/home/devbox/project`.
- `/home/devbox/project/README.md` exists and matches the selected localization variant.
- `/home/devbox/project/entrypoint.sh` exists and is executable.
- Source localized README files must not remain in `/home/devbox/project`.
- Running the starter entrypoint from `/home/devbox/project` must keep a foreground process alive long enough for conformance startup checks.

## Package and Command Contract

An Alpine runtime image must provide:

- Alpine-native package management through `apk`.
- BusyBox.
- Bash.
- sudo-capable default user behavior.
- curl or wget, preferably both.
- Git.
- Python 3.
- tar, gzip, unzip, and zip.
- OpenSSH client and server.
- `libgcc`, `libstdc++`, and practical musl/glibc-compatibility support for native tooling risk reduction.

## SSH and Service Contract

An Alpine runtime image must satisfy:

- `/usr/sbin/sshd` is executable.
- sshd host keys can be generated during build or service startup.
- sshd runtime configuration enables TCP forwarding.
- password authentication is disabled unless a future product requirement explicitly changes this.
- public-key authentication is enabled.
- `/run/nologin` and `/etc/nologin` do not block non-root SSH logins after startup.
- The existing s6 entrypoint remains the container entrypoint for the base image.

## Localization Contract

For `en_US`:

- `/home/devbox/project/README.md` uses English content.
- README names Alpine, the selected release, `apk`, and musl compatibility caveats.

For `zh_CN`:

- `/home/devbox/project/README.md` uses Simplified Chinese content.
- README names Alpine, the selected release, `apk`, and musl compatibility caveats.

For both:

- Runtime metadata and starter behavior must remain equivalent.
- Localized source files must not remain in the final project directory.

## Validation Contract

Static checks must verify:

- All source layout files exist.
- `tests/runtime-conformance/run.sh` registers `operating-systems/alpine/3.22`.
- Runtime build and conformance planners find exactly one Alpine runtime target for the selected Alpine path.

Smoke checks must verify:

- Alpine identity and selected release.
- `devbox` user.
- project template files.
- required commands, package manager, and sshd.
- starter entrypoint does not exit early.

Conformance checks must verify:

- image architecture when requested.
- common project runtime contract.
- Alpine-specific runtime identity.
- Alpine package manager and BusyBox availability.
- root entrypoint order and project file ownership.
- legacy smoke script execution as `devbox`.
- no unregistered-runtime outcome.

Real DevBox validation must verify:

- Alpine appears in the template catalog.
- A DevBox can be created from Alpine.
- The instance does not crash-loop.
- Web terminal works.
- SSH works.
- `/home/devbox/project` is writable.
- `apk` can install and run a small package.
- VS Code Server-style access has a recorded pass, limitation, or product-approved exception.
