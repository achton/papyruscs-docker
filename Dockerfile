FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
ARG DEBIAN_FRONTEND=noninteractive
ARG PAPYRUSCS_SHA=8032db803e291a2838639c4e8693c66bdcb56648

# Install build dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        unzip \
        libgdiplus \
        libc6-dev

WORKDIR /tmp

# Fetch latest PapyrusCS codebase and move into place.
RUN curl -sLS -o papyruscs-release.zip https://github.com/mjungnickel18/papyruscs/archive/$PAPYRUSCS_SHA.zip \
    && mkdir ./papyruscs \
    && unzip -q papyruscs-release.zip -d ./papyruscs \
    && rm -rf /app \
    && find ./papyruscs/ -maxdepth 1 -mindepth 1 -type d -exec mv {} /app \;

# Fetch and replace textures.
RUN curl -sLS -o Vanilla_Resource_Pack.zip https://aka.ms/resourcepacktemplate \
    && unzip -q Vanilla_Resource_Pack.zip \
    && rm -rf /app/textures/blocks \
    && cp -af textures/blocks /app/textures/ \
    && cp -af textures/terrain_texture.json /app/textures/

# Compile PapyrusCS for linux-x64 and make binary executable.
# NOTE: The Release build configuration is broken currently, so use Debug.
WORKDIR /app
RUN dotnet publish PapyrusCs -c Debug --self-contained --runtime linux-x64
RUN chmod +x ./PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish/PapyrusCs

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
ENV PATH /app/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish/:$PATH

ENTRYPOINT ["PapyrusCs"]