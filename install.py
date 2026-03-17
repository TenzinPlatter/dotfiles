#!/usr/bin/env python3
"""Dotfiles dependency installer for Ubuntu.

Most tools are installed from upstream sources (GitHub releases, cargo, etc.)
since Ubuntu apt packages are typically too old.

Usage:
    ./install.py --all
    ./install.py rust cargo zsh neovim tmux
    ./install.py --list
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

HOME = Path.home()
BOLD = "\033[1m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
RED = "\033[0;31m"
RESET = "\033[0m"


def info(msg: str) -> None:
    print(f"{GREEN}[INFO]{RESET} {msg}", flush=True)


def warn(msg: str) -> None:
    print(f"{YELLOW}[WARN]{RESET} {msg}", flush=True)


def error(msg: str) -> None:
    print(f"{RED}[ERROR]{RESET} {msg}", flush=True)


def section(msg: str) -> None:
    print(f"\n{BOLD}=== {msg} ==={RESET}", flush=True)


def run(cmd: str, check: bool = True, **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, shell=True, check=check, **kwargs)


def has(cmd: str) -> bool:
    return shutil.which(cmd) is not None


def github_latest_version(repo: str) -> str:
    """Get latest release tag from a GitHub repo."""
    result = run(
        f'curl -s "https://api.github.com/repos/{repo}/releases/latest" | jq -r .tag_name',
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def github_latest_version_bare(repo: str) -> str:
    """Get latest release version without leading 'v'."""
    return github_latest_version(repo).lstrip("v")


# =============================================================================
# Installers
# =============================================================================


def install_apt_deps() -> None:
    section("APT: base build dependencies & libraries")
    run("sudo apt-get update -qq")
    run(
        "sudo apt-get install -y "
        "build-essential cmake curl wget unzip git git-lfs "
        "pkg-config libssl-dev libfontconfig1-dev "
        "python3 python3-pip python3-venv "
        "wl-clipboard playerctl pavucontrol jq gdb stow "
        "libevent-dev ncurses-dev bison"
    )
    info("APT base deps installed")


def install_rust() -> None:
    section("Rust toolchain")
    if has("rustup"):
        info("rustup already installed, updating")
        run("rustup update")
    else:
        run("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y")
    info("Rust toolchain ready")


def install_cargo_tools() -> None:
    section("Cargo tools (parallel)")

    tools = {
        "eza": "eza",
        "bat": "bat",
        "zoxide": "zoxide",
        "fd-find": "fd",
        "ripgrep": "rg",
        "git-delta": "delta",
        "yazi-fm": "yazi",
    }

    cargo = str(HOME / ".cargo" / "bin" / "cargo")
    if not os.path.exists(cargo):
        cargo = "cargo"

    to_install = []
    for crate, binary in tools.items():
        if has(binary):
            info(f"{binary} already installed, skipping")
        else:
            to_install.append(crate)

    if not to_install:
        info("All cargo tools already installed")
        return

    # cargo install can't truly run in parallel safely on the same target dir,
    # but we can batch them in one command
    info(f"Installing: {', '.join(to_install)}")
    run(f"{cargo} install {' '.join(to_install)}")


def install_zsh() -> None:
    section("Zsh")
    if not has("zsh"):
        run("sudo apt-get install -y zsh")

    shell = os.environ.get("SHELL", "")
    if "zsh" not in shell:
        warn("Run 'chsh -s $(which zsh)' to set zsh as your default shell")

    # Antidote
    antidote_dir = HOME / ".config" / "zsh" / ".antidote"
    if antidote_dir.is_dir():
        info("antidote already present")
    else:
        run(f"git clone --depth=1 https://github.com/mattmc3/antidote.git {antidote_dir}")
    info("Zsh + antidote ready")


def install_fzf() -> None:
    section("fzf")
    if has("fzf"):
        info("fzf already installed")
        return
    fzf_dir = HOME / ".fzf"
    if not fzf_dir.is_dir():
        run(f"git clone --depth 1 https://github.com/junegunn/fzf.git {fzf_dir}")
    run(f"{fzf_dir}/install --key-bindings --completion --no-update-rc --no-bash --no-fish")


def install_neovim() -> None:
    section("Neovim")
    if has("nv") or has("nvim"):
        info("neovim already installed")
        return
    script = Path(__file__).parent / "install-nvim.sh"
    run(f"bash {script}")


def install_tmux() -> None:
    section("tmux (from source)")
    if has("tmux"):
        info("tmux already installed")
        return
    version = "3.5a"
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/tmux.tar.gz "
            f"https://github.com/tmux/tmux/releases/download/{version}/tmux-{version}.tar.gz"
        )
        run(f"tar xzf {tmpdir}/tmux.tar.gz -C {tmpdir}")
        run(f"cd {tmpdir}/tmux-{version} && ./configure && make -j$(nproc) && sudo make install")

    # TPM
    tpm_dir = HOME / ".config" / "tmux" / "plugins" / "tpm"
    if not tpm_dir.is_dir():
        run(f"git clone https://github.com/tmux-plugins/tpm {tpm_dir}")


def install_kitty() -> None:
    section("kitty")
    if has("kitty"):
        info("kitty already installed")
        return
    run("curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n")
    local_bin = HOME / ".local" / "bin"
    local_bin.mkdir(parents=True, exist_ok=True)
    kitty_app = HOME / ".local" / "kitty.app" / "bin"
    (local_bin / "kitty").unlink(missing_ok=True)
    (local_bin / "kitten").unlink(missing_ok=True)
    (local_bin / "kitty").symlink_to(kitty_app / "kitty")
    (local_bin / "kitten").symlink_to(kitty_app / "kitten")


def install_lazygit() -> None:
    section("lazygit")
    if has("lazygit"):
        info("lazygit already installed")
        return
    version = github_latest_version_bare("jesseduffield/lazygit")
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/lazygit.tar.gz "
            f"https://github.com/jesseduffield/lazygit/releases/download/v{version}/lazygit_{version}_Linux_x86_64.tar.gz"
        )
        run(f"tar xzf {tmpdir}/lazygit.tar.gz -C {tmpdir}")
        run(f"sudo install {tmpdir}/lazygit /usr/local/bin/lazygit")


def install_gh() -> None:
    section("GitHub CLI (gh)")
    if has("gh"):
        info("gh already installed")
        return
    run(
        "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg "
        "| sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    )
    run(
        'echo "deb [arch=$(dpkg --print-architecture) '
        "signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] "
        'https://cli.github.com/packages stable main" '
        "| sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    )
    run("sudo apt-get update -qq && sudo apt-get install -y gh")


def install_volta() -> None:
    section("Volta (Node version manager)")
    if has("volta"):
        info("volta already installed")
        return
    run("curl https://get.volta.sh | bash -s -- --skip-setup")
    volta = HOME / ".volta" / "bin" / "volta"
    run(f"{volta} install node")


def install_helix() -> None:
    section("Helix editor")
    if has("hx"):
        info("helix already installed")
        return
    version = github_latest_version("helix-editor/helix")
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/helix.tar.xz "
            f"https://github.com/helix-editor/helix/releases/download/{version}/helix-{version}-x86_64-linux.tar.xz"
        )
        run(f"tar xJf {tmpdir}/helix.tar.xz -C {tmpdir}")
        run("sudo mkdir -p /opt/helix")
        run(f"sudo cp -r {tmpdir}/helix-*/* /opt/helix/")
        run("sudo ln -sf /opt/helix/hx /usr/local/bin/hx")


def install_direnv() -> None:
    section("direnv")
    if has("direnv"):
        info("direnv already installed")
        return
    run(
        "sudo curl -Lo /usr/local/bin/direnv "
        "https://github.com/direnv/direnv/releases/latest/download/direnv.linux-amd64"
    )
    run("sudo chmod +x /usr/local/bin/direnv")


def install_fastfetch() -> None:
    section("fastfetch")
    if has("fastfetch"):
        info("fastfetch already installed")
        return
    version = github_latest_version("fastfetch-cli/fastfetch")
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/fastfetch.deb "
            f"https://github.com/fastfetch-cli/fastfetch/releases/download/{version}/fastfetch-linux-amd64.deb"
        )
        run(f"sudo dpkg -i {tmpdir}/fastfetch.deb || sudo apt-get install -f -y")


def install_docker() -> None:
    section("Docker")
    if has("docker"):
        info("docker already installed")
        return
    run("curl -fsSL https://get.docker.com | sh")
    run(f"sudo usermod -aG docker {os.environ['USER']}")
    warn("Log out and back in for docker group membership to take effect")


def install_lazydocker() -> None:
    section("lazydocker")
    if has("lazydocker"):
        info("lazydocker already installed")
        return
    version = github_latest_version_bare("jesseduffield/lazydocker")
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/lazydocker.tar.gz "
            f"https://github.com/jesseduffield/lazydocker/releases/download/v{version}/lazydocker_{version}_Linux_x86_64.tar.gz"
        )
        run(f"tar xzf {tmpdir}/lazydocker.tar.gz -C {tmpdir}")
        run(f"sudo install {tmpdir}/lazydocker /usr/local/bin/lazydocker")


def install_kanata() -> None:
    section("kanata")
    if has("kanata"):
        info("kanata already installed")
        return
    version = github_latest_version("jtroo/kanata")
    run(
        f"sudo curl -Lo /usr/local/bin/kanata "
        f"https://github.com/jtroo/kanata/releases/download/{version}/kanata"
    )
    run("sudo chmod +x /usr/local/bin/kanata")


def install_niri() -> None:
    section("niri (Wayland compositor)")
    if has("niri"):
        info("niri already installed")
        return
    warn("Installing niri build deps...")
    run(
        "sudo apt-get install -y "
        "libwayland-dev libseat-dev libudev-dev libinput-dev libgbm-dev "
        "libxkbcommon-dev libpango1.0-dev libdbus-1-dev libpipewire-0.3-dev "
        "libsystemd-dev clang"
    )
    cargo = str(HOME / ".cargo" / "bin" / "cargo")
    if not os.path.exists(cargo):
        cargo = "cargo"
    run(f"{cargo} install niri")


def install_waybar() -> None:
    section("waybar")
    if has("waybar"):
        info("waybar already installed")
        return
    warn("Building waybar from source...")
    run(
        "sudo apt-get install -y "
        "meson ninja-build libgtkmm-3.0-dev libgtk-layer-shell-dev "
        "libpulse-dev libnl-3-dev libnl-genl-3-dev libdbusmenu-gtk3-dev "
        "libsndio-dev libevdev-dev libjsoncpp-dev libmpdclient-dev "
        "libfmt-dev libspdlog-dev libwayland-dev scdoc"
    )
    with tempfile.TemporaryDirectory() as tmpdir:
        run(f"git clone https://github.com/Alexays/Waybar.git {tmpdir}/waybar")
        run(
            f"cd {tmpdir}/waybar && "
            "meson setup build --prefix=/usr/local && "
            "ninja -C build && "
            "sudo ninja -C build install"
        )


def install_distrobox() -> None:
    section("distrobox")
    if has("distrobox"):
        info("distrobox already installed")
        return
    run("curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh")


def install_zellij() -> None:
    section("zellij")
    if has("zellij"):
        info("zellij already installed")
        return
    version = github_latest_version("zellij-org/zellij")
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/zellij.tar.gz "
            f"https://github.com/zellij-org/zellij/releases/download/{version}/zellij-x86_64-unknown-linux-musl.tar.gz"
        )
        run(f"tar xzf {tmpdir}/zellij.tar.gz -C {tmpdir}")
        run(f"sudo install {tmpdir}/zellij /usr/local/bin/zellij")


def install_fonts() -> None:
    section("JetBrainsMono Nerd Font")
    font_dir = HOME / ".local" / "share" / "fonts" / "JetBrainsMono"
    if font_dir.is_dir():
        info("JetBrainsMono Nerd Font already installed")
        return
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/jbm.zip "
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        )
        font_dir.mkdir(parents=True, exist_ok=True)
        run(f"unzip -o {tmpdir}/jbm.zip -d {font_dir}")
    run("fc-cache -fv")


# =============================================================================
# Installer registry & parallel execution
# =============================================================================

# (name, function, dependencies)
# Dependencies are other installer names that must complete first.
INSTALLERS: dict[str, tuple[callable, list[str]]] = {
    "apt": (install_apt_deps, []),
    "rust": (install_rust, []),
    "cargo": (install_cargo_tools, ["rust"]),
    "zsh": (install_zsh, []),
    "fzf": (install_fzf, []),
    "neovim": (install_neovim, ["apt"]),
    "tmux": (install_tmux, ["apt"]),
    "kitty": (install_kitty, []),
    "lazygit": (install_lazygit, []),
    "gh": (install_gh, []),
    "volta": (install_volta, []),
    "helix": (install_helix, []),
    "direnv": (install_direnv, []),
    "fastfetch": (install_fastfetch, []),
    "docker": (install_docker, []),
    "lazydocker": (install_lazydocker, []),
    "kanata": (install_kanata, []),
    "niri": (install_niri, ["rust", "apt"]),
    "waybar": (install_waybar, ["apt"]),
    "distrobox": (install_distrobox, []),
    "zellij": (install_zellij, []),
    "fonts": (install_fonts, []),
}


def run_parallel(targets: list[str]) -> None:
    """Run installers in parallel, respecting dependency ordering."""
    completed: set[str] = set()
    failed: set[str] = set()
    pending = set(targets)

    # Validate all targets exist
    for t in targets:
        if t not in INSTALLERS:
            error(f"Unknown target: {t}")
            sys.exit(1)

    # Ensure dependencies are in the target list
    to_add = set()
    for t in targets:
        for dep in INSTALLERS[t][1]:
            if dep not in pending:
                to_add.add(dep)
    pending |= to_add
    targets_full = list(pending)

    with ThreadPoolExecutor(max_workers=4) as pool:
        futures = {}

        while pending or futures:
            # Find tasks whose deps are satisfied
            ready = []
            for t in list(pending):
                deps = INSTALLERS[t][1]
                if all(d in completed for d in deps):
                    if any(d in failed for d in deps):
                        warn(f"Skipping {t}: dependency failed")
                        pending.discard(t)
                        failed.add(t)
                        continue
                    ready.append(t)

            for t in ready:
                pending.discard(t)
                fn = INSTALLERS[t][0]
                futures[pool.submit(fn)] = t

            if not futures:
                if pending:
                    error(f"Deadlock: {pending} can't be scheduled")
                    break
                break

            # Wait for at least one to finish
            done_iter = as_completed(futures)
            future = next(done_iter)
            name = futures.pop(future)
            try:
                future.result()
                completed.add(name)
                info(f"{name} completed")
            except Exception as e:
                error(f"{name} failed: {e}")
                failed.add(name)

    if failed:
        error(f"Failed targets: {', '.join(sorted(failed))}")
    else:
        info("All targets installed successfully!")


def main() -> None:
    parser = argparse.ArgumentParser(description="Dotfiles dependency installer")
    parser.add_argument("targets", nargs="*", help="Categories to install")
    parser.add_argument("--all", action="store_true", help="Install everything")
    parser.add_argument("--list", action="store_true", help="List available targets")
    args = parser.parse_args()

    if args.list:
        print("Available targets:")
        for name in sorted(INSTALLERS):
            deps = INSTALLERS[name][1]
            dep_str = f" (depends on: {', '.join(deps)})" if deps else ""
            print(f"  {name}{dep_str}")
        return

    if not args.all and not args.targets:
        parser.print_help()
        return

    targets = list(INSTALLERS.keys()) if args.all else args.targets
    run_parallel(targets)

    print()
    info("Done! You may need to restart your shell or log out/in for all changes to take effect.")


if __name__ == "__main__":
    main()
