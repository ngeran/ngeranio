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

The blog includes automation for AI-assisted content creation with a comprehensive system for safe, automated publishing.

### 🤖 AI Automation System (Phase 1 Complete)

The site now has a **fully automated AI content creation and publishing system** with these foundation components:

#### **Core Libraries** (`scripts/lib/`)

All automation scripts use these shared libraries:

**1. common.sh** - Utility Functions
- Logging (info, success, warning, error, debug)
- String manipulation (trim, lowercase, slug generation)
- File/directory helpers
- Git utilities
- Hugo build helpers
- Progress indicators

**2. logger.sh** - Advanced Logging System
- Multiple log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- Component-specific log files:
  - `logs/automation.log` - Main automation log
  - `logs/quality-gate.log` - Quality validation log
  - `logs/build.log` - Build operations log
  - `logs/deployment.log` - Deployment log
  - `logs/rollback.log` - Rollback operations log
- Log rotation and analysis
- Search and statistics

**3. error-handler.sh** - Error Management
- Error trapping and handling
- Cleanup on errors
- Recovery suggestions
- Lock file management (prevents concurrent operations)
- Safe execution wrappers
- Retry mechanisms (with configurable attempts)

**4. config.sh** - Configuration Management
- Load and validate configuration from `.env`
- Type-safe config getters
- Feature flag helpers
- Path helpers
- Cloudflare integration checks

#### **Configuration File** (`.env`)

All automation settings are centralized in `.env`:
- Site configuration (URL, Hugo version)
- Git configuration (author, repository)
- Content configuration (categories, word count)
- Quality gate settings (strict mode, validation rules)
- Build configuration (output dir, preview port)
- Deployment settings (auto-push, backups, safety)
- Cloudflare settings (account ID, project name, API token)

### Quick Start for AI Agents

```bash
# Load automation libraries
source scripts/lib/config.sh

# Access configuration
get_config SITE_URL              # → https://ngeranio.com
get_config HUGO_VERSION          # → 0.152.2
get_config MIN_WORD_COUNT        # → 500
is_strict_mode                   # → true/false
should_create_backups          # → true/false
```

### Phase 1 Testing & Verification

#### Automated Test Suite (Recommended)

Run the comprehensive Phase 1 test script:

```bash
# Run all Phase 1 tests
./scripts/test-phase1.sh
```

This script verifies:
- Directory structure (logs/, scripts/lib/)
- Library loading (all 4 core libraries)
- Configuration system (loading, validation, getters)
- Logging system (log files, component-specific logging)
- Error handling (error codes, validation functions)
- System dependencies (Hugo, Git, GitHub CLI)
- Safety features (auto-push settings, rollback, strict mode)

**Expected Output:**
- 27-29 tests should pass
- 1-2 warnings are OK (GitHub CLI authentication, DEPLOY_AUTO_PUSH setting)
- Success rate: ~93%

#### Manual Testing

To manually verify Phase 1 foundation:

```bash
# Test 1: Load configuration
source scripts/lib/config.sh
echo "Config loaded: $CONFIG_LOADED"
echo "Config valid: $CONFIG_VALID"

# Test 2: Check logging
source scripts/lib/logger.sh
log_info "Test log message"
show_config

# Test 3: Verify all libraries
source scripts/lib/common.sh
source scripts/lib/error-handler.sh
source scripts/lib/config.sh
echo "✓ All libraries loaded successfully"

# Test 4: Check logs directory
ls -la logs/

# Test 5: Validate environment
hugo version
git status
gh --version
```

### Automation Safety Features

**🛡️ Safety Mechanisms:**
- **No automatic GitHub pushes** - All git operations require manual approval
- **Configuration validation** - All settings validated before use
- **Error recovery** - Automatic cleanup and recovery suggestions
- **Lock files** - Prevents concurrent automation runs
- **Comprehensive logging** - All operations logged for audit trail
- **Rollback ready** - Backup and rollback mechanisms prepared

**⚠️ Important Notes:**
- GitHub CLI is installed but needs authentication: `gh auth login`
- Cloudflare is connected but **NO automatic deployments** will happen
- All automation scripts are safe to run locally for testing
- Git repository is in clean state (safe to work on)

### Available Automation Scripts

#### Existing Scripts (to be enhanced)

- `scripts/create-post.sh` - Create new blog posts
- `scripts/preview.sh` - Preview site with drafts
- `scripts/publish-drafts.sh` - Publish draft posts

#### Coming in Phase 2+

- `scripts/ai-content-manager.sh` - Content creation and updates
- `scripts/quality-gate.sh` - Quality validation
- `scripts/build-preview.sh` - Build and preview system
- `scripts/git-automation.sh` - Git operations
- `scripts/deployment-safety.sh` - Safety checks and rollback
- `scripts/orchestrator.sh` - Main workflow coordinator

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
