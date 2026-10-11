FROM node:24-bookworm-slim

ARG PI_VERSION
ARG UV_VERSION

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

# Install Pi agent harness
#
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent@${PI_VERSION}

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
ENTRYPOINT ["pi"]
