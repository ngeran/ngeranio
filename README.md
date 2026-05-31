# ngeran[io]

A network engineering blog — routing, automation, observability, and problem-solving. Published at [ngeranio.com](https://ngeranio.com/).

## Quick Start

```bash
# Start the dev server (Docker + Hugo)
./dev.sh start

# Stop the server
./dev.sh stop

# Check if running
./dev.sh status
```

The dev server runs at `http://localhost:1313`.

## Dev Script Commands

```bash
./dev.sh start              # Start Hugo dev server
./dev.sh start --port 8080  # Use a custom port
./dev.sh start --theme 0xComa   # Switch theme and start
./dev.sh stop               # Stop the dev container
./dev.sh status             # Check container status
./dev.sh build              # Rebuild Tailwind CSS
./dev.sh logs               # Tail container logs
./dev.sh shell              # Open shell inside container
./dev.sh clean              # Remove container and pull fresh image
```

## Themes

The site has two themes in `themes/`:

- **0xComa** — terminal/hacker aesthetic (black bg, green accent, monospaced UI)
- **vector** — Nord color palette with Tailwind CSS

Switch between them:

```bash
# Option 1: Use the dev script
./dev.sh start --theme vector

# Option 2: Edit hugo.toml directly
# theme = '0xComa'  ← change this line
```

## Rebuilding CSS

After editing `tailwind.config.js` or `src/input.css` in a theme directory:

```bash
./dev.sh build
```

Or manually:

```bash
cd themes/0xComa && npx tailwindcss -i src/input.css -o assets/css/styles.css --minify
```

## Creating Content

```bash
./scripts/create-post.sh bgp "BGP Communities"
./scripts/preview.sh
./scripts/quality-gate.sh validate content/routing/bgp/bgp-communities/index.md
```

> Note: `create-post.sh` is hardcoded for routing categories (ospf, bgp, mpls, junos). For other sections, create posts manually as described below.

## How Sections, Navigation, and Posts Work

This is a practical reference for adding new sections, subsections, and posts.

### Content hierarchy

```
content/
  <section>/              # Top-level section (e.g., observability/)
    _index.md             # Section landing page
    <subsection>/         # Subsection (e.g., twamp/)
      _index.md           # Subsection landing page
      <post-slug>/        # Individual post (page bundle)
        index.md          # Post content
        featured.png      # Featured image (optional)
```

### How the navigation menu works

The header (`themes/0xComa/layouts/partials/header.html`) renders menu items from `hugo.toml`. It has two modes:

- **Flat link** `[ observability ]` — shown when a section has pages but no visible subsections.
- **Dropdown** `[ routing ]` with submenu — shown when subsections exist and each has more than one page (the `_index.md` counts as one, so a subsection needs at least one post).

The condition is: `gt (len $sec.Pages) 1` for the section, and `gt (len .Pages) 1` for each subsection.

### Step-by-step: activate a section

The observability section is used as the working example. It already exists in `hugo.toml` and has an `_index.md`.

#### 1. Section must be in hugo.toml

Both `mainSections` and the menu entry must exist. Check `hugo.toml`:

```toml
[params]
  mainSections = ['routing', 'automation', 'ai', 'linux', 'labs', 'observability']

[[menus.main]]
  name = 'observability'
  pageRef = '/observability'
  weight = 70
```

#### 2. Section needs an `_index.md`

File: `content/observability/_index.md`

```toml
+++
title = 'Observability'
date = 2026-05-24
draft = false
summary = 'Monitoring, telemetry, logging, and network observability.'
+++
```

#### 3. Create a subsection (optional)

Create a directory and `_index.md` under the section:

```bash
mkdir -p content/observability/twamp
```

File: `content/observability/twamp/_index.md`

```toml
+++
title = 'TWAMP'
date = 2026-05-30
draft = false
summary = 'Two-Way Active Measurement Protocol for network performance monitoring.'
tags = ["TWAMP", "Observability", "Measurement"]
+++
```

#### 4. Create a post

Each post lives in its own directory (a Hugo page bundle) with an `index.md`:

```bash
mkdir -p content/observability/twamp/introduction
```

File: `content/observability/twamp/introduction/index.md`

```toml
+++
title = 'TWAMP Introduction'
date = 2026-05-30T12:00:00-04:00
draft = false
tags = ["TWAMP", "Observability", "Measurement"]
featured_image = 'featured.png'
summary = 'Overview of the Two-Way Active Measurement Protocol.'
+++

### Overview

Write your content here in Markdown...
```

#### 5. When the nav link appears

The nav link for a section appears when the section has **at least one page** (a subsection or a post). The header template (`themes/0xComa/layouts/partials/header.html`) checks `gt (len $sec.Pages) 0`. The `_index.md` does not count — only child pages and subsections do.

- Drafts are excluded from page count in production builds.
- Run `hugo server -D` during development to preview drafts.
- Set `draft = false` to publish.

#### 6. When the dropdown appears

A dropdown (like routing has) appears when **subsections exist** and each subsection has **more than one page** (its `_index.md` + at least one post). For observability, once a second subsection (e.g., `gnmi/`) is added with content, the dropdown will render instead of a flat link.

### Quick reference: frontmatter fields

| Field | Required | Example |
|-------|----------|---------|
| `title` | yes | `'TWAMP Introduction'` |
| `date` | yes | `2026-05-30T12:00:00-04:00` |
| `draft` | yes | `false` |
| `tags` | no | `["TWAMP", "Observability"]` |
| `summary` | no | `'Brief description for list pages.'` |
| `featured_image` | no | `'featured.png'` |

Use `+++` delimiters for TOML frontmatter (the project convention).

## Known Fixes

A log of identified issues and their fixes lives in **[FIX.md](FIX.md)**.

## Project Structure

```
content/
  routing/bgp/      # BGP study notes
  routing/ospf/     # OSPF study notes
  routing/mpls/     # MPLS study notes
  projects/         # Automation projects
scripts/            # Content workflow scripts
themes/0xComa/      # Terminal aesthetic theme
themes/vector/      # Nord palette theme
hugo.toml           # Site configuration
```
