# Base stage for dependencies
FROM ubuntu:22.04 AS base
ENV TARGETARCH="linux-arm64"

RUN apt update && \
  apt upgrade -y && \
  apt install -y curl git jq libicu70 && \
  rm -rf /var/lib/apt/lists/*

# Install Azure CLI in a separate stage to leverage caching
FROM base AS azurecli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Final runtime image
FROM base AS final
WORKDIR /azp/

# Copy installed Azure CLI from the previous stage
COPY --from=azurecli /usr/bin/az /usr/bin/az
COPY --from=azurecli /usr/share/az* /usr/share/

# Copy and prepare the startup script
COPY ./start.sh ./
RUN chmod +x ./start.sh

# Create agent user with a fixed UID for consistency
RUN useradd -m -d /home/agent -u 1001 agent && \
    chown -R agent:agent /azp /home/agent

USER agent
# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT ["./start.sh"]

# Build image
# docker build -t saadbelk/cheveo/azp-agent-arm64:0.0.1 . --progress=plain --no-cache
# Push Image:
# docker push saadbelk/cheveo/azp-agent-arm64:0.0.1

