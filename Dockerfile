FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
ARG DEBIAN_FRONTEND=noninteractive
ARG PACKAGE_URL=https://github.com/papyrus-mc/papyruscs/archive/refs/heads/master.zip

# Install build dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        unzip \
        libgdiplus \
        libc6-dev

WORKDIR /tmp

# Fetch latest PapyrusCS codebase and move into place.
RUN curl -sLS -o papyruscs-release.zip $PACKAGE_URL \
    && mkdir ./papyruscs \
    && unzip -q papyruscs-release.zip -d ./papyruscs \
    && rm -rf /app \
    && find ./papyruscs/ -maxdepth 1 -mindepth 1 -type d -exec mv {} /app \;

# Fetch and replace textures.
RUN curl -sLS -o resource_pack.zip https://github.com/Mojang/bedrock-samples/archive/refs/heads/main.zip \
    && unzip -q resource_pack.zip \
    && rm -rf /app/textures/blocks \
    && cp -af bedrock-samples-main/resource_pack/textures/blocks /app/textures/ \
    && cp -af bedrock-samples-main/resource_pack/textures/terrain_texture.json /app/textures/

# Compile PapyrusCS for linux-x64 and make binary executable.
WORKDIR /app
RUN dotnet publish PapyrusCs -c Release --self-contained --runtime linux-x64
RUN chmod +x ./PapyrusCs/bin/Release/netcoreapp3.1/linux-x64/publish/PapyrusCs

# -----------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/core/runtime:3.1 AS runtime
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install runtime dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgdiplus \
        libc6-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy built PapyrusCS app over from build container.
COPY --from=build /app/ ./

# Add binary to path.
ENV PATH /app/PapyrusCs/bin/Release/netcoreapp3.1/linux-x64/publish/:$PATH

ENTRYPOINT ["PapyrusCs"]
