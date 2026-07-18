+++
title = 'Hugo on k3s with Nix — three crashes and a dirty tree'
date = 2026-07-18T09:00:00-04:00
draft = true
tags = ["Homelab", "NixOS", "Kubernetes", "Hugo", "Nix"]
featured_image = 'featured.png'
summary = 'Migrating this blog into my dev→Nix→k3s pipeline. The image built fine — then the pod crashed three different ways before it would stay up. Every dead end, with the exact errors.'
+++

## TL;DR

Migrating this blog into my **dev → Nix image → k3s** pipeline took four failed
deploys. The Nix build succeeded first try; the *pod* is what kept dying — three
distinct nginx crashes, then a silent exit loop. Each one was a gap in my
scaffold template that nobody had hit before, because this was the first Hugo
site actually deployed through it. The fixes are all one-liners; finding them
cost an evening. If you're serving a static site with nginx inside a
`dockerTools.buildImage`, pin these three lines before you deploy.

**Versions (these stacks drift — pin yours in the post):** NixOS 26.05,
k3s v1.35.6, Hugo 0.163.3+extended, nginx 1.30.3. Written 2026-07.

## The setup

The pipeline is a `flake.nix` that declares two things: a `devShell` (Hugo +
Node, loaded by direnv) and a `packages.image` — an OCI image built by Nix with
**no Dockerfile**. `just` drives it: `just build` → `nix build .#image`, `just
push` → skopeo to a local registry, `just deploy` → `kubectl apply` + rollout.
The Hugo site builds **offline** inside the image (nixpkgs ships the extended
Hugo with the SCSS/JS asset pipeline), and nginx serves the result on `:80`.

That all evaluated and built green. Then:

## Crash 1 — `getpwnam("nobody") failed`

```text
[emerg] 1#1: getpwnam("nobody") failed
```

nginx's compiled-in default worker user is `nobody`. A from-scratch
`dockerTools` image has no `/etc/passwd` at all — the template added `root`, but
not `nobody`, so nginx couldn't resolve the worker user and exited.

**Fix:** one directive in `nginx.conf`:

```nginx
user root;   # only root exists in this image's /etc/passwd
```

## Crash 2 — `mkdir() "/tmp/client_temp" failed`

```text
[emerg] 1#1: mkdir() "/tmp/client_temp" failed (2: No such file or directory)
```

A from-scratch image has **no `/tmp`** either. The config pointed all the temp
paths (`client_body_temp_path`, the pid, etc.) at `/tmp/...` — but `/tmp` itself
didn't exist, so nginx couldn't create the subdirectories.

**Fix:** add a tiny layer to `copyToRoot` that makes the runtime dirs:

```nix
runtimeDirs = pkgs.runCommand "nginx-runtime-dirs" { } ''
  mkdir -p $out/tmp $out/var/log/nginx $out/var/cache/nginx
  chmod 1777 $out/tmp
'';
```

## Crash 3 — pod `Completed`, exit 0, forever

Now nginx started clean — no errors in the logs — and the pod immediately went
`Completed` and restart-looped. Status `Completed` means the container's PID 1
**exited 0**. Why? Because nginx daemonizes by default: the master forks to the
background, the entry process returns, and the container considers itself done.

```text
NAME                        READY   STATUS      RESTARTS
hugo-site-7f7497f4b7-9f27g  0/1     Completed   6
```

**Fix:** run nginx in the foreground so it stays as PID 1:

```nginx
daemon off;
```

After that, `1/1 Running`, HTTP 200, real homepage served.

## Two more traps that weren't crashes but hurt

**skopeo refused to push:**

```text
Error loading trust policy: no policy.json file found
```

There's no system `containers/policy.json` on this box, so skopeo needs
`--insecure-policy` on the copy. My `justfile`'s `push` recipe was missing it
(another template gap — the Python project on the same cluster had it, the Hugo
one didn't).

**The "dirty tree" that wouldn't clear.** Every `nix build` warned the git tree
was dirty, and `node_modules/` (1439 files) + `public/` (82) kept getting copied
into the image. Root cause: **`.gitignore` has no inline comments.** Lines like

```gitignore
node_modules/        # Node.js dependencies
```

…match nothing — git treats the whole line (spaces, `#`, comment) as the
literal pattern. So those dirs were never ignored, stayed tracked, and got baked
into every build. Move comments to their own line, then
`git rm --cached -r node_modules public` to untrack.

## What I tried that didn't work

- **Adding `nobody` to `/etc/passwd`** instead of `user root;`. Works, but
  running workers as root is simpler for a single-purpose static-serving
  container and matches how every nginx Docker image does it.
- **`runAsRoot` in `buildImage` to `mkdir /tmp`.** Also works, but it needs
  fakeroot and is slower; a `runCommand` layer in `copyToRoot` is the idiomatic
  Nix way and needs no root.
- **Assuming the template was correct because the skill said so.** The
  scaffolding docs confidently said "Hugo deploys offline, no lock step" — true
  for the *build*, silently false for the *pod*. The template had never actually
  been run end-to-end. Lesson: a green `nix build` says nothing about whether
  the container will stay up.

## Lessons

1. **`nix build` passing ≠ the pod running.** The build proves the flake
   evaluates; only `kubectl get pods` proves the image works. Always smoke-test
   with `docker run` before pushing.
2. **A from-scratch image is *really* from scratch** — no `/tmp`, no
   `/etc/passwd`, no shell. Anything your process expects to exist, you must
   layer in.
3. **Templates rot until someone deploys them.** The first real user is the QA
   department. Backport every fix you find into the template, or the next
   migrator hits the same wall.

## References

- The pipeline guide: `~/.omni-nix/PIPELINE.md`
- The (now-fixed) Hugo template: `~/.omni-nix/templates/hugo/flake.nix`
- [nginx: `daemon` directive](https://nginx.org/en/docs/ngx_core_module.html#daemon)
- [Nix `dockerTools.buildImage`](https://nixos.org/manual/nixpkgs/stable/#ssec-pkgs-dockerTools-buildImage)
