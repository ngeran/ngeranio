# 🚀 TUI Quick Setup Guide

## One Command to Rule Them All!

Just run this command:

```bash
./scripts/tui
```

**That's it!** The script will:
1. ✅ Check for Python
2. ✅ Create a virtual environment automatically
3. ✅ Install all dependencies (Textual)
4. ✅ Launch the TUI

---

## 📋 What Happens

### First Time Setup (Automatic)

When you run `./scripts/tui` for the first time:

```
============================================
NGERAN[IO] AUTOMATION TUI
============================================

✓ Python 3.x.x found
ℹ Checking Python venv module...
✓ Python venv module available
ℹ Setting up virtual environment...
ℹ Creating new virtual environment at .venv/...
✓ Virtual environment created
ℹ Activating virtual environment...
✓ Virtual environment activated
ℹ Upgrading pip...
✓ pip upgraded
ℹ Installing dependencies...
✓ Dependencies installed
ℹ Verifying Textual installation...
✓ Textual x.x.x installed
============================================
LAUNCHING TUI
============================================

✓ All setup complete!
To stop the TUI: Press 'q' or Ctrl+C
To restart: Run './scripts/tui' again

Starting TUI...
```

### Subsequent Launches (Instant)

After the first setup, subsequent launches are instant:

```
============================================
NGERAN[IO] AUTOMATION TUI
============================================

Virtual environment found
✓ Textual x.x.x ready

Launching TUI...
```

---

## 🎯 How It Works

### The Smart Launcher

The `./scripts/tui` script is smart:

1. **First run**: Calls `setup-tui.sh` to create venv + install dependencies
2. **Future runs**: Uses the existing venv, launches instantly

### Virtual Environment

- **Location**: `.venv/` in your project root
- **Isolated**: Dependencies don't affect system Python
- **Ignored**: `.venv/` is in `.gitignore` (won't be committed)

---

## 🔧 Manual Setup (Optional)

If you want to run setup manually:

```bash
# Run the setup script directly
./scripts/setup-tui.sh

# This will:
# - Create .venv/ if it doesn't exist
# - Install textual
# - Launch the TUI
```

---

## 🗑️ Clean Start (If Needed)

If something goes wrong, start fresh:

```bash
# Remove the virtual environment
rm -rf .venv

# Run TUI again (will recreate everything)
./scripts/tui
```

---

## 📁 What Gets Created

```
ngeranio/
├── .venv/                    # ← Virtual environment (auto-created)
│   ├── bin/
│   │   ├── python3           # Python in venv
│   │   ├── pip               # Pip in venv
│   │   └── activate          # Activation script
│   └── lib/
│       └── python3.x/
│           └── site-packages/
│               └── textual/   # ← Textual installed here
│
├── scripts/
│   ├── tui                   # ← Smart launcher
│   ├── setup-tui.sh          # ← Setup script
│   ├── automation-tui.py     # ← TUI application
│   └── requirements.txt      # ← Dependencies
│
└── .gitignore                # ← .venv/ is ignored
```

---

## ✅ Prerequisites

### Required:

1. **Python 3.7+**
   ```bash
   python3 --version
   ```

2. **python3-venv module**
   ```bash
   # Check if available
   python3 -c "import venv"

   # If not available:
   # Ubuntu/Debian:
   sudo apt install python3-venv

   # macOS: Should be included with python3
   # Arch:
   sudo pacman -S python-pip
   ```

### NOT Required:

- ❌ pip (not needed system-wide)
- ❌ sudo (venv is in your home directory)
- ❌ system-wide packages

---

## 🎮 Usage

### Start TUI:

```bash
./scripts/tui
```

### Stop TUI:

- Press `q`
- Or press `Ctrl+C`

### Restart TUI:

```bash
./scripts/tui
```

---

## 🆚 Old vs New Approach

### Old (Required pip):

```bash
# ❌ Needed system-wide pip
pip install textual

# ❌ Might need sudo
sudo pip3 install textual

# ❌ System-wide installation
./scripts/tui
```

### New (Virtual Environment):

```bash
# ✅ Just run it!
./scripts/tui

# ✅ Everything happens automatically
# ✅ No sudo needed
# ✅ Isolated dependencies
```

---

## 🐛 Troubleshooting

### "python3-venv not found"

```bash
# Ubuntu/Debian:
sudo apt install python3-venv

# Then try again:
./scripts/tui
```

### "Permission denied"

```bash
# Make scripts executable:
chmod +x scripts/tui
chmod +x scripts/setup-tui.sh

# Then try again:
./scripts/tui
```

### "Textual installation failed"

```bash
# Remove venv and try again:
rm -rf .venv
./scripts/tui
```

### TUI doesn't start

```bash
# Check Python version:
python3 --version  # Should be 3.7+

# Check venv exists:
ls -la .venv/

# Re-run setup:
rm -rf .venv
./scripts/tui
```

---

## 💡 Tips

### 1. Alias for Quick Access

Add to `~/.bashrc` or `~/.zshrc`:

```bash
alias blog='cd /path/to/ngeranio && ./scripts/tui'
```

Then just type:
```bash
blog
```

### 2. Always Use ./scripts/tui

Even after setup, always use:
```bash
./scripts/tui
```

It will automatically:
- Activate venv
- Check dependencies
- Launch TUI

### 3. Don't Commit .venv

The `.venv/` directory is already in `.gitignore`, so it won't be committed to git.

Each developer runs `./scripts/tui` to create their own local venv.

---

## 📦 What Gets Installed

Only one Python package:

- **textual** (>= 0.50.0) - TUI framework

That's it! Minimal dependencies.

---

## 🚀 Ready?

Just run:

```bash
./scripts/tui
```

**First run**: ~30 seconds (creates venv + installs)
**Subsequent runs**: < 1 second (instant launch)

Happy blogging! 🎉
