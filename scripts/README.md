# Automation Scripts

This directory contains helper scripts for content creation and site management.

## Available Scripts

### create-post.sh
Create a new blog post with proper structure.

```bash
./scripts/create-post.sh <category> <title>
```

**Categories**: ospf, bgp, mpls, junos

**Example**:
```bash
./scripts/create-post.sh ospf "OSPF Virtual Links"
```

Creates:
- `content/routing/ospf/ospf-virtual-links/index.md`
- `content/routing/ospf/ospf-virtual-links/featured.png` (placeholder)
- Pre-filled frontmatter and template

### preview.sh
Start the Hugo development server with draft support.

```bash
./scripts/preview.sh
```

Opens at http://localhost:1313 with live reload.

### publish-drafts.sh
Publish draft posts by setting `draft = false`.

```bash
# List all drafts and prompt to publish all
./scripts/publish-drafts.sh

# Publish specific post
./scripts/publish-drafts.sh content/routing/ospf/my-post/index.md
```

## Usage for AI Agents

AI agents can use these scripts to automate content creation:

1. **Create post**: `./scripts/create-post.sh bgp "BGP Communities"`
2. **Edit content**: Modify the generated `index.md`
3. **Add images**: Add diagrams/images to the post directory
4. **Preview**: `./scripts/preview.sh` (check in browser)
5. **Publish**: `./scripts/publish-drafts.sh content/routing/bgp/bgp-communities/index.md`
6. **Commit**: `git add content/ && git commit -m "Add post: BGP Communities"`

## Requirements

- Hugo (extended version for Tailwind CSS)
- bash or compatible shell
- ImageMagick (optional, for featured image generation)

## Installation

Scripts are already executable. If you need to make them executable:

```bash
chmod +x scripts/*.sh
```
