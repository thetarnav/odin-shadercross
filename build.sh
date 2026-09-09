#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$ROOT_DIR/build.env"

if [[ ! -f "$ENV_FILE" ]]; then
	echo "ERROR: $ENV_FILE does not exist."
	exit 1
fi

load_env() {
	while IFS= read -r line || [[ -n "$line" ]]; do
		# Ignore empty lines and comments.
		[[ -z "$line" || "$line" == \#* ]] && continue

		if [[ "$line" != *=* ]]; then
			continue
		fi

		local name="${line%%=*}"
		local value="${line#*=}"

		# Ignore values already supplied by the environment.
		if [[ -n "${!name+x}" ]]; then
			continue
		fi

		# Remove optional surrounding quotes.
		if [[ "$value" == \"*\" && "$value" == *\" ]]; then
			value="${value:1:${#value}-2}"
		elif [[ "$value" == \'*\' && "$value" == *\' ]]; then
			value="${value:1:${#value}-2}"
		fi

		export "$name=$value"
	done < "$ENV_FILE"
}

load_env

: "${SHADERCROSS_REF:?SHADERCROSS_REF is not set}"
: "${SHADERCROSS_URL:?SHADERCROSS_URL is not set}"
: "${SHADERCROSS_FLAGS:?SHADERCROSS_FLAGS is not set}"
: "${SHADERCROSS_PREFIX:?SHADERCROSS_PREFIX is not set}"
: "${SHADERCROSS_CLONE_DIR:?SHADERCROSS_CLONE_DIR is not set}"
: "${SHADERCROSS_BUILD_DIR:?SHADERCROSS_BUILD_DIR is not set}"

resolve_path() {
	if [[ "$1" = /* ]]; then
		printf '%s\n' "$1"
	else
		printf '%s\n' "$ROOT_DIR/$1"
	fi
}

INSTALL_PREFIX="$(resolve_path "$SHADERCROSS_PREFIX")"
CLONE_DIR="$(resolve_path "$SHADERCROSS_CLONE_DIR")"
BUILD_DIR="$(resolve_path "$SHADERCROSS_BUILD_DIR")"

library_present() {
	find "$INSTALL_PREFIX/lib" -type f \
		\( \
			-name 'libSDL3_shadercross.so' \
			-o -name 'libSDL3_shadercross.so.*' \
			-o -name 'libSDL3_shadercross.dylib' \
			-o -name 'SDL3_shadercross.dll' \
			-o -name 'SDL3_shadercross.lib' \
		\) \
		-print -quit 2>/dev/null | grep -q .
}

if library_present; then
	echo "WARNING: SDL_shadercross is already installed at:"
	echo "         $INSTALL_PREFIX/lib"
	echo "Skipping clone and build."
	echo "Remove the installed library if this was unintentional."
	exit 0
fi

if [[ -d "$CLONE_DIR/.git" ]]; then
	echo "Source repository already exists:"
	echo "  $CLONE_DIR"
	echo "Checking out $SHADERCROSS_REF..."

	git -C "$CLONE_DIR" fetch --depth 1 origin "$SHADERCROSS_REF"
	git -C "$CLONE_DIR" checkout "$SHADERCROSS_REF"
	git -C "$CLONE_DIR" submodule update --init --recursive
else
	echo "Cloning SDL_shadercross $SHADERCROSS_REF..."
	echo "  $SHADERCROSS_URL"
	echo "  -> $CLONE_DIR"

	mkdir -p "$(dirname "$CLONE_DIR")"

	git clone \
		--depth 1 \
		--branch "$SHADERCROSS_REF" \
		--recurse-submodules \
		"$SHADERCROSS_URL" \
		"$CLONE_DIR"
fi

echo "Configuring SDL_shadercross..."

cmake \
	-S "$CLONE_DIR" \
	-B "$BUILD_DIR" \
	-G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	"-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX" \
	-DCMAKE_INSTALL_RPATH='$ORIGIN' \
	-DCMAKE_BUILD_RPATH='$ORIGIN' \
	$SHADERCROSS_FLAGS

echo "Building SDL_shadercross..."

cmake \
	--build "$BUILD_DIR" \
	--config Release

echo "Installing SDL_shadercross..."

cmake \
	--install "$BUILD_DIR" \
	--config Release

echo "SDL_shadercross build complete."
echo "Installed to: $INSTALL_PREFIX"
