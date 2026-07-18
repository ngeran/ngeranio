+++
title = 'How Nix runs the pipeline: flakes, the store, and the scaffold'
date = 2026-07-18T11:00:00-04:00
draft = true
tags = ["Homelab", "NixOS", "Nix", "Flakes"]
featured_image = 'featured.png'
summary = 'Part 1 of the dev→Nix→k3s series. What a flake.nix actually is, how nix build turns it into a container image with no Dockerfile, how the project scaffold is generated, and which stacks the pipeline supports — the engine under the overview post.'
+++

This is **part 1** of the _dev → Nix → k3s_ series. The [overview post](/homelab/the-pipeline/)
is the map; this one opens up the engine — Nix. We'll cover what a `flake.nix`
is and how it works, how `nix build` turns it into a container image with **no
Dockerfile**, how the project scaffold appears under `nix flake init`, and which
languages the pipeline supports.

**Versions:** NixOS 26.05, Nix with flakes enabled. Written 2026-07.

## Nix in one minute (if you're not a NixOS user)

Nix is a **purely functional package manager**. A package is a function: it
takes inputs (source, dependencies, compiler) and produces a *derivation* stored
in `/nix/store` under a path hashed from **all** of its inputs. Same inputs in →
same hash out → identical, bit-for-bit output, forever. Two versions of the same
library coexist as separate store paths; nothing ever gets overwritten, and
"it worked yesterday" is a statement of fact, not nostalgia.

A **flake** is the reproducible unit on top of that: a directory with a
`flake.nix` (the recipe) and a `flake.lock` (the exact, pinned version of every
input). The lock is the anchor — same lock, same build, on any machine.

## What a flake.nix is, and how it works

Every project in this pipeline is one `flake.nix` declaring **two outputs**: a
development shell and a container image. Here's the shape, condensed from a real
project (the [full Hugo version](/homelab/hugo-on-k3s-with-nix/) also wires up
the nginx config and a `/tmp` layer):

```nix
{
  description = "my site — Hugo devShell + nginx image";

  inputs.nixpkgs.url = "nixpkgs/nixos-26.05";   # flake.lock pins the EXACT revision

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in {
      # ── 1) dev tools ────────────────────────────────────────────────
      # `nix develop`, or auto-loaded by direnv via .envrc → `use flake`.
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system; in {
          default = pkgs.mkShell {
            packages = with pkgs; [ hugo nodejs_22 ];
          };
        });

      # ── 2) the image ────────────────────────────────────────────────
      # `nix build .#image` → ./result, an OCI tarball. No Dockerfile.
      packages = forAllSystems (system:
        let pkgs = pkgsFor system; in {
          image = pkgs.dockerTools.buildImage {
            name = "localhost:5000/mysite";
            copyToRoot = [ pkgs.nginx /* + the built static site */ ];
            config.Cmd = [ "${pkgs.nginx}/bin/nginx" ];
          };
        });
    };
}
```

Two things worth noticing:

- **The devShell and the image come from the same file.** Your dev environment
  and your production artifact are declared together, so they can't silently
  drift apart the way `requirements.txt` plus a Dockerfile can.
- **`flake.lock` is what makes it reproducible.** `inputs.nixpkgs.url` looks
  loose (`nixos-26.05`), but the lock freezes the exact commit. Re-build the
  same project in two years and you get the same bytes.

`nix build .#image` evaluates the `packages.image` attribute and realizes it in
the store as an OCI tarball, pointed at by the `./result` symlink. **There is no
Docker daemon involved and no Dockerfile** — `dockerTools.buildImage` is itself a
Nix derivation that emits a standards-compliant image directly. The dev side is
symmetrical: `nix develop` (or direnv's `use flake`) materializes `devShells.default`
into an isolated shell where `hugo`/`node`/`python` resolve without polluting the
system.

## How the scaffold is generated

You start a project with:

```bash
mkdir ~/mysite && cd ~/mysite && git init
nix flake init -t ~/.omni-nix#hugo
```

`nix flake init -t <flake>#<template>` copies a **template** declared in that
flake's `templates` output. The interesting part is *where* those templates live:
they're declared inside **the omni-nix system flake itself** — the very same
`flake.nix` that configures my entire desktop. From `~/.omni-nix/flake.nix`:

```nix
templates.python = { path = ./templates/python;
  description = "Python web service — Nix devShell + image, just → push → k3s rollout"; };
templates.hugo   = { path = ./templates/hugo;
  description = "Hugo static site → nginx image, just → push → k3s rollout"; };
templates.react  = { path = ./templates/react;
  description = "React (Vite) static build → nginx image, just → push → k3s rollout"; };
templates.dev    = { path = ./templates/dev;
  description = "Project devShell — node / python / hugo / tailwind (no image/deploy)"; };
defaultTemplate  = self.templates.dev;
```

Each template is a full directory — `flake.nix` + `.envrc` + `justfile` +
`manifests/` + a sample app or site — and `nix flake init -t` drops it into the
new repo. Because the templates live inside the system flake, scaffolding is
**reproducible**: the skeleton you get is versioned with the system, not grabbed
from a random GitHub repo or a half-remembered `cp -r`. (Bare `nix flake init -t
~/.omni-nix` with no name falls back to `defaultTemplate` — the kitchen-sink dev
shell.)

## What stacks the pipeline supports

Three real stacks — each shipping a devShell + a Nix image + a `justfile` — plus
a generic dev shell:

| Template | Builds | Deps come from | One-time step |
|---|---|---|---|
| `#python` | Flask / FastAPI service (gunicorn / uvicorn) | `python3.withPackages ([ … ])` | none |
| `#hugo` | static site → **nginx** image | nixpkgs Hugo (offline build) | none |
| `#react` | Vite static build → **nginx** image | `buildNpmPackage` from `package.json` | set `npmDepsHash` |
| `#dev` | devShell only (node / python / hugo / tailwind) | — | none |

The common shape is the whole point: **whatever the stack, the contract is
identical** — a `flake.nix` with a `devShells.default` and a `packages.image`,
driven by a `justfile` (build → push → deploy), landed on k3s by `manifests/`.
Learn the shape once; it works for a Python API, a Hugo blog, and a React app.

> ⚠️ **Two dep sources, kept in sync by hand.** Python and React each carry
> *two* dependency lists: `requirements.txt` / `package.json` (your **local**
> dev) and the flake's `withPackages` / `buildNpmPackage` (what the **image**
> ships). Add a dependency to *both*, or local dev and prod drift apart. Hugo
> dodges this entirely — its only dependency is nixpkgs' Hugo.

## How Nix "handles" the pipeline

Zooming back out, Nix is doing three jobs at once:

1. **The system** — the omni-nix flake *is* the NixOS config (desktop,
   home-manager, theming) and it *also* declares the pipeline's toolchain
   (`just`, `skopeo`, `kubectl`, `direnv`, as system packages) and the project
   templates. One config owns the whole shop.
2. **Each project** — a self-contained flake, reproducible from its lock, dev and
   prod declared together.
3. **The build** — `dockerTools.buildImage` produces the OCI image straight from
   the flake; no Dockerfile, no Docker daemon.

Repave the box, re-apply the system flake, and the toolchain, the templates, and
every project's ability to rebuild identically all come back. That's what it
means for the pipeline to be **Nix-managed end to end** — not merely "uses Nix to
build images."

## What's next

- **Part 2** opens up `packages.image` — how `dockerTools.buildImage` layers a
  static site with nginx into a real OCI image, and the three things a
  from-scratch image needs to actually run nginx in a pod. That's exactly the
  ground covered by the _[three crashes and a dirty tree](/homelab/hugo-on-k3s-with-nix/)_
  war story.
- Until then: the [overview post](/homelab/the-pipeline/) for the map, and the
  full reference at `~/.omni-nix/PIPELINE.md`.
