# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **ngeran[io]**, a Hugo-based technical blog focused on networking and routing technologies. The site shares JNCIE-SP study notes and networking knowledge, particularly around OSPF, BGP, MPLS, and Junos.

## Build and Development Commands

```bash
# Build the static site (outputs to public/)
hugo

# Run development server with live reload (default: http://localhost:1313)
hugo server

# Create a new post with frontmatter (uses archetypes/default.md)
hugo new content/routing/{section}/{post-name}/index.md

# Build including drafts
hugo -D

# Development server with drafts (includes draft posts)
hugo server -D

# Development with future-dated content
hugo server -F

# Build for production (minified, optimized)
hugo --minify
```

### Local Testing Workflow

1. **Install Hugo**: Ensure Hugo extended version is installed (for Tailwind CSS support)
2. **Run dev server**: `hugo server -D` (includes drafts for testing)
3. **Visit**: Open http://localhost:1313 in browser
4. **Live reload**: Changes to content, layouts, or assets trigger automatic rebuild
5. **Test production build**: Run `hugo --minify` to verify final output

### Cloudflare Pages Deployment

The site automatically deploys to Cloudflare Pages when pushed to GitHub:
- GitHub repository is synced with Cloudflare Pages
- Build command: `hugo --minify`
- Build output directory: `public/`
- Deployments trigger automatically on push to main branch

## Content Structure

### Organization
Posts are organized hierarchically under `content/`:
- `content/routing/ospf/` - OSPF protocol posts
- `content/routing/bgp/` - BGP protocol posts
- `content/routing/mpls/` - MPLS protocol posts
- `content/junos/` - Juniper-specific content

Each post has its own directory containing:
- `index.md` - Main content file
- `featured.png` - Featured image for the post
- Additional images/diagrams referenced in the content

### Frontmatter Format (TOML)

```toml
+++
title = 'Post Title'
date = 2024-12-10T17:36:42-05:00
draft = false
tags = ["BGP", "Routing", "Juniper"]
featured_image = 'featured.png'
summary = 'Brief description shown in post listings'
+++
```

Key fields:
- `draft` - Set to `true` for work-in-progress posts, `false` for published
- `tags` - Array of topic tags for categorization
- `featured_image` - Path to the post's featured image (relative to post directory)
- `summary` - Short description for index/listing pages

## Architecture

### Hugo Configuration (`hugo.toml`)
- **Theme**: Custom "vector" theme (`themes/vector/`)
- **Base URL**: https://ngeranio.com/
- **Main content section**: `routing` (set via `params.mainSections`)
- **Pagination**: 6 posts per page (`pagerSize = 6`)
- **Syntax highlighting**: Enabled with custom CSS classes (`noClasses = false`)
- **Menu structure**: Hierarchical with Home → Posts (OSPF, BGP, MPLS) → Projects

### Content Frontmatter Defaults
Default template in `archetypes/default.md` uses Hugo template syntax:
- Title: Auto-generated from filename with hyphens replaced by spaces
- Date: Auto-set to creation date
- Draft: Defaults to `true`

### Site Navigation
Menu structure defined in `hugo.toml` under `[[menus.main]]`:
- Home (weight: 10)
- Posts dropdown (weight: 20)
  - OSPF (`/routing/ospf`)
  - BGP (`/routing/bgp`)
  - MPLS (`/routing/mpls`)
- Projects (weight: 30)

## Theme Customization

The Vector theme is customized through:
- **Logo**: `/static/networking-dark.png` (set in `[params.site]`)
- **Author info**: Configured in `[params.author]` (name, bio, avatar)
- **Social links**: Template available but commented out in config
- **Next/Prev navigation**: Enabled via `params.enableNextPrevPages`

## Content Guidelines

1. **Post URLs**: Use subdirectories with `index.md` (e.g., `content/routing/bgp/bgp-attributes/index.md`)
2. **Image paths**: Store post-specific images in the same directory as the `index.md` file
3. **Draft workflow**: Set `draft = true` in frontmatter, use `hugo server -D` to preview
4. **Technical accuracy**: Content covers enterprise networking protocols and Juniper configuration
5. **Code/diagrams**: Network diagrams are common; include image files in post directories

## Git Workflow

- **Main branch**: `main`
- **Content commits**: Focus on technical accuracy and proper frontmatter
- **Image assets**: Commit alongside content changes (images are in version control)

## AI Agent Content Creation

The blog includes automation for AI-assisted content creation.

### Quick Start for AI Agents

```bash
# Create a new post
./scripts/create-post.sh ospf "OSPF Virtual Links"

# Preview with drafts
./scripts/preview.sh

# Publish when ready
./scripts/publish-drafts.sh content/routing/ospf/ospf-virtual-links/index.md
```

### AI Content Templates

- `.ai-content-template.md` - Master template for new posts
- `AI_AGENT_GUIDE.md` - Comprehensive guide for content creation
- `scripts/` - Automation scripts for post creation and publishing

### Content Structure for AI

When creating content, follow this structure:
1. Overview - Brief introduction
2. Background - Context and relevance
3. Key Concepts - Technical explanations
4. Configuration Examples - Real Junos code
5. Verification - How to verify it works
6. Troubleshooting - Common issues
7. Exam Tips - JNCIE-SP specific guidance
8. Summary - Key takeaways
9. References - Documentation links

## Theme Features

### Dark/Light Mode
- Automatic theme detection based on system preference
- Manual toggle button in navigation (sun/moon icon)
- Smooth transitions between themes
- Persistent theme preference in localStorage

### Modern UI/UX
- Responsive design with mobile-first approach
- Tailwind CSS for styling
- Nordic-inspired color palette (Nord theme colors)
- Smooth animations and transitions
- Optimized typography for technical content
- Sticky table of contents on blog posts
- Accessible navigation with keyboard support

### Theme Customization
- **Colors**: Modified in `themes/vector/assets/css/theme.css`
- **Layouts**: Hugo templates in `themes/vector/layouts/`
- **JavaScript**: Theme switcher in `themes/vector/assets/js/theme-switcher.js`
- **Tailwind config**: `themes/vector/tailwind.config.js`
