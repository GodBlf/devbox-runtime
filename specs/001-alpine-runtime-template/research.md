# Research: Alpine Runtime Template

## Decision: Use Alpine 3.22 as the feature baseline

**Rationale**: The feature specification names Alpine 3.22 as the default when product does not specify another version. The repository already uses `alpine:3.22` for the tooling image, and Alpine Linux announced 3.22.0 as the first release in the v3.22 stable series on 2025-05-30. Using 3.22 keeps this feature aligned with the source requirement and existing repository precedent.

**Alternatives considered**:

- Latest Alpine stable: rejected for this feature because the requirement explicitly chooses 3.22 as the default baseline unless product says otherwise.
- Alpine edge: rejected because runtime templates should be release-stable and reproducible.

**References**:

- Alpine Linux 3.22.0 release announcement: https://alpinelinux.org/posts/Alpine-3.22.0-released.html
- Alpine release archive showing ongoing 3.22 patch releases: https://www.alpinelinux.org/posts/

## Decision: Add an Alpine-specific base package installer

**Rationale**: Existing shared installers are split by Debian/APT and RPM/DNF-YUM families. Alpine uses `apk` and musl, so forcing Alpine through an existing installer would make package names, cache cleanup, and error behavior unclear. A new `tooling/scripts/install-base-pkg-apk.sh` keeps package-family behavior explicit and matches the repository's pattern of package-manager-specific installer scripts.

The installer should provide the operating-system runtime minimum expected by the spec and current OS runtimes: shell, package manager, basic commands, archive tools, network/download tools, Git, Python 3, OpenSSH server/client, sudo/shadow user management, timezone support, s6 prerequisites, and compatibility packages for musl/native binaries.

**Alternatives considered**:

- Inline all `apk add` commands in the Alpine base image build: rejected because common base package installation already lives in shared tooling scripts.
- Expand `install-base-pkg-rpm.sh` or `install-base-pkg-deb.sh`: rejected because mixing package-family behavior would reduce maintainability and make future Alpine fixes risky.

## Decision: Keep Alpine runtime structure identical to existing operating-system runtimes

**Rationale**: The repository's OS runtimes follow a consistent shape: base image, runtime image, project template, build script, smoke test, and conformance registration. Fedora 44 is the closest current reference because it is an operating-system runtime recently added in the same stable directory structure. Alpine should add the same file set under `operating-systems/alpine/3.22` so runtime planners and CI matrix generation work without special path handling.

**Alternatives considered**:

- Put Alpine under experimental paths: rejected because current stable paths are `base-images/` and `runtime-images/`, and the feature is for a user-selectable DevBox template.
- Add only a runtime image without a base image: rejected because existing OS runtimes use a base/runtime split and release tooling can resolve dependencies through Dockerfile `FROM` relationships.

## Decision: Validate VS Code Server-style access explicitly and treat unsupported outcomes as product decisions

**Rationale**: Alpine uses musl libc, while VS Code Remote Development states that recent x86 glibc-based distributions provide the best support. Current VS Code docs list Alpine 3.16+ requirements as `musl`, `libgcc`, and `libstdc++`, but also state Alpine is supported in Dev Containers and WSL and is not yet supported for the broader remote-host case. The FAQ also says prebuilt VS Code servers from release 1.99 require glibc 2.28+ for unsupported Linux hosts unless a custom sysroot workaround is used, and that workaround is not an officially supported usage scenario.

The Alpine runtime should still include practical compatibility packages such as `libgcc`, `libstdc++`, `gcompat`, `bash`, `tar`, `curl` or `wget`, and OpenSSH, because they reduce predictable failures and are useful independent of VS Code. However, the release decision must be based on real DevBox validation evidence for the product's actual code-editing path.

**Alternatives considered**:

- Declare VS Code Server unsupported up front: rejected because the product may use a supported container-style path or a custom integration that works with Alpine.
- Assume `gcompat` makes Remote SSH fully supported: rejected because official documentation still requires validation and native extensions may fail on Alpine.
- Add a full custom glibc sysroot during runtime build: rejected for initial planning because it would increase image complexity and still be an unsupported workaround unless product explicitly chooses that route.

**References**:

- VS Code Remote Development with Linux prerequisites: https://code.visualstudio.com/docs/remote/linux
- VS Code Remote Development FAQ: https://code.visualstudio.com/docs/remote/faq

## Decision: Add Alpine-specific conformance registration and checks

**Rationale**: `tests/runtime-conformance/run.sh` currently rejects unregistered runtime paths and uses `check_os_runtime` for existing OS runtimes. Alpine needs a `operating-systems/alpine/3.22)` branch so it cannot fall into the unregistered-runtime failure. Alpine validation should assert Alpine identity and BusyBox, plus Alpine-specific package-manager and musl/compatibility expectations where appropriate. It must not inherit glibc-only checks from Fedora-style smoke tests.

**Alternatives considered**:

- Rely only on legacy smoke tests: rejected because conformance is the published runtime release gate.
- Add broad glibc checks for all OS runtimes: rejected because Alpine is intentionally musl-based.

## Decision: Keep localization behavior user-facing and clean in the final image

**Rationale**: Existing runtime builds copy `README.$L10N.md` to `/home/devbox/project/README.md`, copy shared user docs when present, remove the template source directory, and conformance checks that localized README source files do not remain in the project. Alpine should follow that same model. The zh_CN variant should include user-facing Chinese starter content and should not leave both localized source README files in the final project.

**Alternatives considered**:

- Ship both README files in the project directory: rejected because conformance explicitly treats leftover localized source files as an error.
- Make the zh_CN README differ materially from en_US beyond language and mirror guidance: rejected because runtime metadata, version, access caveats, and package-manager guidance must stay aligned.

## Decision: Adjust shared scripts only for real Alpine incompatibilities

**Rationale**: Alpine may differ in group names, package names, command locations, OpenSSH defaults, logrotate paths, and locale tooling. The plan should prefer small compatibility guards in shared scripts when those scripts are already meant to be cross-distro. Alpine-only behavior should stay in the Alpine base `build.sh` or new `install-base-pkg-apk.sh`.

**Alternatives considered**:

- Fork every shared script into Alpine-specific copies: rejected because it would duplicate s6, sshd, user, and docs behavior and increase drift from other OS runtimes.
- Modify shared scripts broadly without tests: rejected because the same scripts serve Debian, Ubuntu, Fedora, Kylin, and Anolis.
