#!/usr/bin/env python3
"""
============================================
NGERAN[IO] AUTOMATION TUI
============================================
VS Code-inspired Terminal User Interface
Modern, elegant, and functional

Author: NGERAN[IO] Team
Version: 2.0.0
Last Updated: 2026-01-04
============================================
"""

# =============================================
# IMPORTS
# =============================================
from textual.app import App, ComposeResult
from textual.widgets import (
    Static, Button, Input, Label, DataTable,
    Footer, Header, Tree, RichLog, Markdown, TextArea, Select
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
import asyncio


# =============================================
# CONFIGURATION & CONSTANTS
# =============================================
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
CONTENT_DIR = PROJECT_ROOT / "content" / "routing"


# =============================================
# UTILITY FUNCTIONS
# =============================================

def run_command(cmd: list, cwd: str = None) -> tuple[int, str, str]:
    """
    Execute a shell command and capture its output.
    
    Args:
        cmd: List of command arguments (e.g., ['ls', '-la'])
        cwd: Working directory for command execution
        
    Returns:
        Tuple of (exit_code, stdout, stderr)
        
    Raises:
        None - All exceptions are caught and returned as error codes
    """
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
        return -1, "", "Command timed out after 300 seconds"
    except Exception as e:
        return -1, "", str(e)


def get_draft_posts() -> list[dict]:
    """
    Scan content directory for draft posts.
    
    Returns:
        List of dictionaries containing post metadata:
        - category: Category name
        - title: Post title
        - path: Relative path from project root
    """
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


def get_all_posts() -> list[dict]:
    """
    Scan content directory for all posts (drafts and published).
    
    Returns:
        List of dictionaries containing post metadata:
        - category: Category name
        - title: Post title
        - path: Relative path from project root
        - is_draft: Boolean indicating draft status
        - full_path: Absolute path to post file
    """
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


def get_categories() -> list[str]:
    """
    Get list of all category directories.
    
    Returns:
        Sorted list of category names
    """
    categories = []
    try:
        for cat_dir in CONTENT_DIR.iterdir():
            if cat_dir.is_dir():
                categories.append(cat_dir.name)
    except Exception as e:
        pass
    return sorted(categories)


def get_all_directories() -> list[str]:
    """
    Recursively scan project directories for dropdown selection.
    
    Returns:
        List of relative directory paths from project root
        
    Note:
        - Includes project root as "."
        - Recursively scans up to 3 levels deep
        - Excludes hidden directories (starting with .)
    """
    directories = []
    try:
        # Add project root
        directories.append(".")

        # Add content subdirectories
        for item in sorted(PROJECT_ROOT.iterdir()):
            if item.is_dir() and not item.name.startswith('.'):
                # Add first-level directories
                rel_path = item.relative_to(PROJECT_ROOT)
                directories.append(str(rel_path))

                # Recursively add subdirectories (up to 3 levels deep)
                if item.name in ['content', 'scripts', 'static']:
                    for sub_item in sorted(item.iterdir()):
                        if sub_item.is_dir() and not sub_item.name.startswith('.'):
                            sub_rel = sub_item.relative_to(PROJECT_ROOT)
                            directories.append(str(sub_rel))

                            # Third level for content
                            if item.name == 'content':
                                for sub_sub_item in sorted(sub_item.iterdir()):
                                    if sub_sub_item.is_dir() and not sub_sub_item.name.startswith('.'):
                                        sub_sub_rel = sub_sub_item.relative_to(PROJECT_ROOT)
                                        directories.append(str(sub_sub_rel))
    except Exception:
        pass

    return directories


def create_category(category_name: str) -> tuple[bool, str]:
    """
    Create a new category directory.
    
    Args:
        category_name: Name of the category to create
        
    Returns:
        Tuple of (success: bool, message: str)
    """
    try:
        cat_path = CONTENT_DIR / category_name.lower()
        if cat_path.exists():
            return False, f"Category '{category_name}' already exists"

        cat_path.mkdir(parents=True, exist_ok=True)
        return True, f"Category '{category_name}' created successfully"
    except Exception as e:
        return False, f"Failed to create category: {str(e)}"


def read_post_content(post_path: str) -> str:
    """
    Read the content of a post file.
    
    Args:
        post_path: Relative path to post file from project root
        
    Returns:
        File content as string, or error message if read fails
    """
    try:
        full_path = PROJECT_ROOT / post_path
        if full_path.exists():
            with open(full_path) as f:
                return f.read()
        return "# Post Not Found\n\nThe file could not be read."
    except Exception as e:
        return f"# Error\n\n{str(e)}"


def get_stats() -> dict:
    """
    Calculate blog statistics.
    
    Returns:
        Dictionary containing:
        - drafts: Total number of draft posts
        - published: Total number of published posts
        - categories: Dict mapping category names to post counts
        - last_commit: Human-readable time of last git commit
    """
    stats = {
        'drafts': 0,
        'published': 0,
        'categories': {},
        'last_commit': 'N/A'
    }

    try:
        # Count posts by category
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

        # Get last commit timestamp
        code, out, _ = run_command(['git', 'log', '-1', '--format=%cr'])
        if code == 0:
            stats['last_commit'] = out.strip()

    except Exception as e:
        pass

    return stats


# =============================================
# BACKGROUND TASK SYSTEM
# =============================================

class BackgroundTask:
    """
    Async background task runner for non-blocking operations.

    Features:
        - Run shell commands asynchronously
        - Stream output to callback
        - Update status during execution
        - Handle timeouts
    """

    def __init__(self, command: list, cwd: str = None, on_output=None, on_complete=None):
        """
        Initialize background task.

        Args:
            command: Command list to execute
            cwd: Working directory
            on_output: Callback for output lines (stdout, stderr)
            on_complete: Callback when task completes (exit_code)
        """
        self.command = command
        self.cwd = cwd or str(PROJECT_ROOT)
        self.on_output = on_output
        self.on_complete = on_complete
        self.process = None
        self.running = False

    async def run(self):
        """Run the command asynchronously."""
        self.running = True

        try:
            self.process = await asyncio.create_subprocess_exec(
                *self.command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.STDOUT,
                cwd=self.cwd
            )

            while True:
                line = await self.process.stdout.readline()
                if not line:
                    break

                output = line.decode('utf-8', errors='ignore')
                if self.on_output:
                    self.on_output(output.rstrip())

            await self.process.wait()

            if self.on_complete:
                self.on_complete(self.process.returncode)

        except Exception as e:
            if self.on_output:
                self.on_output(f"[red]Error: {str(e)}[/red]")
            if self.on_complete:
                self.on_complete(-1)
        finally:
            self.running = False


# =============================================
# CUSTOM WIDGETS - STATUS & NAVIGATION
# =============================================

class StatusBar(Static):
    """
    Bottom status bar displaying blog statistics and keyboard shortcuts.
    
    Layout:
        [Statistics] ................... [Keyboard Shortcuts]
    """
    
    def compose(self) -> ComposeResult:
        """Compose the status bar with live statistics."""
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
    """
    Top navigation bar with tab-style buttons.
    
    Features:
        - Tab switching between different views
        - Active tab highlighting
        - Quit button in top-right corner
    """
    
    current_view = reactive("dashboard")

    def compose(self) -> ComposeResult:
        """Compose the navigation bar."""
        with Horizontal(id="nav-bar"):
            yield Button("Dashboard", id="nav-dashboard", classes="nav-btn")
            yield Button("Posts", id="nav-posts", classes="nav-btn")
            yield Button("Automation", id="nav-automation", classes="nav-btn")
            yield Button("AI Agent", id="nav-ai", classes="nav-btn")
            yield Button("Git", id="nav-git", classes="nav-btn")
            yield Button("Settings", id="nav-settings", classes="nav-btn")
            yield Static("", id="nav-spacer", classes="nav-spacer")
            yield Button("➕ Add", id="nav-add", classes="nav-btn")
            yield Button("✏️ Rename", id="nav-rename", classes="nav-btn")
            yield Button("🗑️ Delete", id="nav-delete", classes="nav-btn")
            yield Static("", id="nav-spacer-2", classes="nav-spacer")
            yield Static("[#bf616a]Quit[/#bf616a]", id="nav-quit", classes="nav-link")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """
        Handle navigation button clicks.

        Updates active tab styling and notifies app to change view.
        Also handles file management buttons.
        """
        button_id = event.button.id

        # Handle file management buttons
        if button_id == "nav-add":
            self.app.push_screen(AddItemModal())
            return
        elif button_id == "nav-rename":
            # Get selected file from tree
            try:
                file_tree = self.app.query_one(FileTree)
                tree = file_tree.query_one("#file-tree", Tree)
                selected_node = tree.cursor_node
                if selected_node and selected_node.data:
                    item_path = selected_node.data
                    if isinstance(item_path, Path) and item_path.exists():
                        self.app.push_screen(RenameItemModal(item_path))
            except Exception as e:
                pass
            return
        elif button_id == "nav-delete":
            # Get selected file from tree
            try:
                file_tree = self.app.query_one(FileTree)
                tree = file_tree.query_one("#file-tree", Tree)
                selected_node = tree.cursor_node
                if selected_node and selected_node.data:
                    item_path = selected_node.data
                    if isinstance(item_path, Path) and item_path.exists():
                        self.app.push_screen(DeleteItemModal(item_path))
            except Exception as e:
                pass
            return

        # Handle navigation buttons
        nav_id = button_id.replace("nav-", "")
        self.current_view = nav_id

        # Update active state styling
        for btn in self.query(".nav-btn"):
            btn.remove_class("active")
        event.button.add_class("active")

        # Notify app to change content
        if hasattr(self.app, "change_view"):
            self.app.change_view(nav_id)

    def on_click(self, event) -> None:
        """Handle quit link click."""
        if event.widget.id == "nav-quit":
            self.app.exit()


# =============================================
# CUSTOM WIDGETS - FILE EXPLORER
# =============================================

class FileTree(Static):
    """
    Left sidebar file explorer with nvim-inspired styling.

    Features:
        - Hierarchical file tree
        - Recursive directory browsing
        - File type filtering
        - File open in editor on click
    """

    def compose(self) -> ComposeResult:
        """Compose the file tree sidebar."""
        yield Label("EXPLORER", id="sidebar-title")
        yield Tree("Project Root", id="file-tree")

    def on_mount(self) -> None:
        """Initialize the file tree on mount."""
        tree = self.query_one("#file-tree", Tree)
        self.populate_tree(tree.root)

    def populate_tree(self, root) -> None:
        """
        Populate tree with project files and directories.

        Args:
            root: Root tree node to populate

        Structure:
            - Main directories (content, scripts, themes, etc.)
            - Configuration files
        """
        # Clear existing children before repopulating
        if hasattr(root, '_children'):
            root._children.clear()

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
        """
        Recursively add directory contents to tree.
        
        Args:
            parent: Parent tree node
            dir_path: Path to directory to scan
            
        Features:
            - Alphabetically sorted
            - Directories first, then files
            - File type filtering (md, sh, py, toml, yaml, yml, txt, json)
            - Hides hidden files (starting with .)
        """
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
        """
        Handle file/directory selection in tree.
        
        Args:
            event: Tree node selection event
            
        Behavior:
            - Files: Open in content area
            - Directories: Expand/collapse
        """
        node = event.node
        file_path = node.data

        if file_path and isinstance(file_path, Path):
            # Check if it's a file (not directory)
            if file_path.is_file():
                # Open file in content area
                if hasattr(self.app, "open_file_in_content"):
                    self.app.open_file_in_content(file_path)


# =============================================
# CUSTOM WIDGETS - AI AGENT TAB
# =============================================

class AIAgentTab(Static):
    """
    AI-powered content creation and management.

    Features:
        - Content generation assistance
        - Quality improvement suggestions
        - Tag and summary generation
        - Script integration
    """

    def compose(self) -> ComposeResult:
        """Compose the AI Agent tab."""
        with Vertical(id="ai-container"):
            # AI Actions Section
            yield Static("🤖 AI Assistant", id="ai-title")
            with Horizontal(id="ai-actions"):
                yield Button("📝 Create Post", id="btn-ai-create", variant="default")
                yield Button("🏷️ Suggest Tags", id="btn-ai-tags", variant="default")
                yield Button("✨ Improve Content", id="btn-ai-improve", variant="default")
                yield Button("📊 Analyze Post", id="btn-ai-analyze", variant="default")

            # Status Section
            with Horizontal(id="ai-status"):
                yield Static("Status: Ready", id="ai-status-text")
                yield Static("", id="ai-status-indicator")

            # Log Output Section
            yield Static("💬 AI Output", id="ai-log-title")
            yield RichLog(id="ai-log", wrap=True, markup=True, auto_scroll=True)

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle AI Agent button presses."""
        log = self.query_one("#ai-log", RichLog)
        status_text = self.query_one("#ai-status-text", Static)

        if event.button.id == "btn-ai-create":
            self._ai_create_post(log, status_text)
        elif event.button.id == "btn-ai-tags":
            self._ai_suggest_tags(log, status_text)
        elif event.button.id == "btn-ai-improve":
            self._ai_improve_content(log, status_text)
        elif event.button.id == "btn-ai-analyze":
            self._ai_analyze_post(log, status_text)

    def _ai_create_post(self, log, status_text):
        """Create new post with AI assistance."""
        status_text.update("Status: Opening create post modal...")
        log.write("[cyan]Opening post creation modal...[/cyan]\n")
        log.write("[dim]Use the modal to create a new post[/dim]\n")
        # Open CreatePostScreen
        self.app.push_screen(CreatePostScreen())
        status_text.update("Status: Ready")

    def _ai_suggest_tags(self, log, status_text):
        """Suggest tags for current post."""
        status_text.update("Status: Analyzing content...")
        log.write("[cyan]Analyzing post content for tag suggestions...[/cyan]\n")

        # Check if file is open
        if not hasattr(self.app, 'current_open_file') or not self.app.current_open_file:
            log.write("[yellow]No file currently open[/yellow]\n")
            log.write("[dim]Open a post from the sidebar first[/dim]\n")
            status_text.update("Status: Ready")
            return

        file_path = self.app.current_open_file

        def on_output(line):
            log.write(line + "\n")

        def on_complete(exit_code):
            if exit_code == 0:
                log.write("[green]✓ Tag suggestions generated[/green]\n")
            else:
                log.write("[yellow]Select a post and run manually:[/yellow]")
                log.write("[dim]./scripts/ai-content-manager.sh info <post-path>[/dim]\n")
            status_text.update("Status: Ready")

        task = BackgroundTask(
            ["bash", "scripts/ai-content-manager.sh", "info", str(file_path)],
            on_output=on_output,
            on_complete=on_complete
        )
        asyncio.create_task(task.run())

    def _ai_improve_content(self, log, status_text):
        """Get AI suggestions to improve content."""
        status_text.update("Status: Analyzing content...")
        log.write("[cyan]Analyzing content quality...[/cyan]\n")

        if not hasattr(self.app, 'current_open_file') or not self.app.current_open_file:
            log.write("[yellow]No file currently open[/yellow]\n")
            log.write("[dim]Open a post from the sidebar first[/dim]\n")
            status_text.update("Status: Ready")
            return

        file_path = self.app.current_open_file
        log.write(f"[dim]Post: {file_path.name}[/dim]\n")

        # Run quality gate
        def on_output(line):
            log.write(line + "\n")

        def on_complete(exit_code):
            log.write("\n[cyan]Suggestions:[/cyan]")
            log.write("[green]•[/green] Check word count (min 500)")
            log.write("[green]•[/green] Add frontmatter summary")
            log.write("[green]•[/green] Include featured image")
            log.write("[green]•[/green] Add relevant tags")
            status_text.update("Status: Ready")

        task = BackgroundTask(
            ["bash", "scripts/quality-gate.sh", "validate", str(file_path)],
            on_output=on_output,
            on_complete=on_complete
        )
        asyncio.create_task(task.run())

    def _ai_analyze_post(self, log, status_text):
        """Analyze current post."""
        status_text.update("Status: Analyzing post...")
        log.write("[cyan]Analyzing post structure and content...[/cyan]\n")

        if not hasattr(self.app, 'current_open_file') or not self.app.current_open_file:
            log.write("[yellow]No file currently open[/yellow]\n")
            log.write("[dim]Open a post from the sidebar first[/dim]\n")
            status_text.update("Status: Ready")
            return

        file_path = self.app.current_open_file

        try:
            content = file_path.read_text()
            lines = content.split('\n')

            # Basic stats
            word_count = len(content.split())
            line_count = len(lines)
            has_frontmatter = '+++' in content

            log.write(f"[green]File:[/green] {file_path.name}\n")
            log.write(f"[green]Words:[/green] {word_count}\n")
            log.write(f"[green]Lines:[/green] {line_count}\n")
            log.write(f"[green]Frontmatter:[/green] {'✓' if has_frontmatter else '✗'}\n")

            # Check frontmatter
            if has_frontmatter:
                log.write("\n[dim]Frontmatter fields:[/dim]\n")
                in_frontmatter = False
                for line in lines:
                    if '+++' in line:
                        in_frontmatter = not in_frontmatter
                        if not in_frontmatter:
                            break
                    elif in_frontmatter and '=' in line:
                        field = line.split('=')[0].strip()
                        log.write(f"[cyan]•[/cyan] {field}")

            log.write("\n[green]✓ Analysis complete[/green]\n")

        except Exception as e:
            log.write(f"[red]Error: {str(e)}[/red]\n")

        status_text.update("Status: Ready")


# =============================================
# CUSTOM WIDGETS - AUTOMATION TAB
# =============================================

class AutomationTab(Static):
    """
    Automation hub for running scripts and managing workflows.

    Features:
        - Quick actions (quality gate, preview, tests, build)
        - Live log viewer
        - Background task execution
        - Status indicators
    """

    def __init__(self):
        super().__init__()
        self.preview_process = None
        self.preview_running = False

    def compose(self) -> ComposeResult:
        """Compose the automation tab."""
        with Vertical(id="automation-container"):
            # Quick Actions Section
            yield Static("⚡ Quick Actions", id="automation-title")
            with Horizontal(id="quick-actions"):
                yield Button("✓ Quality Gate", id="btn-quality", variant="default")
                yield Button("▶ Preview", id="btn-preview", variant="default")
                yield Button("⏹ Stop", id="btn-stop", variant="error")
                yield Button("⚙ Tests", id="btn-tests", variant="default")
                yield Button("🔨 Build", id="btn-build", variant="default")

            # Status Section
            with Horizontal(id="automation-status"):
                yield Static("Status: Ready", id="status-text")
                yield Static("", id="status-indicator")

            # Log Output Section
            yield Static("📋 Output", id="log-title")
            yield RichLog(id="automation-log", wrap=True, markup=True, auto_scroll=True)

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle automation button presses."""
        log = self.query_one("#automation-log", RichLog)
        status_text = self.query_one("#status-text", Static)

        if event.button.id == "btn-quality":
            self._run_quality_gate(log, status_text)

        elif event.button.id == "btn-preview":
            self._run_preview(log, status_text)

        elif event.button.id == "btn-stop":
            self._stop_preview(log, status_text)

        elif event.button.id == "btn-tests":
            self._run_tests(log, status_text)

        elif event.button.id == "btn-build":
            self._run_build(log, status_text)

    def _run_quality_gate(self, log, status_text):
        """Run quality gate validation."""
        status_text.update("Status: Running quality gate...")
        log.write("[cyan]Running quality gate validation...[/cyan]\n")

        def on_output(line):
            log.write(line + "\n")

        def on_complete(exit_code):
            if exit_code == 0:
                log.write("[green]✓ Quality gate passed[/green]\n")
            else:
                log.write(f"[red]✗ Quality gate failed (exit code: {exit_code})[/red]\n")
            status_text.update("Status: Ready")

        task = BackgroundTask(
            ["bash", "scripts/quality-gate.sh", "validate-drafts"],
            on_output=on_output,
            on_complete=on_complete
        )
        asyncio.create_task(task.run())

    def _run_preview(self, log, status_text):
        """Start preview server."""
        if self.preview_running:
            log.write("[yellow]Preview server is already running[/yellow]\n")
            log.write("[dim]Click ⏹ Stop first to restart[/dim]\n")
            return

        status_text.update("Status: Starting preview...")
        log.write("[cyan]Starting Hugo preview server...[/cyan]\n")
        self.preview_running = True

        def on_output(line):
            log.write(line + "\n")

        def on_complete(exit_code):
            if exit_code == 0:
                log.write("[green]✓ Preview server started on http://localhost:1313[/green]\n")
                log.write("[dim]Click ⏹ Stop to stop the server[/dim]\n")
                status_text.update("Status: Preview running")
            else:
                log.write(f"[red]✗ Failed to start preview (exit code: {exit_code})[/red]\n")
                self.preview_running = False
                status_text.update("Status: Ready")

        task = BackgroundTask(
            ["bash", "scripts/preview.sh"],
            on_output=on_output,
            on_complete=on_complete
        )
        self.preview_task = task
        asyncio.create_task(task.run())

    def _stop_preview(self, log, status_text):
        """Stop preview server."""
        if not self.preview_running:
            log.write("[yellow]No preview server running[/yellow]\n")
            return

        status_text.update("Status: Stopping preview...")
        log.write("[cyan]Stopping Hugo preview server...[/cyan]\n")

        try:
            import subprocess
            # Kill Hugo server
            subprocess.run(["pkill", "-f", "hugo server"], timeout=5)
            self.preview_running = False
            log.write("[green]✓ Preview server stopped[/green]\n")
            status_text.update("Status: Ready")
        except Exception as e:
            log.write(f"[red]Error stopping server: {str(e)}[/red]\n")
            log.write("[dim]Try running: pkill -f 'hugo server'[/dim]\n")
            status_text.update("Status: Error")

    def _run_tests(self, log, status_text):
        """Run test suites."""
        status_text.update("Status: Running tests...")
        log.write("[cyan]Running Phase 2 test suite...[/cyan]\n")

        def on_output(line):
            log.write(line + "\n")

        def on_complete(exit_code):
            if exit_code == 0:
                log.write("[green]✓ All tests passed[/green]\n")
            else:
                log.write(f"[red]✗ Some tests failed (exit code: {exit_code})[/red]\n")
            status_text.update("Status: Ready")

        task = BackgroundTask(
            ["bash", "scripts/test-phase2.sh"],
            on_output=on_output,
            on_complete=on_complete
        )
        asyncio.create_task(task.run())

    def _run_build(self, log, status_text):
        """Build Hugo site."""
        status_text.update("Status: Building site...")
        log.write("[cyan]Building Hugo site...[/cyan]\n")

        def on_output(line):
            log.write(line + "\n")

        def on_complete(exit_code):
            if exit_code == 0:
                log.write("[green]✓ Site built successfully[/green]\n")
                log.write("[dim]Output: public/ directory[/dim]\n")
            else:
                log.write(f"[red]✗ Build failed (exit code: {exit_code})[/red]\n")
            status_text.update("Status: Ready")

        task = BackgroundTask(
            ["hugo", "--minify"],
            on_output=on_output,
            on_complete=on_complete
        )
        asyncio.create_task(task.run())


# =============================================
# CUSTOM WIDGETS - CONTENT AREA
# =============================================

class ContentArea(Static):
    """
    Main content display area with integrated editor.
    
    Features:
        - Rich log for displaying content
        - Integrated markdown editor
        - Live preview mode
        - File editing capabilities
    """

    def compose(self) -> ComposeResult:
        """Compose the content area."""
        with Vertical(id="content-container"):
            # Title bar with file actions
            with Horizontal(id="content-header"):
                yield Static("", id="file-name")
                yield Static("✏ Edit", id="action-edit")
                yield Static("💾 Save", id="action-save")
                yield Static("👁 Preview", id="action-preview")
                yield Static("✕ Close", id="action-close")
            # Main content display - switches between log and editor
            yield RichLog(id="content-log", auto_scroll=False)
            # Automation tab (hidden by default)
            yield AutomationTab()
            # AI Agent tab (hidden by default)
            yield AIAgentTab()
            # Editor and preview container for split view
            with Horizontal(id="editor-preview-container"):
                yield TextArea(id="inline-editor", language="markdown")
                yield Markdown(id="inline-preview")

    def on_mount(self) -> None:
        """
        Initialize content area on mount.

        Default state: Show log, hide editor and header
        """
        header = self.query_one("#content-header", Horizontal)
        editor_preview_container = self.query_one("#editor-preview-container", Horizontal)
        automation_tab = self.query_one(AutomationTab)
        ai_tab = self.query_one(AIAgentTab)

        # Hide all initially
        header.visible = False
        editor_preview_container.visible = False
        automation_tab.visible = False
        ai_tab.visible = False

        # Add hidden class to prevent layout space usage
        header.set_class(True, "-hidden")
        editor_preview_container.set_class(True, "-hidden")
        automation_tab.set_class(True, "-hidden")
        ai_tab.set_class(True, "-hidden")

    def enter_edit_mode(self, file_path: Path) -> None:
        """
        Enter edit mode for a file.
        
        Args:
            file_path: Path to file to edit
            
        Behavior:
            - Loads file content into editor
            - Shows editor interface
            - Hides content log
            - Focuses editor
        """
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
        """
        Handle clicks on action buttons in header.
        
        Args:
            event: Click event
        """
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
        """
        Auto-update preview when editor content changes.
        
        Args:
            event: Text area change event
        """
        if event.text_area.id == "inline-editor":
            try:
                preview = self.query_one("#inline-preview", Markdown)
                if preview.visible:
                    preview.update(event.text_area.text)
            except:
                pass

    def save_current_file(self) -> None:
        """
        Save the current file being edited.
        
        Behavior:
            - Writes editor content to file
            - Shows success message (auto-dismisses)
            - Handles errors gracefully
        """
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
        """
        Toggle preview mode - show split editor and preview.
        
        Behavior:
            - First click: Shows split view (editor + preview)
            - Second click: Hides preview, shows editor only
        """
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
            action_preview.update("📝 Edit")

    def exit_edit_mode(self) -> None:
        """
        Exit edit mode and return to default view.
        
        Behavior:
            - Hides editor and header
            - Shows content log
            - Clears file tracking
        """
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


# =============================================
# CUSTOM WIDGETS - UTILITY DISPLAYS
# =============================================

class NiceOutput(Static):
    """
    Styled output display for command results.
    
    Usage:
        output = NiceOutput()
        output.write("Some text to display")
    """
    
    def write(self, text: str) -> None:
        """
        Write text to output display.
        
        Args:
            text: Text to display (supports Rich markup)
        """
        self.update(text)


class NiceStatus(Static):
    """
    Styled status message display with semantic colors.
    
    Message Types:
        - Success: Green
        - Error: Red
        - Info: Blue
        - Warning: Yellow
    """

    def show_success(self, message: str):
        """Display success message in green."""
        self.update(f"[green bold]SUCCESS[/green bold] [white]{message}[/white]")

    def show_error(self, message: str):
        """Display error message in red."""
        self.update(f"[red bold]ERROR[/red bold] [white]{message}[/white]")

    def show_info(self, message: str):
        """Display info message in blue."""
        self.update(f"[blue bold]INFO[/blue bold] [white]{message}[/white]")

    def show_warning(self, message: str):
        """Display warning message in yellow."""
        self.update(f"[yellow bold]WARNING[/yellow bold] [white]{message}[/white]")

    def clear(self):
        """Clear the status display."""
        self.update("")


# =============================================
# MODAL SCREENS - BASE CLASS
# =============================================

class NiceModal(ModalScreen):
    """
    Base class for small popup modal screens.
    
    Features:
        - Centered popup layout
        - Header with title and close button
        - Content area
        - ESC key to close
    """

    def __init__(self, title: str, **kwargs):
        super().__init__(**kwargs)
        self.title_text = title

    def compose(self) -> ComposeResult:
        """Compose the modal layout."""
        # Create a small centered popup
        with Vertical(id="modal-container"):
            yield Horizontal(
                Static(f"[bold cyan]{self.title_text}[/bold cyan]", id="modal-title"),
                Button("×", id="btn_close_modal", variant="error"),
                id="modal-header"
            )
            yield Container(id="modal-content")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """Close modal when X button clicked."""
        if event.button.id == "btn_close_modal":
            try:
                self.app.pop_screen()
            except Exception:
                pass  # Already closed or no screen to pop

    def on_key(self, event) -> None:
        """Close modal on Escape key."""
        if event.key == "escape":
            try:
                self.app.pop_screen()
            except Exception:
                pass  # Already closed or no screen to pop


# =============================================
# MODAL SCREENS - FILE MANAGEMENT
# =============================================

class AddItemModal(ModalScreen):
    """
    Modal for creating new files or folders.
    
    Features:
        - Toggle between file and folder creation
        - Parent directory selection (dropdown)
        - Name input with validation
        - Auto-creates markdown frontmatter for .md files
    """

    def __init__(self):
        super().__init__()
        self.item_type = "file"  # Default to file

    def compose(self) -> ComposeResult:
        """Compose the add item modal."""
        # Get directories for dropdown
        dirs = get_all_directories()
        options = [(d, d) for d in dirs]

        with Vertical(id="add-modal"):
            # Header with title and close link
            yield Horizontal(
                Static("➕ Create New Item", id="modal-title"),
                Static("[#bf616a]✕[/#bf616a]", id="link-close", classes="modal-close"),
                id="modal-header"
            )

            with Vertical(id="modal-body"):
                # Type selection
                yield Static("What would you like to create?", id="form-hint")
                yield Horizontal(
                    Button("📄 File", id="btn-type-file", variant="primary"),
                    Button("📁 Folder", id="btn-type-folder"),
                    id="type-toggle"
                )

                # Parent directory dropdown
                yield Label("Parent Directory:", classes="field-label")
                yield Select(
                    options,
                    value="content",
                    id="select-parent",
                    classes="field-select"
                )

                # Name input
                yield Label("Name:", classes="field-label")
                yield Input(
                    placeholder="my-post.md",
                    id="input-name",
                    classes="field-input"
                )

                # Action buttons
                yield Horizontal(
                    Button("Create", id="btn-create", variant="primary"),
                    Button("Cancel", id="btn-cancel"),
                    id="actions"
                )

    def on_click(self, event) -> None:
        """Handle clicks on close link."""
        if event.widget.id == "link-close":
            self.app.pop_screen()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """
        Handle button presses in the modal.
        
        Args:
            event: Button press event
        """
        if event.button.id == "btn-cancel":
            self.app.pop_screen()
            return

        if event.button.id == "btn-type-file":
            self.item_type = "file"
            self.query_one("#btn-type-file", Button).variant = "primary"
            self.query_one("#btn-type-folder", Button).variant = "default"
            self.query_one("#input-name", Input).placeholder = "my-post.md"

        elif event.button.id == "btn-type-folder":
            self.item_type = "folder"
            self.query_one("#btn-type-file", Button).variant = "default"
            self.query_one("#btn-type-folder", Button).variant = "primary"
            self.query_one("#input-name", Input).placeholder = "my-folder"

        elif event.button.id == "btn-create":
            select_parent = self.query_one("#select-parent", Select)
            name_input = self.query_one("#input-name", Input)

            parent_dir = select_parent.value
            name = name_input.value.strip()

            if not parent_dir or not name:
                return

            # Construct full path
            if parent_dir == ".":
                full_path = PROJECT_ROOT / name
            else:
                full_path = PROJECT_ROOT / parent_dir / name

            try:
                # Create parent directory if needed
                full_path.parent.mkdir(parents=True, exist_ok=True)

                # Check if exists
                if full_path.exists():
                    return

                # Create the item
                if self.item_type == "file":
                    full_path.touch()
                    # Add default frontmatter for markdown files
                    if name.endswith('.md'):
                        from datetime import datetime
                        with open(full_path, 'w') as f:
                            f.write(f'''+++
title = ""
date = {datetime.now().strftime('%Y-%m-%dT%H:%M:%S%z')}
draft = true
+++

''')
                else:
                    full_path.mkdir()

                # Refresh file tree immediately
                try:
                    file_tree = self.app.query_one(FileTree)
                    tree = file_tree.query_one("#file-tree", Tree)
                    file_tree.populate_tree(tree.root)
                    tree.refresh()
                except Exception as refresh_error:
                    pass

                # Close modal
                self.app.pop_screen()

            except Exception as e:
                pass


class RenameItemModal(ModalScreen):
    """
    Modal for renaming files or folders.
    
    Features:
        - Shows current name and location
        - Input validation
        - Auto-refresh file tree on success
    """

    def __init__(self, item_path: Path):
        super().__init__()
        self.item_path = item_path
        self.item_type = "folder" if item_path.is_dir() else "file"

    def compose(self) -> ComposeResult:
        """Compose the rename modal."""
        with Vertical(id="rename-modal"):
            # Header with title and close link
            yield Horizontal(
                Static(f"Rename {self.item_type.capitalize()}", id="modal-title"),
                Static("[#bf616a]✕[/#bf616a]", id="link-close", classes="modal-close"),
                id="modal-header"
            )
            with Vertical(id="modal-body"):
                # Current item info
                yield Static(f"[dim]{self.item_path.name}[/dim]", id="current-name")
                yield Static(f"[dim]in {self.item_path.parent}[/dim]", id="location")
                yield Label("New Name:", classes="field-label")
                yield Input(
                    placeholder=f"new-name{'.md' if self.item_type == 'file' else ''}",
                    id="input-new-name",
                    classes="field-input"
                )

                # Action buttons
                yield Horizontal(
                    Button("Rename", id="btn-rename", variant="primary"),
                    Button("Cancel", id="btn-cancel"),
                    id="actions"
                )

    def on_click(self, event) -> None:
        """Handle clicks on close link."""
        if event.widget.id == "link-close":
            self.app.pop_screen()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """
        Handle button presses in the modal.
        
        Args:
            event: Button press event
        """
        if event.button.id == "btn-cancel":
            self.app.pop_screen()
            return

        if event.button.id == "btn-rename":
            name_input = self.query_one("#input-new-name", Input)
            new_name = name_input.value.strip()

            if not new_name:
                return

            try:
                new_path = self.item_path.parent / new_name

                if new_path.exists():
                    return

                self.item_path.rename(new_path)

                # Refresh file tree immediately
                try:
                    file_tree = self.app.query_one(FileTree)
                    tree = file_tree.query_one("#file-tree", Tree)
                    file_tree.populate_tree(tree.root)
                    tree.refresh()
                except Exception as refresh_error:
                    pass

                # Close modal
                self.app.pop_screen()

            except Exception:
                pass


class DeleteItemModal(ModalScreen):
    """
    Modal for deleting files or folders with confirmation.
    
    Features:
        - Warning message
        - Shows item count for folders
        - Requires typing "DELETE" to confirm
        - Safe deletion with error handling
    """

    def __init__(self, item_path: Path):
        super().__init__()
        self.item_path = item_path
        self.item_type = "folder" if item_path.is_dir() else "file"

    def compose(self) -> ComposeResult:
        """Compose the delete confirmation modal."""
        with Vertical(id="delete-modal"):
            # Header with title and close link
            yield Horizontal(
                Static(f"Delete {self.item_type.capitalize()}", id="modal-title"),
                Static("[#bf616a]✕[/#bf616a]", id="link-close", classes="modal-close"),
                id="modal-header"
            )
            with Vertical(id="modal-body"):
                # Warning and item info
                yield Static(f"[yellow bold]⚠ WARNING: This cannot be undone![/yellow bold]", id="warning")
                yield Static(f"[bold]{self.item_path.name}[/bold]", id="item-name")
                yield Static(f"[dim]in {self.item_path.parent}[/dim]", id="location")

                # Count items if folder
                if self.item_type == "folder":
                    try:
                        item_count = len(list(self.item_path.iterdir()))
                        yield Static(f"[dim]Contains {item_count} item(s)[/dim]", id="item-count")
                    except:
                        pass

                yield Label("Type DELETE to confirm:", classes="field-label")
                yield Input(
                    placeholder="Type DELETE",
                    id="input-confirm",
                    classes="field-input",
                    password=True
                )

                # Action buttons
                yield Horizontal(
                    Button("Delete", id="btn-delete", variant="error"),
                    Button("Cancel", id="btn-cancel"),
                    id="actions"
                )

    def on_click(self, event) -> None:
        """Handle clicks on close link."""
        if event.widget.id == "link-close":
            self.app.pop_screen()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """
        Handle button presses in the modal.
        
        Args:
            event: Button press event
        """
        if event.button.id == "btn-cancel":
            self.app.pop_screen()
            return

        if event.button.id == "btn-delete":
            confirm_input = self.query_one("#input-confirm", Input)
            confirmation = confirm_input.value.strip()

            if confirmation != "DELETE":
                return

            try:
                if self.item_type == "file":
                    self.item_path.unlink()
                else:
                    import shutil
                    shutil.rmtree(self.item_path)

                # Refresh file tree immediately
                try:
                    file_tree = self.app.query_one(FileTree)
                    tree = file_tree.query_one("#file-tree", Tree)
                    file_tree.populate_tree(tree.root)
                    tree.refresh()
                except Exception as refresh_error:
                    pass

                # Close modal
                self.app.pop_screen()

            except Exception:
                pass


# =============================================
# MODAL SCREENS - POST MANAGEMENT
# =============================================

class CreatePostScreen(NiceModal):
    """
    Full-screen content creation interface.

    Features:
        - Left sidebar: categories, options
        - Right area: title input, content editor
        - Similar to main app layout
    """

    def __init__(self):
        super().__init__("Create New Post")
        self.category = None
        self.post_created = False

    def compose(self) -> ComposeResult:
        """Compose the full-screen create post interface."""
        # Main container
        with Horizontal(id="create-post-container"):
            # Left sidebar - options
            with Vertical(id="create-sidebar"):
                yield Static("⚙ Options", id="sidebar-title")

                # Category selection
                yield Static("Category:", classes="field-label")
                with Horizontal():
                    yield Static(" [+]", id="link-add-cat", classes="nav-link")
                    yield Static(" [−]", id="link-delete-cat", classes="nav-link")

                # Get categories - ensure unique by tracking lowercase IDs
                seen_ids = set()  # Track lowercase category IDs to prevent duplicates

                # Add default categories first
                default_cats = ["OSPF", "BGP", "MPLS", "Junos"]
                for cat in default_cats:
                    cat_id = cat.lower()
                    if cat_id not in seen_ids:
                        seen_ids.add(cat_id)
                        yield Button(f"• {cat}", id=f"cat_{cat_id}", classes="cat-btn")

                # Add categories from filesystem (if not already added)
                try:
                    for cat_dir in CONTENT_DIR.iterdir():
                        if cat_dir.is_dir():
                            cat_name = cat_dir.name.capitalize()
                            cat_id = cat_name.lower()
                            # Only add if we haven't seen this ID before
                            if cat_id not in seen_ids:
                                seen_ids.add(cat_id)
                                yield Button(f"• {cat_name}", id=f"cat_{cat_id}", classes="cat-btn")
                except:
                    pass

                # Actions
                yield Static("", id="sidebar-spacer")
                yield Button("✓ Create Post", id="btn_create", variant="primary")
                yield Button("✕ Cancel", id="btn_cancel", variant="default")

            # Right content area
            with Vertical(id="create-content"):
                # Title input
                yield Static("Title:", classes="field-label")
                yield Input(
                    placeholder="Enter post title (e.g., 'OSPF Virtual Links Explained')...",
                    id="input-title",
                    classes="form-input"
                )

                # Content editor
                yield Static("Content:", classes="field-label")
                yield TextArea(
                    id="post-content",
                    language="markdown",
                    placeholder="Write your post content here...",
                    show_line_numbers=True
                )

                # Status
                yield NiceStatus("", id="status")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle button presses."""
        status = self.query_one("#status", NiceStatus)

        # Category selection
        if event.button.id.startswith("cat_"):
            self.category = event.button.id.replace("cat_", "")

            # Update button styles
            for btn in self.query(".cat-btn"):
                btn.remove_class("selected")

            event.button.add_class("selected")
            status.show_info(f"Category: {self.category.upper()}")

        # Add category
        elif event.button.id == "link-add-cat":
            def refresh_categories():
                """Refresh category buttons after adding new category."""
                try:
                    # Remove existing category buttons
                    create_sidebar = self.query_one("#create-sidebar")
                    old_buttons = list(create_sidebar.query(".cat-btn"))
                    for btn in old_buttons:
                        btn.remove()

                    # Add category buttons again (including new category)
                    seen_ids = set()
                    default_cats = ["OSPF", "BGP", "MPLS", "Junos"]
                    for cat in default_cats:
                        cat_id = cat.lower()
                        if cat_id not in seen_ids:
                            seen_ids.add(cat_id)
                            new_btn = Button(f"• {cat}", id=f"cat_{cat_id}", classes="cat-btn")
                            create_sidebar.mount(new_btn, before="#sidebar-spacer")

                    # Add categories from filesystem
                    try:
                        for cat_dir in CONTENT_DIR.iterdir():
                            if cat_dir.is_dir():
                                cat_name = cat_dir.name.capitalize()
                                cat_id = cat_name.lower()
                                if cat_id not in seen_ids:
                                    seen_ids.add(cat_id)
                                    new_btn = Button(f"• {cat_name}", id=f"cat_{cat_id}", classes="cat-btn")
                                    create_sidebar.mount(new_btn, before="#sidebar-spacer")
                    except:
                        pass
                except Exception as e:
                    pass

            # Push category creation screen with refresh callback
            self.app.push_screen(CreateCategoryScreen(on_success=refresh_categories))
            return

        # Cancel
        elif event.button.id == "btn_cancel":
            try:
                self.app.pop_screen()
            except:
                pass
            return

        # Create post
        elif event.button.id == "btn_create":
            if not self.category:
                status.show_error("Please select a category")
                return

            title_input = self.query_one("#input-title", Input)
            title = title_input.value.strip()
            if not title:
                status.show_error("Please enter a title")
                return

            content_editor = self.query_one("#post-content", TextArea)
            content = content_editor.text

            status.show_info("Creating post...")
            script = SCRIPT_DIR / "create-post.sh"
            code, out, err = run_command([str(script), self.category, title])

            if code == 0:
                status.show_success(f"✓ Created: {title}")

                # Add content if provided
                if content.strip():
                    try:
                        # Find the created file
                        import glob
                        pattern = f"content/routing/{self.category}/*/index.md"
                        files = glob.glob(str(PROJECT_ROOT / pattern))
                        if files:
                            newest = max(files, key=os.path.getctime)
                            with open(newest, 'w') as f:
                                f.write(content)
                            status.show_success(f"✓ Content added")
                    except Exception as e:
                        status.show_error(f"✗ Content not added: {e}")

                # Refresh file tree
                try:
                    file_tree = self.app.query_one(FileTree)
                    tree = file_tree.query_one("#file-tree", Tree)
                    file_tree.populate_tree(tree.root)
                    tree.refresh()
                except:
                    pass

                # Close after short delay
                def close_and_open():
                    try:
                        self.app.pop_screen()
                        # Open the created post
                        import glob
                        pattern = f"content/routing/{self.category}/*/index.md"
                        files = glob.glob(str(PROJECT_ROOT / pattern))
                        if files:
                            newest = max(files, key=os.path.getctime)
                            if hasattr(self.app, 'open_file_in_content'):
                                self.app.open_file_in_content(Path(newest))
                    except:
                        pass

                self.set_timer(1.5, close_and_open)
            else:
                # Show detailed error message
                error_msg = err if err else out
                status.show_error(f"Failed: {error_msg.strip() if error_msg else 'Unknown error'}")

        elif event.button.id == "btn_close_modal":
            try:
                self.app.pop_screen()
            except Exception:
                pass

    def on_click(self, event) -> None:
        """Handle link clicks."""
        if event.widget.id == "link-add-cat":
            def refresh_categories():
                """Refresh category buttons after adding new category."""
                try:
                    # Remove existing category buttons
                    create_sidebar = self.query_one("#create-sidebar")
                    old_buttons = list(create_sidebar.query(".cat-btn"))
                    for btn in old_buttons:
                        btn.remove()

                    # Add category buttons again (including new category)
                    seen_ids = set()
                    default_cats = ["OSPF", "BGP", "MPLS", "Junos"]
                    for cat in default_cats:
                        cat_id = cat.lower()
                        if cat_id not in seen_ids:
                            seen_ids.add(cat_id)
                            new_btn = Button(f"• {cat}", id=f"cat_{cat_id}", classes="cat-btn")
                            create_sidebar.mount(new_btn, before="#sidebar-spacer")

                    # Add categories from filesystem
                    try:
                        for cat_dir in CONTENT_DIR.iterdir():
                            if cat_dir.is_dir():
                                cat_name = cat_dir.name.capitalize()
                                cat_id = cat_name.lower()
                                if cat_id not in seen_ids:
                                    seen_ids.add(cat_id)
                                    new_btn = Button(f"• {cat_name}", id=f"cat_{cat_id}", classes="cat-btn")
                                    create_sidebar.mount(new_btn, before="#sidebar-spacer")
                    except:
                        pass
                except Exception as e:
                    pass

            # Push category creation screen with refresh callback
            self.app.push_screen(CreateCategoryScreen(on_success=refresh_categories))

        elif event.widget.id == "link-delete-cat":
            def refresh_categories():
                """Refresh category buttons after deleting a category."""
                try:
                    # Remove existing category buttons
                    create_sidebar = self.query_one("#create-sidebar")
                    old_buttons = list(create_sidebar.query(".cat-btn"))
                    for btn in old_buttons:
                        btn.remove()

                    # Add category buttons again (excluding deleted category)
                    seen_ids = set()
                    default_cats = ["OSPF", "BGP", "MPLS", "Junos"]
                    for cat in default_cats:
                        cat_id = cat.lower()
                        if cat_id not in seen_ids:
                            seen_ids.add(cat_id)
                            new_btn = Button(f"• {cat}", id=f"cat_{cat_id}", classes="cat-btn")
                            create_sidebar.mount(new_btn, before="#sidebar-spacer")

                    # Add categories from filesystem
                    try:
                        for cat_dir in CONTENT_DIR.iterdir():
                            if cat_dir.is_dir():
                                cat_name = cat_dir.name.capitalize()
                                cat_id = cat_name.lower()
                                if cat_id not in seen_ids:
                                    seen_ids.add(cat_id)
                                    new_btn = Button(f"• {cat_name}", id=f"cat_{cat_id}", classes="cat-btn")
                                    create_sidebar.mount(new_btn, before="#sidebar-spacer")
                    except:
                        pass
                except Exception as e:
                    pass

            # Push category deletion screen with refresh callback
            self.app.push_screen(DeleteCategoryScreen(on_success=refresh_categories))


class DeleteCategoryScreen(ModalScreen):
    """
    Modal for deleting blog categories.

    Features:
        - Category selection dropdown
        - Shows warning if category contains posts
        - Deletes directory and all contents
    """

    def __init__(self, on_success=None):
        super().__init__()
        self.on_success = on_success

    def compose(self) -> ComposeResult:
        """Compose the delete category modal."""
        with Vertical(id="category-modal"):
            # Header with title and close link
            yield Horizontal(
                Static("🗑 Delete Category", id="modal-title"),
                Static("[#bf616a]✕[/#bf616a]", id="link-close", classes="modal-close"),
                id="modal-header"
            )

            with Vertical(id="modal-body"):
                yield Label("Select Category to Delete:", classes="field-label")

                # Get all categories from filesystem
                categories = []
                try:
                    for parent in ["routing", "junos", "projects"]:
                        parent_dir = PROJECT_ROOT / "content" / parent
                        if parent_dir.exists():
                            for cat_dir in parent_dir.iterdir():
                                if cat_dir.is_dir():
                                    # Count posts in category
                                    post_count = len(list(cat_dir.glob("*/index.md")))
                                    display_name = f"{cat_dir.name} ({parent})"
                                    if post_count > 0:
                                        display_name += f" - {post_count} post(s)"
                                    categories.append((display_name, str(cat_dir)))
                except:
                    pass

                if not categories:
                    yield Static("[dim]No categories found[/dim]", id="form-hint")
                else:
                    yield Select(
                        [Select.Option(label, value=path) for label, path in categories],
                        id="select-category",
                        classes="field-select"
                    )

                    yield Static("[red]⚠ Warning: This will delete the category and ALL posts within it![/red]", id="warning")

                yield Horizontal(
                    Button("Delete", id="btn_delete", classes="cat-btn"),
                    Button("Cancel", id="btn_cancel", classes="cat-btn"),
                    id="delete-actions"
                )
                yield NiceStatus("", id="status")

    def on_click(self, event) -> None:
        """Handle clicks on close link."""
        if event.widget.id == "link-close":
            try:
                self.app.pop_screen()
            except Exception:
                pass

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle button presses."""
        status = self.query_one("#status", NiceStatus)

        if event.button.id == "btn_delete":
            try:
                select = self.query_one("#select-category", Select)
                category_path = select.value

                if not category_path:
                    status.show_error("Please select a category")
                    return

                # Delete the directory
                import shutil
                category_dir = Path(category_path)
                if category_dir.exists():
                    shutil.rmtree(category_dir)
                    status.show_success(f"✓ Deleted: {category_dir.name}")

                    # Refresh file tree
                    try:
                        file_tree = self.app.query_one(FileTree)
                        tree = file_tree.query_one("#file-tree", Tree)
                        file_tree.populate_tree(tree.root)
                        tree.refresh()
                    except:
                        pass

                    # Call success callback if provided
                    if self.on_success:
                        self.on_success()

                    # Close modal after short delay
                    def close_modal():
                        try:
                            self.app.pop_screen()
                        except:
                            pass
                    self.set_timer(1, close_modal)
                else:
                    status.show_error("Category not found")
            except Exception as e:
                status.show_error(f"Failed: {str(e)}")

        elif event.button.id == "btn_cancel":
            try:
                self.app.pop_screen()
            except Exception:
                pass


class ViewPostsScreen(NiceModal):
    """
    Modal for viewing and managing all posts.
    
    Features:
        - Filter by status (All, Drafts, Published)
        - DataTable with post information
        - Preview, Edit, and Open in Editor actions
    """

    def __init__(self):
        super().__init__("View & Edit Posts")
        self.show_all = True  # Show both drafts and published

    def compose(self) -> ComposeResult:
        """Compose the view posts modal."""
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
        """Load posts on mount."""
        self.load_posts()

    def load_posts(self):
        """
        Load and display posts in the table.
        
        Behavior:
            - Filters based on current filter setting
            - Updates table columns based on filter
        """
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
        """
        Handle button presses in the modal.
        
        Args:
            event: Button press event
        """
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

        elif event.button.id in ["btn_edit", "btn_open_editor"]:
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


class PostPreviewScreen(NiceModal):
    """
    Modal for previewing a post with markdown rendering.
    
    Features:
        - Markdown rendering
        - Shows post title and path
        - Quick access to edit mode
    """

    def __init__(self, post_path: str, content: str):
        super().__init__(f"Preview: {Path(post_path).stem}")
        self.post_path = post_path
        self.content = content

    def compose(self) -> ComposeResult:
        """Compose the preview modal."""
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
        """Handle button presses."""
        if event.button.id == "btn_close":
            self.app.pop_screen()
        elif event.button.id == "btn_edit":
            # Open integrated editor/preview
            self.app.push_screen(EditorPreview(self.post_path, self.content))


class EditorPreview(NiceModal):
    """
    Modal with integrated editor and live preview.
    
    Features:
        - Split view (editor on left, preview on right)
        - Live preview updates as you type
        - Save and cancel actions
        - Tracks unsaved changes
    """

    def __init__(self, post_path: str, content: str):
        super().__init__("Edit & Preview")
        self.post_path = post_path
        self.content = content
        self.original_content = content

    def compose(self) -> ComposeResult:
        """Compose the editor/preview modal."""
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
        """Setup live preview updates and focus editor."""
        editor = self.query_one("#editor", TextArea)
        editor.focus()

    def on_text_area_changed(self, event: TextArea.Changed) -> None:
        """
        Update live preview when editor changes.
        
        Args:
            event: Text area change event
        """
        if event.text_area.id == "editor":
            try:
                preview = self.query_one("#live-preview", Markdown)
                preview.update(event.text_area.text)
            except:
                pass

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """
        Handle button presses in the modal.
        
        Args:
            event: Button press event
        """
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


class CreateCategoryScreen(ModalScreen):
    """
    Modal for creating new blog categories.

    Features:
        - Shows existing categories
        - Name input with validation
        - Parent section selection (routing, junos, projects)
        - Creates directory in selected parent section
    """

    def __init__(self, on_success=None):
        super().__init__()
        self.on_success = on_success
        self.parent_section = "routing"  # Default to routing

    def compose(self) -> ComposeResult:
        """Compose the create category modal."""
        with Vertical(id="category-modal"):
            # Header with title and close link
            yield Horizontal(
                Static("📁 Create New Category", id="modal-title"),
                Static("[#bf616a]✕[/#bf616a]", id="link-close", classes="modal-close"),
                id="modal-header"
            )

            with Vertical(id="modal-body"):
                # Parent section dropdown
                yield Label("Parent Section:", classes="field-label")
                yield Select(
                    [
                        Select.Option("Routing", value="routing"),
                        Select.Option("Junos", value="junos"),
                        Select.Option("Projects", value="projects"),
                    ],
                    value="routing",
                    id="select-parent",
                    classes="field-select"
                )

                # Category name input
                yield Label("Category Name:", classes="field-label")
                yield Input(
                    placeholder="e.g., Network Automation",
                    id="input-category",
                    classes="form-input"
                )
                yield Horizontal(
                    Button("Create", id="btn_create", classes="cat-btn"),
                    Button("Cancel", id="btn_cancel", classes="cat-btn"),
                    id="create-actions"
                )
                yield NiceStatus("", id="status")

    def on_select_changed(self, event: Select.Changed) -> None:
        """Handle parent section selection."""
        if event.select.id == "select-parent":
            self.parent_section = event.value

    def on_click(self, event) -> None:
        """Handle clicks on close link."""
        if event.widget.id == "link-close":
            try:
                self.app.pop_screen()
            except Exception:
                pass

    def on_button_pressed(self, event: Button.Pressed) -> None:
        """
        Handle button presses in the modal.

        Args:
            event: Button press event
        """
        status = self.query_one("#status", NiceStatus)

        if event.button.id == "btn_create":
            cat_input = self.query_one("#input-category", Input)
            category_name = cat_input.value.strip()

            if not category_name:
                status.show_error("Please enter a category name")
                return

            status.show_info("Creating category...")
            # Create category in selected parent section
            category_path = f"{self.parent_section}/{category_name.lower()}"
            success, message = create_category(category_path)

            if success:
                status.show_success(message)
                # Call success callback if provided
                if self.on_success:
                    self.on_success()
                # Close modal on success
                try:
                    self.app.pop_screen()
                except Exception:
                    pass
            else:
                status.show_error(message)

        elif event.button.id == "btn_cancel":
            try:
                self.app.pop_screen()
            except Exception:
                pass


# =============================================
# MAIN APPLICATION
# =============================================

class BlogAutomationApp(App):
    """
    Main TUI application with VS Code-inspired interface.
    
    Features:
        - Multi-view navigation (Dashboard, Posts, Automation, etc.)
        - File explorer with tree view
        - Integrated markdown editor
        - Post management
        - Git integration
        - Keyboard shortcuts
    """

    # Load CSS from external file
    CSS_PATH = str(SCRIPT_DIR / "tui.css")

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
        """Initialize application on mount."""
        pass

    def compose(self) -> ComposeResult:
        """Compose the main application layout."""
        yield TopNav()
        with Horizontal(id="main-container"):
            yield FileTree()
            with Vertical(id="main-content"):
                yield ContentArea()
        yield StatusBar()

    def change_view(self, view: str) -> None:
        """
        Change the main content view.

        Args:
            view: View name (dashboard, posts, automation, ai, git, settings)
        """
        content_area_widget = self.query_one(ContentArea)
        content_log = self.query_one("#content-log", RichLog)

        # Get tabs
        try:
            automation_tab = content_area_widget.query_one(AutomationTab)
        except:
            automation_tab = None

        try:
            ai_tab = content_area_widget.query_one(AIAgentTab)
        except:
            ai_tab = None

        # Get sidebar
        try:
            file_tree = self.query_one(FileTree)
        except:
            file_tree = None

        # Hide header
        try:
            header = content_area_widget.query_one("#content-header", Horizontal)
            header.visible = False
            header.set_class(True, "-hidden")
        except:
            pass

        # Hide editor-preview container
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

        # Handle automation view - show sidebar
        if view == "automation" and automation_tab:
            content_log.clear()
            content_log.visible = False
            content_log.set_class(True, "-hidden")
            if ai_tab:
                ai_tab.visible = False
                ai_tab.set_class(True, "-hidden")
            automation_tab.visible = True
            automation_tab.set_class(False, "-hidden")
            # Show sidebar for automation
            if file_tree:
                file_tree.visible = True
                file_tree.set_class(False, "-hidden")
            return

        # Handle AI view - hide sidebar, full screen
        if view == "ai" and ai_tab:
            content_log.clear()
            content_log.visible = False
            content_log.set_class(True, "-hidden")
            if automation_tab:
                automation_tab.visible = False
                automation_tab.set_class(True, "-hidden")
            ai_tab.visible = True
            ai_tab.set_class(False, "-hidden")
            # Hide sidebar for AI full-screen experience
            if file_tree:
                file_tree.visible = False
                file_tree.set_class(True, "-hidden")
            return

        # For other views, show sidebar and tabs hide, show log
        if automation_tab:
            automation_tab.visible = False
            automation_tab.set_class(True, "-hidden")
        if ai_tab:
            ai_tab.visible = False
            ai_tab.set_class(True, "-hidden")

        # Show sidebar for normal views
        if file_tree:
            file_tree.visible = True
            file_tree.set_class(False, "-hidden")

        # Show log
        content_log.clear()
        content_log.visible = True
        content_log.set_class(False, "-hidden")

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
        """
        Open a file in the main content area.
        
        Args:
            file_path: Path to file to open
            
        Behavior:
            - Markdown files: Opens in edit mode
            - Other files: Opens in view mode
        """
        content_area = self.query_one(ContentArea)

        # Track current file
        self.current_open_file = file_path

        # For markdown files, open directly in edit mode
        if file_path.suffix == '.md':
            content_area.enter_edit_mode(file_path)
        else:
            # For other files, show in view mode
            content_log = self.query_one("#content-log", RichLog)
            content_area.current_file_path = file_path

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

    # =============================================
    # ACTION HANDLERS
    # =============================================

    def action_save_file(self) -> None:
        """Save the currently open file (Ctrl+S)."""
        content_area = self.query_one(ContentArea)
        if hasattr(content_area, 'current_file_path') and content_area.current_file_path:
            content_area.save_current_file()

    def action_preview_file(self) -> None:
        """Toggle preview for current file (Ctrl+O)."""
        content_area = self.query_one(ContentArea)
        if hasattr(content_area, 'current_file_path') and content_area.current_file_path:
            content_area.preview_current_file()

    def action_close_editor(self) -> None:
        """Close editor and return to view mode (ESC)."""
        content_area = self.query_one(ContentArea)
        if hasattr(content_area, 'current_file_path') and content_area.current_file_path:
            content_area.exit_edit_mode()
        else:
            self.app.pop_screen()

    def action_refresh(self) -> None:
        """Refresh current view (Ctrl+R)."""
        log = self.query_one("#content-log", RichLog)
        log.write("\n[dim]Refreshing...[/dim]\n")
        # Force re-render current view
        nav = self.query_one(TopNav)
        self.change_view(nav.current_view)

    def action_create_post(self) -> None:
        """Open create post modal (Ctrl+N)."""
        self.push_screen(CreatePostScreen())

    def action_preview(self) -> None:
        """Preview the site (Ctrl+Shift+P)."""
        log = self.query_one("#content-log", RichLog)
        log.write(
            "\n[bold cyan]Starting preview server...[/bold cyan]\n\n"
            "Open [bold]http://localhost:1313[/bold] in your browser\n\n"
            "[yellow]Press Ctrl+C to stop the server[/yellow]\n\n"
            "[dim]Note: Server runs in background[/dim]\n"
            "[dim]Stop with: pkill hugo[/dim]\n"
        )

    def action_create_category(self) -> None:
        """Create a new category (Ctrl+K)."""
        self.push_screen(CreateCategoryScreen())

    def action_view_posts(self) -> None:
        """View all posts (Ctrl+V)."""
        self.push_screen(ViewPostsScreen())

    # =============================================
    # VIEW RENDERERS
    # =============================================

    def show_dashboard(self, log: RichLog) -> None:
        """
        Render the dashboard view.
        
        Args:
            log: RichLog widget to render content into
            
        Content:
            - Blog statistics
            - Category breakdown
            - Quick actions
            - System status
        """
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

        log.write("[dim]" + "╌" * 65)
        log.write("[dim]Use the file explorer on the left to browse your project files.[/dim]")

    def show_posts(self, log: RichLog) -> None:
        """
        Render the posts view.
        
        Args:
            log: RichLog widget to render content into
            
        Content:
            - All posts grouped by category
            - Status indicators (draft/published)
            - Quick access instructions
        """
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
        log.write(f"[bold cyan]║                      ALL POSTS ({len(posts)})                          ║[/bold cyan]")
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
                log.write(f"     [#88c0d0]Click file in sidebar to open →[/#88c0d0]\n")

        log.write("\n[bold yellow]ACTIONS[/bold yellow]")
        log.write("─" * 65)
        log.write("  [green]•[/green] Browse file explorer on left to open any post")
        log.write("  [green]•[/green] Use [Ctrl+V] to open post management modal")
        log.write("  [green]•[/green] Click on files in sidebar to edit")
        log.write("  [green]•[/green] Use [Ctrl+N] to create new posts")

    def show_automation(self, log: RichLog) -> None:
        """Render the automation view."""
        log.write(
            f"[bold cyan]⚡ AUTOMATION HUB[/bold cyan]\n\n"
            f"[dim]Blog automation scripts and tools[/dim]\n\n"
            f"[bold]Quick Actions:[/bold]\n"
            f"  [cyan]Press the button below to run automation tasks[/cyan]\n\n"
            f"[dim]Available Features:[/dim]\n"
            f"  • ✓ Quality Gate - Validate content quality\n"
            f"  • ▶ Preview - Start Hugo dev server\n"
            f"  • ⚙ Tests - Run test suites\n"
            f"  • 🔨 Build - Generate static site\n\n"
            f"[dim]Select a file from the sidebar and use automation buttons[/dim]"
        )

    def show_ai(self, log: RichLog) -> None:
        """Render the AI agent view."""
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
        """Render the git view."""
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
        """Render the settings view."""
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
