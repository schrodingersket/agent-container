FROM nvidia/cuda:12.9.2-cudnn-devel-ubuntu24.04

ARG PI_VERSION
ARG UV_VERSION
ARG NODE_VERSION

ENV NVM_DIR="${HOME:-/root}/.nvm"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     bash \
     ca-certificates \
     curl \
     default-jdk \
     git \
     gnupg \
     ripgrep \
     vim \
  && rm -rf /var/lib/apt/lists/*

# Install Pi agent harness via NVM
#
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash \
  && bash -c "source ${NVM_DIR}/nvm.sh && nvm install ${NODE_VERSION} && npm install -g --ignore-scripts @earendil-works/pi-coding-agent@${PI_VERSION}"

# Install uv
#
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh

# Install Claude Code
#
RUN install -d -m 0755 /etc/apt/keyrings \
  && curl -fsSL https://downloads.claude.ai/keys/claude-code.asc \
     -o /etc/apt/keyrings/claude-code.asc \
  && gpg --show-keys /etc/apt/keyrings/claude-code.asc \
  && echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" \
     | tee /etc/apt/sources.list.d/claude-code.list \
  && apt update \
  && apt install claude-code \
  && ln -s ~/.claude/.claude.json ~/.claude.json

WORKDIR /workspace
ENTRYPOINT ["bash", "-c", "source $NVM_DIR/nvm.sh && exec \"$@\"", "--"]
