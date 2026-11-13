# SwarmStudio releases

Downloads for SwarmStudio staff tools.

## llm-server (current)

llm-server runs SwarmStudio's staging model steps on your own computer, with your own Claude login.
Platform staff only.

- **Releases:** [llm-server releases](https://github.com/swarmstudio/swarmstudio-releases/releases?q=llm-server&expanded=true).
  They are pre-releases, so GitHub's "Latest" badge points at the old CLI below, not at llm-server.
- **Guide:** every release attaches `INSTALL.md`, the full step-by-step guide (download, verify, unpack, log in, serve,
  troubleshooting). Use the one attached to the release you download.

### In short

```bash
V=2026.11.15
P=darwin-arm64        # or darwin-x86_64, linux-x86_64, linux-aarch64 (uname -m: arm64 / x86_64 / aarch64)
BASE=https://github.com/swarmstudio/swarmstudio-releases/releases/download/llm-server-v$V
curl -fLO $BASE/llm-server-$V-$P.tar.gz && curl -fLO $BASE/SHA256SUMS
shasum -a 256 -c SHA256SUMS --ignore-missing          # Linux: sha256sum -c --ignore-missing SHA256SUMS
mkdir -p ~/Applications && tar -xzf llm-server-$V-$P.tar.gz -C ~/Applications
xattr -dr com.apple.quarantine ~/Applications/llm-server-$V-$P   # macOS only

claude auth status                                     # must say "loggedIn": true (install Claude Code and /login first)
~/Applications/llm-server-$V-$P/bin/llm-server login   # paste the flc_... credential from Studio > Local lanes
~/Applications/llm-server-$V-$P/bin/llm-server serve
```

### How serving works

- Plain `llm-server serve` serves **every workspace on staging**, every org's brains and **everyone's personal brains**.
- Every staff laptop does the same, and they share the work: the first live laptop that can serve a step takes it, with no
  warnings. Staging's own pods take only what no live laptop can serve.
- A personal brain's step can therefore run on any staff laptop, through the Claude subscription of whoever's laptop takes it.
- Each laptop sends a heartbeat every 10 s. A laptop that goes away (lid closed, network lost) loses nothing: its waiting
  work goes to another laptop at once, and the steps it was running are re-queued within about 35 s.
- Narrowing (`--workspaces`, `--org`, `--personal you@...`, `--kinds`) is for debugging only.
- Staging refuses too-old releases (`TUNNEL_CLIENT_OUTDATED` / `LLM_SERVER_OUTDATED`): download the newest one.
  On 2026.11.14 run `llm-server serve --all-workspaces` (a bare `serve` needs 2026.11.15 or newer).

## SwarmStudio CLI (`swarm`) — retired

The `swarm` command-line tool below was retired on 2026-10-09 and is no longer maintained. Its releases (v1.x) and
`install.sh` stay here for reference only.

<details>
<summary>Old CLI instructions</summary>

Standalone binary releases for the SwarmStudio CLI.

### Quick Install

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

### Supported Platforms

| Platform | Architecture | Asset name |
|----------|-------------|------------|
| Linux | x86_64 (Intel/AMD) | `swarmstudio-cli-*-linux-amd64.tar.gz` |
| Linux | ARM64 (Graviton, etc.) | `swarmstudio-cli-*-linux-arm64.tar.gz` |
| macOS | Apple Silicon (M1-M4) | `swarmstudio-cli-*-darwin-arm64.tar.gz` |
| macOS | Intel | `swarmstudio-cli-*-darwin-x86_64.tar.gz` |

No Python installation required. Each archive is a self-contained binary.

### Manual Install

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

### Verify Installation

```bash
swarm --version
swarm --help
```

### Getting Started

```bash
# 1) Install
swarm install

# 2.a) Create new workspace
swarm workspace create <name>

# 2.b) List and use existing workspace
swarm workspace list
swarm workspace use <id-or-slug>

# 3) Run a task flow
swarm task run <task-description>
```

### Uninstall

```bash
sudo rm -rf /usr/local/lib/swarmstudio-cli
sudo rm -f /usr/local/bin/swarm
```

</details>
