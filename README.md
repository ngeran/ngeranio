# ngeran[io]

JNCIE-SP study notes published as a Hugo blog at [ngeranio.com](https://ngeranio.com/).

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
