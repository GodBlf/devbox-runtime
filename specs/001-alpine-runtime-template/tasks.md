# Tasks: Alpine Runtime Template

**Input**: Design documents from `specs/001-alpine-runtime-template/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/runtime-template-contract.md`, `quickstart.md`

**Tests**: Validation tasks are included because the specification requires smoke, conformance, startup, package-manager, and real DevBox verification.

**Organization**: Tasks are grouped by user story to support independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches different files and has no dependency on incomplete tasks.
- **[Story]**: User story label for story phases only.
- Every task includes an exact repository path or feature artifact path.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the Alpine runtime source tree and preserve the existing operating-system runtime conventions before implementation begins.

- [X] T001 Create Alpine source directories in base-images/operating-systems/alpine/3.22, runtime-images/operating-systems/alpine/3.22/project-template, and tests/runtime-smoke/operating-systems/alpine/3.22
- [X] T002 [P] Compare Fedora 44 base image structure against the Alpine plan using base-images/operating-systems/fedora/44/Dockerfile
- [X] T003 [P] Compare Fedora 44 runtime template structure against the Alpine plan using runtime-images/operating-systems/fedora/44/project-template/entrypoint.sh
- [X] T004 [P] Confirm the Alpine contract paths and validation scope in specs/001-alpine-runtime-template/contracts/runtime-template-contract.md before editing source files

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add shared Alpine compatibility support that the Alpine base/runtime images depend on.

**Critical**: No user story implementation should start until the shared package, cleanup, user, login, localization, and sshd compatibility surfaces are ready.

- [X] T005 Add Alpine package installer with required apk packages in tooling/scripts/install-base-pkg-apk.sh
- [X] T006 Update package cache cleanup for apk without changing existing apt/dnf/yum behavior in tooling/scripts/cleanup.sh
- [X] T007 Update user creation compatibility for Alpine shadow/sudo group behavior in tooling/scripts/configure-user.sh
- [X] T008 Update login and utmp handling so Alpine images do not fail on missing distro-specific groups in tooling/scripts/configure-login.sh
- [X] T009 Update localization flow so zh_CN and en_US remain valid on Alpine without assuming apt sources or glibc locale generation in tooling/scripts/configure-l10n.sh
- [X] T010 Update sshd configuration compatibility for Alpine OpenSSH paths, host keys, and log ownership in tooling/scripts/svc/configure-sshd.sh
- [X] T011 Verify shared script changes remain compatible with Fedora 44 by reviewing base-images/operating-systems/fedora/44/build.sh

**Checkpoint**: Shared Alpine prerequisites are ready for the Alpine base image.

---

## Phase 3: User Story 1 - Create an Alpine DevBox (Priority: P1) MVP

**Goal**: A user can select Alpine, create a DevBox, and get a running Alpine environment with the expected user, workspace, starter content, package manager, SSH, and startup behavior.

**Independent Test**: Build the Alpine base/runtime images, run the direct runtime checks from `quickstart.md`, confirm `/etc/os-release` reports Alpine 3.22, `devbox` can use `/home/devbox/project`, and sshd reports `allowtcpforwarding yes`.

### Implementation for User Story 1

- [X] T012 [US1] Add Alpine 3.22 base Dockerfile using the shared tooling stage and `/init` entrypoint in base-images/operating-systems/alpine/3.22/Dockerfile
- [X] T013 [US1] Add Alpine base build script that calls install-base-pkg-apk, s6, SDK server, svc, login, l10n, user, docs, and cleanup scripts in base-images/operating-systems/alpine/3.22/build.sh
- [X] T014 [US1] Add Alpine runtime Dockerfile that derives from the Alpine base image and installs the project template in runtime-images/operating-systems/alpine/3.22/Dockerfile
- [X] T015 [US1] Add Alpine runtime build script that copies the localized README, entrypoint, and shared runtime docs into the devbox project in runtime-images/operating-systems/alpine/3.22/build.sh
- [X] T016 [P] [US1] Add Alpine starter entrypoint with non-root rerun, stable foreground HTTP serving, and no early exit in runtime-images/operating-systems/alpine/3.22/project-template/entrypoint.sh
- [X] T017 [P] [US1] Add English Alpine README with Alpine 3.22, apk usage, musl caveat, default port, and entrypoint behavior in runtime-images/operating-systems/alpine/3.22/project-template/README.en_US.md
- [X] T018 [P] [US1] Add Simplified Chinese Alpine README with Alpine 3.22, apk usage, musl caveat, default port, and entrypoint behavior in runtime-images/operating-systems/alpine/3.22/project-template/README.zh_CN.md
- [X] T019 [US1] Build en_US Alpine base and runtime images using the commands in specs/001-alpine-runtime-template/quickstart.md
- [X] T020 [US1] Build zh_CN Alpine base and runtime images using the commands in specs/001-alpine-runtime-template/quickstart.md
- [X] T021 [US1] Run direct en_US runtime identity, workspace, package-manager, command, and sshd checks from specs/001-alpine-runtime-template/quickstart.md
- [X] T022 [US1] Run direct zh_CN runtime identity, localized README, workspace, package-manager, command, and sshd checks from specs/001-alpine-runtime-template/quickstart.md

**Checkpoint**: User Story 1 is independently functional when both localized runtime images build and pass direct runtime checks.

---

## Phase 4: User Story 2 - Validate Alpine Runtime Quality (Priority: P2)

**Goal**: A platform engineer can prove the Alpine runtime is registered, planned, smoke-tested, and conformance-tested like other operating-system runtimes.

**Independent Test**: Run static file checks, runtime build planning, conformance planning, Alpine smoke tests, and runtime conformance for both `en_US` and `zh_CN`; all required outputs match the quickstart expectations.

### Tests and Validation for User Story 2

- [X] T023 [US2] Add Alpine smoke script covering Alpine 3.22 identity, devbox user, project template, apk, BusyBox, Bash, sudo, curl, wget, Git, Python 3, archive tools, sshd, and entrypoint liveness in tests/runtime-smoke/operating-systems/alpine/3.22/smoke.sh
- [X] T024 [US2] Add Alpine-specific conformance helper checks for apk, BusyBox, Alpine identity, and compatibility packages without glibc-only assertions in tests/runtime-conformance/run.sh
- [X] T025 [US2] Register operating-systems/alpine/3.22 in runtime-specific conformance dispatch in tests/runtime-conformance/run.sh
- [X] T026 [US2] Update conformance coverage documentation to include Alpine 3.22, locales, architecture expectations, and musl compatibility notes in tests/runtime-conformance/README.md
- [X] T027 [US2] Run static source checks from specs/001-alpine-runtime-template/quickstart.md
- [X] T028 [US2] Run runtime build planner for operating-systems alpine/3.22 with prerequisites using specs/001-alpine-runtime-template/quickstart.md
- [X] T029 [US2] Run runtime conformance planner for operating-systems alpine/3.22 with l10n both and arch amd64 using specs/001-alpine-runtime-template/quickstart.md
- [X] T030 [US2] Run en_US Alpine smoke test in tests/runtime-smoke/operating-systems/alpine/3.22/smoke.sh
- [X] T031 [US2] Run zh_CN Alpine smoke test in tests/runtime-smoke/operating-systems/alpine/3.22/smoke.sh
- [X] T032 [US2] Run en_US Alpine runtime conformance through tests/runtime-conformance/run.sh
- [X] T033 [US2] Run zh_CN Alpine runtime conformance through tests/runtime-conformance/run.sh

**Checkpoint**: User Story 2 is independently functional when planner, smoke, and conformance validation pass for both required localized variants.

---

## Phase 5: User Story 3 - Resolve Alpine Compatibility Risk (Priority: P3)

**Goal**: Support and product stakeholders have explicit evidence for Alpine web terminal, SSH, package-manager, and VS Code Server-style access before release.

**Independent Test**: Review the validation evidence file and confirm it records pass, limitation, or product-approved exception for every required access path.

### Implementation and Validation for User Story 3

- [X] T034 [P] [US3] Create compatibility evidence template for web terminal, SSH, apk install, startup, and VS Code Server-style access in specs/001-alpine-runtime-template/validation-evidence.md
- [X] T035 [US3] Run s6 and sshd container startup validation from specs/001-alpine-runtime-template/quickstart.md and record results in specs/001-alpine-runtime-template/validation-evidence.md
- [X] T036 [US3] Run Alpine package-manager and compatibility package validation from specs/001-alpine-runtime-template/quickstart.md and record results in specs/001-alpine-runtime-template/validation-evidence.md
- [X] T037 [US3] Validate Alpine template creation in the real DevBox product environment and record catalog, create, startup, terminal, SSH, workspace, and apk results in specs/001-alpine-runtime-template/validation-evidence.md
- [X] T038 [US3] Validate VS Code Server-style access or equivalent DevBox code-editing access and record pass, limitation, or product-approved exception in specs/001-alpine-runtime-template/validation-evidence.md

**Checkpoint**: User Story 3 is independently functional when `validation-evidence.md` contains an explicit release decision for each required access path.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final checks that protect release quality and keep the diff focused.

- [X] T039 Run shell syntax checks for Alpine and modified shared scripts in base-images/operating-systems/alpine/3.22/build.sh, runtime-images/operating-systems/alpine/3.22/build.sh, tests/runtime-smoke/operating-systems/alpine/3.22/smoke.sh, tooling/scripts/install-base-pkg-apk.sh, tooling/scripts/cleanup.sh, tooling/scripts/configure-user.sh, tooling/scripts/configure-login.sh, tooling/scripts/configure-l10n.sh, and tooling/scripts/svc/configure-sshd.sh
- [X] T040 Confirm Dockerfile dependencies are parseable by the build planner for runtime-images/operating-systems/alpine/3.22/Dockerfile
- [X] T041 Confirm no fork-only workflow changes are present in .github/workflows
- [X] T042 Update implementation notes with final validation status and any product-approved limitations in specs/001-alpine-runtime-template/validation-evidence.md
- [X] T043 Run git status review to ensure no build outputs, cache files, temporary logs, or secrets are included in /Users/godblf/Projects/devbox-runtime

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup; blocks all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational; delivers MVP runtime creation.
- **User Story 2 (Phase 4)**: Depends on Foundational and benefits from US1 image files; can start once source files exist.
- **User Story 3 (Phase 5)**: Depends on US1 images and US2 validation surfaces.
- **Polish (Phase 6)**: Depends on the selected story scope being complete.

### User Story Dependencies

- **US1 (P1)**: No dependency on other user stories after Phase 2.
- **US2 (P2)**: Requires the Alpine source files from US1 for smoke and conformance to run, but conformance script work can begin after Phase 2.
- **US3 (P3)**: Requires built runtime images and validation commands from US1 and US2.

### Dependency Graph

```text
Phase 1 Setup
  -> Phase 2 Foundational
    -> US1 Create Alpine DevBox
      -> US2 Validate Alpine Runtime Quality
        -> US3 Resolve Alpine Compatibility Risk
          -> Phase 6 Polish
```

## Parallel Opportunities

- T002, T003, and T004 can run in parallel after T001 because they inspect different files.
- T016, T017, and T018 can run in parallel after T014 and T015 because they edit different project-template files.
- T024, T025, and T026 should be sequenced carefully because two tasks edit `tests/runtime-conformance/run.sh`; T026 can run in parallel with either because it edits `tests/runtime-conformance/README.md`.
- T030 and T031 can run independently once both localized images exist.
- T032 and T033 can run independently once smoke validation is passing.
- T034 can run in parallel with US1 and US2 implementation because it creates a feature artifact.

## Parallel Example: User Story 1

```text
Task: "Add Alpine starter entrypoint with non-root rerun, stable foreground HTTP serving, and no early exit in runtime-images/operating-systems/alpine/3.22/project-template/entrypoint.sh"
Task: "Add English Alpine README with Alpine 3.22, apk usage, musl caveat, default port, and entrypoint behavior in runtime-images/operating-systems/alpine/3.22/project-template/README.en_US.md"
Task: "Add Simplified Chinese Alpine README with Alpine 3.22, apk usage, musl caveat, default port, and entrypoint behavior in runtime-images/operating-systems/alpine/3.22/project-template/README.zh_CN.md"
```

## Parallel Example: User Story 2

```text
Task: "Run en_US Alpine smoke test in tests/runtime-smoke/operating-systems/alpine/3.22/smoke.sh"
Task: "Run zh_CN Alpine smoke test in tests/runtime-smoke/operating-systems/alpine/3.22/smoke.sh"
Task: "Run en_US Alpine runtime conformance through tests/runtime-conformance/run.sh"
Task: "Run zh_CN Alpine runtime conformance through tests/runtime-conformance/run.sh"
```

## Parallel Example: User Story 3

```text
Task: "Create compatibility evidence template for web terminal, SSH, apk install, startup, and VS Code Server-style access in specs/001-alpine-runtime-template/validation-evidence.md"
Task: "Run Alpine package-manager and compatibility package validation from specs/001-alpine-runtime-template/quickstart.md and record results in specs/001-alpine-runtime-template/validation-evidence.md"
```

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete US1 source files and localized image builds.
3. Run direct runtime checks for `en_US` and `zh_CN`.
4. Stop and validate that users can create a basic Alpine runtime before adding broader conformance and product validation.

### Incremental Delivery

1. Complete Setup and Foundational tasks.
2. Deliver US1 for a buildable and directly testable Alpine runtime.
3. Deliver US2 to make the runtime release-gate compliant.
4. Deliver US3 to close DevBox access and VS Code Server-style compatibility risk.
5. Complete Polish before PR handoff.

### Scope Guidance

- **MVP**: Phase 1, Phase 2, and US1.
- **Release candidate**: MVP plus US2.
- **Release-ready**: Release candidate plus US3 and Phase 6.

## Notes

- Keep final PR diff focused on runtime, template, smoke, conformance, and necessary shared tooling fixes.
- Do not keep fork-only workflow accommodations in `.github/workflows` unless separately approved.
- If product changes the Alpine target version before implementation, update all `3.22` paths and checks consistently before starting task execution.
