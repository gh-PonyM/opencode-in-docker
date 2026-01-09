ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

# Adapt to the default user used by the base image
ARG USERNAME=ubuntu
ARG SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive

# Install git, GNU utils, and other essential tools
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    wget \
    nano \
    ca-certificates \
    curl \
    unzip \
    gnupg \
    sudo \
    git \
    zsh \
    stow \
    # GNU core utilities
    coreutils \
    findutils \
    grep \
    sed \
    less \
    iproute2 \
    iputils-ping \
    net-tools \
    jq \
    man-db && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /home/$USERNAME/.ssh && \
    chmod 700 /home/$USERNAME/.ssh && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh && \
    mkdir -p /usr/local/share/npm-global && \
    chown -R $USERNAME:$USERNAME /usr/local/share

# Configure ubuntu user with sudo privileges
# RUN usermod -aG sudo ubuntu && \
#     echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu && \
#     chmod 0440 /etc/sudoers.d/ubuntu

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

USER $USERNAME

COPY --chown=$USERNAME:$USERNAME .bashrc /home/$USERNAME/.bashrc
COPY --chown=$USERNAME:$USERNAME .zshrc /home/$USERNAME/.zshrc

# fzf install --all will configure zsh and bashrc
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
   ~/.fzf/install --all && \
  sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Set default shell and editor
ENV EDITOR=nano \
  VISUAL=nano \
  NPM_CONFIG_PREFIX=/usr/local/share/npm-global \
  PATH=$PATH:/usr/local/share/npm-global/bin \
  SHELL=$SHELL

# -- OpenCode Config
# Create the directory structure for the auth file and config and fix ownership
# This prevents Docker from creating it as 'root' when the volume is mounted.
# This is important to be able to mount the OpenCode auth on docker run
#    -v ~/.local/share/opencode/auth.json:/home/$USERNAME/.local/share/opencode/auth.json
#    -v ~/.config/opencode:/home/$USERNAME/.config/opencode
RUN mkdir -p /home/$USERNAME/.local/share/opencode && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.local/share/opencode && \
    mkdir -p /home/$USERNAME/.config/opencode && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/opencode && \
    npm i -g opencode-ai

COPY configs/* /home/$USERNAME/.config/opencode/

# Copy and set up entrypoint
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/env", "bash"]
