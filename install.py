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
import atexit
import os
import platform
import queue
import shutil
import subprocess
import sys
import tempfile
import threading
from pathlib import Path

HOME = Path.home()
ARCH = platform.machine()  # "x86_64" or "aarch64"
IS_ARM = ARCH in ("aarch64", "arm64")
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
RED = "\033[0;31m"
RESET = "\033[0m"

# All log messages go through this queue; only the main thread prints.
_msg_queue: queue.Queue[str | None] = queue.Queue()

# /dev/null file descriptor shared across all subprocesses
_devnull: int = -1


def _drain_messages() -> None:
    """Print all pending messages from the queue (call from main thread only)."""
    while True:
        try:
            msg = _msg_queue.get_nowait()
            if msg is not None:
                print(msg, flush=True)
        except queue.Empty:
            break


def info(msg: str) -> None:
    _msg_queue.put(f"{GREEN}[OK]{RESET} {msg}")


def warn(msg: str) -> None:
    _msg_queue.put(f"{YELLOW}[WARN]{RESET} {msg}")


def error(msg: str) -> None:
    _msg_queue.put(f"{RED}[FAIL]{RESET} {msg}")


def sudo_keepalive() -> None:
    """Prompt for sudo once, then refresh the timestamp every 60s in a daemon thread."""
    subprocess.run("sudo -v", shell=True, check=True)
    stop = threading.Event()

    def _refresh():
        while not stop.wait(60):
            run("sudo -vn", check=False)

    t = threading.Thread(target=_refresh, daemon=True)
    t.start()
    atexit.register(stop.set)


def run(cmd: str, check: bool = True, **kwargs) -> subprocess.CompletedProcess:
    kwargs.setdefault("stdin", _devnull)
    kwargs.setdefault("stdout", _devnull)
    kwargs.setdefault("stderr", _devnull)
    return subprocess.run(cmd, shell=True, check=check, **kwargs)


def run_capture(cmd: str) -> str:
    """Run a command and return its stdout."""
    result = subprocess.run(
        cmd,
        shell=True,
        check=True,
        stdin=_devnull,
        stdout=subprocess.PIPE,
        stderr=_devnull,
        text=True,
    )
    return result.stdout.strip()


def has(cmd: str) -> bool:
    return shutil.which(cmd) is not None


def github_latest_version(repo: str) -> str:
    """Get latest release tag from a GitHub repo."""
    return run_capture(
        f'curl -s "https://api.github.com/repos/{repo}/releases/latest" | jq -r .tag_name'
    )


def github_latest_version_bare(repo: str) -> str:
    """Get latest release version without leading 'v'."""
    return github_latest_version(repo).lstrip("v")


# =============================================================================
# Installers
# =============================================================================


def install_apt_deps() -> None:
    run("sudo apt-get update -qq")
    run(
        "sudo apt-get install -y "
        "build-essential cmake curl wget unzip git git-lfs "
        "pkg-config libssl-dev libfontconfig1-dev "
        "python3 python3-pip python3-venv "
        "wl-clipboard playerctl pavucontrol jq gdb stow "
        "libevent-dev ncurses-dev bison"
    )


def install_rust() -> None:
    if has("rustup"):
        run("rustup update")
    else:
        run("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y")


def install_go() -> None:
    if has("go"):
        return
    version = run_capture("curl -s 'https://go.dev/dl/?mode=json' | jq -r '.[0].version'")
    go_arch = "arm64" if IS_ARM else "amd64"
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/go.tar.gz "
            f"https://go.dev/dl/{version}.linux-{go_arch}.tar.gz"
        )
        run(f"sudo rm -rf /usr/local/go")
        run(f"sudo tar -C /usr/local -xzf {tmpdir}/go.tar.gz")
        run("sudo ln -sf /usr/local/go/bin/go /usr/local/bin/go")
        run("sudo ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt")


def _cargo() -> str:
    cargo = str(HOME / ".cargo" / "bin" / "cargo")
    return cargo if os.path.exists(cargo) else "cargo"


def _cargo_install(crate: str, binary: str) -> None:
    if has(binary):
        return
    run(f"{_cargo()} install {crate}")


def _cargo_binstall(crate: str, binary: str) -> None:
    if has(binary):
        return
    if not has("cargo-binstall"):
        run(f"{_cargo()} install cargo-binstall")
    run(f"{_cargo()} binstall -y {crate}")


def install_eza() -> None:
    _cargo_install("eza", "eza")


def install_bat() -> None:
    _cargo_install("bat", "bat")


def install_zoxide() -> None:
    _cargo_install("zoxide", "zoxide")


def install_fd() -> None:
    _cargo_install("fd-find", "fd")


def install_delta() -> None:
    _cargo_install("git-delta", "delta")


def install_yazi() -> None:
    _cargo_binstall("yazi-fm", "yazi")
    _cargo_binstall("yazi-cli", "ya")


def install_zsh() -> None:
    if not has("zsh"):
        run("sudo apt-get install -y zsh")

    shell = os.environ.get("SHELL", "")
    if "zsh" not in shell:
        warn("Run 'chsh -s $(which zsh)' to set zsh as your default shell")

    # Antidote
    antidote_dir = HOME / ".config" / "zsh" / ".antidote"
    if not antidote_dir.is_dir():
        run(f"git clone --depth=1 https://github.com/mattmc3/antidote.git {antidote_dir}")


def install_fzf() -> None:
    if has("fzf"):
        return
    fzf_dir = HOME / ".fzf"
    if not fzf_dir.is_dir():
        run(f"git clone --depth 1 https://github.com/junegunn/fzf.git {fzf_dir}")
    run(f"{fzf_dir}/install --key-bindings --completion --no-update-rc --no-bash --no-fish")


def install_neovim() -> None:
    if has("nv") or has("nvim"):
        return
    nvim_arch = "aarch64" if IS_ARM else "x86_64"
    version = github_latest_version_bare("neovim/neovim")
    install_dir = "/opt/nvim"
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/nvim.tar.gz "
            f"https://github.com/neovim/neovim/releases/download/v{version}/nvim-linux-{nvim_arch}.tar.gz"
        )
        run(f"sudo mkdir -p {install_dir}")
        run(f"sudo tar -xzf {tmpdir}/nvim.tar.gz -C {install_dir} --strip-components=1")
    run(f"sudo ln -sf {install_dir}/bin/nvim /usr/local/bin/nv")


def install_tmux() -> None:
    if has("tmux"):
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
    if has("kitty"):
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
    if has("lazygit"):
        return
    version = github_latest_version_bare("jesseduffield/lazygit")
    lg_arch = "arm64" if IS_ARM else "x86_64"
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/lazygit.tar.gz "
            f"https://github.com/jesseduffield/lazygit/releases/download/v{version}/lazygit_{version}_Linux_{lg_arch}.tar.gz"
        )
        run(f"tar xzf {tmpdir}/lazygit.tar.gz -C {tmpdir}")
        run(f"sudo install {tmpdir}/lazygit /usr/local/bin/lazygit")


def install_gh() -> None:
    if has("gh"):
        return
    version = github_latest_version_bare("cli/cli")
    gh_arch = "arm64" if IS_ARM else "amd64"
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/gh.tar.gz "
            f"https://github.com/cli/cli/releases/download/v{version}/gh_{version}_linux_{gh_arch}.tar.gz"
        )
        run(f"tar xzf {tmpdir}/gh.tar.gz -C {tmpdir}")
        run(f"sudo install {tmpdir}/gh_{version}_linux_{gh_arch}/bin/gh /usr/local/bin/gh")


def install_volta() -> None:
    if has("volta"):
        return
    run("curl https://get.volta.sh | bash -s -- --skip-setup")
    volta = HOME / ".volta" / "bin" / "volta"
    run(f"{volta} install node")


def install_helix() -> None:
    if has("hx"):
        return
    version = github_latest_version("helix-editor/helix")
    hx_arch = "aarch64" if IS_ARM else "x86_64"
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/helix.tar.xz "
            f"https://github.com/helix-editor/helix/releases/download/{version}/helix-{version}-{hx_arch}-linux.tar.xz"
        )
        run(f"tar xJf {tmpdir}/helix.tar.xz -C {tmpdir}")
        run("sudo mkdir -p /opt/helix")
        run(f"sudo cp -r {tmpdir}/helix-*/* /opt/helix/")
        run("sudo ln -sf /opt/helix/hx /usr/local/bin/hx")


def install_ripgrep() -> None:
    if has("rg"):
        return
    version = github_latest_version_bare("BurntSushi/ripgrep")
    rg_arch = "aarch64" if IS_ARM else "x86_64"
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/ripgrep.tar.gz "
            f"https://github.com/BurntSushi/ripgrep/releases/download/{version}/ripgrep-{version}-{rg_arch}-unknown-linux-musl.tar.gz"
        )
        run(f"tar xzf {tmpdir}/ripgrep.tar.gz -C {tmpdir}")
        run(f"sudo install {tmpdir}/ripgrep-{version}-{rg_arch}-unknown-linux-musl/rg /usr/local/bin/rg")


def install_direnv() -> None:
    if has("direnv"):
        return
    direnv_arch = "arm64" if IS_ARM else "amd64"
    run(
        "sudo curl -Lo /usr/local/bin/direnv "
        f"https://github.com/direnv/direnv/releases/latest/download/direnv.linux-{direnv_arch}"
    )
    run("sudo chmod +x /usr/local/bin/direnv")


def install_fastfetch() -> None:
    if has("fastfetch"):
        return
    version = github_latest_version("fastfetch-cli/fastfetch")
    ff_arch = "aarch64" if IS_ARM else "amd64"
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/fastfetch.deb "
            f"https://github.com/fastfetch-cli/fastfetch/releases/download/{version}/fastfetch-linux-{ff_arch}.deb"
        )
        run(f"sudo dpkg -i {tmpdir}/fastfetch.deb || sudo apt-get install -f -y")


def install_docker() -> None:
    if has("docker"):
        return
    run("curl -fsSL https://get.docker.com | sh")
    run(f"sudo usermod -aG docker {os.environ['USER']}")
    warn("Log out and back in for docker group membership to take effect")


def install_lazydocker() -> None:
    if has("lazydocker"):
        return
    version = github_latest_version_bare("jesseduffield/lazydocker")
    ld_arch = "arm64" if IS_ARM else "x86_64"
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/lazydocker.tar.gz "
            f"https://github.com/jesseduffield/lazydocker/releases/download/v{version}/lazydocker_{version}_Linux_{ld_arch}.tar.gz"
        )
        run(f"tar xzf {tmpdir}/lazydocker.tar.gz -C {tmpdir}")
        run(f"sudo install {tmpdir}/lazydocker /usr/local/bin/lazydocker")


def install_zellij() -> None:
    if has("zellij"):
        return
    version = github_latest_version("zellij-org/zellij")
    zj_arch = "aarch64" if IS_ARM else "x86_64"
    with tempfile.TemporaryDirectory() as tmpdir:
        run(
            f"curl -Lo {tmpdir}/zellij.tar.gz "
            f"https://github.com/zellij-org/zellij/releases/download/{version}/zellij-{zj_arch}-unknown-linux-musl.tar.gz"
        )
        run(f"tar xzf {tmpdir}/zellij.tar.gz -C {tmpdir}")
        run(f"sudo install {tmpdir}/zellij /usr/local/bin/zellij")


def install_fonts() -> None:
    font_dir = HOME / ".local" / "share" / "fonts" / "JetBrainsMono"
    if font_dir.is_dir():
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

INSTALLERS: dict[str, tuple[callable, list[str]]] = {
    "apt": (install_apt_deps, []),
    "rust": (install_rust, []),
    "eza": (install_eza, ["rust"]),
    "bat": (install_bat, ["rust"]),
    "zoxide": (install_zoxide, ["rust"]),
    "fd": (install_fd, ["rust"]),
    "delta": (install_delta, ["rust"]),
    "yazi": (install_yazi, ["rust"]),
    "zsh": (install_zsh, []),
    "fzf": (install_fzf, []),
    "neovim": (install_neovim, ["apt"]),
    "tmux": (install_tmux, ["apt"]),
    "kitty": (install_kitty, []),
    "lazygit": (install_lazygit, []),
    "gh": (install_gh, []),
    "volta": (install_volta, []),
    "helix": (install_helix, []),
    "ripgrep": (install_ripgrep, []),
    "rg": (install_ripgrep, []),
    "direnv": (install_direnv, []),
    "fastfetch": (install_fastfetch, []),
    "docker": (install_docker, []),
    "lazydocker": (install_lazydocker, []),
    "go": (install_go, []),
    "zellij": (install_zellij, []),
    "fonts": (install_fonts, []),
}


def run_parallel(targets: list[str]) -> None:
    """Run installers with threads, respecting dependency ordering.

    Only the main thread prints. Worker threads enqueue messages via
    info()/warn()/error() which write to _msg_queue.
    The main thread drains the queue after each thread completes.
    """
    completed: set[str] = set()
    failed: set[str] = set()
    pending = set(targets)

    # Validate all targets exist
    for t in targets:
        if t not in INSTALLERS:
            error(f"Unknown target: {t}")
            _drain_messages()
            sys.exit(1)

    # Ensure dependencies are in the target list
    for t in list(pending):
        for dep in INSTALLERS[t][1]:
            pending.add(dep)

    active: dict[threading.Thread, str] = {}
    thread_failed: dict[threading.Thread, bool] = {}

    while pending or active:
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

        # Launch ready tasks as threads (max 4 concurrent)
        for t in ready:
            if len(active) >= 4:
                break
            pending.discard(t)
            fn = INSTALLERS[t][0]

            def _worker(func=fn, name=t, th_failed=thread_failed):
                try:
                    func()
                    info(f"{name}")
                except Exception as e:
                    error(f"{name}: {e}")
                    th_failed[threading.current_thread()] = True

            thread = threading.Thread(target=_worker)
            thread.start()
            active[thread] = t

        if not active:
            if pending:
                error(f"Deadlock: {pending} can't be scheduled")
            _drain_messages()
            break

        # Poll for completed threads
        finished = []
        for thread, name in list(active.items()):
            thread.join(timeout=0.2)
            if not thread.is_alive():
                finished.append(thread)

        for thread in finished:
            name = active.pop(thread)
            if thread_failed.get(thread, False):
                failed.add(name)
            else:
                completed.add(name)

        _drain_messages()

    if failed:
        error(f"Failed targets: {', '.join(sorted(failed))}")
        _drain_messages()
    else:
        info("All targets installed successfully!")
        _drain_messages()


def main() -> None:
    global _devnull

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

    # Open /dev/null as a real fd so subprocesses inherit it instead of our TTY
    _devnull = os.open(os.devnull, os.O_RDWR)

    sudo_keepalive()

    if not args.all and not args.targets:
        parser.print_help()
        os.close(_devnull)
        return

    targets = list(INSTALLERS.keys()) if args.all else args.targets
    run_parallel(targets)

    os.close(_devnull)

    print()
    print(f"{GREEN}[OK]{RESET} Done! You may need to restart your shell or log out/in for all changes to take effect.")


if __name__ == "__main__":
    main()
