#!/usr/bin/env python3
"""Set up my dotfiles on a shared Greenroom `gr` box, without touching anyone else.

Run as the `gr` user over SSH (so GR_SSH_REAL_USER is set), once per box. Re-running
is safe: the /etc/zsh/zshenv block is replaced in place, the repo is pulled, and stow
is restowed.

The zshenv block is a no-op for every other session: it only fires when
GR_SSH_REAL_USER is set AND that user has actually populated their own tree under
/home/gr/.gr-users/<user>. So it can never take config away from anyone else.
"""

import os
import subprocess
import sys
from pathlib import Path

REPO_URL = "git@github.com:TenzinPlatter/dotfiles"
ZSHENV = Path("/etc/zsh/zshenv")
START = "# >>> gr-user-dotfiles (managed) >>>"
END = "# <<< gr-user-dotfiles <<<"

BLOCK = f"""{START}
# Per-user dotfiles on a shared gr box. No-op unless this is an SSH session routed
# through the gr-ssh wrapper (GR_SSH_REAL_USER set) AND that user has set up their tree.
if [[ -n "${{GR_SSH_REAL_USER:-}}" ]]; then
    _grbase="/home/gr/.gr-users/${{GR_SSH_REAL_USER%@*}}"
    if [[ -d "$_grbase/.config/zsh" ]]; then
        # gr's default umask is 002 (group-writable); the gr group has multiple members,
        # so group-writable completion dirs trip zsh compinit's security check. 022 keeps
        # anything we create (e.g. antidote plugin dirs) private to us.
        umask 022
        # Part B force-sources /etc/profile from /etc/zsh/zprofile, and Ubuntu's /etc/profile
        # resets PS1 to "$ " for non-bash shells (clobbering starship). It only does so when
        # PS1 is already set, so clearing it here (before zprofile) makes /etc/profile skip it.
        unset PS1
        # The gr-ssh wrapper's `sudo -iu gr` strips SSH_* from the session, so starship's
        # ssh_only hostname module can't tell this is remote. It is — re-assert it.
        export SSH_CONNECTION="${{SSH_CONNECTION:-gr-ssh 0 gr-ssh 0}}"
        export XDG_CONFIG_HOME="$_grbase/.config"
        export XDG_DATA_HOME="$_grbase/.local/share"
        export XDG_STATE_HOME="$_grbase/.local/state"
        export XDG_CACHE_HOME="$_grbase/.cache"
        export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
    fi
    unset _grbase
fi
{END}
"""


def strip_block(text: str) -> str:
    """Remove any existing managed block, preserving everything else verbatim."""
    while START in text:
        before, _, rest = text.partition(START)
        _, _, after = rest.partition(END)
        text = before.rstrip("\n") + "\n" + after.lstrip("\n")
    return text.strip("\n")


def sudo_write(path: Path, content: str) -> None:
    subprocess.run(
        ["sudo", "tee", str(path)],
        input=content, text=True, stdout=subprocess.DEVNULL, check=True,
    )


def run(*cmd: str) -> None:
    subprocess.run(cmd, check=True)


def main() -> int:
    real = os.environ.get("GR_SSH_REAL_USER", "")
    if not real:
        print("GR_SSH_REAL_USER is not set — run this over SSH on a gr-ssh box.", file=sys.stderr)
        return 1
    user = real.split("@", 1)[0]
    base = Path("/home/gr/.gr-users") / user
    repo = base / "dotfiles"

    # gr's login umask is 002; create everything non-group-writable so compinit is happy.
    os.umask(0o022)

    # 1. Idempotently install the zshenv redirect, keeping any existing content.
    existing = ZSHENV.read_text() if ZSHENV.exists() else ""
    kept = strip_block(existing)
    new = (kept + "\n\n" if kept else "") + BLOCK
    sudo_write(ZSHENV, new)
    print(f"zshenv redirect installed for '{user}' -> {base}")

    # 2. Private XDG tree + dotfiles checkout.
    for sub in (".local/share", ".local/state", ".cache"):
        (base / sub).mkdir(parents=True, exist_ok=True)
    if repo.exists():
        run("git", "-C", str(repo), "pull", "--ff-only")
        run("git", "-C", str(repo), "submodule", "update", "--init", "--recursive")
    else:
        run("git", "clone", "--recurse-submodules", REPO_URL, str(repo))

    # 3. Point the private XDG config + bin at the repo (whole-dir symlinks; no stow needed).
    #    .local/.cache stay as real dirs above so runtime state never dirties the repo.
    for name in (".config", "bin"):
        link = base / name
        target = repo / name
        if not target.is_dir():
            continue
        if link.is_symlink():
            if link.resolve() == target.resolve():
                continue
            link.unlink()
        elif link.exists():
            raise SystemExit(f"{link} exists and is not a symlink — refusing to clobber")
        link.symlink_to(target)
        print(f"linked {link} -> {target}")

    # 4. Antidote (zsh plugin manager) is .gitignored, so it's never in the clone.
    #    plugin.zsh sources $ZDOTDIR/.antidote/antidote.zsh — install it if missing.
    antidote = base / ".config" / "zsh" / ".antidote"
    if not antidote.exists():
        run("git", "clone", "--depth=1", "https://github.com/mattmc3/antidote.git", str(antidote))

    print("done — exit and ssh back in to pick up your ZDOTDIR")
    return 0


def _self_test() -> None:
    # Re-stripping is idempotent and never eats surrounding content.
    other = "# distro default\nexport FOO=1\n"
    once = strip_block(other + "\n" + BLOCK)
    assert "FOO=1" in once and START not in once, once
    twice = strip_block(other + "\n" + BLOCK + "\n" + BLOCK)
    assert twice.count("FOO=1") == 1 and START not in twice, twice
    assert strip_block("") == "", "empty file must stay empty"
    print("self-test ok")


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        _self_test()
    else:
        sys.exit(main())
