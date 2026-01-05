# NGERAN[IO] TUI - Architecture & Structure

## Overview
A modern, VS Code-inspired Terminal User Interface for managing your Hugo blog automation.

## File Structure

```
ngeranio/
├── scripts/
│   ├── tui.py                 # Main TUI application (1712 lines)
│   ├── tui.css                # All styling (638 lines)
│   └── TUI-STRUCTURE.md       # This documentation
```

## Application Architecture

### 1. **Entry Point** (Line 1-50)
- Imports and configuration
- Project root detection
- Constants and settings

### 2. **Helper Classes** (Lines 52-200)
- `NiceOutput` - Styled text output widget
- `NiceStatus` - Status message widget (success/error/warning)
- `NiceModal` - Base class for modal screens

### 3. **UI Components**

#### Navigation (Lines 202-241)
- `TopNav` - Top navigation bar with tabs
- Routes: Dashboard, Posts, Automation, AI Agent, Git, Settings

#### Sidebar - File Explorer (Lines 243-336)
- `FileTree` - Left sidebar with project files
- File operations: Add, Rename, Delete
- Tree view with folders and files
- Icons for visual clarity

#### Main Content Area (Lines 338-530)
- `ContentArea` - Main content container
- RichLog for displaying information
- Inline editor with markdown preview
- Split-view editing

### 4. **Modal Screens** (Lines 532-890)

#### Blog Management
- `CreatePostScreen` - Create new blog posts
- `CreateCategoryScreen` - Create new categories
- `EditPostScreen` - Edit existing posts

#### File Management (NEW)
- `AddItemModal` - Add files/folders with type toggle
- `RenameItemModal` - Rename files or folders
- `DeleteItemModal` - Delete with confirmation

#### Automation
- `RunAutomationScreen` - Run automation scripts
- Other automation modals

### 5. **Main Application** (Lines 1282-1712)
- `BlogAutomationApp` - Main app class
- View routing and navigation
- File operations
- Dashboard views
- Integration with automation scripts

## Key Features

### ✨ File Management
- **Add**: Click "➕ Add" → choose File/Folder → enter details
- **Rename**: Select item → click "✏️ Rename" → enter new name
- **Delete**: Select item → click "🗑️ Delete" → type "DELETE" to confirm

### 📝 Content Editing
- **Open**: Click any file in sidebar
- **Edit**: Full markdown editor with syntax highlighting
- **Preview**: Toggle split view (editor + rendered markdown)
- **Save**: Click 💾 Save or press Ctrl+S

### 🎨 Navigation
- **Dashboard**: Overview and statistics
- **Posts**: Browse and manage blog posts
- **Automation**: Run automation scripts
- **Git**: Git operations
- **Settings**: Configuration

### ⌨️ Keyboard Shortcuts
- `Ctrl+N` - New post
- `Ctrl+S` - Save file
- `Ctrl+V` - View posts
- `Ctrl+R` - Refresh
- `Esc` - Close modal/editor
- `Q` - Quit

## Styling (Nord Theme)

All styling is in `scripts/tui.css` (638 lines):
- Color palette: #2e3440, #3b4252, #88c0d0, #616e88
- Clean, minimalistic design
- Dark mode optimized
- Smooth transitions and hover effects

## Data Flow

```
User Action → Event Handler → Modal/Widget → Update UI → Refresh File Tree
```

### Example: Creating a File
1. User clicks "➕ Add" in sidebar
2. `FileTree.on_click()` handles event
3. `AddItemModal` screen is pushed
4. User enters details and clicks "Create"
5. `AddItemModal.on_button_pressed()` processes request
6. File system operations execute
7. `FileTree.populate_tree()` refreshes the view
8. Modal closes with success message

## Best Practices

### Adding New Features
1. Create modal in screens section
2. Add styling in tui.css
3. Wire up event handler in parent widget
4. Test with file operations

### Modifying Styling
- Edit `scripts/tui.css`
- No need to touch Python code
- Changes apply on restart

### Debugging
- Check logs in `/home/nikos/github/ngeran/ngeranio/logs/`
- Use RichLog for debugging output
- Test file operations carefully

## Future Improvements

- [ ] Split into multiple files (widgets, screens, app)
- [ ] Add more keyboard shortcuts
- [ ] Implement hot-reload for CSS
- [ ] Add tests for file operations
- [ ] Create plugin system for extensions
- [ ] Add theme switcher (light/dark)

## Quick Reference

### Important Constants
- `PROJECT_ROOT` - Project root directory
- `SCRIPT_DIR` - Scripts directory location

### Key Methods
- `populate_tree()` - Refresh file tree
- `open_file_in_content()` - Open file for editing
- `change_view()` - Switch between views
- `show_dashboard()` - Display dashboard

### File Operations
- `Path.touch()` - Create file
- `Path.mkdir()` - Create directory
- `Path.rename()` - Rename item
- `Path.unlink()` - Delete file
- `shutil.rmtree()` - Delete directory
