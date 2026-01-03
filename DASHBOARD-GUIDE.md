# 📊 NGERAN[IO] TUI DASHBOARD EXPLAINED

## 🎯 What is the Dashboard?

The dashboard is your **main control center** for the blog. Think of it like a cockpit - everything you need at a glance!

---

## 📐 LAYOUT BREAKDOWN

```
┌─────────────────────────────────────────────────────────────┐
│  1. HEADER SECTION                                          │
│  📊 NGERAN[IO] DASHBOARD                                    │
│  Blog automation at your fingertips                        │
├─────────────────────────────────────────────────────────────┤
│  2. STAT CARDS (4 boxes)                                   │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                              │
│  │ 📝 │ │ 📋 │ │ ✅ │ │ 🕐 │                              │
│  │ 15 │ │  4 │ │ 11 │ │ 2d │                              │
│  │Total│ │Draft│ │Pub │ │Com │                              │
│  └────┘ └────┘ └────┘ └────┘                              │
├─────────────────────────────────────────────────────────────┤
│  3. QUICK ACTIONS (8 buttons in a grid)                    │
│  ┌──────────────┐ ┌──────────────┐                        │
│  │ ✍️ Create    │ │ 📂 Manage    │                        │
│  │   Post       │ │   Posts      │                        │
│  └──────────────┘ └──────────────┘                        │
│  ┌──────────────┐ ┌──────────────┐                        │
│  │ ✅ Validate  │ │ 👁️ Preview   │                        │
│  └──────────────┘ └──────────────┘                        │
│  ... (8 total)                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 1️⃣ HEADER SECTION

**What you see:**
```
📊 NGERAN[IO] DASHBOARD
Blog automation at your fingertips
```

**What it does:**
- Tells you you're in the **TUI Dashboard**
- Just a title bar, nothing clickable

---

## 2️⃣ STAT CARDS (Live Statistics)

These are **4 boxes** showing your blog's live stats:

### 📝 Total Posts (Top Left)
- **Shows:** Total number of posts (drafts + published)
- **Example:** `15` means you have 15 posts total
- **Updates:** When you press **R** to refresh

### 📋 Drafts (Top Middle)
- **Shows:** How many posts are still drafts
- **Example:** `4` means 4 posts are work-in-progress
- **Note:** Drafts are **NOT** visible on the live website

### ✅ Published (Top Right)
- **Shows:** How many posts are published
- **Example:** `11` means 11 posts are live on your site
- **Note:** Published posts are **visible** to everyone

### 🕐 Last Commit (Bottom Right)
- **Shows:** When you last committed to Git
- **Example:** `2d ago` means 2 days ago
- **Helpful:** Track how active you've been

### 💡 Why Stat Cards Matter
- **At-a-glance info** - See your blog health instantly
- **Track progress** - See drafts vs published ratio
- **Stay motivated** - Watch your content grow!
- **Press R** - Refresh stats anytime to see updates

---

## 3️⃣ QUICK ACTIONS (8 Buttons)

These are the **8 action buttons** you can click. Each one does something:

### ✍️ Create Post
**Purpose:** Start writing a new blog post

**What happens:**
1. Opens a modal (popup window)
2. Shows 4 category buttons: OSPF, BGP, MPLS, Junos
3. You click a category (it turns green)
4. Type your post title
5. Click "Create Post"
6. Post is created in the right folder!

**Example workflow:**
```
Click "Create Post"
→ Click "MPLS" button
→ Type: "MPLS Label Switching"
→ Click "Create"
→ Post created at: content/routing/mpls/mpls-label-switching/
```

---

### 📂 Manage Posts
**Purpose:** View and manage all your draft posts

**What happens:**
1. Opens a modal with a table
2. Table shows: Category | Title | Path
3. You can:
   - **Refresh** - Reload the draft list
   - **Edit** - Shows command to edit a post
   - **Delete** - Shows command to delete a post
4. Use arrow keys to select a row

**Example:**
```
Click "Manage Posts"
→ See table of all drafts
→ Use arrow keys to select one
→ Click "Edit" to see edit command
→ Copy that command and run it
```

---

### ✅ Validate
**Purpose:** Quality check all your draft posts

**What happens:**
1. Opens a modal
2. Click "Validate All Drafts"
3. Runs quality checks:
   - Frontmatter complete?
   - Word count sufficient?
   - Featured image exists?
   - Links valid?
   - Tags correct?
4. Shows results in the output area

**Why use it:**
- Catch errors before publishing
- Ensure quality standards
- Fix missing images, broken links, etc.

---

### 👁️ Preview
**Purpose:** See your website locally before publishing

**What happens:**
1. Opens a modal
2. Shows port setting (default: 1313)
3. Click "Start Preview Server"
4. Instructions show:
   ```
   Open http://localhost:1313 in your browser
   Press Ctrl+C to stop the server
   ```
5. Opens Hugo dev server in background
6. View your site in browser!

**Why use it:**
- Test changes before publishing
- See how posts look
- Check formatting and images
- Catch layout issues

---

### 🚀 Publish
**Purpose:** Publish draft posts to the live website

**What happens:**
1. Opens a modal
2. Click "Publish All Drafts"
3. Automatically:
   - Validates each post
   - Changes `draft = true` to `draft = false`
   - Makes posts visible on website
4. Shows success/error for each post

**⚠️ Important:**
- This **does NOT** push to GitHub automatically
- You still need to manually commit and push
- Safety feature - gives you control!

**Example workflow:**
```
1. Click "Publish"
2. All drafts validated and published
3. Click "Git Status" (in main menu)
4. Commit changes manually
5. Push manually when ready
```

---

### 🔄 Git Status
**Purpose:** Check your Git repository status

**What happens:**
1. Opens a modal with 3 buttons:
   - **Check Status** - Shows modified files
   - **Pre-Push Check** - Runs safety tests
   - **Recent Commits** - Shows last 10 commits
2. Output area shows results

**Why use it:**
- See what files have changed
- Run safety checks before pushing
- View commit history
- Understand what's staged

---

### 📋 View Logs
**Purpose:** See what the automation has been doing

**What happens:**
1. Opens a modal with 4 log buttons:
   - **Automation** - Main automation log
   - **Quality Gate** - Validation logs
   - **Build** - Hugo build logs
   - **Deployment** - Deployment logs
2. Click any button to see last 50 lines
3. Output area shows log entries

**Why use it:**
- Debug issues
- Track what happened
- See error messages
- Understand automation flow

---

### 🧪 Run Tests
**Purpose:** Test that automation is working correctly

**What happens:**
1. Opens a modal with 2 buttons:
   - **Phase 1 Tests** - Core library tests
   - **Phase 2 Tests** - Enhanced script tests
2. Click a button to run tests
3. Output shows test results
4. Green = passed, Yellow = issues

**Why use it:**
- Verify system health
- Catch broken automation
- Test after making changes
- Ensure everything works

---

## 🎮 HOW TO USE THE DASHBOARD

### Navigation
- **Tab / Arrow Keys** - Move between buttons
- **Enter** - Click/select button
- **Esc** - Go back / close modal
- **R** - Refresh stat cards
- **Q** - Quit TUI

### Typical Workflows

#### Workflow 1: Create a New Post
```
1. Dashboard opens
2. Check "Drafts" stat (shows current count)
3. Click "Create Post" action button
4. Select category (OSPF/BGP/MPLS/Junos)
5. Type title
6. Click "Create"
7. Press Esc to return to dashboard
8. Press R to see "Drafts" count increased!
```

#### Workflow 2: Edit & Publish a Post
```
1. Click "Manage Posts"
2. Select post in table
3. Click "Edit" - shows command
4. Run that command in another terminal
5. Edit the post in your editor
6. Press Esc to return to dashboard
7. Click "Validate" - quality check
8. Click "Preview" - see it locally
9. Click "Publish" - make it live
10. Click "Git Status" - see changes
11. Commit manually (git add/git commit)
12. Push manually when ready (git push)
```

#### Workflow 3: Check System Health
```
1. Press R - refresh stats
2. Look at stat cards - everything looks good?
3. Click "Run Tests"
4. Run "Phase 1 Tests"
5. Run "Phase 2 Tests"
6. All tests pass? System is healthy!
```

---

## 💡 DASHBOARD TIPS

### Tip 1: Read the Descriptions
Each action button has a subtitle that tells you what it does:
- "Start writing something new"
- "View and edit your drafts"
- "Quality check your content"
- etc.

Read these to understand what each button does!

### Tip 2: Use the Stat Cards
- **Before you start** - See current state
- **After creating** - Watch drafts count go up
- **After publishing** - Watch published count go up
- **Press R often** - Keep stats updated

### Tip 3: Follow the Workflow
The buttons are ordered logically:
```
Create → Manage → Validate → Preview → Publish → Git → Logs → Tests
```
Follow this order for smooth workflow!

### Tip 4: Use Modals for Info
Each action opens a modal with:
- **Output area** - Shows what happened
- **Status message** - Success/error/info
- **Instructions** - What to do next

### Tip 5: Always Validate Before Publishing
```
Create → Validate → Preview → Publish
         ↑         ↑
    Check quality  Test locally
```

---

## 🎨 DESIGN PHILOSOPHY

### Why This Layout?

**1. Stats at Top**
- Most important info
- See instantly
- Always visible

**2. Actions Below**
- Organized by workflow
- Clear labels
- Easy to scan

**3. Visual Hierarchy**
- Big numbers (stats) catch attention
- Icons help identify actions
- Descriptions provide context

**4. Color Coding**
- Green = success
- Red = error
- Yellow = warning
- Blue = info

---

## 📊 READING THE STAT CARDS

### Healthy Blog Ratios

**New Blog (Starting Out):**
```
Total: 5-10 posts
Drafts: 3-7 (60-70%)
Published: 2-3 (30-40%)
```

**Growing Blog:**
```
Total: 10-25 posts
Drafts: 5-10 (40-50%)
Published: 10-15 (50-60%)
```

**Established Blog:**
```
Total: 25+ posts
Drafts: 5-10 (20-30%)
Published: 20+ (70-80%)
```

**Goal:**
- Keep **drafts low** (finish what you start!)
- Keep **published high** (share your knowledge!)
- **Total grows over time** (consistent content creation)

---

## 🎯 QUICK REFERENCE

| Button | Icon | Purpose |
|--------|------|---------|
| Create Post | ✍️ | Make new content |
| Manage Posts | 📂 | View/edit drafts |
| Validate | ✅ | Quality check |
| Preview | 👁️ | Test locally |
| Publish | 🚀 | Make live |
| Git Status | 🔄 | Check changes |
| View Logs | 📋 | See history |
| Run Tests | 🧪 | Verify health |

| Stat Card | Shows | Updates |
|-----------|-------|---------|
| 📝 Total | All posts | Press R |
| 📋 Drafts | WIP posts | Press R |
| ✅ Published | Live posts | Press R |
| 🕐 Last Commit | Git activity | Press R |

---

## 🆘 NEED HELP?

### Inside the TUI
- **Press ?** - Look for help (if available)
- **Read descriptions** - Under each button
- **Check status messages** - Bottom of modals
- **View output** - Scrollable output areas

### Common Issues

**Stats not updating?**
- Press **R** to refresh

**Can't see button text?**
- Resize terminal (make it wider)
- Use fullscreen mode

**Actions not responding?**
- Press **Esc** to close modal
- Try again

**Tests failing?**
- Check logs (View Logs → Automation)
- Run setup script again

---

## 🚀 READY TO USE?

1. **Launch:** `./scripts/tui`
2. **Look around:** Read the stats and buttons
3. **Press R:** Refresh stats
4. **Try something:** Click "Create Post"
5. **Explore:** Check out each action

**Remember:** The dashboard is your cockpit - everything you need, right at your fingertips! 🎮✨
