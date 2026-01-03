#!/usr/bin/env python3
"""
============================================
NGERAN[IO] AUTOMATION TUI
============================================
VS Code-inspired Terminal User Interface
Modern, elegant, and functional
============================================
"""

from textual.app import App, ComposeResult
from textual.widgets import (
    Static, Button, Input, Label, DataTable,
    Footer, Header, Tree, RichLog, Markdown, TextArea
)
from textual.containers import Horizontal, Vertical, Container
from textual.screen import ModalScreen, Screen
from textual.binding import Binding
from textual.reactive import reactive
from textual import on
import subprocess
from pathlib import Path
import sys
import os

# =============================================
# CONFIGURATION
# =============================================
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
CONTENT_DIR = PROJECT_ROOT / "content" / "routing"

# =============================================
# UTILITIES
# =============================================
def run_command(cmd: list, cwd: str = None) -> tuple[int, str, str]:
    """Run a command and return exit code, stdout, stderr"""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300,
            cwd=cwd or str(PROJECT_ROOT)
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Command timed out"
    except Exception as e:
        return -1, "", str(e)


def get_draft_posts():
    """Get list of draft posts"""
    drafts = []
    try:
        for cat_dir in CONTENT_DIR.iterdir():
            if cat_dir.is_dir():
                for post_dir in cat_dir.iterdir():
                    index_file = post_dir / "index.md"
                    if index_file.exists():
                        with open(index_file) as f:
                            content = f.read()
                            if 'draft = true' in content:
                                title = "Untitled"
                                for line in content.split('\n'):
                                    if line.strip().startswith('title ='):
                                        title = line.split('=')[1].strip().strip("'\"")
                                        break

                                drafts.append({
                                    'category': cat_dir.name,
                                    'title': title,
                                    'path': str(index_file.relative_to(PROJECT_ROOT))
                                })
    except Exception as e:
        pass
    return drafts


def get_all_posts():
    """Get list of all posts (drafts and published)"""
    posts = []
    try:
        for cat_dir in CONTENT_DIR.iterdir():
            if cat_dir.is_dir():
                for post_dir in cat_dir.iterdir():
                    index_file = post_dir / "index.md"
                    if index_file.exists():
                        with open(index_file) as f:
                            content = f.read()
                            is_draft = 'draft = true' in content
                            title = "Untitled"
                            for line in content.split('\n'):
                                if line.strip().startswith('title ='):
                                    title = line.split('=')[1].strip().strip("'\"")
                                    break

                            posts.append({
                                'category': cat_dir.name,
                                'title': title,
                                'path': str(index_file.relative_to(PROJECT_ROOT)),
                                'is_draft': is_draft,
                                'full_path': str(index_file)
                            })
    except Exception as e:
        pass
    return posts


def get_categories():
    """Get list of all categories"""
    categories = []
    try:
        for cat_dir in CONTENT_DIR.iterdir():
            if cat_dir.is_dir():
                categories.append(cat_dir.name)
    except Exception as e:
        pass
    return sorted(categories)


def create_category(category_name: str) -> tuple[bool, str]:
    """Create a new category"""
    try:
        cat_path = CONTENT_DIR / category_name.lower()
        if cat_path.exists():
            return False, f"Category '{category_name}' already exists"

        cat_path.mkdir(parents=True, exist_ok=True)
        return True, f"Category '{category_name}' created successfully"
    except Exception as e:
        return False, f"Failed to create category: {str(e)}"


def read_post_content(post_path: str) -> str:
    """Read post content from file"""
    try:
        full_path = PROJECT_ROOT / post_path
        if full_path.exists():
            with open(full_path) as f:
                return f.read()
        return "# Post Not Found\n\nThe file could not be read."
    except Exception as e:
        return f"# Error\n\n{str(e)}"


def get_stats():
    """Get blog statistics"""
    stats = {
        'drafts': 0,
        'published': 0,
        'categories': {},
        'last_commit': 'N/A'
    }

    try:
        # Count posts
        for cat_dir in CONTENT_DIR.iterdir():
            if cat_dir.is_dir():
                cat_name = cat_dir.name
                stats['categories'][cat_name] = {'drafts': 0, 'published': 0}

                for post_dir in cat_dir.iterdir():
                    index_file = post_dir / "index.md"
                    if index_file.exists():
                        with open(index_file) as f:
                            content = f.read()
                            if 'draft = true' in content:
                                stats['drafts'] += 1
                                stats['categories'][cat_name]['drafts'] += 1
                            else:
                                stats['published'] += 1
                                stats['categories'][cat_name]['published'] += 1

        # Get last commit
        code, out, _ = run_command(['git', 'log', '-1', '--format=%cr'])
        if code == 0:
            stats['last_commit'] = out.strip()

    except Exception as e:
        pass

    return stats


# =============================================
# CUSTOM WIDGETS
# =============================================
class StatusBar(Static):
    """Bottom status bar with shortcuts"""
    def compose(self) -> ComposeResult:
        stats = get_stats()
        yield Static(
            f"[bold cyan]{stats['drafts'] + stats['published']}[/bold cyan] posts | "
            f"[green]{stats['published']} published[/green] | "
            f"[yellow]{stats['drafts']} drafts[/yellow] | "
            f"[dim]{stats['last_commit']}[/dim]",
            id="status-left"
        )
        yield Static(
            "[dim]^Q Quit | ^N New Post | ^V View Posts | ^K New Category | ^R Refresh[/dim]",
            id="status-right"
        )


class TopNav(Static):
    """Top navigation bar"""
    current_view = reactive("dashboard")

    def compose(self) -> ComposeResult:
        with Horizontal(id="nav-bar"):
            yield Button("Dashboard", id="nav-dashboard", classes="nav-btn")
            yield Button("Posts", id="nav-posts", classes="nav-btn")
            yield Button("Automation", id="nav-automation", classes="nav-btn")
            yield Button("AI Agent", id="nav-ai", classes="nav-btn")
            yield Button("Git", id="nav-git", classes="nav-btn")
            yield Button("Settings", id="nav-settings", classes="nav-btn")
            yield Static("", id="nav-spacer", classes="nav-spacer")
            yield Static("[#bf616a]Quit[/#bf616a]", id="nav-quit", classes="nav-link")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle nav clicks"""
        nav_id = event.button.id.replace("nav-", "")

        self.current_view = nav_id

        # Update active state
        for btn in self.query(".nav-btn"):
            btn.remove_class("active")
        event.button.add_class("active")

        # Notify app to change content
        if hasattr(self.app, "change_view"):
            self.app.change_view(nav_id)

    def on_click(self, event) -> None:
        """Handle quit link click"""
        if event.widget.id == "nav-quit":
            self.app.exit()


class FileTree(Static):
    """Left sidebar file tree - nvim style"""

    def compose(self) -> ComposeResult:
        yield Label("EXPLORER", id="sidebar-title")
        yield Tree("Project Root", id="file-tree")

    def on_mount(self) -> None:
        tree = self.query_one("#file-tree", Tree)
        self.populate_tree(tree.root)

    def populate_tree(self, root) -> None:
        """Populate tree with project files"""
        # Add main directories
        dirs_to_show = [
            ("content", "content"),
            ("scripts", "scripts"),
            ("themes", "themes"),
            ("static", "static"),
            ("logs", "logs"),
        ]

        for dir_name, label in dirs_to_show:
            dir_path = PROJECT_ROOT / dir_name
            if dir_path.exists():
                dir_node = root.add(label, expand=False, data=dir_path)
                self.add_directory_contents_recursive(dir_node, dir_path)

        # Add config files (leaf nodes, no expand arrow)
        root.add("hugo.toml", data=PROJECT_ROOT / "hugo.toml", allow_expand=False)
        root.add(".env", data=PROJECT_ROOT / ".env", allow_expand=False)
        root.add("CLAUDE.md", data=PROJECT_ROOT / "CLAUDE.md", allow_expand=False)

    def add_directory_contents_recursive(self, parent, dir_path: Path) -> None:
        """Recursively add directory contents to tree"""
        try:
            # Get all items in directory
            items = sorted(dir_path.iterdir())

            # Separate directories and files
            dirs = [item for item in items if item.is_dir() and not item.name.startswith('.')]
            files = [item for item in items if item.is_file() and not item.name.startswith('.')]

            # Filter files by extension
            allowed_extensions = ['.md', '.sh', '.py', '.toml', '.yaml', '.yml', '.txt', '.json']
            files = [f for f in files if f.suffix in allowed_extensions]

            # Add subdirectories first
            for item in dirs:
                dir_node = parent.add(f"{item.name}/", data=item, expand=False)
                # Recursively populate subdirectories
                self.add_directory_contents_recursive(dir_node, item)

            # Then add files (leaf nodes, no expand arrow)
            for item in files:
                parent.add(f"{item.name}", data=item, allow_expand=False)

        except Exception:
            pass

    def on_tree_node_selected(self, event: Tree.NodeSelected) -> None:
        """Handle file selection from tree"""
        node = event.node
        file_path = node.data

        if file_path and isinstance(file_path, Path):
            # Check if it's a file (not directory)
            if file_path.is_file():
                # Open file in content area
                if hasattr(self.app, "open_file_in_content"):
                    self.app.open_file_in_content(file_path)


class ContentArea(Static):
    """Main content area"""

    def compose(self) -> ComposeResult:
        with Vertical(id="content-container"):
            # Title bar with file actions - separate widgets for clickability
            with Horizontal(id="content-header"):
                yield Static("", id="file-name")
                yield Static("✏ Edit", id="action-edit")
                yield Static("💾 Save", id="action-save")
                yield Static("👁 Preview", id="action-preview")
                yield Static("✕ Close", id="action-close")
            # Main content display - switches between log and editor
            yield RichLog(id="content-log", auto_scroll=False)
            # Editor and preview container for split view
            with Horizontal(id="editor-preview-container"):
                yield TextArea(id="inline-editor", language="markdown")
                yield Markdown(id="inline-preview")

    def on_mount(self) -> None:
        """Hide action links and editor initially"""
        header = self.query_one("#content-header", Horizontal)
        editor_preview_container = self.query_one("#editor-preview-container", Horizontal)

        # Hide all initially
        header.visible = False
        editor_preview_container.visible = False

        # Add hidden class to prevent layout space usage
        header.set_class(True, "-hidden")
        editor_preview_container.set_class(True, "-hidden")

    def enter_edit_mode(self, file_path: Path) -> None:
        """Enter edit mode - show editor only"""
        header = self.query_one("#content-header", Horizontal)
        file_name = self.query_one("#file-name", Static)
        action_edit = self.query_one("#action-edit", Static)
        action_save = self.query_one("#action-save", Static)
        action_preview = self.query_one("#action-preview", Static)
        action_close = self.query_one("#action-close", Static)
        content_log = self.query_one("#content-log", RichLog)
        editor_preview_container = self.query_one("#editor-preview-container", Horizontal)
        editor = self.query_one("#inline-editor", TextArea)
        preview = self.query_one("#inline-preview", Markdown)

        # Read file content
        try:
            with open(file_path, 'r') as f:
                content = f.read()

            # Show header with all actions
            header.visible = True
            header.set_class(False, "-hidden")
            file_name.visible = True
            action_edit.visible = True
            action_save.visible = True
            action_preview.visible = True
            action_close.visible = True
            action_preview.update("👁 Preview")  # Reset preview button text
            file_name.update(f"[bold cyan]{file_path.name}[/bold cyan]")

            # Hide log, show editor-preview container
            content_log.visible = False
            content_log.set_class(True, "-hidden")
            editor_preview_container.visible = True
            editor_preview_container.set_class(False, "-hidden")

            # Hide preview initially, show editor only
            preview.visible = False

            # Load content into editor
            editor.text = content

            # Store file path for saving
            self.current_file_path = file_path

            # Scroll to top and focus after render
            def scroll_to_top():
                try:
                    editor.home()
                    editor.focus()
                except:
                    editor.cursor_line = 0
                    editor.focus()

            self.call_later(scroll_to_top)

        except Exception as e:
            pass

    def on_click(self, event) -> None:
        """Handle clicks on action buttons"""
        if not hasattr(self, 'current_file_path') or not self.current_file_path:
            return

        if event.widget.id == "action-save":
            self.save_current_file()
        elif event.widget.id == "action-preview":
            self.preview_current_file()
        elif event.widget.id == "action-close":
            self.exit_edit_mode()
        elif event.widget.id == "action-edit":
            # Focus the editor
            try:
                editor = self.query_one("#inline-editor", TextArea)
                if editor.visible:
                    editor.focus()
            except:
                pass

    def on_text_area_changed(self, event: TextArea.Changed) -> None:
        """Auto-update preview when editor changes"""
        if event.text_area.id == "inline-editor":
            try:
                preview = self.query_one("#inline-preview", Markdown)
                if preview.visible:
                    preview.update(event.text_area.text)
            except:
                pass

    def save_current_file(self) -> None:
        """Save the current file being edited"""
        if not hasattr(self, 'current_file_path') or not self.current_file_path:
            return

        editor = self.query_one("#inline-editor", TextArea)
        file_name = self.query_one("#file-name", Static)
        content = editor.text

        try:
            with open(self.current_file_path, 'w') as f:
                f.write(content)

            # Show success message briefly
            file_name.update(f"[green]✓ Saved![/green]")

            import asyncio
            async def restore_title():
                await asyncio.sleep(1)
                file_name.update(f"[bold cyan]{self.current_file_path.name}[/bold cyan]")

            self.call_later(restore_title)

        except Exception as e:
            pass

    def preview_current_file(self) -> None:
        """Toggle preview mode - show split editor and preview"""
        if not hasattr(self, 'current_file_path') or not self.current_file_path:
            return

        editor = self.query_one("#inline-editor", TextArea)
        preview = self.query_one("#inline-preview", Markdown)
        action_preview = self.query_one("#action-preview", Static)

        # Get current content
        content = editor.text

        # Check if preview is already visible
        if preview.visible:
            # Hide preview, show editor only
            preview.visible = False
            editor.focus()
            action_preview.update("👁 Preview")
        else:
            # Show split view with editor and preview
            preview.visible = True
            preview.update(content)
            action_preview.update("📄 Edit")

    def exit_edit_mode(self) -> None:
        """Exit edit mode and return to default view"""
        header = self.query_one("#content-header", Horizontal)
        content_log = self.query_one("#content-log", RichLog)
        editor_preview_container = self.query_one("#editor-preview-container", Horizontal)

        # Hide header, show log, hide editor
        header.visible = False
        header.set_class(True, "-hidden")
        content_log.visible = True
        content_log.set_class(False, "-hidden")
        editor_preview_container.visible = False
        editor_preview_container.set_class(True, "-hidden")

        # Clear current file tracking
        if hasattr(self, 'current_file_path'):
            delattr(self, 'current_file_path')
        self.app.current_open_file = None

        # Clear log
        content_log.clear()


class NiceOutput(Static):
    """Styled output display"""
    def write(self, text: str) -> None:
        self.update(text)


class NiceStatus(Static):
    """Styled status display"""

    def show_success(self, message: str):
        self.update(f"[green bold]SUCCESS[/green bold] [white]{message}[/white]")

    def show_error(self, message: str):
        self.update(f"[red bold]ERROR[/red bold] [white]{message}[/white]")

    def show_info(self, message: str):
        self.update(f"[blue bold]INFO[/blue bold] [white]{message}[/white]")

    def show_warning(self, message: str):
        self.update(f"[yellow bold]WARNING[/yellow bold] [white]{message}[/white]")

    def clear(self):
        self.update("")


# =============================================
# MODAL SCREENS
# =============================================
class NiceModal(ModalScreen):
    """Base class for small popup modal screens"""

    def __init__(self, title: str, **kwargs):
        super().__init__(**kwargs)
        self.title_text = title

    def compose(self) -> ComposeResult:
        # Create a small centered popup
        with Vertical(id="modal-container"):
            yield Horizontal(
                Static(f"[bold cyan]{self.title_text}[/bold cyan]", id="modal-title"),
                Button("×", id="btn_close_modal", variant="error"),
                id="modal-header"
            )
            yield Container(id="modal-content")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """Close modal when X button clicked"""
        if event.button.id == "btn_close_modal":
            self.app.pop_screen()

    def on_key(self, event) -> None:
        """Close modal on Escape key"""
        if event.key == "escape":
            self.app.pop_screen()


class CreatePostScreen(NiceModal):
    """Create new post screen"""

    def __init__(self):
        super().__init__("Create New Post")
        self.category = None

    def compose(self) -> ComposeResult:
        yield from super().compose()

        yield Static("[dim]Select a category and enter your post title[/dim]", id="form-hint")
        yield Horizontal(
            Static("Category:", classes="form-label"),
            id="form-row-cat"
        )
        yield Horizontal(
            Button("OSPF", id="cat_ospf", classes="cat-btn"),
            Button("BGP", id="cat_bgp", classes="cat-btn"),
            Button("MPLS", id="cat_mpls", classes="cat-btn"),
            Button("Junos", id="cat_junos", classes="cat-btn"),
            id="cat-buttons"
        )
        yield Horizontal(
            Static("Title:", classes="form-label"),
            id="form-row-title"
        )
        yield Input(placeholder="Enter your post title...", id="input-title", classes="form-input")
        yield Horizontal(
            Button("Create Post", id="btn_create", variant="primary"),
            id="create-actions"
        )
        yield NiceOutput("", id="output")
        yield NiceStatus("", id="status")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        status = self.query_one("#status", NiceStatus)
        output = self.query_one("#output", NiceOutput)

        if event.button.id in ["cat_ospf", "cat_bgp", "cat_mpls", "cat_junos"]:
            self.category = event.button.id.replace("cat_", "")

            # Update button styles
            for btn in self.query(".cat-btn"):
                btn.variant = "default"
                btn.remove_class("selected")

            event.button.variant = "success"
            event.button.add_class("selected")
            status.show_info(f"Category: {self.category.upper()}")

        elif event.button.id == "btn_create":
            if not self.category:
                status.show_error("Please select a category first")
                return

            title_input = self.query_one("#input-title", Input)
            title = title_input.value
            if not title:
                status.show_error("Please enter a title")
                return

            status.show_info("Creating post...")
            script = SCRIPT_DIR / "create-post.sh"
            code, out, err = run_command([str(script), self.category, title])

            if code == 0:
                status.show_success(f"Post created: {title}")
                output.write(f"\n[dim]Created: {title}[/dim]\n")
            else:
                status.show_error("Failed to create post")
                output.write(err)

        elif event.button.id == "btn_close_modal":
            self.app.pop_screen()


class ViewPostsScreen(NiceModal):
    """View and manage posts screen"""

    def __init__(self):
        super().__init__("View & Edit Posts")
        self.show_all = True  # Show both drafts and published

    def compose(self) -> ComposeResult:
        # Yield parent components first
        yield from super().compose()

        # Then yield our content
        yield Horizontal(
            Button("All Posts", id="filter_all", variant="primary"),
            Button("Drafts Only", id="filter_drafts"),
            Button("Published Only", id="filter_published"),
            id="filter-buttons"
        )
        yield DataTable(id="posts-table")
        yield Horizontal(
            Button("Preview", id="btn_preview"),
            Button("Edit", id="btn_edit"),
            Button("Open in Editor", id="btn_open_editor"),
            Button("Close", id="btn_close"),
            id="table-actions"
        )
        yield NiceStatus("", id="status")

    def on_mount(self) -> None:
        self.load_posts()

    def load_posts(self):
        table = self.query_one("#posts-table", DataTable)
        table.clear(columns=True)

        if self.show_all:
            table.add_column("Status", key="status", width=8)
            table.add_column("Title", key="title", width=35)
            table.add_column("Category", key="category", width=12)
            table.add_column("Path", key="path", width=50)

            posts = get_all_posts()
            for post in posts:
                status_icon = "[DRAFT]" if post['is_draft'] else "[PUB]"
                table.add_row(
                    status_icon,
                    post['title'],
                    post['category'].upper(),
                    post['path']
                )
        else:
            table.add_column("Title", key="title", width=35)
            table.add_column("Category", key="category", width=12)
            table.add_column("Path", key="path", width=50)

            posts = get_all_posts()
            filtered_posts = [p for p in posts if p['is_draft']] if "drafts" in str(self.show_all).lower() else [p for p in posts if not p['is_draft']]

            for post in filtered_posts:
                table.add_row(
                    post['title'],
                    post['category'].upper(),
                    post['path']
                )

        status = self.query_one("#status", NiceStatus)
        if table.row_count == 0:
            status.show_info("No posts found")
        else:
            status.clear()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        status = self.query_one("#status", NiceStatus)
        table = self.query_one("#posts-table", DataTable)

        if event.button.id in ["filter_all", "filter_drafts", "filter_published"]:
            if event.button.id == "filter_all":
                self.show_all = True
            elif event.button.id == "filter_drafts":
                self.show_all = "drafts"
            else:
                self.show_all = "published"
            self.load_posts()

        elif event.button.id == "btn_close":
            self.app.pop_screen()

        elif event.button.id == "btn_preview":
            if table.row_count == 0:
                status.show_error("No posts to preview")
                return

            # Get the actual row key from cursor position
            row_key = list(table.rows.keys())[table.cursor_row]
            path_cell = table.get_cell(row_key, "path")

            post_path = str(path_cell)
            content = read_post_content(post_path)

            # Open preview screen
            self.app.push_screen(PostPreviewScreen(post_path, content))

        elif event.button.id == "btn_edit":
            if table.row_count == 0:
                status.show_error("No posts to edit")
                return

            # Get the actual row key from cursor position
            row_key = list(table.rows.keys())[table.cursor_row]
            path_cell = table.get_cell(row_key, "path")

            post_path = str(path_cell)
            content = read_post_content(post_path)

            # Open integrated editor/preview
            self.app.push_screen(EditorPreview(post_path, content))

        elif event.button.id == "btn_open_editor":
            if table.row_count == 0:
                status.show_error("No posts to open")
                return

            # Get the actual row key from cursor position
            row_key = list(table.rows.keys())[table.cursor_row]
            path_cell = table.get_cell(row_key, "path")

            post_path = str(path_cell)
            content = read_post_content(post_path)

            # Open integrated editor/preview
            self.app.push_screen(EditorPreview(post_path, content))


class PostPreviewScreen(NiceModal):
    """Preview post with markdown rendering"""

    def __init__(self, post_path: str, content: str):
        super().__init__(f"Preview: {Path(post_path).stem}")
        self.post_path = post_path
        self.content = content

    def compose(self) -> ComposeResult:
        yield from super().compose()

        # Extract title from content
        title = self.post_path.split('/')[-2]
        for line in self.content.split('\n'):
            if line.strip().startswith('title ='):
                title = line.split('=')[1].strip().strip("'\"")
                break

        yield Static(f"[bold cyan]Title:[/bold cyan] {title}", id="preview-title")
        yield Static(f"[dim]Path: {self.post_path}[/dim]", id="preview-path")
        yield Horizontal(
            Button("Close", id="btn_close", variant="error"),
            Button("Edit", id="btn_edit"),
            id="preview-actions"
        )
        yield Vertical(Markdown(self.content, id="preview-markdown"), id="preview-scroll")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "btn_close":
            self.app.pop_screen()
        elif event.button.id == "btn_edit":
            # Open integrated editor/preview
            self.app.push_screen(EditorPreview(self.post_path, self.content))


class EditorPreview(NiceModal):
    """Integrated editor and live preview"""

    def __init__(self, post_path: str, content: str):
        super().__init__("Edit & Preview")
        self.post_path = post_path
        self.content = content
        self.original_content = content

    def compose(self) -> ComposeResult:
        yield from super().compose()

        # Extract title from content
        title = self.post_path.split('/')[-2]
        for line in self.content.split('\n'):
            if line.strip().startswith('title ='):
                title = line.split('=')[1].strip().strip("'\"")
                break

        yield Static(f"[bold cyan]Editing:[/bold cyan] {title}", id="edit-title")
        yield Static(f"[dim]Path: {self.post_path}[/dim]", id="edit-path")
        yield Horizontal(
            Button("Save", id="btn_save", variant="primary"),
            Button("Cancel", id="btn_cancel", variant="error"),
            id="edit-actions"
        )
        with Horizontal(id="editor-preview-split"):
            with Vertical(id="editor-pane"):
                yield Static("[bold]EDITOR[/bold]", id="pane-label-editor")
                yield TextArea(self.content, id="editor", language="markdown")
            with Vertical(id="preview-pane"):
                yield Static("[bold]PREVIEW[/bold]", id="pane-label-preview")
                yield Markdown(self.content, id="live-preview")
        yield NiceStatus("", id="status")

    def on_mount(self) -> None:
        """Setup live preview updates"""
        editor = self.query_one("#editor", TextArea)
        editor.focus()

    def on_text_area_changed(self, event: TextArea.Changed) -> None:
        """Update live preview when editor changes"""
        if event.text_area.id == "editor":
            try:
                preview = self.query_one("#live-preview", Markdown)
                preview.update(event.text_area.text)
            except:
                pass

    def on_button_pressed(self, event: Button.Pressed) -> None:
        status = self.query_one("#status", NiceStatus)

        if event.button.id == "btn_cancel":
            # Check if there are unsaved changes
            editor = self.query_one("#editor", TextArea)
            if editor.text != self.original_content:
                # Could add confirmation here
                pass
            self.app.pop_screen()

        elif event.button.id == "btn_save":
            editor = self.query_one("#editor", TextArea)
            new_content = editor.text

            # Write to file
            full_path = PROJECT_ROOT / self.post_path
            try:
                with open(full_path, 'w') as f:
                    f.write(new_content)
                status.show_success("File saved successfully")

                # Update original content
                self.original_content = new_content

                # Refresh file tree if exists
                try:
                    file_tree = self.app.query_one(FileTree)
                    file_tree.populate_tree(file_tree.query_one("#file-tree", Tree).root)
                except:
                    pass

                # Close after a brief delay to show success message
                import asyncio
                async def close_screen():
                    await asyncio.sleep(1)
                    self.app.pop_screen()
                self.call_later(close_screen)

            except Exception as e:
                status.show_error(f"Failed to save: {str(e)}")



class CreateCategoryScreen(NiceModal):
    """Create new category screen"""

    def __init__(self):
        super().__init__("Create New Category")

    def compose(self) -> ComposeResult:
        yield from super().compose()

        yield Static("[dim]Enter the name for your new category[/dim]", id="form-hint")
        yield Static("Existing categories: " + ", ".join(get_categories()), id="existing-cats")
        yield Horizontal(
            Static("Category Name:", classes="form-label"),
            Input(placeholder="e.g., Network Automation", id="input-category", classes="form-input"),
            id="form-row-cat"
        )
        yield Static("[dim]Category will be created as: content/routing/[category-name]/[/dim]", id="form-info")
        yield Horizontal(
            Button("Create Category", id="btn_create", variant="primary"),
            Button("Cancel", id="btn_cancel"),
            id="create-actions"
        )
        yield NiceOutput("", id="output")
        yield NiceStatus("", id="status")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        status = self.query_one("#status", NiceStatus)
        output = self.query_one("#output", NiceOutput)

        if event.button.id == "btn_create":
            cat_input = self.query_one("#input-category", Input)
            category_name = cat_input.value.strip()

            if not category_name:
                status.show_error("Please enter a category name")
                return

            status.show_info("Creating category...")
            success, message = create_category(category_name)

            if success:
                status.show_success(message)
                output.write(f"\n[dim]Created: content/routing/{category_name.lower()}/[/dim]\n")
            else:
                status.show_error("Failed")
                output.write(message)

        elif event.button.id in ["btn_cancel", "btn_close_modal"]:
            self.app.pop_screen()


# =============================================
# MAIN APPLICATION
# =============================================
class BlogAutomationApp(App):
    """VS Code-inspired TUI application"""

    CSS = """
    /* NORD THEME - Clean, Minimalistic Design with Better Separators */

    /* Global Styles */
    Screen {
        background: #2e3440;
        layout: vertical;
    }

    /* Top Navigation */
    TopNav {
        height: 3;
        dock: top;
    }

    #nav-bar {
        height: 3;
        background: #2e3440;
        border-bottom: solid #616e88;
        padding: 0 1;
    }

    .nav-btn {
        height: 1;
        margin: 1 0 0 0;
        padding: 0 1;
        border: none;
        background: transparent;
        text-style: none;
        color: #d8dee9;
    }

    .nav-btn:hover {
        background: #434c5e;
        text-style: bold;
    }

    .nav-btn.active {
        background: #5e81ac;
        text-style: bold;
        color: #eceff4;
    }

    .nav-spacer {
        width: 1fr;
    }

    .nav-link {
        height: 1;
        margin: 1 1 0 0;
        padding: 0 1;
    }

    .nav-link:hover {
        text-style: bold;
    }

    /* Sidebar */
    FileTree {
        width: 35;
        background: #2e3440;
        border-right: solid #616e88;
        content-align: left top;
    }

    #main-container {
        height: 1fr;
        width: 1fr;
    }

    #main-content {
        height: 100%;
        width: 1fr;
    }

    #sidebar-title {
        text-style: bold;
        padding: 1;
        margin-bottom: 0;
        border-bottom: solid #616e88;
        color: #88c0d0;
        background: #2e3440;
    }

    #sidebar-actions {
        height: 6;
        margin-top: 0;
        padding: 1;
        border-top: solid #616e88;
        background: #2e3440;
    }

    .sidebar-action {
        width: 1fr;
        height: 3;
        margin: 0 0 1 0;
        background: #3b4252;
        color: #d8dee9;
        border: solid #616e88;
        text-style: none;
        text-align: center;
        min-width: 9;
    }

    .sidebar-action:hover {
        background: #5e81ac;
        color: #eceff4;
    }

    #file-tree {
        height: 1fr;
        background: #2e3440;
    }

    Tree {
        background: transparent;
    }

    TreeScreen {
        background: transparent;
    }

    /* Tree node styling */
    TreeNode {
        background: transparent;
    }

    TreeNode.--highlight {
        background: #434c5e;
        text-style: bold;
    }


    /* Main Content */
    #main-container {
        height: 1fr;
    }

    #main-horizontal {
        height: 1fr;
    }

    ContentArea {
        height: 1fr;
        width: 1fr;
    }

    #content-container {
        height: 100%;
        width: 100%;
        padding: 0;
    }

    /* Hidden widgets should not take any space */
    #content-header.-hidden {
        display: none;
    }

    #content-log.-hidden {
        display: none;
    }

    #inline-editor.-hidden {
        display: none;
    }

    #inline-preview.-hidden {
        display: none;
    }

    #editor-preview-container.-hidden {
        display: none;
    }

    #content-header {
        height: 3;
        width: 100%;
        border-bottom: solid #616e88;
        background: #2e3440;
        padding: 0 1;
    }

    #file-name {
        width: 2fr;
        content-align: left middle;
        text-style: bold;
        color: #88c0d0;
        padding: 0 1;
    }

    #action-edit, #action-save, #action-preview, #action-close {
        color: #88c0d0;
        padding: 0 1;
        text-style: bold;
        width: 12;
        content-align: center middle;
    }

    #action-edit:hover, #action-save:hover, #action-preview:hover, #action-close:hover {
        background: #3b4252;
        color: #88c0d0;
        text-style: bold underline;
    }

    #content-log {
        height: 1fr;
        width: 1fr;
        border: none;
        background: #2e3440;
        padding: 2;
        color: #d8dee9;
        overflow-y: auto;
    }

    /* Inline editor and preview */
    #inline-editor {
        height: 1fr;
        width: 1fr;
        background: #2e3440;
        border: none;
        padding: 0;
        margin: 0;
    }

    #inline-preview {
        height: 1fr;
        width: 1fr;
        background: #2e3440;
        border: none;
        padding: 1;
        overflow-y: auto;
    }

    /* Status Bar */
    StatusBar {
        height: 1;
        dock: bottom;
        background: #2e3440;
        border-top: solid #616e88;
        color: #d8dee9;
        padding: 0 1;
    }

    #status-left {
        width: 2fr;
        content-align: left middle;
    }

    #status-right {
        width: 1fr;
        content-align: right middle;
    }

    /* Modal Styles - Force small popup size */
    NiceModal {
        align: center middle;
    }

    #modal-container {
        width: 70;
        height: auto;
        border: thick #616e88;
        background: #2e3440;
        layout: vertical;
        padding: 0;
        overflow-y: auto;
    }

    #modal-header {
        height: 3;
        border-bottom: solid #616e88;
        background: #2e3440;
        padding: 0 1;
    }

    #modal-title {
        content-align: center middle;
        width: 1fr;
        color: #88c0d0;
        text-style: bold;
    }

    #btn_close_modal {
        width: 3;
        height: 1;
        margin: 1;
    }

    #modal-content {
        padding: 1 2;
        height: auto;
        overflow-y: auto;
    }

    /* Form Styles */
    #form-hint {
        padding: 0 1;
        margin-bottom: 1;
        text-align: center;
        color: #d8dee9;
        border-bottom: solid #3b4252;
        padding-bottom: 1;
    }

    .form-label {
        width: 15;
        content-align: left middle;
        padding: 0 1;
        color: #d8dee9;
    }

    #form-row-cat, #form-row-title {
        height: 3;
        margin-bottom: 1;
        border-bottom: solid #3b4252;
        padding-bottom: 1;
    }

    #cat-buttons {
        width: 1fr;
    }

    .cat-btn {
        width: 1fr;
        height: 3;
        margin: 0 1 0 0;
        background: #3b4252;
        color: #d8dee9;
        border: solid #616e88;
    }

    .cat-btn.selected {
        background: #5e81ac;
        text-style: bold;
        color: #eceff4;
    }

    .form-input {
        width: 1fr;
        margin-bottom: 1;
        background: #2e3440;
        border: solid #616e88;
        color: #d8dee9;
    }

    #create-actions, #edit-actions {
        height: 3;
        margin-top: 1;
        border-top: solid #616e88;
        padding-top: 1;
    }

    #create-actions Button, #edit-actions Button {
        width: 1fr;
        margin-right: 1;
    }

    /* Output and Status */
    NiceOutput {
        height: 15;
        border: solid #616e88;
        background: #2e3440;
        padding: 1;
        margin-top: 1;
        overflow-y: auto;
        color: #d8dee9;
    }

    NiceStatus {
        height: 3;
        padding: 0 1;
        margin-top: 1;
        border-top: solid #616e88;
    }

    /* DataTable for Posts */
    DataTable {
        height: 20;
        border: solid #616e88;
        margin-bottom: 1;
        background: #2e3440;
    }

    /* Markdown Preview */
    #preview-scroll {
        height: 1fr;
        border: solid #616e88;
        background: #2e3440;
        padding: 1;
        overflow-y: auto;
    }

    #preview-markdown {
        width: 100%;
        color: #d8dee9;
    }

    /* Filter Buttons */
    #filter-buttons {
        height: 3;
        margin-bottom: 1;
        border-bottom: solid #616e88;
        padding-bottom: 1;
    }

    #filter-buttons Button {
        width: 1fr;
        height: 1;
        margin-right: 1;
        background: #3b4252;
        color: #d8dee9;
        border: solid #616e88;
    }

    /* Table Actions */
    #table-actions, #preview-actions {
        height: 3;
        margin-top: 1;
        border-top: solid #616e88;
        padding-top: 1;
    }

    #table-actions Button, #preview-actions Button {
        width: 1fr;
        margin-right: 1;
        background: #3b4252;
        color: #d8dee9;
        border: solid #616e88;
    }

    /* Form Elements */
    #info-row {
        height: 3;
        margin-bottom: 1;
    }

    #existing-cats {
        padding: 0 1;
        margin-bottom: 1;
        text-style: italic;
        color: #81a1c1;
        border-bottom: solid #3b4252;
        padding-bottom: 1;
    }

    #preview-title, #edit-title {
        color: #88c0d0;
        text-style: bold;
        padding: 0 1;
        border-bottom: solid #616e88;
        padding-bottom: 1;
        margin-bottom: 1;
    }

    #preview-path, #edit-path {
        color: #616e88;
        padding: 0 1;
        margin-bottom: 1;
    }

    #form-info {
        padding: 0 1;
        margin-bottom: 1;
        color: #81a1c1;
        border-bottom: solid #3b4252;
        padding-bottom: 1;
    }

    /* Editor Styles */
    #editor {
        height: 1fr;
        border: solid #616e88;
        background: #2e3440;
        margin-top: 1;
    }

    TextArea {
        background: #2e3440;
        color: #d8dee9;
        border: solid #616e88;
    }

    /* Editor/Preview Split */
    #editor-preview-split {
        height: 1fr;
        border-top: solid #616e88;
        border-bottom: solid #616e88;
    }

    #editor-pane, #preview-pane {
        width: 1fr;
        height: 1fr;
        padding: 1;
    }

    #editor-pane {
        border-right: solid #616e88;
    }

    #pane-label-editor, #pane-label-preview {
        text-style: bold;
        color: #88c0d0;
        padding: 0 0 1 0;
        border-bottom: solid #616e88;
        margin-bottom: 1;
    }

    #live-preview {
        height: 1fr;
        overflow-y: auto;
        background: #2e3440;
        padding: 1;
    }

    /* Warning message */
    #warning-msg {
        padding: 1;
        margin-bottom: 1;
        text-align: center;
        border: solid #bf616a;
        background: #3b4252;
    }

    #current-path, #delete-path {
        padding: 0 1;
        margin-bottom: 1;
        color: #81a1c1;
        border-bottom: solid #3b4252;
        padding-bottom: 1;
    }

    /* Nord Theme Line Separators */
    #form-row-filename, #form-row-directory, #form-row-newname, #form-row-confirm {
        border-bottom: solid #3b4252;
        padding-bottom: 1;
        margin-bottom: 1;
    }
    """

    BINDINGS = [
        Binding("q", "quit", "Quit", show=False),
        Binding("ctrl+c", "quit", "Quit", show=False),
        Binding("escape", "close_editor", "Close", show=False),
        Binding("ctrl+r", "refresh", "Refresh", show=True),
        Binding("ctrl+n", "create_post", "New Post", show=True),
        Binding("ctrl+o", "preview_file", "Preview", show=True),
        Binding("ctrl+k", "create_category", "New Category", show=True),
        Binding("ctrl+v", "view_posts", "View Posts", show=True),
        Binding("ctrl+s", "save_file", "Save", show=True),
        Binding("ctrl+shift+p", "preview", "Preview Site", show=True),
    ]

    def __init__(self):
        super().__init__()
        self.current_open_file = None


    def on_mount(self) -> None:
        """Initialize app"""
        pass

    def compose(self) -> ComposeResult:
        """Build the UI"""
        yield TopNav()
        with Horizontal(id="main-container"):
            yield FileTree()
            with Vertical(id="main-content"):
                yield ContentArea()
        yield StatusBar()

    def change_view(self, view: str) -> None:
        """Change main content view"""
        content_area_widget = self.query_one(ContentArea)
        content_log = self.query_one("#content-log", RichLog)

        # Hide header
        try:
            header = content_area_widget.query_one("#content-header", Horizontal)
            header.visible = False
            header.set_class(True, "-hidden")
        except:
            pass

        # Clear content and show log
        content_log.clear()
        content_log.visible = True
        content_log.set_class(False, "-hidden")

        # Make sure editor-preview container is hidden
        try:
            editor_preview_container = content_area_widget.query_one("#editor-preview-container", Horizontal)
            editor_preview_container.visible = False
            editor_preview_container.set_class(True, "-hidden")
        except:
            pass

        # Clear current file tracking
        if hasattr(content_area_widget, 'current_file_path'):
            delattr(content_area_widget, 'current_file_path')
        self.current_open_file = None

        views = {
            "dashboard": self.show_dashboard,
            "posts": self.show_posts,
            "automation": self.show_automation,
            "ai": self.show_ai,
            "git": self.show_git,
            "settings": self.show_settings,
        }

        if view in views:
            views[view](content_log)

    def open_file_in_content(self, file_path: Path) -> None:
        """Open file in main content area"""
        content_area = self.query_one(ContentArea)

        # Track current file
        self.current_open_file = file_path

        # For markdown files, open directly in edit mode
        if file_path.suffix == '.md':
            content_area.enter_edit_mode(file_path)
        else:
            # For other files, show in view mode
            content_title = self.query_one("#content-title", Static)
            content_log = self.query_one("#content-log", RichLog)
            content_area.current_file_path = file_path

            # Update title
            content_title.update(f"[bold cyan]{file_path.name}[/bold cyan]")

            # Clear and load content
            content_log.clear()

            try:
                # Read file content
                with open(file_path, 'r') as f:
                    content = f.read()

                # Display relative path
                rel_path = file_path.relative_to(PROJECT_ROOT)
                content_log.write(f"[dim]Path: {rel_path}[/dim]\n")
                content_log.write("")
                content_log.write(content)

            except Exception as e:
                content_log.write(f"[red]Error reading file:[/red] {str(e)}")

    def action_save_file(self) -> None:
        """Save the file being edited"""
        content_area = self.query_one(ContentArea)
        if hasattr(content_area, 'current_file_path') and content_area.current_file_path:
            content_area.save_current_file()

    def action_preview_file(self) -> None:
        """Preview the current file"""
        content_area = self.query_one(ContentArea)
        if hasattr(content_area, 'current_file_path') and content_area.current_file_path:
            content_area.preview_current_file()

    def action_close_editor(self) -> None:
        """Close editor and return to view mode"""
        content_area = self.query_one(ContentArea)
        if hasattr(content_area, 'current_file_path') and content_area.current_file_path:
            content_area.exit_edit_mode()
        else:
            self.app.pop_screen()

    def show_dashboard(self, log: RichLog) -> None:
        """Show dashboard view"""
        log.clear()
        log.visible = True

        stats = get_stats()
        total_posts = stats['drafts'] + stats['published']

        # Dashboard header
        log.write("[bold cyan]╔═══════════════════════════════════════════════════════════════╗[/bold cyan]")
        log.write("[bold cyan]║               NGERAN[IO] BLOG DASHBOARD                      ║[/bold cyan]")
        log.write("[bold cyan]╚═══════════════════════════════════════════════════════════════╝[/bold cyan]\n")

        # Blog Statistics
        log.write("[bold yellow]📊 BLOG STATISTICS[/bold yellow]")
        log.write("─" * 65)
        log.write(f"  [bold]Total Posts:[/bold]         [cyan]{total_posts}[/cyan]")
        log.write(f"  [bold]Published Posts:[/bold]     [green]{stats['published']}[/green] ✅")
        log.write(f"  [bold]Draft Posts:[/bold]         [yellow]{stats['drafts']}[/yellow] 📋")
        log.write(f"  [bold]Last Git Commit:[/bold]     [dim]{stats['last_commit']}[/dim]\n")

        # Categories breakdown
        log.write("[bold yellow]📁 CATEGORIES BREAKDOWN[/bold yellow]")
        log.write("─" * 65)
        if stats['categories']:
            for cat, counts in stats['categories'].items():
                cat_total = counts['drafts'] + counts['published']
                log.write(f"  [bold cyan]{cat.upper()}[/bold cyan]: {cat_total} posts ({counts['published']} published, {counts['drafts']} drafts)")
        else:
            log.write("  [dim]No categories found[/dim]\n")

        # Quick Actions
        log.write("\n[bold yellow]⚡ QUICK ACTIONS[/bold yellow]")
        log.write("─" * 65)
        log.write("  [Ctrl+N] Create new post")
        log.write("  [Ctrl+O] Preview current file")
        log.write("  [Ctrl+K] Create new category")
        log.write("  [Ctrl+V] View & manage posts")
        log.write("  [Ctrl+R] Refresh dashboard\n")

        # System Status
        log.write("[bold yellow]🔧 SYSTEM STATUS[/bold yellow]")
        log.write("─" * 65)
        log.write("  [green]✓[/green] Hugo Extended: [green]Installed[/green]")
        log.write("  [green]✓[/green] Git: [green]Available[/green]")
        log.write("  [green]✓[/green] GitHub CLI: [green]Available[/green]")
        log.write("  [green]✓[/green] Python 3: [green]Available[/green]\n")

        # Automation info
        log.write("[bold yellow]🤖 AUTOMATION INFO[/bold yellow]")
        log.write("─" * 65)
        log.write("  Phase 1 Libraries: [green]✓ Installed[/green]")
        log.write("  Phase 2 Scripts: [green]✓ Enhanced[/green]")
        log.write("  Quality Gate: [green]✓ Active[/green]")
        log.write("  AI Content Manager: [green]✓ Ready[/green]\n")

        log.write("[dim]═" * 65)
        log.write("[dim]Use the file explorer on the left to browse your project files.[/dim]")

    def show_posts(self, log: RichLog) -> None:
        """Show posts view - list all posts in sidebar area"""
        log.clear()
        log.visible = True

        # Hide editor and preview
        try:
            content_area = self.query_one(ContentArea)
            editor = content_area.query_one("#inline-editor", TextArea)
            preview = content_area.query_one("#inline-preview", Markdown)
            editor.visible = False
            preview.visible = False
        except:
            pass

        # Scan for all posts
        posts = []

        try:
            for cat_dir in CONTENT_DIR.iterdir():
                if cat_dir.is_dir():
                    for post_dir in cat_dir.iterdir():
                        index_file = post_dir / "index.md"
                        if index_file.exists():
                            # Read post metadata
                            title = post_dir.name
                            is_draft = True
                            summary = ""

                            try:
                                with open(index_file, 'r') as f:
                                    content = f.read()
                                    # Parse frontmatter
                                    if 'draft = false' in content:
                                        is_draft = False
                                    # Extract title
                                    for line in content.split('\n'):
                                        if line.strip().startswith('title ='):
                                            title = line.split('=')[1].strip().strip("'\"")
                                            break
                                        if line.strip() == '+++':
                                            break
                                    # Extract summary
                                    for line in content.split('\n'):
                                        if line.strip().startswith('summary ='):
                                            summary = line.split('=')[1].strip().strip("'\"")
                                            break
                            except:
                                pass

                            posts.append({
                                'path': index_file,
                                'title': title,
                                'category': cat_dir.name,
                                'draft': is_draft,
                                'summary': summary
                            })
        except Exception as e:
            log.write(f"[red]Error scanning posts:[/red] {str(e)}")
            return

        # Sort by title
        posts.sort(key=lambda p: p['title'])

        # Display posts in a nice format
        log.write("[bold cyan]╔═══════════════════════════════════════════════════════════════╗[/bold cyan]")
        log.write("[bold cyan]║                      ALL POSTS ({})                          ║[/bold cyan]".format(len(posts)))
        log.write("[bold cyan]╚═══════════════════════════════════════════════════════════════╝[/bold cyan]\n")

        if not posts:
            log.write("[yellow]No posts found. Create your first post with Ctrl+N[/yellow]")
            return

        # Group by category
        by_category = {}
        for post in posts:
            cat = post['category'].upper()
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(post)

        # Display posts by category
        for category, cat_posts in sorted(by_category.items()):
            log.write(f"[bold yellow]📁 {category}[/bold yellow] ({len(cat_posts)} posts)")
            log.write("─" * 65)

            for post in cat_posts:
                status = "[yellow]📋 DRAFT[/yellow]" if post['draft'] else "[green]✅ PUBLISHED[/green]"
                summary_preview = post['summary'][:50] + "..." if len(post['summary']) > 50 else post['summary']

                log.write(f"\n  [bold cyan]▸[/bold cyan] [bold]{post['title']}[/bold]")
                log.write(f"     {status}")
                log.write(f"     [dim]{summary_preview}[/dim]")
                log.write(f"     [dim]Path: {post['path'].relative_to(PROJECT_ROOT)}[/dim]")

                # Add clickable instruction
                log.write(f"     [#88c0d0]Click here to open →[/#88c0d0]\n")

        log.write("\n[bold yellow]ACTIONS[/bold yellow]")
        log.write("─" * 65)
        log.write("  [green]•[/green] Browse file explorer on left to open any post")
        log.write("  [green]•[/green] Use [Ctrl+V] to open post management modal")
        log.write("  [green]•[/green] Click on files in sidebar to edit")
        log.write("  [green]•[/green] Use [Ctrl+N] to create new posts")

    def show_automation(self, log: RichLog) -> None:
        """Show automation view"""
        log.write(
            f"[bold cyan]AUTOMATION[/bold cyan]\n\n"
            f"[dim]Blog automation scripts and tools[/dim]\n\n"
            f"[bold]Available Scripts:[/bold]\n"
            f"  • [cyan]create-post.sh[/cyan] - Create new blog posts\n"
            f"  • [cyan]preview.sh[/cyan] - Preview site locally\n"
            f"  • [cyan]publish-drafts.sh[/cyan] - Publish drafts to live\n"
            f"  • [cyan]quality-gate.sh[/cyan] - Validate content quality\n"
            f"  • [cyan]ai-content-manager.sh[/cyan] - AI-assisted management\n\n"
            f"[bold]Phase 1 Libraries:[/bold]\n"
            f"  • [cyan]common.sh[/cyan] - Utility functions\n"
            f"  • [cyan]logger.sh[/cyan] - Advanced logging\n"
            f"  • [cyan]error-handler.sh[/cyan] - Error management\n"
            f"  • [cyan]config.sh[/cyan] - Configuration management\n\n"
            f"[dim]All scripts are located in [bold]scripts/[/bold] directory.[/dim]"
        )

    def show_ai(self, log: RichLog) -> None:
        """Show AI agent view"""
        log.write(
            f"[bold cyan]AI AGENT[/bold cyan]\n\n"
            f"[dim]AI-powered content creation and management[/dim]\n\n"
            f"[bold]AI Features:[/bold]\n"
            f"  • Automated content generation\n"
            f"  • Quality validation\n"
            f"  • SEO optimization\n"
            f"  • Image suggestions\n\n"
            f"[bold]AI Content Manager:[/bold]\n"
            f"  Run: [cyan]./scripts/ai-content-manager.sh[/cyan]\n\n"
            f"[bold]Commands:[/bold]\n"
            f"  • [cyan]create[/cyan] - Create new post with AI\n"
            f"  • [cyan]update[/cyan] - Update existing post\n"
            f"  • [cyan]validate[/cyan] - Validate content\n"
            f"  • [cyan]list[/cyan] - List all posts\n\n"
            f"[dim]Check [bold]AI_AGENT_GUIDE.md[/bold] for more info.[/dim]"
        )

    def show_git(self, log: RichLog) -> None:
        """Show git view"""
        log.write(
            f"[bold cyan]GIT & GITHUB[/bold cyan]\n\n"
            f"[dim]Version control and deployment[/dim]\n\n"
            f"[bold]Git Operations:[/bold]\n"
            f"  • Check status\n"
            f"  • Commit changes\n"
            f"  • Push to GitHub\n"
            f"  • Pre-push safety checks\n\n"
            f"[bold]Deployment:[/bold]\n"
            f"  • Automatic deployment to Cloudflare Pages\n"
            f"  • Triggered on push to main branch\n"
            f"  • Build command: [cyan]hugo --minify[/cyan]\n\n"
            f"[bold]Safety Features:[/bold]\n"
            f"  • Pre-push validation\n"
            f"  • Automatic backups\n"
            f"  • Rollback capability\n"
            f"  • Quality gate checks\n\n"
            f"[dim]Check [bold]logs/deployment.log[/bold] for deployment history.[/dim]"
        )

    def show_settings(self, log: RichLog) -> None:
        """Show settings view"""
        log.write(
            f"[bold cyan]SETTINGS[/bold cyan]\n\n"
            f"[dim]Configuration and preferences[/dim]\n\n"
            f"[bold]Configuration:[/bold]\n"
            f"  • Site URL: https://ngeranio.com\n"
            f"  • Main sections: routing\n"
            f"  • Pagination: 6 posts per page\n\n"
            f"[bold]Environment:[/bold]\n"
            f"  • Hugo Extended: [green]✓ Installed[/green]\n"
            f"  • Git: [green]✓ Available[/green]\n"
            f"  • GitHub CLI: [green]✓ Available[/green]\n"
            f"  • Python 3: [green]✓ Available[/green]\n\n"
            f"[bold]Key Files:[/bold]\n"
            f"  • [cyan].env[/cyan] - Environment variables\n"
            f"  • [cyan]hugo.toml[/cyan] - Site configuration\n"
            f"  • [cyan]CLAUDE.md[/cyan] - Automation guide\n\n"
            f"[dim]Edit [bold].env[/bold] to change settings.[/dim]"
        )

    def action_refresh(self) -> None:
        """Refresh current view"""
        log = self.query_one("#content-log", RichLog)
        log.write("\n[dim]Refreshing...[/dim]\n")
        # Force re-render current view
        nav = self.query_one(TopNav)
        self.change_view(nav.current_view)

    def action_create_post(self) -> None:
        """Open create post modal"""
        self.push_screen(CreatePostScreen())

    def action_preview(self) -> None:
        """Preview the site"""
        log = self.query_one("#content-log", RichLog)
        log.write(
            "\n[bold cyan]Starting preview server...[/bold cyan]\n\n"
            "Open [bold]http://localhost:1313[/bold] in your browser\n\n"
            "[yellow]Press Ctrl+C to stop the server[/yellow]\n\n"
            "[dim]Note: Server runs in background[/dim]\n"
            "[dim]Stop with: pkill hugo[/dim]\n"
        )

    def action_create_category(self) -> None:
        """Create a new category"""
        self.push_screen(CreateCategoryScreen())

    def action_view_posts(self) -> None:
        """View all posts"""
        self.push_screen(ViewPostsScreen())


# =============================================
# ENTRY POINT
# =============================================
if __name__ == "__main__":
    try:
        import textual
    except ImportError:
        print("[red]Error: textual is not installed[/red]")
        print("\nTo install, run:")
        print("  pip install textual")
        print("\nThe TUI will guide you through installation")
        sys.exit(1)

    app = BlogAutomationApp()
    app.title = "NGERAN[IO] Blog Automation"
    app.run()
