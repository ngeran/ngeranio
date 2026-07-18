+++
title = 'The dev environment: a Nix shell that loads itself'
date = 2026-07-18T11:30:00-04:00
draft = false
tags = ["Homelab", "NixOS", "Nix", "direnv", "Dev"]
featured_image = 'featured.png'
summary = 'Part 0 of the dev→Nix→k3s series — the foundation everything else builds on. A per-project Nix shell that direnv auto-loads when you cd in. Self-contained and beginner-friendly: set it up, run a Python hello world, and install packages without touching your system.'
+++

This is **part 0** of the _dev → Nix → k3s_ series — the layer everything else
stands on. Before there's an image or a cluster, there's the environment you
actually write code in. The goal: a **per-project shell that loads itself**.
Walk into a project directory (`cd`), and the exact tools that project needs
appear on your `PATH`. Walk out, and they vanish. Nothing is ever installed
globally, and your system stays clean.

Everything below is copy-pasteable. By the end you'll have a working dev shell
for a Python project, run a hello world in it, and know how to install packages
without ever touching system Python.

**Written against:** Nix with flakes, direnv, nix-direnv (2026-07).

## The problem it kills

The old loop: `sudo apt install python3.11`, then `pip install` into the system
until two projects fight over conflicting library versions, and a year later
your `/usr/bin` and `~/.config` are an undebuggable graveyard. "Works on my
machine" stops being a threat when the environment *is* the project.

The Nix shell replaces all of that with one rule: **the tools a project needs
are declared in that project's `flake.nix`, and they exist only while you're
inside the project.**

## What it actually is

Three pieces, all general-purpose tools you enable once:

- **The devShell** — declared in the project's `flake.nix`. A list of packages
  (`python3`, `hugo`, `nodejs_22`, …) that Nix builds into an isolated,
  reproducible environment.
- **direnv** — a shell extension. A one-line `.envrc` containing `use flake`
  tells it: *"when I enter this directory, load the flake's devShell into the
  shell; when I leave, unload it."*
- **nix-direnv** — caches the flake evaluation, so loading is instant after the
  first time.

The payoff: two projects can pin different Python versions and never collide,
because neither Python is global — each lives in `/nix/store` and is mapped into
your shell only for the directory that asked for it.

## Prerequisites (one-time, on your machine)

You need **Nix with flakes**, **direnv**, and **nix-direnv**.

**On NixOS** (flakes are built in) — enable direnv through your config. If you
use home-manager (the common desktop case), add this to your `home.nix` and
rebuild:

```nix
programs.direnv = {
  enable = true;
  enableBashIntegration = true;     # or enableZshIntegration / enableFishIntegration
  nix-direnv.enable = true;
};
```

If you manage everything in `configuration.nix` instead, `programs.direnv.enable = true;`
there does the direnv half. Then **log out and back in** so the shell hook is active.

**On any other Linux or macOS:**

```bash
# 1. Nix with flakes (the Determinate installer enables flakes + the flake command):
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. direnv + nix-direnv:
nix profile install nixpkgs#direnv nixpkgs#nix-direnv

# 3. Hook direnv into your shell (bash shown; use `direnv hook zsh` for zsh):
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# 4. Tell direnv to use nix-direnv:
mkdir -p ~/.config/direnv
echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' > ~/.config/direnv/direnvrc

exec $SHELL && direnv version    # reload shell, then verify direnv is present
```

## Reproduce it: your first dev shell

Make a project and drop in **two files** — a `flake.nix` declaring the tools,
and a one-line `.envrc` triggering direnv:

```bash
mkdir my-project && cd my-project && git init
```

**`flake.nix`** — this is the whole dev shell. The `packages` line lists what
the project needs (Python here):

```nix
{
  description = "dev shell for my-project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      # "works on any CPU" — you can ignore this block, just keep it.
      forAllSystems = nixpkgs.lib.genAttrs
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in {
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system; in {
          default = pkgs.mkShell {
            packages = with pkgs; [ python3 ];   # ← your tools go here
          };
        });
    };
}
```

**`.envrc`** — a single line:

```bash
use flake
```

Now stage and authorize:

```bash
git add flake.nix .envrc        # the flake MUST be git-tracked (see golden rules)
direnv allow                    # authorize the .envrc to run (security gate)
```

The first `direnv allow` builds the shell (a few seconds); you'll see direnv
report it loading. From now on, just `cd` in and out.

## Test it: hello world

Inside the project, create `hello.py`:

```python
print("hello from the nix dev shell")
```

…and run it:

```bash
python3 hello.py
# → hello from the nix dev shell
```

That `python3` is the one from your flake — not a system install. If you don't
believe it, check where it lives:

```bash
which python3
# → /nix/store/…-python3-3.13.14/bin/python3
```

## Installing packages (the wall you'll hit, and the fix)

Your very next instinct will be `python3 -m pip install requests`. **Don't** —
it won't work, and that's deliberate:

```bash
python3 -m pip install requests
# → /nix/store/…/python3: No module named pip
```

Nix's `python3` ships **without pip** because Nix's store is read-only — you're
not supposed to mutate it. The Nix way to get third-party packages is a
project-local virtual environment managed by **uv**. Add `uv` to the flake:

```nix
packages = with pkgs; [ python3 uv ];   # ← added uv
```

Re-allow, then create a venv and install into it:

```bash
direnv allow                     # pick up the new uv package
uv venv                          # creates .venv/ (once)
uv pip install requests          # installs into .venv, NOT the system
uv run python -c "import requests; print('requests', requests.__version__)"
```

`uv run` runs your script using the venv automatically. The `.venv/` lives inside
the project; throw it away and `uv venv` recreates it identically. Your system
Python is never touched.

> ⚠️ **Never** `pip install` against Nix's Python — it's read-only and pip-less
> by design. Always go through `uv` into the project's `.venv`.

## Swap the stack

The pattern is identical for any language — change one line. Want a Hugo site
instead?

```nix
packages = with pkgs; [ hugo nodejs_22 ];   # then: hugo server -D
```

Want Node/React? `packages = with pkgs; [ nodejs_22 ];`, then `npm install`.
The flake is the only thing that changes; direnv, the golden rules, and
start/stop below are the same for every stack.

## How to use it

The directory *is* the switch — just move around:

| You do | What happens |
|---|---|
| `cd my-project/` | tools auto-load |
| `cd ..` | tools auto-unload |
| edit `flake.nix` or `.envrc` | run `direnv allow` to pick up the change |
| `direnv reload` | force a clean re-evaluation |
| `direnv status` | see exactly what the shell added |
| `nix develop` | enter the devShell *without* direnv (good for debugging) |

## How to start and stop it

There is **no `start` or `stop` command** — the environment is bound to the
directory:

- **Start** = `cd` into the project. direnv activates the shell automatically.
- **Stop** = `cd` out (or close the terminal). The tools leave your `PATH`
  automatically.

If you want a manual, explicit shell — say, to read an evaluation error direnv
swallowed — drop direnv entirely:

```bash
nix develop        # enters the devShell in the foreground
exit               # leaves it
```

"Starting" the dev environment is walking into the folder; "stopping" it is
walking back out.

## The two golden rules (these fail silently)

1. **`flake.nix` must be git-tracked inside the project.** Nix flakes evaluate
   from the *git index* — an untracked `flake.nix` is invisible, and direnv
   silently falls back to your global `PATH` (no `python`, no `node`, and no
   obvious error). `git add flake.nix .envrc` fixes it; no commit needed.
2. **`direnv allow` after every edit** to `flake.nix` or `.envrc`. direnv blocks
   on a stale allow-hash until you re-allow — so if your new tool isn't there
   right after you edited the flake, you forgot this step.

If direnv never seems to trigger at all, the shell hook isn't loaded — log out
and back in once after enabling direnv, or open a new terminal.

## What to commit

```bash
git add flake.nix flake.lock .envrc
```

The flake and lock pin the toolchain; `.envrc` is the trigger. They travel with
the repo, so any clone gets the identical environment with a single
`direnv allow`. `.venv/`, `node_modules/`, and `.direnv/` are **never** committed
— add them to your `.gitignore`.

## Why this is part 0

The devShell isn't a side feature — it's the foundation. The very same
`flake.nix` that gives you `python3` / `hugo` while you develop also declares the
**production image** (`packages.image`) that the rest of this series builds and
ships. You develop *in* the devShell; you ship *what the same flake builds*. One
source of truth for dev and prod is the entire reason this setup exists.

- **Next:** [Part 1 — How Nix runs the pipeline](/homelab/nix-under-the-hood/)
  (flakes, the store, the scaffold, supported stacks).
- **The map:** [The pipeline: dev → Nix image → k3s](/homelab/the-pipeline/).
