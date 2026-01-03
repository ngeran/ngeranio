# 🖥️ Blog Automation TUI - Quick Start

## What is this?

A **Terminal User Interface (TUI)** for your blog automation - like an app, but in your terminal! No need to memorize commands.

---

## 🚀 3-Step Setup

### 1️⃣ Install Textual (One-Time)

```bash
pip install textual
```

### 2️⃣ Launch the TUI

```bash
./scripts/tui
```

### 3️⃣ Use the Interface!

Navigate with **arrow keys** or **mouse**, press **Enter** to select.

---

## 📱 What You Can Do

```
┌───────────────────────────────────────┐
│   📝 NGERAN[IO] BLOG AUTOMATION       │
│   Choose an action:                   │
├───────────────────────────────────────┤
│                                       │
│   [Create New Post]                   │
│   [Manage Posts]                      │
│   [Validate Content]                  │
│   [Preview Site]                      │
│   [Publish Posts]                     │
│   [Git Operations]                    │
│   [View Logs]                         │
│   [Run Tests]                         │
│   [Exit]                              │
│                                       │
└───────────────────────────────────────┘
```

**Create Post** → Click category → Type title → Done!
**Manage Posts** → See table → Click to edit/delete
**Validate** → Click "Validate All" → See results
**Preview** → Click "Start" → Open http://localhost:1313
**Publish** → Select post → Click "Publish" → Live!

---

## 🎮 Controls

| Key | Action |
|-----|--------|
| **↑↓←→** | Navigate |
| **Enter** | Select |
| **Tab** | Next field |
| **Esc** | Back |
| **q** | Quit |
| **Mouse** | Click buttons! |

---

## 📚 Full Documentation

See **`TUI-GUIDE.md`** for complete guide with:
- Step-by-step examples
- All screens explained
- Troubleshooting
- Tips & tricks

---

## ✨ Why Use the TUI?

❌ **Command Line:** Remember all commands and flags
✅ **TUI:** Just click buttons!

❌ **Command Line:** Hard for beginners
✅ **TUI:** Easy for everyone!

❌ **Command Line:** No visual feedback
✅ **TUI:** Real-time status updates

---

## 🎯 Example Workflow

1. `./scripts/tui` → Launch
2. Click **"Create New Post"**
3. Click **"MPLS"** → Type: "My MPLS Post"
4. Click **"Create Post"** → Done!
5. Click **"Back"** → Main Menu
6. Click **"Preview Site"** → Click **"Start Server"**
7. Open browser → http://localhost:1313 → See your post!
8. Click **"Stop Server"** → Done!

All without typing a single command! 🎉

---

**Ready? Run `./scripts/tui` now!**
