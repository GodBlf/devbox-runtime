#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- bash "$SCRIPT_PATH" "$@"
fi

app_env=${1:-development}
build_target=${JAVA_BUILD_TARGET:-HelloWorld}

if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ]; then
    echo "Production environment detected"
else
    echo "Development environment detected"
fi

javac "${build_target}.java"
exec java "$build_target"
