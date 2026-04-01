# SwarmStudio CLI

Standalone binary releases for the SwarmStudio CLI.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/swarmstudio/swarmstudio-releases/main/install.sh | bash
```

This auto-detects your platform and installs the latest version to `/usr/local/bin/swarm`.

### Options

```bash
# Install specific version
curl -fsSL https://raw.githubusercontent.com/swarmstudio/swarmstudio-releases/main/install.sh | bash -s -- --version v1.0.0

# Install to custom directory
curl -fsSL https://raw.githubusercontent.com/swarmstudio/swarmstudio-releases/main/install.sh | bash -s -- --dir ~/.local

# Skip confirmation prompt
curl -fsSL https://raw.githubusercontent.com/swarmstudio/swarmstudio-releases/main/install.sh | bash -s -- --no-confirm
```

## Supported Platforms

| Platform | Architecture | Asset name |
|----------|-------------|------------|
| Linux | x86_64 (Intel/AMD) | `swarmstudio-cli-*-linux-amd64.tar.gz` |
| Linux | ARM64 (Graviton, etc.) | `swarmstudio-cli-*-linux-arm64.tar.gz` |
| macOS | Apple Silicon (M1-M4) | `swarmstudio-cli-*-darwin-arm64.tar.gz` |
| macOS | Intel | `swarmstudio-cli-*-darwin-x86_64.tar.gz` |

No Python installation required. Each archive is a self-contained binary.

## Manual Install

1. Download the archive for your platform from [Releases](https://github.com/swarmstudio/swarmstudio-releases/releases)
2. Extract:
   ```bash
   tar -xzf swarmstudio-cli-*.tar.gz
   ```
3. Install:
   ```bash
   cd swarmstudio-cli-*/
   ./install.sh
   ```

Or manually copy:
```bash
sudo cp -r swarm /usr/local/lib/swarmstudio-cli/
sudo ln -sf /usr/local/lib/swarmstudio-cli/swarm /usr/local/bin/swarm
```

## Verify Installation

```bash
swarm --version
swarm --help
```

## Getting Started

```bash
# 1) Install
swarm install

# 2) Set up workspace
swarm workspace setup <name>

# 3) Run a task flow
swarm task run <task-description>
```

## Uninstall

```bash
sudo rm -rf /usr/local/lib/swarmstudio-cli
sudo rm -f /usr/local/bin/swarm
```
