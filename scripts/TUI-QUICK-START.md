# 🚀 TUI Quick Start Guide

## File Structure (Simple & Clean)

```
ngeranio/
│
├── scripts/
│   ├── tui.py                    ← Main application (1712 lines)
│   ├── tui.css                   ← All styling (638 lines)
│   ├── TUI-STRUCTURE.md          ← Detailed architecture
│   └── TUI-QUICK-START.md        ← This file
│
└── content/                      ← Your blog content
```

## 📝 Code Organization (tui.py)

```
Lines 1-50:      Imports & Config
Lines 52-200:    Utility Functions
Lines 202-336:   Navigation & Sidebar
Lines 338-530:   Main Content Area
Lines 532-890:   Modal Screens
Lines 892-1280:  View Methods
Lines 1282-1712: Main App Class
```

## 🎯 Quick Reference

### Starting the TUI
```bash
./scripts/tui
# or
python3 scripts/tui.py
```

### File Management
```
Click "➕ Add"    → Create file/folder
Click "✏️ Rename" → Rename selected item
Click "🗑️ Delete" → Delete selected item (type "DELETE" to confirm)
```

### Editing
```
Click any file      → Opens in editor
Click "👁 Preview"   → Toggle split view
Click "💾 Save"      → Save (or Ctrl+S)
Click "✕ Close"      → Close editor
```

### Navigation
```
Dashboard   → Overview & stats
Posts       → Browse blog posts
Automation  → Run scripts
Git         → Git operations
Settings    → Configuration
```

## ⌨️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl+N` | New post |
| `Ctrl+S` | Save file |
| `Ctrl+V` | View posts |
| `Ctrl+R` | Refresh |
| `Esc` | Close modal/editor |
| `Q` | Quit app |

## 🎨 Styling

Edit `scripts/tui.css` to customize:
- Colors (Nord theme)
- Layout
- Fonts
- Animations

**No Python changes needed!**

## 🔧 Common Tasks

### Add New Feature
1. Create modal screen in `screens` section (lines 532-890)
2. Add styling in `tui.css`
3. Wire up button handler
4. Test!

### Change Colors
Edit `scripts/tui.css`:
```css
/* Nord theme colors */
--bg-dark: #2e3440;
--bg-light: #3b4252;
--accent: #88c0d0;
--border: #616e88;
```

### Debug File Operations
Check logs: `tail -f logs/automation.log`

## 📊 Key Classes

| Class | Purpose | Lines |
|-------|---------|-------|
| `FileTree` | Sidebar file explorer | 243-336 |
| `ContentArea` | Main content editor | 338-530 |
| `AddItemModal` | Create files/folders | 588-720 |
| `RenameItemModal` | Rename items | 723-799 |
| `DeleteItemModal` | Delete items | 802-888 |
| `BlogAutomationApp` | Main app | 1282-1712 |

## 🎓 Learning Path

1. **Read TUI-STRUCTURE.md** - Understand architecture
2. **Explore tui.py** - Start with widget classes
3. **Customize tui.css** - Try changing colors
4. **Add a feature** - Create a simple modal
5. **Contribute** - Share improvements!

## 💡 Tips

- **Keep it simple** - Don't over-engineer
- **Use existing patterns** - Copy from similar features
- **Test file ops** - Always test with dummy files first
- **Read the docs** - Check Textual docs for widgets
- **Git commit often** - Easy to rollback if needed

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| CSS not loading | Check `tui.css` path in `CSS_PATH` |
| File operations fail | Check file permissions |
| Tree not refreshing | Call `populate_tree()` |
| Modal too large | Adjust width in `tui.css` |
| Colors wrong | Check Nord theme palette |

## 📚 Resources

- **Textual Docs**: https://textual.textual.io/
- **Nord Theme**: https://nordtheme.com/
- **Project Docs**: See `CLAUDE.md` in project root

## 🎉 You're Ready!

Start the TUI and explore:
```bash
./scripts/tui
```

**Happy coding!** 🚀
