#!/usr/bin/env bash
#
# SwarmStudio CLI installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/swarmstudio/swarmstudio-releases/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/swarmstudio/swarmstudio-releases/main/install.sh | bash -s -- --version 1.0.0
#
# Options (via arguments):
#   --version VERSION   Install a specific version (default: latest)
#   --dir DIR           Install to a custom directory (default: /usr/local)
#   --no-confirm        Skip confirmation prompt
#

set -euo pipefail

REPO="swarmstudio/swarmstudio-releases"
INSTALL_PREFIX="/usr/local"
VERSION=""
NO_CONFIRM=false

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)  VERSION="$2"; shift 2 ;;
        --dir)      INSTALL_PREFIX="$2"; shift 2 ;;
        --no-confirm) NO_CONFIRM=true; shift ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# ---------------------------------------------------------------------------
# Detect platform
# ---------------------------------------------------------------------------
detect_platform() {
    local os arch

    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os" in
        Linux)  os="linux" ;;
        Darwin) os="darwin" ;;
        *)
            echo "Error: Unsupported operating system: $os" >&2
            echo "SwarmStudio CLI supports Linux and macOS." >&2
            exit 1
            ;;
    esac

    case "$arch" in
        x86_64|amd64)  arch="x86_64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)
            echo "Error: Unsupported architecture: $arch" >&2
            echo "SwarmStudio CLI supports x86_64 and arm64." >&2
            exit 1
            ;;
    esac

    # Map to our naming convention
    case "${os}-${arch}" in
        linux-x86_64)  echo "linux-amd64" ;;
        linux-arm64)   echo "linux-arm64" ;;
        darwin-arm64)  echo "darwin-arm64" ;;
        darwin-x86_64) echo "darwin-x86_64" ;;
        *)
            echo "Error: Unsupported platform: ${os}-${arch}" >&2
            exit 1
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Resolve version
# ---------------------------------------------------------------------------
resolve_version() {
    if [ -n "$VERSION" ]; then
        echo "$VERSION"
        return
    fi

    # Get latest release tag from GitHub API
    local latest
    if command -v gh &>/dev/null; then
        latest=$(gh release view --repo "$REPO" --json tagName -q '.tagName' 2>/dev/null || true)
    fi

    if [ -z "$latest" ]; then
        latest=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null \
            | grep '"tag_name"' \
            | head -1 \
            | sed 's/.*"tag_name": *"//;s/".*//')
    fi

    if [ -z "$latest" ]; then
        echo "Error: Could not determine latest version." >&2
        echo "Specify a version with: --version 1.0.0" >&2
        exit 1
    fi

    echo "$latest"
}

# ---------------------------------------------------------------------------
# Download and install
# ---------------------------------------------------------------------------
install() {
    local platform version asset_name download_url tmp_dir

    platform="$(detect_platform)"
    version="$(resolve_version)"

    # Strip leading 'v' if present for asset name
    local ver_num="${version#v}"
    asset_name="swarmstudio-cli-${ver_num}-${platform}.tar.gz"
    download_url="https://github.com/${REPO}/releases/download/${version}/${asset_name}"

    echo "SwarmStudio CLI Installer"
    echo "========================="
    echo ""
    echo "  Version:  ${version}"
    echo "  Platform: ${platform}"
    echo "  Install:  ${INSTALL_PREFIX}/bin/swarm"
    echo ""

    # Confirm unless --no-confirm
    if [ "$NO_CONFIRM" = false ] && [ -t 0 ]; then
        printf "Proceed with installation? [Y/n] "
        read -r answer
        case "$answer" in
            [nN]*) echo "Cancelled."; exit 0 ;;
        esac
    fi

    # Check for sudo
    local SUDO=""
    if [ ! -w "${INSTALL_PREFIX}/bin" ] 2>/dev/null; then
        if command -v sudo &>/dev/null; then
            SUDO="sudo"
            echo "Note: sudo required to install to ${INSTALL_PREFIX}"
        else
            echo "Error: ${INSTALL_PREFIX}/bin is not writable and sudo is not available." >&2
            echo "Use --dir to install to a writable location." >&2
            exit 1
        fi
    fi

    # Download
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT

    echo "Downloading ${asset_name}..."
    if command -v gh &>/dev/null; then
        gh release download "$version" \
            --repo "$REPO" \
            --pattern "$asset_name" \
            --dir "$tmp_dir" 2>/dev/null \
        || curl -fSL "$download_url" -o "${tmp_dir}/${asset_name}"
    else
        curl -fSL "$download_url" -o "${tmp_dir}/${asset_name}"
    fi

    # Extract
    echo "Extracting..."
    tar -xzf "${tmp_dir}/${asset_name}" -C "$tmp_dir"

    # Find the extracted swarm directory
    local swarm_dir="${tmp_dir}/swarmstudio-cli-${ver_num}-${platform}/swarm"
    if [ ! -d "$swarm_dir" ]; then
        # Try alternative layout
        swarm_dir=$(find "$tmp_dir" -name "swarm" -type d | head -1)
    fi

    if [ ! -f "${swarm_dir}/swarm" ]; then
        echo "Error: Could not find swarm binary in downloaded archive." >&2
        exit 1
    fi

    # Install
    local target_dir="${INSTALL_PREFIX}/lib/swarmstudio-cli"
    echo "Installing to ${target_dir}..."

    $SUDO mkdir -p "$target_dir"
    $SUDO rm -rf "${target_dir:?}/"*
    $SUDO cp -r "${swarm_dir}/"* "$target_dir/"
    $SUDO chmod +x "${target_dir}/swarm"

    # Create symlink in bin
    $SUDO mkdir -p "${INSTALL_PREFIX}/bin"
    $SUDO ln -sf "${target_dir}/swarm" "${INSTALL_PREFIX}/bin/swarm"

    echo ""
    echo "Successfully installed SwarmStudio CLI ${version}!"
    echo ""
    echo "  Run:  swarm --help"
    echo ""

    # Verify
    if command -v swarm &>/dev/null; then
        swarm --version
    else
        echo "Note: ${INSTALL_PREFIX}/bin may not be in your PATH."
        echo "Add it with: export PATH=\"${INSTALL_PREFIX}/bin:\$PATH\""
    fi
}

install
