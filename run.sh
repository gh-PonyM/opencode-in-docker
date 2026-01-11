#!/usr/bin/env bash

set -uo pipefail

run-opencode() {
    local USERNAME=ubuntu
    local IMAGE_NAME=${OPENCODE_IMAGE_NAME:-ubuntu-opencode:latest}
    local PROJECT_PATH="${1:-$PWD}"
    # Resolve absolute path
    PROJECT_PATH="$(cd "$PROJECT_PATH" 2>/dev/null && pwd)" || {
        echo "Error: Project path '$1' does not exist"
        return 1
    }
    local REPO_NAME=$(basename "$PROJECT_PATH")
    local C_HOSTNAME="dev"
    local CONTAINER_NAME="opencode-$REPO_NAME"

    echo "Starting OpenCode container for: $PROJECT_PATH"
    pushd $PROJECT_PATH
    # Get git user config from host
    local GIT_USER_NAME="$(git config user.name 2>/dev/null || echo '')"
    local GIT_USER_EMAIL="$(git config user.email 2>/dev/null || echo '')"

    local wd
    if [[ "$PROJECT_PATH" == "$HOME"* ]]; then
        # Strip $HOME prefix and construct container path
        local rel_path="${PROJECT_PATH#$HOME/}"
        wd="/home/$USERNAME/$rel_path"
    else
        wd="/home/$USERNAME/Repos/$REPO_NAME"
    fi

    local OPENCODE_MOUNT_ARGS=()
    if [[ -n "${OPENCODE_DOTFILES_LOCAL:-}" ]]; then
        local DOTFILES_LOCAL="$OPENCODE_DOTFILES_LOCAL"
        local DOTFILES_CONTAINER_PATH
        if [[ "$DOTFILES_LOCAL" == "$HOME"* ]]; then
            # Preserve relative structure under /home/$USERNAME
            local rel_path="${DOTFILES_LOCAL#$HOME/}"
            DOTFILES_CONTAINER_PATH="/home/$USERNAME/$rel_path"
        else
            # Fallback location for non-$HOME paths
            DOTFILES_CONTAINER_PATH=$OPENCODE_DOTFILES_LOCAL
        fi
        echo "Including your dotfiles as folder mount: $DOTFILES_LOCAL:$DOTFILES_CONTAINER_PATH"
        OPENCODE_MOUNT_ARGS+=(
            -v "$DOTFILES_LOCAL:$DOTFILES_CONTAINER_PATH:ro"
        )
    fi
    local LOCAL_AUTH_DIR="$HOME/.local/share/opencode"
    # to run /connect within the container if not ANTHROPIC_API_KEY or OPENROUTER_API_KEY is used, e.g. for Github Copilot
    mkdir -p "$LOCAL_AUTH_DIR"
    docker run -it --rm \
        --name "$CONTAINER_NAME" \
        -h "$C_HOSTNAME" \
        -w "$wd" \
        -e ANTHROPIC_API_KEY \
        -e OPENROUTER_API_KEY \
        -e GH_TOKEN \
        -e GIT_USER_NAME="$GIT_USER_NAME" \
        -e GIT_USER_EMAIL="$GIT_USER_EMAIL" \
        -v "$PROJECT_PATH:$wd" \
        -v "$HOME/.config/opencode:/home/$USERNAME/.config/opencode:ro" \
        -v "$HOME/.local/state/opencode:/home/$USERNAME/.local/state/opencode:rw" \
        -v "$LOCAL_AUTH_DIR:/home/$USERNAME/.local/share/opencode:rw" \
        "${OPENCODE_MOUNT_ARGS[@]}" \
        "$IMAGE_NAME"
}

run-opencode "$@"
