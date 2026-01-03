# 🎉 New TUI Features - Complete Guide

## What's New?

Your TUI has been upgraded with powerful new features for complete blog management!

---

## ✨ New Features Overview

### 1️⃣ **Quit Button (Top Right)**
- **Location**: Top navigation bar, right side
- **Icon**: ✕ Quit
- **Function**: One-click exit from TUI
- **Shortcut**: Press Q or Ctrl+C

### 2️⃣ **View & Edit Posts**
- **Access**: Click "Posts" tab OR press Ctrl+V
- **Features**:
  - View ALL posts (drafts and published)
  - Filter by: All / Drafts Only / Published Only
  - Preview posts with markdown rendering
  - Edit posts in external editor
  - Open directly in VS Code/vim/nano

### 3️⃣ **Create New Categories**
- **Access**: Press Ctrl+K
- **Features**:
  - Enter category name
  - See existing categories
  - Auto-creates directory structure
  - Validates category doesn't exist

### 4️⃣ **Markdown Preview**
- **Access**: View Posts → Select post → Click "Preview"
- **Features**:
  - Full markdown rendering
  - Scrollable content
  - Shows post title
  - Edit button for quick access

### 5️⃣ **Edit Posts**
- **Options**:
  1. **Edit** button - Shows file path
  2. **Open in Editor** - Launches VS Code/vim/nano
  3. **Preview** → **Edit** - From preview screen

---

## 🎮 Complete Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| **Ctrl+N** | Create new post |
| **Ctrl+V** | View & edit posts |
| **Ctrl+K** | Create new category |
| **Ctrl+R** | Refresh current view |
| **Ctrl+P** | Preview site |
| **Q** | Quit TUI |
| **Ctrl+C** | Quit TUI |
| **Esc** | Close modal/go back |

---

## 📖 Detailed Usage Guides

### **Guide 1: View Existing Posts**

**Option A: Click "Posts" Tab**
1. Click "✍️ Posts" in top navigation
2. Modal opens with all posts
3. See status icon: 📋 (draft) or ✅ (published)

**Option B: Keyboard Shortcut**
1. Press Ctrl+V
2. Modal opens instantly

**Filter Posts:**
- **All Posts** - Show everything
- **Drafts Only** - Show only 📋 posts
- **Published Only** - Show only ✅ posts

**Post Information:**
- Title
- Category (OSPF, BGP, MPLS, etc.)
- Full path to file

---

### **Guide 2: Preview & Edit Posts**

**Step 1: View Posts**
- Press Ctrl+V OR click "Posts" tab

**Step 2: Select Post**
- Use arrow keys to select a row
- Selected row is highlighted

**Step 3: Choose Action**

**Option A: Preview (📖)**
- Click "Preview" button
- See full markdown rendering
- Scroll to read content
- Click "Edit" from preview to modify

**Option B: Edit (✏️)**
- Click "Edit" button
- Shows full file path
- Open manually in your editor

**Option C: Open in Editor (📁)**
- Click "Open in Editor" button
- Automatically tries editors in order:
  1. VS Code (code)
  2. Vim
  3. Nano
  4. Vi
- Opens the first available editor

---

### **Guide 3: Create New Category**

**Step 1: Open Category Creator**
- Press Ctrl+K

**Step 2: Enter Category Name**
- Type name: e.g., "Network Automation"
- Case-insensitive
- Spaces allowed

**Step 3: See Info**
- Existing categories shown
- Path will be: `content/routing/[category-name]/`

**Step 4: Create**
- Click "Create Category"
- Directory created automatically
- Success message shown

**Example:**
```
Input: Network Automation
Created: content/routing/network automation/
```

---

### **Guide 4: Edit Post Workflow**

**Complete Workflow:**

1. **Press Ctrl+V** - View all posts
2. **Select post** - Use arrow keys
3. **Click "Open in Editor"** - Launches VS Code
4. **Edit in VS Code** - Make changes
5. **Save file** - :w in vim or Ctrl+S in VS Code
6. **Go back to TUI** - See your changes
7. **Click "Preview"** - See markdown rendering
8. **Done!**

---

## 🎯 New UI Elements

### **Top Navigation Bar**
```
┌────────────────────────────────────────────────┐
│ 🏠 | ✍️ | 🔧 | 🤖 | 📦 | ⚙️         | ✕ Quit │
│ Dash Posts Auto AI   Git Settings              │
└────────────────────────────────────────────────┘
```

- **New**: Quit button on right
- **Spacer**: Pushes quit button to edge

### **Status Bar (Bottom)**
```
┌────────────────────────────────────────────────┐
│ 📊 15 posts | ✓ 11 published | ⚠ 4 drafts     │
│ ^Q Quit | ^N New Post | ^V View Posts | ...   │
└────────────────────────────────────────────────┘
```

- **Left**: Live statistics
- **Right**: All keyboard shortcuts

---

## 📝 View Posts Modal

### **Layout**
```
┌────────────────────────────────────────────────┐
│ ✍️ View & Edit Posts                    ×     │
├────────────────────────────────────────────────┤
│ [All Posts] [Drafts Only] [Published Only]    │
├────────────────────────────────────────────────┤
│ Status | Title        | Category | Path       │
│ 📋      | MPLS Labels | MPLS     | content/... │
│ ✅      | BGP Basics  | BGP      | content/... │
├────────────────────────────────────────────────┤
│ [📖 Preview] [✏️ Edit] [📁 Open] [Close]        │
└────────────────────────────────────────────────┘
```

### **Features**
- **Filter buttons** - Toggle between all/drafts/published
- **DataTable** - Sortable, scrollable table
- **Action buttons** - Preview, edit, open in editor

---

## 📖 Markdown Preview Modal

### **Layout**
```
┌────────────────────────────────────────────────┐
│ 📖 Preview: MPLS Label Switching        ×     │
├────────────────────────────────────────────────┤
│ Title: MPLS Label Switching                    │
│ Path: content/routing/mpls/...                │
├────────────────────────────────────────────────┤
│ [✕ Close] [✏️ Edit]                           │
├────────────────────────────────────────────────┤
│ # MPLS Label Switching                         │
│ ## Introduction                                │
│ Full markdown content rendered beautifully...  │
│                                                │
│ (scrollable)                                   │
└────────────────────────────────────────────────┘
```

### **Features**
- **Title display** - Shows post title
- **Path** - Full file path
- **Markdown rendering** - Full content preview
- **Edit button** - Open in editor
- **Scrollable** - Read long posts easily

---

## 📁 Create Category Modal

### **Layout**
```
┌────────────────────────────────────────────────┐
│ 📁 Create New Category                   ×     │
├────────────────────────────────────────────────┤
│ Enter the name for your new category           │
│ Existing categories: bgp, mpls, ospf, junos    │
├────────────────────────────────────────────────┤
│ Category Name: [_________________]             │
│ Category will be created as:                   │
│ content/routing/[category-name]/               │
├────────────────────────────────────────────────┤
│ [Create Category] [Cancel]                     │
├────────────────────────────────────────────────┤
│ ✓ Category created successfully                │
│ Created: content/routing/network automation/  │
└────────────────────────────────────────────────┘
```

---

## 💡 Pro Tips

### **Tip 1: Quick Post Editing**
```
Ctrl+V → Select Post → Open in Editor → Edit → Save → Preview
```

### **Tip 2: Filter Efficiently**
- Use "All Posts" to see everything
- Use "Drafts Only" to find work-in-progress
- Use "Published Only" to review live content

### **Tip 3: Create Category First**
1. Press Ctrl+K
2. Create new category
3. Press Ctrl+N
4. New category available for selection!

### **Tip 4: Preview Before Publishing**
1. Edit your post
2. Ctrl+V to view posts
3. Preview to see rendered markdown
4. Make sure it looks good
5. Publish when ready

### **Tip 5: Editor Integration**
- **VS Code users**: "Open in Editor" launches VS Code
- **Vim users**: Opens vim automatically
- **Nano users**: Opens nano automatically
- Falls back to showing path if no editor found

---

## 🔄 Complete Workflows

### **Workflow 1: Create Post in New Category**

1. **Create Category**: Ctrl+K
   - Enter: "Data Center"
   - Click: Create Category

2. **Create Post**: Ctrl+N
   - Select: Not in list? Create category first!
   - Or choose from existing

3. **Edit Post**: Ctrl+V → Open in Editor
   - VS Code opens automatically
   - Write your content

4. **Preview**: Ctrl+V → Preview
   - See how it looks
   - Make changes if needed

5. **Done!**

---

### **Workflow 2: Review All Published Posts**

1. **View Posts**: Ctrl+V

2. **Filter**: Click "Published Only"

3. **Review**: Use arrow keys to browse

4. **Preview**: Click Preview on any post

5. **Edit if needed**: Click Edit from preview

---

### **Workflow 3: Update Old Post**

1. **Find Post**: Ctrl+V

2. **Locate**: Use arrow keys or scan titles

3. **Open**: Click "Open in Editor"

4. **Edit**: Make changes in VS Code

5. **Save**: Save file

6. **Preview**: Back to TUI, preview changes

7. **Done!**

---

## 🎨 Visual Improvements

### **Quit Button**
- Red color (error variant)
- Right-aligned
- Clear ✕ icon
- Cannot be missed

### **Status Icons**
- 📋 = Draft post
- ✅ = Published post
- Easy visual identification

### **Filter Buttons**
- Primary variant for active filter
- Side by side for easy switching
- Clear visual feedback

---

## 🚀 Advanced Usage

### **For Power Users**

**Memorize Shortcuts:**
- Ctrl+V - Most used (view posts)
- Ctrl+N - Second most used (create)
- Ctrl+K - When expanding blog
- Ctrl+R - Refresh often

**Editor Integration:**
- Set `EDITOR` environment variable
- TUI will use your preferred editor
- Example: `export EDITOR=code`

**Workflow Optimization:**
1. Keep TUI open
2. Edit in VS Code
3. Refresh TUI (Ctrl+R)
4. Preview changes
5. Repeat

---

## 🔧 Troubleshooting

### **Issue: Editor Not Opening**

**Solution:**
```bash
# Install VS Code
sudo apt install code

# Or set vim as default
export EDITOR=vim

# Or edit manually
# TUI shows full path when "Edit" clicked
```

### **Issue: Category Already Exists**

**Solution:**
- TUI shows error message
- Check existing categories list
- Use different name or existing category

### **Issue: Can't See All Posts**

**Solution:**
- Click "All Posts" filter
- Use arrow keys to scroll
- Check status bar for post count

---

## 📚 Summary

### **New Features:**
✅ Quit button in top nav
✅ View all posts (drafts + published)
✅ Filter posts by status
✅ Create new categories
✅ Markdown preview
✅ Edit in external editor
✅ VS Code integration

### **New Shortcuts:**
- Ctrl+V - View posts
- Ctrl+K - New category
- Updated status bar

### **Benefits:**
- Complete post management
- Visual workflow
- Professional editor integration
- Full markdown preview
- Category flexibility

---

## 🎉 Enjoy!

Your TUI is now a **complete blog management system**! 🚀

**Remember:**
- **Ctrl+V** - View & manage posts
- **Ctrl+K** - Create categories
- **Click ✕** - Quit anytime

Happy blogging! ✨
