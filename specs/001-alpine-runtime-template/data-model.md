# Data Model: Alpine Runtime Template

## Alpine Runtime Template

**Description**: User-selectable DevBox operating-system template for Alpine.

**Fields**:

- `kind`: `operating-systems`
- `name`: `alpine`
- `version`: `3.22`
- `runtime_path`: `operating-systems/alpine/3.22`
- `base_image_name`: `alpine-3.22`
- `runtime_image_name`: `alpine-3.22`
- `supported_locales`: `en_US`, `zh_CN`
- `minimum_architecture_scope`: `amd64`
- `release_architecture_scope`: `amd64`, `arm64` when CI resources allow
- `status`: `planned`, `implemented`, `validated`, `released`, or `blocked`

**Relationships**:

- Has one Target Alpine Release.
- Has two Localized Runtime Variants.
- Produces one Base Image and one Runtime Image per locale and architecture.
- Requires Validation Evidence before release.
- Requires a Compatibility Decision for DevBox access paths.

**Validation Rules**:

- `runtime_path` must have matching source and smoke-test paths.
- `version` must remain consistent across Dockerfiles, README content, smoke tests, conformance registration, and validation commands.
- `status` cannot advance to `released` unless smoke, conformance, startup, SSH, package-manager, and real DevBox validation have acceptable outcomes.

## Target Alpine Release

**Description**: The Alpine Linux release selected for this template.

**Fields**:

- `version`: default `3.22`
- `source`: `default-from-requirement` or `product-confirmed`
- `docker_base_reference`: expected to resolve to the selected Alpine release
- `musl_based`: `true`

**Relationships**:

- Used by Alpine Runtime Template.
- Referenced by Localized Runtime Variants and Validation Evidence.

**Validation Rules**:

- If product chooses a different release, every path, runtime identity check, README, smoke test, conformance target, and validation command must be updated consistently.
- Alpine identity checks must verify both distribution name and release.

## Localized Runtime Variant

**Description**: Locale-specific runtime output and starter content.

**Fields**:

- `locale`: `en_US` or `zh_CN`
- `normalized_locale`: `en-us` or `zh-cn`
- `readme_source`: locale-specific project template README
- `readme_target`: `/home/devbox/project/README.md`
- `timezone_behavior`: default or zh_CN-specific if configured by shared tooling
- `package_source_behavior`: default or zh_CN-specific if configured by shared tooling

**Relationships**:

- Belongs to Alpine Runtime Template.
- Is validated by smoke and conformance checks.

**Validation Rules**:

- The final project directory must contain only the selected `README.md`, not the original localized README source files.
- Both locale variants must describe the same runtime version, package manager, entrypoint behavior, and compatibility caveats.
- The zh_CN variant must provide Simplified Chinese starter content.

## Base Image

**Description**: Alpine operating-system base image with shared DevBox services and users configured.

**Fields**:

- `path`: `base-images/operating-systems/alpine/3.22`
- `dockerfile`: base image Dockerfile
- `build_script`: base build script
- `base_distribution`: Alpine 3.22
- `package_manager`: `apk`
- `default_user`: `devbox`
- `project_dir`: `/home/devbox/project`
- `entrypoint`: `/init`

**Relationships**:

- Uses shared tooling scripts.
- Is consumed by Runtime Image.

**Validation Rules**:

- Must install the package-manager, user, SSH, shell, archive, network, docs, s6, and compatibility prerequisites needed by the runtime contract.
- Must create a usable default user and writable project directory.
- Must keep startup managed by the existing s6 entrypoint contract.

## Runtime Image

**Description**: User-facing Alpine runtime image with starter project files.

**Fields**:

- `path`: `runtime-images/operating-systems/alpine/3.22`
- `dockerfile`: runtime image Dockerfile
- `build_script`: runtime build script
- `project_template`: localized README files and `entrypoint.sh`
- `workdir`: `/home/devbox/project`

**Relationships**:

- Built from Base Image.
- Contains one Localized Runtime Variant per image build.

**Validation Rules**:

- Must copy the correct localized README into the project directory.
- Must copy executable starter entrypoint.
- Must not leave project files owned by root after conformance root-entrypoint checks.
- Must start the starter service without exiting early.

## Validation Evidence

**Description**: The commands and results used to prove the feature is ready.

**Fields**:

- `planner_result`: build and conformance matrix output
- `build_results`: base and runtime image build outcomes for required locales and architectures
- `smoke_results`: locale-specific smoke test outcomes
- `conformance_results`: locale-specific conformance outcomes
- `startup_result`: s6/sshd running-container outcome
- `package_manager_result`: Alpine package-manager install/use outcome
- `real_devbox_result`: template catalog, create, terminal, SSH, workspace, and code-editing access outcome

**Relationships**:

- Belongs to Alpine Runtime Template.
- Informs Compatibility Decision.

**Validation Rules**:

- Any failed required validation blocks release unless product explicitly accepts a documented limitation.
- Evidence must include both `en_US` and `zh_CN` for the minimum architecture scope.

## Compatibility Decision

**Description**: Product-facing conclusion for Alpine DevBox access compatibility.

**Fields**:

- `web_terminal`: `pass`, `blocked`, or `limited`
- `ssh`: `pass`, `blocked`, or `limited`
- `vscode_server_style_access`: `pass`, `blocked`, `limited`, or `not-applicable`
- `limitation_notes`: required when any access path is not `pass`
- `product_approval`: required when releasing with limitations

**Relationships**:

- Derived from Validation Evidence.
- Required by Alpine Runtime Template before release.

**Validation Rules**:

- Must be explicit before release.
- Must not claim support for VS Code Server-style access without real DevBox validation evidence.
