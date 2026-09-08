# Odin SDL_shadercross

Odin bindings and build script for the [SDL_shadercross](https://github.com/libsdl-org/SDL_shadercross) library.

## Building

Odin bindings are in [`shadercross.odin`](./shadercross.odin).

The scripts assume that [SDL3](https://github.com/libsdl-org/SDL) is already installed as a system library. \
To build the SDL_shadercross library run the shell script for your system.\
Windows build script: [`build.bat`](./build.bat).\
Bash build script: [`build.sh`](./build.sh).

The scripts can be configures with following environment variables:
```env
# git url
SHADERCROSS_URL=https://github.com/libsdl-org/SDL_shadercross.git

# git branch/commit/tag
SHADERCROSS_REF=main

# installation location
SHADERCROSS_PREFIX=.

# git clone location
SHADERCROSS_CLONE_DIR=./SDL_shadercross

# cmake build dist
SHADERCROSS_BUILD_DIR=./SDL_shadercross/build

# cmake flags
SHADERCROSS_FLAGS=-DSPIRV_WERROR=OFF -DSDLSHADERCROSS_DXC=ON -DSDLSHADERCROSS_VENDORED=ON -DSDLSHADERCROSS_SPIRVCROSS_SHARED=OFF -DSDLSHADERCROSS_SHARED=ON -DSDLSHADERCROSS_STATIC=OFF -DSDLSHADERCROSS_CLI=OFF -DSDLSHADERCROSS_INSTALL=ON
```

## License

[SDL_shadercross](https://github.com/libsdl-org/SDL_shadercross/blob/main/LICENSE.txt) and the bindings are [zlib](./LICENSE.txt) licensed.
