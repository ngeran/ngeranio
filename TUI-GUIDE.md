# 🖥️ NGERAN[IO] AUTOMATION TUI - USER GUIDE

## What is the TUI?

The **Terminal User Interface (TUI)** is a graphical interface in your terminal that makes using the blog automation super easy - no need to memorize command-line commands! It's like using an app, but right in your terminal.

---

## 🚀 Quick Start (3 Steps)

### Step 1: Install Dependencies (One-Time Setup)

```bash
# Install Textual library
pip install textual

# Or use pip3
pip3 install textual
```

### Step 2: Launch the TUI

```bash
# From anywhere in your project
./scripts/tui

# Or directly
python3 scripts/automation-tui.py
```

### Step 3: Use the Interface

Use your **arrow keys** or **mouse** to navigate, **Enter** to select, and follow the on-screen prompts!

---

## 📱 TUI Features

The TUI has **8 main screens**:

### 1. 🏠 Main Menu
The home screen with all options:
- Create New Post
- Manage Posts
- Validate Content
- Preview Site
- Publish Posts
- Git Operations
- View Logs
- Run Tests

### 2. ✍️ Create Post
Easily create new blog posts:
- Select category (OSPF, BGP, MPLS, Junos)
- Enter post title
- Automatic post creation

### 3. 📂 Manage Posts
View and manage draft posts:
- List all draft posts in a table
- View post information
- Edit posts in your editor
- Delete posts

### 4. ✅ Validate Content
Quality check your posts:
- Validate all drafts at once
- Check specific posts
- See detailed validation reports

### 5. 👁️ Preview Site
Preview your blog locally:
- Start development server
- Optional validation before starting
- Custom port support
- Stop server when done

### 6. 🚀 Publish Posts
Publish drafts to live:
- Publish specific posts
- Publish all drafts at once
- Automatic validation before publishing

### 7. 🔄 Git Operations
Manage your git repository:
- Check git status
- Run pre-push safety checks
- View recent commits

### 8. 📋 View Logs
See what's happening:
- View automation logs
- View quality gate logs
- View build logs
- View deployment logs
- See recent entries from all logs

### 9. 🧪 Run Tests
Test your automation system:
- Run Phase 1 tests
- Run Phase 2 tests
- Run all tests at once

---

## 🎮 Navigation Guide

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Tab** | Move between buttons/fields |
| **Enter** | Select button/confirm action |
| **Esc** | Go back / Cancel |
| **Arrow Keys** | Navigate tables and lists |
| **q** | Quit TUI |
| **Ctrl+C** | Quit TUI |

### Mouse Navigation

- **Click** on buttons to select them
- **Click** on table rows to select posts
- **Click** on tabs to switch between screens
- **Scroll** in output areas to see logs

---

## 📚 Step-by-Step Examples

### Example 1: Create a New Post (Complete Workflow)

1. **Launch TUI**
   ```bash
   ./scripts/tui
   ```

2. **Main Menu**
   - Select: "Create New Post" (press Enter)

3. **Create Post Screen**
   - Click "MPLS" button (select category)
   - Type your title in the input field
   - Click "Create Post"

4. **Result**
   - Post created with confirmation message
   - You can now edit the post (see Example 2)

### Example 2: Manage and Edit Posts

1. **From Main Menu**
   - Select: "Manage Posts"

2. **Manage Posts Screen**
   - You'll see a table of all draft posts
   - Use arrow keys to select a post
   - Click "View Info" to see details
   - Click "Edit Post" to open in your editor
   - Click "Delete Post" to remove (with confirmation)

### Example 3: Validate Before Publishing

1. **From Main Menu**
   - Select: "Validate Content"

2. **Validate Screen**
   - Click "Validate All Drafts" for all posts
   - OR Click "Validate Specific Post" for one post
   - See validation results in output area

### Example 4: Preview Your Site

1. **From Main Menu**
   - Select: "Preview Site"

2. **Preview Screen**
   - Port shows "1313" (default)
   - Click "Start Server" to start
   - OR Click "Start with Validation" to validate first
   - Open http://localhost:1313 in your browser
   - Click "Stop Server" when done

### Example 5: Publish Your Post

1. **From Main Menu**
   - Select: "Publish Posts"

2. **Publish Screen**
   - You'll see a table of draft posts
   - Select the post you want to publish
   - Click "Publish Selected" for one post
   - OR Click "Publish All Drafts" for all
   - Automatic validation before publishing
   - See confirmation when done

### Example 6: Check Git Status

1. **From Main Menu**
   - Select: "Git Operations"

2. **Git Screen**
   - Click "Check Status" to see git status
   - Click "Pre-Push Safety Check" before pushing
   - Click "View Recent Commits" to see commit history

### Example 7: View Logs

1. **From Main Menu**
   - Select: "View Logs"

2. **Logs Screen**
   - Click on any log type (Automation, Quality Gate, etc.)
   - OR Click "All Logs (Recent)" to see everything
   - Last 50 lines shown automatically

### Example 8: Run Tests

1. **From Main Menu**
   - Select: "Run Tests"

2. **Tests Screen**
   - Click "Phase 1 Tests" for basic tests
   - Click "Phase 2 Tests" for enhanced scripts
   - Click "All Tests" for complete test suite
   - See test results in output area

---

## 🎨 Screen Layout

Each screen follows a consistent layout:

```
┌─────────────────────────────────────┐
│     SCREEN TITLE (centered)          │
├─────────────────────────────────────┤
│                                     │
│         [Button 1]                   │
│         [Button 2]                   │
│         [Button 3]                   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │   Output / Status Area      │   │
│  │   (scrollable if needed)    │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ✓ Status / Info / Warning         │
└─────────────────────────────────────┘
```

---

## 🔧 Troubleshooting

### "Textual is not installed"

**Solution:**
```bash
pip install textual
```

### "Python 3 is not installed"

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Arch Linux
sudo pacman -S python
```

### TUI looks weird / colors wrong

**Solution:** Make sure your terminal supports colors:
- Linux: Most terminals work (gnome-terminal, konsole, etc.)
- macOS: Terminal.app or iTerm2
- Windows: Use Windows Terminal or Git Bash

### Can't click with mouse

**Solution:** Check that your terminal supports mouse:
- Most modern terminals do
- If not, use keyboard navigation (Tab, Enter, Arrows)

### Script execution fails

**Solution:** Check that bash scripts are executable:
```bash
chmod +x scripts/*.sh
```

---

## 🆚 TUI vs Command Line

| Task | Command Line | TUI |
|------|--------------|-----|
| Create Post | `./scripts/create-post.sh mpls "Title"` | Click buttons |
| Validate | `./scripts/quality-gate.sh validate file.md` | Click "Validate" |
| Preview | `./scripts/preview.sh --validate` | Click "Start Server" |
| Publish | `./scripts/publish-drafts.sh file.md --validate` | Click "Publish" |
| View Logs | `cat logs/automation.log` | Click "View Logs" |

**TUI Advantages:**
- ✅ No need to remember commands
- ✅ Visual feedback
- ✅ Easier for beginners
- ✅ Interactive tables
- ✅ Real-time status updates

**Command Line Advantages:**
- ✅ Faster for experienced users
- ✅ Scriptable
- ✅ Can be automated
- ✅ Works over SSH without TUI support

---

## 💡 Tips and Tricks

### Tip 1: Quick Access

Create an alias for quick access:
```bash
# Add to your ~/.bashrc or ~/.zshrc
alias blog-tui='./scripts/tui'
alias blog='./scripts/tui'

# Now just type:
blog
```

### Tip 2: Keep TUI Running

Keep the TUI open while you work:
1. Start the TUI
2. Preview your site
3. Leave TUI running
4. Edit posts in another terminal
5. Come back to TUI to validate/publish

### Tip 3: Use for Content Creation Workflow

1. Create post in TUI
2. Edit in your editor (VS Code, etc.)
3. Validate in TUI
4. Preview in TUI
5. Publish in TUI
6. Commit in TUI (check status)
7. Push via command line (manual safety step)

### Tip 4: Check Logs Often

After any operation:
- Click "View Logs" in main menu
- See "All Logs (Recent)" for everything
- Helps debug issues

### Tip 5: Run Tests Regularly

After making changes:
- Click "Run Tests" in main menu
- Run "All Tests" for complete validation
- Fix any issues before publishing

---

## 🎓 Learning Path

### Beginner (Non-Techie)
1. Start with TUI exclusively
2. Learn the screens and buttons
3. Create a test post
4. Go through the complete workflow
5. Delete test post and try again

### Intermediate
1. Use TUI for most operations
2. Learn command-line for speed
3. Understand what each script does
4. Check logs to understand operations

### Advanced
1. Use command line for speed
2. Use TUI for complex operations
3. Customize scripts
4. Extend TUI with new features

---

## 🔐 Safety Features

The TUI includes all safety features from the automation:

- ✅ **Automatic validation** before publishing
- ✅ **Backup creation** before modifications
- ✅ **Pre-push safety checks** in git screen
- ✅ **Draft mode** by default (won't publish accidentally)
- ✅ **Confirmation prompts** for destructive actions
- ✅ **Comprehensive logging** of all actions

---

## 📞 Getting Help

### Inside the TUI

Each screen has:
- Clear labels and buttons
- Status messages (green for success, red for errors)
- Output areas with detailed information

### Documentation

- `CLAUDE.md` - Full automation documentation
- `TUI-GUIDE.md` - This file
- Script help: `./scripts/script-name.sh --help`

### Troubleshooting

1. Check the output area in the TUI
2. View logs (View Logs → All Logs)
3. Run tests (Run Tests → All Tests)
4. Check this guide's troubleshooting section

---

## 🚀 Next Steps

Now that you know how to use the TUI:

1. **Create your first post** using the TUI
2. **Go through the complete workflow**
3. **Experiment with all screens**
4. **Check logs** to understand what's happening
5. **Run tests** to ensure everything works

Happy blogging! 🎉
