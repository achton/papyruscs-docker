PapyrusCS container image
=========================

[![Build status](https://img.shields.io/docker/cloud/build/achton/papyruscs-docker.svg)](https://hub.docker.com/r/achton/papyruscs-docker) [![Docker pulls](https://img.shields.io/docker/pulls/achton/papyruscs-docker.svg)](https://hub.docker.com/r/achton/papyruscs-docker)

This image containerizes the Minecraft mapper [PapyrusCS](https://github.com/mjungnickel18/papyruscs) such that it can be used to effectively render worlds into HTML maps.

This image does *not*;
- provide a mechanism for fetching your world data (you should mount it into the container).
- do anything fancy to hand you the generated output (you should mount a volume for this too).
- serve the generated HTML (you can use any basic HTTP container image for that).

This image *does*:
- contain a `master` version of the PapyrusCS source
- hold a compiled binary built under .NET Core 3.1
- use the latest Vanilla texture pack
- let you pass arbitrary options to PapyrusCS via the Docker runtime
- include a `docker-compose.yaml` file for easy local usage

## Mounts

You should mount any worlds you need and the output folder into the container image, so they can be referenced by PapyrusCS. See examples below.

## Examples

### Run PapyrusCS thru Docker
```
$ docker run \
    -it \
    --rm \
    --name papyruscs-docker \
    -v "$(pwd)"/worlds:/app/worlds \
    -v "$(pwd)"/output:/app/output \
    achton/papyruscs-docker \
    <options>
```

### Run PapyrusCS thru docker-compose
```
$ docker-compose run \
    --rm \
    papyruscs \
    <options>
```

### Build basic Overworld map
```
$ docker-compose run \
    --rm \
    papyruscs \
    -w ./worlds/survival \
    -o ./output \
    --dim 0
```

### Build map using Underground profile
```
$ docker-compose run \
    --rm \
    papyruscs \
    -w ./worlds/survival \
    -o ./output \
    --dim 0 \
    --profile underground
```

See [PapyrusCS usage](https://github.com/mjungnickel18/papyruscs#usage) for a list of all available options.

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
