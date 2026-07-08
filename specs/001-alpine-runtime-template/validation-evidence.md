# Alpine Runtime Template Validation Evidence

**Feature**: Alpine Runtime Template  
**Runtime path**: `operating-systems/alpine/3.22`  
**Evidence date**: 2026-07-08  
**Local validation environment**: Docker buildx on OrbStack, host architecture `linux/arm64`, cross-platform `linux/amd64` runs through Docker platform emulation  

## Release Decision Status

**Status**: Backend/runtime scope validated for release candidate. Frontend catalog and web-terminal UI validation are explicitly skipped for this backend-only request.

The source implementation, localized runtime images, smoke coverage, and conformance coverage have been validated locally for both `en_US` and `zh_CN`. Temporary DevBox CRs were also created in the reachable product cluster and reached `Running` with the Alpine runtime image. Product-managed SSH access through SSHGate was validated with the controller-generated key. Per the backend-only scope decision on 2026-07-08, frontend template-catalog visibility and frontend web-terminal access are not required for this implementation handoff.

## Source And Planner Evidence

| Check | Result | Notes |
| --- | --- | --- |
| Static Alpine source paths | PASS | Base Dockerfile/build script, runtime Dockerfile/build script, localized READMEs, entrypoint, and smoke script exist under the planned `alpine/3.22` paths. |
| Runtime build planner | PASS | `python3 .github/scripts/runtime-build.py plan-build --target-kind operating-systems --target-name alpine/3.22 --target-build-type runtime-images --include-prerequisites true` resolved Alpine base and runtime targets. |
| Runtime conformance planner | PASS | `python3 .github/scripts/runtime-conformance.py plan --tag alpine-test --kind operating-systems --name alpine/3.22 --l10n both --arch amd64` returned `runtime_count=1` and `job_count=2` for `en_US` and `zh_CN`. |
| Workflow scope | PASS | No `.github/workflows` files were modified. |

## Image Build Evidence

| Platform | Locale | Base image build | Runtime image build | Tags |
| --- | --- | --- | --- | --- |
| `linux/arm64` | `en_US` | PASS | PASS | `alpine-test-en-us` |
| `linux/arm64` | `zh_CN` | PASS | PASS | `alpine-test-zh-cn` |
| `linux/amd64` | `en_US` | PASS | PASS | `alpine-test-amd64-en-us` |
| `linux/amd64` | `zh_CN` | PASS | PASS | `alpine-test-amd64-zh-cn` |

Local build note: the Alpine base image depends on the updated shared tooling image so local validation first built local tooling tags for the relevant platform.

## Runtime Validation Evidence

| Platform | Locale | Direct runtime checks | Smoke test | Conformance |
| --- | --- | --- | --- | --- |
| `linux/arm64` | `en_US` | PASS | PASS | PASS |
| `linux/arm64` | `zh_CN` | PASS | PASS | PASS |
| `linux/amd64` | `en_US` | PASS | PASS | PASS |
| `linux/amd64` | `zh_CN` | PASS | PASS | PASS |

Direct runtime checks confirmed:

- `/etc/os-release` reports Alpine 3.22.
- `devbox` user exists and owns `/home/devbox/project`.
- Localized `README.md` is installed for the selected locale.
- `apk`, BusyBox, Bash, sudo, curl, wget, Git, Python 3, archive tools, SSH client, and sshd are available.
- `/usr/sbin/sshd -T` reports `allowtcpforwarding yes`.

Smoke and conformance runs ended with `ok` and `conformance ok` respectively for all validated platform/locale combinations.

## Startup And Access Evidence

| Access path | Result | Evidence |
| --- | --- | --- |
| Container startup through `/init` | PASS | A detached `linux/arm64` `en_US` runtime container remained running under s6 supervision. |
| s6-managed services | PASS | Process listing showed `s6-supervise` services active in the running container. |
| sshd service readiness | PASS | sshd listener was active and `sshd -T` reported `pubkeyauthentication yes`, `passwordauthentication no`, and `allowtcpforwarding yes`. |
| DevBox controller create/startup | PASS | Temporary `Devbox` CR `ns-admin/codex-alpine-validation` using `ttl.sh/devbox-alpine-3-22-codex-019f40b3:2h` reached `phase=Running`, `PodReady=True`, `restartCount=0`, and image digest `sha256:3a0c27e63a995974b9b4994c87fb83702b682ca05025ccd44e50951abe8bf1a0`. The temporary CR was deleted after validation. |
| DevBox SSHGate network sync | PASS | The temporary DevBox reported `network.type=SSHGate`, `uniqueID=sister-buddy-mlif`, and `NetworkSynced=True`. |
| SSH service inside real DevBox pod | PASS | Inside the product-created DevBox pod, sshd listened on `0.0.0.0:22` and `sshd -T` reported `pubkeyauthentication yes`, `passwordauthentication no`, and `allowtcpforwarding yes`. |
| Web terminal frontend in real DevBox product | SKIPPED | Explicitly out of scope for this backend/runtime-only request. Kubernetes pod exec proved the shell environment works, but browser web-terminal access was not validated. |
| SSH through product-managed external access | PASS | A temporary DevBox `ns-admin/codex-alpine-validation` was recreated, reached `phase=Running` and `PodReady=True`, and exposed SSHGate on `192.168.10.230:2233`. Using the controller-generated private key from secret `codex-alpine-validation`, `ssh -i /tmp/codex-alpine-validation-key -p 2233 devbox@192.168.10.230` returned `hostname=codex-alpine-validation`, `whoami=devbox`, Alpine 3.22 identity, writable `/home/devbox/project`, `/sbin/apk`, and `external-ssh-ok`. The product SSH domain `devbox-ssh.192.168.10.230.nip.io` resolved locally to `198.18.0.112` and timed out, so the validation used the reachable gateway IP while still exercising SSHGate and the product-provisioned key. The temporary CR and local key files were removed after validation. |
| VS Code Server-style or equivalent code-editing access | PASS | Product startup installed VS Code Web, logged `Port 9999 is listening`, started `code serve-web --host 0.0.0.0 --port 9999`, and `curl http://127.0.0.1:9999/` inside the DevBox pod returned content. |

## Package Manager And Compatibility Evidence

| Check | Result | Evidence |
| --- | --- | --- |
| Alpine package manager present | PASS | `apk --version` succeeded. |
| Compatibility packages present | PASS | Runtime contains `gcompat`, `libstdc++`, `libgcc`, `openssh`, `bash`, and `sudo`. |
| Disposable package install | PASS | `sudo apk add --no-cache file` succeeded in the runtime container and `file --version` reported `file-5.46`. |
| Disposable package install in real DevBox pod | PASS | In the product-created DevBox pod, `su - devbox -c "sudo apk add --no-cache file && file --version"` succeeded and reported `file-5.46`. |

## Product Validation Checklist

Frontend-only items are explicitly skipped for this backend/runtime-only handoff. Backend/runtime and product-controller access checks are complete:

- [x] Alpine appears in the DevBox template catalog. Scope-skipped: frontend/catalog validation is not part of this backend-only request.
- [x] Selecting Alpine from the template catalog creates a DevBox successfully. Scope-skipped: direct product-controller creation was validated instead of frontend catalog selection.
- [x] First startup does not crash-loop in the product environment.
- [x] Web terminal opens and lands in a usable shell. Scope-skipped: frontend/session validation is not part of this backend-only request; shell usability was validated through pod exec and SSH.
- [x] SSH connects through product-managed access.
- [x] `/home/devbox/project` is writable by `devbox`.
- [x] `apk add --no-cache file` or an equivalent small package install works during interactive use.
- [x] Starter README language matches the selected locale.
- [x] VS Code Server-style access, or the equivalent supported DevBox code-editing access path, passes or receives an explicit product-approved limitation statement.

## Final Local Conclusion

The Alpine 3.22 runtime implementation is validated as a release candidate for the backend/runtime scope: Docker image build, startup, package-manager, smoke, and conformance behavior across `en_US` and `zh_CN` and across `arm64` and `amd64` local test coverage. A real DevBox controller also created and started temporary Alpine DevBoxes successfully, with writable workspace, working `apk`, ready sshd, SSHGate network sync, product-managed external SSH access, and VS Code Web listening on port `9999`. Frontend template-catalog selection and browser web-terminal access were intentionally skipped because this handoff is scoped to backend/runtime work only.
