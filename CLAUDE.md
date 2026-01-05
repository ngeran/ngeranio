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

### 🚀 AI Automation System (Phase 2 Complete)

Phase 2 builds on Phase 1 by integrating all scripts with the Phase 1 libraries and adding comprehensive content management and quality validation.

#### **Enhanced Scripts** (Phase 1 Library Integration)

All existing scripts now use Phase 1 libraries for consistency, better error handling, and improved logging:

**1. create-post.sh** - Enhanced Post Creation
- **Phase 1 Integration**: Uses common.sh, logger.sh, error-handler.sh, config.sh
- **New Features**:
  - `--force` - Overwrite existing posts
  - `--no-backup` - Skip backup creation
  - Configuration from .env (content dir, image settings)
  - Component-specific logging (log_content)
  - Cross-platform compatibility (macOS/Linux)

**Usage:**
```bash
# Create a new post
./scripts/create-post.sh ospf "OSPF Virtual Links"

# Create with force overwrite
./scripts/create-post.sh bgp "BGP Communities" --force

# Create without backup
./scripts/create-post.sh mpls "MPLS Labels" --no-backup
```

**2. preview.sh** - Enhanced Development Server
- **Phase 1 Integration**: Uses all Phase 1 libraries
- **New Features**:
  - `--port PORT` - Custom port (default: 1313)
  - `--validate` - Validate all drafts before starting
  - `--category CAT` - Preview specific category
  - Integration with quality-gate.sh
  - Component-specific logging (log_build)

**Usage:**
```bash
# Start preview server (default port 1313)
./scripts/preview.sh

# Start on custom port
./scripts/preview.sh --port 8080

# Validate drafts before starting
./scripts/preview.sh --validate

# Preview specific category
./scripts/preview.sh --category ospf
```

**3. publish-drafts.sh** - Enhanced Publishing System
- **Phase 1 Integration**: Uses all Phase 1 libraries
- **New Features**:
  - `--validate` - Validate before publishing
  - `--backup` - Create backup before publishing
  - `--category CAT` - Publish all drafts in category
  - `--force` - Skip confirmation prompts
  - Integration with quality-gate.sh
  - Cross-platform sed commands (macOS/Linux)
  - Component-specific logging (log_deployment)

**Usage:**
```bash
# List all drafts and publish interactively
./scripts/publish-drafts.sh

# Publish specific post with validation
./scripts/publish-drafts.sh content/routing/ospf/virtual-links/index.md --validate

# Publish with backup
./scripts/publish-drafts.sh content/routing/ospf/virtual-links/index.md --backup

# Publish all drafts in category
./scripts/publish-drafts.sh --category ospf --validate

# Force publish all drafts (no confirmation)
./scripts/publish-drafts.sh --force
```

#### **Quality Gate System** (`scripts/quality-gate.sh`)

Comprehensive content validation before publishing:

**Validation Checks:**
- Frontmatter completeness (title, date, draft, tags, summary)
- Content quality (word count, headings, code blocks)
- Image verification (featured image exists, valid format)
- Link validation (internal links work)
- Tag validation (tags exist, proper format)
- Category validation (category is valid)

**Usage:**
```bash
# Validate single post
./scripts/quality-gate.sh validate content/routing/ospf/virtual-links/index.md

# Validate all draft posts
./scripts/quality-gate.sh validate-drafts

# Show quality gate configuration
./scripts/quality-gate.sh config

# Run validation in strict mode (fails on warnings)
./scripts/quality-gate.sh validate content/routing/bgp/bgp-attributes/index.md --strict
```

#### **AI Content Manager** (`scripts/ai-content-manager.sh`)

Comprehensive content management system for AI agents:

**Available Commands:**
- `create <category> <title>` - Create new post
- `update <file>` - Update existing post (opens in editor)
- `delete <file>` - Delete post (with confirmation)
- `list [drafts|published]` - List posts
- `info <file>` - Show detailed post information
- `validate <file>` - Validate post (uses quality-gate.sh)

**Usage:**
```bash
# Create new post
./scripts/ai-content-manager.sh create ospf "OSPF Virtual Links"

# Update existing post
./scripts/ai-content-manager.sh update content/routing/ospf/virtual-links/index.md

# List draft posts
./scripts/ai-content-manager.sh list drafts

# List published posts
./scripts/ai-content-manager.sh list published

# Show detailed post information
./scripts/ai-content-manager.sh info content/routing/bgp/bgp-attributes/index.md

# Validate post
./scripts/ai-content-manager.sh validate content/routing/ospf/virtual-links/index.md

# Delete post
./scripts/ai-content-manager.sh delete content/routing/ospf/old-post/index.md
```

**Options:**
- `--no-backup` - Skip backup before update/delete
- `--force` - Force operation without confirmation
- `--verbose` - Show detailed output

### Phase 2 Testing & Verification

#### Automated Test Suite (Recommended)

Run the comprehensive Phase 2 test script:

```bash
# Run all Phase 2 tests
./scripts/test-phase2.sh
```

This script verifies:
- Phase 2 core scripts (quality-gate.sh, ai-content-manager.sh)
- Enhanced scripts integration (all scripts use Phase 1 libraries)
- Configuration integration (get_config usage)
- Logging integration (component-specific logging)
- Quality gate integration (scripts integrate with quality-gate.sh)
- Enhanced functionality (new options, validation, backups)
- AI content manager commands (all 6 commands)
- Error handling (proper return codes)
- Cross-platform compatibility (macOS sed support)
- Help documentation (all scripts have help)

**Expected Output:**
- 38-42 tests should pass
- 0-2 warnings are acceptable
- Success rate: ~95%

#### Manual Testing

To manually verify Phase 2 functionality:

```bash
# Test 1: Create a post
./scripts/create-post.sh ospf "Test Post"
# Expected: Post created in content/routing/ospf/test-post/

# Test 2: Validate the post
./scripts/quality-gate.sh validate content/routing/ospf/test-post/index.md
# Expected: Validation report with warnings (incomplete content)

# Test 3: Preview with validation
./scripts/preview.sh --validate
# Expected: Server starts after validating drafts

# Test 4: List drafts
./scripts/ai-content-manager.sh list drafts
# Expected: List of all draft posts

# Test 5: Get post info
./scripts/ai-content-manager.sh info content/routing/ospf/test-post/index.md
# Expected: Detailed post information

# Test 6: Publish (if ready)
./scripts/publish-drafts.sh content/routing/ospf/test-post/index.md --validate
# Expected: Validation followed by publishing

# Test 7: Check logs
cat logs/automation.log
cat logs/quality-gate.log
cat logs/build.log
cat logs/deployment.log
# Expected: Component-specific log entries
```

### Automation Safety Features

**🛡️ Safety Mechanisms:**
- **No automatic GitHub pushes** - All git operations require manual approval
- **Configuration validation** - All settings validated before use
- **Error recovery** - Automatic cleanup and recovery suggestions
- **Lock files** - Prevents concurrent automation runs
- **Comprehensive logging** - All operations logged for audit trail
- **Rollback ready** - Backup and rollback mechanisms prepared
- **Quality gate validation** - Content validated before publishing
- **Backup before modification** - Automatic backups before updates/deletes

**⚠️ Important Notes:**
- GitHub CLI is installed but needs authentication: `gh auth login`
- Cloudflare is connected but **NO automatic deployments** will happen
- All automation scripts are safe to run locally for testing
- Git repository is in clean state (safe to work on)
- Quality validation prevents publishing incomplete/invalid content
- Backups created automatically before modifications

### Available Automation Scripts

#### Phase 2 Scripts (All Enhanced with Phase 1 Libraries)

**Enhanced Existing Scripts:**
- `scripts/create-post.sh` - Create new blog posts (enhanced with Phase 1 libs)
- `scripts/preview.sh` - Preview site with drafts (enhanced with Phase 1 libs)
- `scripts/publish-drafts.sh` - Publish draft posts (enhanced with Phase 1 libs)

**New Phase 2 Scripts:**
- `scripts/ai-content-manager.sh` - Comprehensive content management system
- `scripts/quality-gate.sh` - Quality validation and content checks
- `scripts/test-phase2.sh` - Comprehensive Phase 2 test suite

#### Phase 1 Libraries (All Scripts Use These)

- `scripts/lib/common.sh` - Utility functions
- `scripts/lib/logger.sh` - Advanced logging system
- `scripts/lib/error-handler.sh` - Error management
- `scripts/lib/config.sh` - Configuration management

### 🖥️ Terminal User Interface (TUI)

A graphical terminal interface that makes the automation system easy to use without memorizing commands!

**Quick Start:**
```bash
# Install dependencies (one-time)
pip install textual

# Launch the TUI
./scripts/tui

# Or directly
python3 scripts/automation-tui.py
```

**TUI Features:**

The TUI provides an intuitive interface with 8 main screens:

1. **Main Menu** - Navigate to all features
2. **Create Post** - Create new posts with button clicks
3. **Manage Posts** - View, edit, delete drafts in a table
4. **Validate Content** - Quality check your posts
5. **Preview Site** - Start development server
6. **Publish Posts** - Publish drafts to live
7. **Git Operations** - Check status, safety checks, commits
8. **View Logs** - See all automation logs
9. **Run Tests** - Run Phase 1 and Phase 2 tests

**Automation Tab - Quick Actions:**

The Automation tab (Phase 1 Complete) provides four main action buttons:

1. **✓ Quality Gate**
   - **Command**: `bash scripts/quality-gate.sh validate-drafts`
   - **Purpose**: Validates all draft posts for quality issues
   - **Checks**: Frontmatter completeness, word count (min 500), image presence, link validity, tag format, category validation
   - **Output**: Real-time validation showing which posts pass/fail and why
   - **Use Case**: Run before publishing to ensure content meets quality standards
   - **Expected**: May show warnings for incomplete drafts - this is normal

2. **▶ Preview**
   - **Command**: `bash scripts/preview.sh`
   - **Purpose**: Starts Hugo development server
   - **Output**: Shows Hugo server startup messages and status
   - **Note**: Displays server status, not the actual preview interface
   - **Access**: Open http://localhost:1313 in your browser to see the site
   - **Use Case**: Test site locally with live reload during development

3. **⚙ Tests**
   - **Command**: `bash scripts/test-phase2.sh`
   - **Purpose**: Runs Phase 2 test suite (38-42 tests)
   - **Tests**: All scripts, configuration, logging, quality gate, AI content manager
   - **Output**: Real-time test results with pass/fail counts
   - **Success Rate**: ~95% (0-2 warnings acceptable)
   - **Use Case**: Verify automation system is working correctly after changes

4. **🔨 Build**
   - **Command**: `hugo --minify`
   - **Purpose**: Generates optimized static site
   - **Output**: Build progress and any errors
   - **Result**: Static files created in `public/` directory
   - **Use Case**: Prepare site for deployment to production

**Background Task System:**
- All automation buttons run asynchronously (non-blocking)
- UI stays responsive during long operations
- Real-time log streaming - output appears as it runs
- Status indicator: "Status: Running..." → "Status: Ready"
- Exit code handling: ✓ success / ✗ failure messages

**Usage:**

```bash
# Launch TUI
./scripts/tui

# Navigate with:
# - Arrow keys or mouse to navigate
# - Enter to select
# - Tab to move between fields
# - Esc to go back
# - q to quit
```

**TUI vs Command Line:**

| Operation | Command Line | TUI |
|-----------|--------------|-----|
| Create Post | `./scripts/create-post.sh mpls "Title"` | Click buttons |
| Validate | `./scripts/quality-gate.sh validate file.md` | Click "Validate" |
| Preview | `./scripts/preview.sh --validate` | Click "Start Server" |
| Publish | `./scripts/publish-drafts.sh file.md --validate` | Click "Publish" |
| View Logs | `cat logs/automation.log` | Click "View Logs" |

**TUI Advantages:**
- ✅ No need to remember commands
- ✅ Visual feedback and status indicators
- ✅ Interactive tables for posts
- ✅ Real-time log viewing
- ✅ Easier for non-technical users
- ✅ Mouse navigation supported

**Documentation:**
- See `TUI-GUIDE.md` for complete TUI documentation
- Includes step-by-step examples
- Troubleshooting guide
- Tips and tricks

#### Coming in Phase 3+

- `scripts/build-preview.sh` - Build and preview system
- `scripts/git-automation.sh` - Git operations (safe, with approval)
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
