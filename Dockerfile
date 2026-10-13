FROM nvidia/cuda:12.9.2-cudnn-devel-ubuntu24.04

ARG CLAUDE_CODE_VERSION
ARG CODEX_VERSION
ARG NODE_VERSION
ARG OPENCODE_VERSION
ARG PI_VERSION
ARG UV_VERSION

ENV NVM_DIR="${HOME:-/root}/.nvm"
ENV CLAUDE_CONFIG_DIR="${HOME:-/root}/.claude"

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

# Install uv+nvm+node
#
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash \
  && bash -c "source ${NVM_DIR}/nvm.sh && nvm install ${NODE_VERSION}"

# Install Pi agent harness
#
RUN bash -c "source ${NVM_DIR}/nvm.sh && npm install -g \
    @earendil-works/pi-coding-agent@${PI_VERSION} \
    --ignore-scripts"

# Install other harnesses (may be useful for bootstrapping Pi)
#
RUN bash -c "source ${NVM_DIR}/nvm.sh && npm install -g \
    @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
    @openai/codex@${CODEX_VERSION} \
    @opencode/cli@${OPENCODE_VERSION}"



WORKDIR /workspace
ENTRYPOINT ["bash", "-c", "source $NVM_DIR/nvm.sh && exec \"$@\"", "--"]
