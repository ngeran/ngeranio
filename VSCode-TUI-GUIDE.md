# 🖥️ VS Code-Inspired TUI - Complete Guide

## What is This?

A **professional, VS Code-inspired terminal interface** for managing your NGERAN[IO] blog. It combines the power of your automation scripts with an elegant, modern interface.

---

## 🎨 Layout Overview

```
┌────────────────────────────────────────────────────────────┐
│  Top Navigation Bar (Tabs)                                │
├──────────┬───────────────────────────────────────────────┤
│          │                                               │
│  File    │  Main Content Area                           │
│  Tree    │  (Changes based on navigation)               │
│  (Left   │                                               │
│  Side    │  • Dashboard stats                            │
│  Bar)    │  • Posts management                           │
│          │  • Automation scripts                         │
│  📁      │  • AI agent features                          │
│  EXPLORER│  • Git operations                             │
│  ├─content│  • Settings                                  │
│  ├─scripts│                                               │
│  ├─themes │                                               │
│  └─logs  │                                               │
├──────────────────────────────────────────────────────────┤
│  Status Bar: Stats | Shortcuts                            │
└──────────────────────────────────────────────────────────┘
```

---

## 📍 Section Breakdown

### 1️⃣ Top Navigation Bar

**6 Main Tabs:**

| Tab | Icon | Purpose |
|-----|------|---------|
| **Dashboard** | 🏠 | Overview, stats, quick actions |
| **Posts** | ✍️ | Manage blog posts |
| **Automation** | 🔧 | Scripts and tools |
| **AI Agent** | 🤖 | AI-powered features |
| **Git** | 📦 | Version control |
| **Settings** | ⚙️ | Configuration |

**How it works:**
- Click any tab to change the main content area
- Active tab is highlighted
- Each tab shows different information

---

### 2️⃣ Left Sidebar - File Explorer

**What it shows:**
```
📁 EXPLORER
├─ 📄 content/
│  └─ routing/
├─ ⚙️ scripts/
│  ├─ create-post.sh
│  ├─ preview.sh
│  └─ etc.
├─ 🎨 themes/
├─ 📦 static/
└─ 📋 logs/
```

**Purpose:**
- Browse your project files
- See directory structure
- Locate posts, scripts, config files
- Expandable folders (Tree widget)

**Key Features:**
- Shows main project directories
- Lists important files (up to 20 per directory)
- Icons for different file types
- 📁 = directories, 📄 = files

---

### 3️⃣ Main Content Area

This area **changes based on which tab is active**:

#### 🏠 Dashboard Tab
Shows:
- Blog statistics (total, drafts, published)
- Last commit time
- Quick actions
- Instructions

```
📊 DASHBOARD

Welcome to NGERAN[IO] Blog Automation

Blog Statistics:
  📝 Total Posts: 15
  📋 Drafts: 4
  ✅ Published: 11
  🕐 Last Commit: 2 days ago

Quick Actions:
  • Press Ctrl+N to create a new post
  • Press Ctrl+P to preview the site
  • Click navigation tabs to explore
  • Browse files in the sidebar
```

#### ✍️ Posts Tab
Shows:
- List of all draft posts
- Title, category, and path
- Count of drafts

```
✍️ POSTS MANAGEMENT

Manage your blog posts

Draft Posts (4):

  1. MPLS Label Switching
     Category: mpls
     Path: content/routing/mpls/mpls-label-switching/index.md

  2. BGP Communities
     Category: bgp
     Path: content/routing/bgp/bgp-communities/index.md
  ...
```

#### 🔧 Automation Tab
Shows:
- All available scripts
- Phase 1 libraries
- What each script does

```
🔧 AUTOMATION

Blog automation scripts and tools

Available Scripts:
  • create-post.sh - Create new blog posts
  • preview.sh - Preview site locally
  • publish-drafts.sh - Publish drafts to live
  • quality-gate.sh - Validate content quality
  • ai-content-manager.sh - AI-assisted management

Phase 1 Libraries:
  • common.sh - Utility functions
  • logger.sh - Advanced logging
  • error-handler.sh - Error management
  • config.sh - Configuration management
```

#### 🤖 AI Agent Tab
Shows:
- AI features available
- AI Content Manager usage
- Commands and options

```
🤖 AI AGENT

AI-powered content creation and management

AI Features:
  • Automated content generation
  • Quality validation
  • SEO optimization
  • Image suggestions

AI Content Manager:
  Run: ./scripts/ai-content-manager.sh

Commands:
  • create - Create new post with AI
  • update - Update existing post
  • validate - Validate content
  • list - List all posts
```

#### 📦 Git Tab
Shows:
- Git operations
- Deployment info
- Safety features

```
📦 GIT & GITHUB

Version control and deployment

Git Operations:
  • Check status
  • Commit changes
  • Push to GitHub
  • Pre-push safety checks

Deployment:
  • Automatic deployment to Cloudflare Pages
  • Triggered on push to main branch
  • Build command: hugo --minify

Safety Features:
  • Pre-push validation
  • Automatic backups
  • Rollback capability
  • Quality gate checks
```

#### ⚙️ Settings Tab
Shows:
- Configuration details
- Environment status
- Key files

```
⚙️ SETTINGS

Configuration and preferences

Configuration:
  • Site URL: https://ngeranio.com
  • Main sections: routing
  • Pagination: 6 posts per page

Environment:
  • Hugo Extended: ✓ Installed
  • Git: ✓ Available
  • GitHub CLI: ✓ Available
  • Python 3: ✓ Available

Key Files:
  • .env - Environment variables
  • hugo.toml - Site configuration
  • CLAUDE.md - Automation guide
```

---

### 4️⃣ Bottom Status Bar

**Two sections:**

**Left Side (Stats):**
```
📊 15 posts | ✓ 11 published | ⚠ 4 drafts | 2 days ago
```
- Total posts count
- Published count (green)
- Drafts count (yellow)
- Last commit time

**Right Side (Shortcuts):**
```
^Q Quit | ^R Refresh | ^N New Post | ^P Preview
```
- Quick keyboard shortcuts reference

---

## ⌨️ Keyboard Shortcuts

### Global Shortcuts

| Key | Action |
|-----|--------|
| **Q** | Quit TUI |
| **Ctrl+C** | Quit TUI |
| **Esc** | Close modal/go back |
| **Ctrl+R** | Refresh current view |
| **Ctrl+N** | Create new post |
| **Ctrl+P** | Preview site |

### Navigation

| Key | Action |
|-----|--------|
| **Tab** | Navigate between widgets |
| **Enter** | Select/click |
| **Arrow Keys** | Navigate lists/trees |
| **Click** | Mouse works too! |

---

## 🎯 Common Workflows

### Workflow 1: Create a New Post

1. **Press Ctrl+N** (or use Dashboard tab)
2. Modal opens with category selection
3. Click category button (OSPF/BGP/MPLS/Junos)
4. Type post title
5. Click "Create Post"
6. Success message shows
7. File created in correct directory

### Workflow 2: View/Edit Draft Posts

1. **Click "Posts" tab** in top nav
2. See list of all draft posts
3. Note the path for the post you want
4. Open in your editor using the path
5. Edit and save
6. Preview with Ctrl+P

### Workflow 3: Preview Site

1. **Press Ctrl+P** (or click "Preview" in Dashboard)
2. Instructions appear in content area
3. Open http://localhost:1313 in browser
4. See your site live
5. Stop server when done: `pkill hugo`

### Workflow 4: Check Automation Status

1. **Click "Automation" tab**
2. See all available scripts
3. Review Phase 1 libraries
4. Understand what tools are available
5. Use scripts from terminal if needed

### Workflow 5: AI-Assisted Creation

1. **Click "AI Agent" tab**
2. Read about AI features
3. Use `ai-content-manager.sh` from terminal
4. Follow commands shown in TUI

### Workflow 6: Deploy Changes

1. **Click "Git" tab**
2. Review deployment info
3. Use terminal to commit changes
4. Push to GitHub
5. Auto-deploys to Cloudflare

---

## 💡 Design Philosophy

### Why VS Code-Inspired?

**1. Familiar Layout**
- Most developers use VS Code
- Intuitive navigation
- Professional feel

**2. Efficient Workflow**
- File explorer sidebar
- Tabbed navigation
- Status bar with info

**3. Focus Areas**
- **Hugo** - Blog content management
- **Automation** - Scripts and tools
- **AI Agent** - AI-powered features
- **GitHub** - Version control & deployment

**4. Clean & Modern**
- Not cluttered
- Information hierarchy
- Visual feedback

---

## 🎨 Visual Design Elements

### Color Coding

- **Cyan** - Headings, navigation
- **Green** - Success, published items
- **Yellow** - Warnings, drafts
- **Red** - Errors
- **Dim** - Secondary text

### Icons

- 📊 Dashboard/Stats
- ✍️ Writing/Posts
- 🔧 Tools/Automation
- 🤖 AI Features
- 📦 Git/Deployment
- ⚙️ Settings
- 📁 Folders
- 📄 Files

### Layout Spacing

- Borders separate sections
- Padding for breathing room
- Consistent alignment
- Professional look

---

## 🚀 Advanced Usage

### Tip 1: Keep TUI Open

Keep the TUI running while you work:
1. Create post in TUI (Ctrl+N)
2. Edit in your editor (VS Code, etc.)
3. Preview in browser (Ctrl+P)
4. Refresh TUI to see updates (Ctrl+R)

### Tip 2: Use File Explorer

The sidebar isn't just for show:
- Browse to find post files
- See project structure
- Understand organization
- Locate scripts and configs

### Tip 3: Reference Information

Each tab provides useful info:
- **Automation** - See all scripts
- **AI** - Learn AI features
- **Git** - Understand deployment
- **Settings** - Check configuration

### Tip 4: Keyboard Power User

Memorize shortcuts:
- **Ctrl+N** - Quick post creation
- **Ctrl+R** - Refresh current view
- **Ctrl+P** - Start preview
- **Q** - Fast quit

### Tip 5: Multi-Tab Workflow

1. **Dashboard** - Check stats
2. **Posts** - Find draft to edit
3. **Automation** - Run script
4. **Git** - Commit and push

---

## 🎓 Learning Path

### Beginner

1. Start with **Dashboard** tab
2. Learn keyboard shortcuts
3. Create your first post (Ctrl+N)
4. Preview your site (Ctrl+P)
5. Explore other tabs

### Intermediate

1. Use **Posts** tab to manage drafts
2. Browse **File Explorer** sidebar
3. Read **Automation** tab for scripts
4. Use **AI** tab for AI features
5. Check **Git** tab before deploying

### Advanced

1. Customize workflows
2. Combine TUI with terminal
3. Use automation scripts directly
4. Integrate AI content creation
5. Master all shortcuts

---

## 🔧 Troubleshooting

### Issue: TUI Looks Wrong

**Solution:**
- Make terminal at least 80x24
- Use fullscreen if possible
- Check terminal supports colors

### Issue: Can't See All Content

**Solution:**
- Use arrow keys to scroll
- Resize terminal window
- Try fullscreen mode

### Issue: Buttons Not Working

**Solution:**
- Press Tab to focus
- Use Enter to click
- Try mouse click instead
- Check for modal dialogs

### Issue: File Tree Empty

**Solution:**
- Run from project root
- Check directory permissions
- Ensure .venv exists

---

## 📊 Comparison: Old vs New

| Feature | Old TUI | New VS Code TUI |
|---------|---------|-----------------|
| **Layout** | Centered buttons | VS Code layout |
| **Navigation** | Button grid | Top tabs |
| **File Browser** | None | Left sidebar |
| **Content** | Modals only | Dynamic content area |
| **Status** | Hidden | Bottom status bar |
| **Shortcuts** | Not visible | Always visible |
| **Info** | Scattered | Organized by tab |
| **Feel** | Basic | Professional |

---

## 🎯 Quick Reference Card

```
╔══════════════════════════════════════════════════╗
║  VS Code TUI - Quick Reference                    ║
╠══════════════════════════════════════════════════╣
║  Tabs:                                            ║
║    🏠 Dashboard  ✍️ Posts  🔧 Automation          ║
║    🤖 AI Agent  📦 Git  ⚙️ Settings               ║
║                                                   ║
║  Shortcuts:                                       ║
║    Ctrl+N - New Post    Ctrl+R - Refresh          ║
║    Ctrl+P - Preview      Q - Quit                 ║
║                                                   ║
║  Sidebar:                                         ║
║    📁 File Explorer (browse project)              ║
║                                                   ║
║  Status Bar:                                      ║
║    Left: Stats  Right: Shortcuts                  ║
╚══════════════════════════════════════════════════╝
```

---

## 🚀 Getting Started

### 1. Launch
```bash
./scripts/tui
```

### 2. Explore
- Click each tab
- Browse file tree
- Read content area

### 3. Create
- Press Ctrl+N
- Select category
- Type title
- Create post

### 4. Work
- Edit in your editor
- Preview with Ctrl+P
- Refresh with Ctrl+R

### 5. Deploy
- Check Git tab
- Commit changes
- Push to GitHub
- Auto-deploy!

---

## 💡 Why This Design?

### Focus on Your Workflow

The TUI is designed around **your actual needs**:

1. **Hugo Blog Management** - Create, edit, preview posts
2. **Automation** - Run scripts without memorizing commands
3. **AI Agent** - Understand AI capabilities
4. **Git/Deployment** - Track version control

### Professional Aesthetics

- Looks like VS Code (familiar)
- Clean layout (not cluttered)
- Color-coded information (easy to scan)
- Status always visible (no guessing)

### Efficient Interactions

- Keyboard shortcuts (fast)
- Tab navigation (organized)
- File browser (context)
- Always-on status (informed)

---

## 🎉 Enjoy!

This TUI is designed to make blog management **professional, efficient, and even enjoyable**!

**Remember:**
- Press **Ctrl+N** for quick post creation
- Browse tabs to learn features
- Check status bar for info
- Use file explorer to navigate

Happy blogging! 🚀✨
