#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$ROOT_DIR/build"
LIB_DIR="$BUILD_DIR/lib"

mkdir -p "$LIB_DIR"

case "$(uname -s)" in
	Linux)
		echo "Building example for Linux"

		# Copy runtime libraries next to the executable.
		cp -f "$SDL3_ROOT"/lib/libSDL3.so* "$LIB_DIR/"
		cp -f "$ROOT_DIR"/lib/libSDL3_shadercross.so* "$LIB_DIR/"
		cp -f "$ROOT_DIR"/lib/libdxcompiler.so* "$LIB_DIR/"
		cp -f "$ROOT_DIR"/lib/libdxil.so* "$LIB_DIR/"

		# Link against the installed libraries and make the executable
		# search for them relative to build/example.
		odin build example \
			-out:"$BUILD_DIR/example" \
			-extra-linker-flags:"-L$SDL3_ROOT/lib -L$ROOT_DIR/lib -Wl,-rpath,\$ORIGIN/lib"
		;;

	Darwin)
		echo "Building example for macOS"

		# Copy runtime libraries next to the executable.
		cp -f "$SDL3_ROOT"/lib/libSDL3*.dylib "$LIB_DIR/"
		cp -f "$ROOT_DIR"/lib/libSDL3_shadercross*.dylib "$LIB_DIR/"
		cp -f "$ROOT_DIR"/lib/libdxcompiler*.dylib "$LIB_DIR/" 2>/dev/null || true
		cp -f "$ROOT_DIR"/lib/libdxil*.dylib "$LIB_DIR/" 2>/dev/null || true

		# Link against the installed libraries and make the executable
		# search for them relative to build/example.
		odin build example \
			-out:"$BUILD_DIR/example" \
			-extra-linker-flags:"-L$SDL3_ROOT/lib -L$ROOT_DIR/lib -rpath @loader_path/lib"
		;;

	*)
		echo "Unsupported platform: $(uname -s)"
		exit 1
		;;
esac

echo "Built: $BUILD_DIR/example"
