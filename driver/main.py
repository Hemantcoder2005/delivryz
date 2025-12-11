import os
import difflib
import re
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from pathlib import Path

IGNORED_DIRS_DEFAULT = {
    ".git", ".svn", ".hg", "__pycache__", "build", "dist", "out",
    ".idea", ".vscode", ".vs", ".gradle", ".dart_tool", "node_modules",
    ".cache", ".pytest_cache", "target"
}

# ------------------------------------------------------
# Syntax Highlighting Rules
# ------------------------------------------------------
HIGHLIGHT_RULES = {
    "python": {
        "keywords": r"\b(False|class|finally|is|return|None|continue|for|lambda|try|True|def|from|nonlocal|while|and|del|global|not|with|as|elif|if|or|yield|assert|else|import|pass|break|except|in|raise)\b",
        "strings": r"(\"[^\"]*\"|'[^']*')",
        "comments": r"#.*",
        "numbers": r"\b\d+(\.\d+)?\b",
    },
    "dart": {
        "keywords": r"\b(abstract|else|import|super|as|enum|in|switch|assert|export|interface|sync|await|extends|is|this|break|external|library|throw|case|factory|mixin|true|catch|false|new|try|class|final|null|typedef|const|finally|on|var|continue|for|operator|void|covariant|get|part|while|default|hide|rethrow|with|deferred|if|return|yield|do|implements|set|dynamic|static)\b",
        "strings": r"(\"[^\"]*\"|'[^']*')",
        "comments": r"//.*|/\*[\s\S]*?\*/",
        "numbers": r"\b\d+(\.\d+)?\b",
    },
    "html": {
        "tags": r"</?[\w\-]+(?:\s+[\w\-]+(?:=(?:\"[^\"]*\"|'[^']*'|[^\s>]+))?)*\s*/?>",
        "strings": r"(\"[^\"]*\"|'[^']*')",
        "comments": r"<!--[\s\S]*?-->",
    }
}

class DiffViewer:
    def __init__(self, root, dir1: str, dir2: str, min_change_threshold=0.05):
        self.root = root
        self.root.title("Visual Directory Diff Tool (Dark Mode + Syntax)")
        self.root.geometry("1500x850")

        self.dir1 = Path(dir1)
        self.dir2 = Path(dir2)
        self.file_pairs = []
        self.current_index = 0
        self.changes_made = False
        self.original_left = ""
        self.original_right = ""
        self.min_change_threshold = min_change_threshold  # 5% minimum change by default

        self.setup_dark_theme()
        self.setup_ui()
        self.scan_directories()
        if self.file_pairs:
            self.load_file_pair(0)
        else:
            messagebox.showinfo("Info", "No significant differences found between directories!")

    # ------------------------------------------------------
    # Theme
    # ------------------------------------------------------
    def setup_dark_theme(self):
        self.bg_color = "#1e1e1e"
        self.text_bg = "#252526"
        self.text_fg = "#d4d4d4"
        self.diff_left_color = "#ff9999"     # brighter red
        self.diff_right_color = "#99ff99"    # brighter green
        self.missing_color = "#2d3f50"
        self.accent_color = "#0e639c"

        style = ttk.Style()
        style.theme_use("clam")
        style.configure("TFrame", background=self.bg_color)
        style.configure("TLabel", background=self.bg_color, foreground=self.text_fg)
        style.configure("TLabelFrame", background=self.bg_color, foreground=self.text_fg)
        style.configure("TButton", background=self.accent_color, foreground="white", padding=6)
        style.map("TButton", background=[("active", "#1177bb")])
        style.configure("TCombobox", fieldbackground=self.text_bg, foreground=self.text_fg)

    # ------------------------------------------------------
    # UI
    # ------------------------------------------------------
    def setup_ui(self):
        top = ttk.Frame(self.root, padding="10")
        top.pack(fill=tk.X)
        ttk.Label(top, text="File:").pack(side=tk.LEFT, padx=5)
        self.file_combo = ttk.Combobox(top, width=80, state='readonly')
        self.file_combo.pack(side=tk.LEFT, padx=5)
        self.file_combo.bind('<<ComboboxSelected>>', self.on_file_selected)
        ttk.Button(top, text="◄ Prev", command=self.prev_file).pack(side=tk.LEFT, padx=5)
        ttk.Button(top, text="Next ►", command=self.next_file).pack(side=tk.LEFT, padx=5)
        self.status_label = ttk.Label(top, text="")
        self.status_label.pack(side=tk.LEFT, padx=20)

        main = ttk.Frame(self.root, padding="10")
        main.pack(fill=tk.BOTH, expand=True)

        self.left_text = self.make_text_widget(main, "Directory 1", side=tk.LEFT, padx=(0, 5))
        self.right_text = self.make_text_widget(main, "Directory 2", side=tk.LEFT, padx=(5, 0))

        bottom = ttk.Frame(self.root, padding="10")
        bottom.pack(fill=tk.X)
        ttk.Button(bottom, text="Save Left", command=self.save_left).pack(side=tk.LEFT, padx=5)
        ttk.Button(bottom, text="Save Right", command=self.save_right).pack(side=tk.LEFT, padx=5)
        ttk.Button(bottom, text="Save Both", command=self.save_both).pack(side=tk.LEFT, padx=5)
        ttk.Button(bottom, text="Discard Changes", command=self.discard_changes).pack(side=tk.LEFT, padx=20)
        ttk.Button(bottom, text="Copy All Left → Right", command=self.copy_left_to_right).pack(side=tk.LEFT, padx=5)
        ttk.Button(bottom, text="Copy All Right → Left", command=self.copy_right_to_left).pack(side=tk.LEFT, padx=5)

    def make_text_widget(self, parent, label, side, padx):
        frame = ttk.LabelFrame(parent, text=label, padding="5")
        frame.pack(side=side, fill=tk.BOTH, expand=True, padx=padx)
        path_label = ttk.Label(frame, text="", wraplength=600)
        path_label.pack(anchor=tk.W, pady=(0, 5))
        scroll_y = ttk.Scrollbar(frame)
        scroll_y.pack(side=tk.RIGHT, fill=tk.Y)
        scroll_x = ttk.Scrollbar(frame, orient=tk.HORIZONTAL)
        scroll_x.pack(side=tk.BOTTOM, fill=tk.X)
        text = tk.Text(frame, wrap=tk.NONE, yscrollcommand=scroll_y.set,
                       xscrollcommand=scroll_x.set, background=self.text_bg,
                       foreground=self.text_fg, insertbackground="white",
                       font=("Consolas", 11), undo=True)
        text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scroll_y.config(command=text.yview)
        scroll_x.config(command=text.xview)
        text.tag_config('diff', background=self.diff_left_color)
        text.tag_config('missing', background=self.missing_color)
        # syntax tags
        text.tag_config('keyword', foreground='#569cd6')
        text.tag_config('string', foreground='#ce9178')
        text.tag_config('comment', foreground='#6a9955')
        text.tag_config('number', foreground='#b5cea8')
        text.tag_config('tag', foreground='#569cd6')
        return text

    # ------------------------------------------------------
    # Core Logic
    # ------------------------------------------------------
    def has_significant_changes(self, content1, content2):
        """Check if two files have significant differences (more than threshold)"""
        # Always consider it significant if one file is empty and the other isn't
        if (not content1 and content2) or (not content2 and content1):
            return True
        
        # If both are empty or very small, not significant
        if not content1 and not content2:
            return False
        
        lines1 = content1.splitlines()
        lines2 = content2.splitlines()
        
        # If line count difference is large, it's significant
        max_lines = max(len(lines1), len(lines2))
        if max_lines == 0:
            return False
        
        # Count actual differences
        diff = list(difflib.Differ().compare(lines1, lines2))
        changed_lines = sum(1 for line in diff if line.startswith('+ ') or line.startswith('- '))
        
        # Calculate change ratio
        change_ratio = changed_lines / max_lines
        
        # Return True if change ratio exceeds threshold
        return change_ratio >= self.min_change_threshold

    def scan_directories(self):
        files1 = self.list_files(self.dir1)
        files2 = self.list_files(self.dir2)
        all_paths = sorted(set(files1.keys()) | set(files2.keys()))
        for rel in all_paths:
            f1 = files1.get(rel)
            f2 = files2.get(rel)
            # If one file is missing, it's a significant difference
            if f1 is None or f2 is None:
                self.file_pairs.append((f1, f2, rel))
                continue
            # If both files exist, compare their content
            try:
                content1 = Path(f1).read_text(encoding='utf-8', errors='ignore')
                content2 = Path(f2).read_text(encoding='utf-8', errors='ignore')
                # Only add if contents are different AND significantly different
                if content1 != content2 and self.has_significant_changes(content1, content2):
                    self.file_pairs.append((f1, f2, rel))
            except Exception:
                # If we can't read the files, assume they're different
                self.file_pairs.append((f1, f2, rel))
        
        self.file_combo['values'] = [str(rp) for _, _, rp in self.file_pairs]
        if self.file_pairs:
            self.file_combo.current(0)
            self.update_status()

    def list_files(self, base: Path):
        result = {}
        for root, dirs, files in os.walk(base):
            dirs[:] = [d for d in dirs if d not in IGNORED_DIRS_DEFAULT]
            for f in files:
                p = Path(root) / f
                try:
                    result[p.relative_to(base)] = p
                except Exception:
                    pass
        return result

    def load_file_pair(self, index: int):
        if not 0 <= index < len(self.file_pairs):
            return
        self.current_index = index
        f1, f2, rel = self.file_pairs[index]
        c1 = Path(f1).read_text(encoding='utf-8', errors='ignore') if f1 and Path(f1).exists() else ""
        c2 = Path(f2).read_text(encoding='utf-8', errors='ignore') if f2 and Path(f2).exists() else ""
        self.original_left, self.original_right = c1, c2
        self.left_text.delete('1.0', tk.END)
        self.right_text.delete('1.0', tk.END)
        self.left_text.insert('1.0', c1)
        self.right_text.insert('1.0', c2)
        ext = rel.suffix.lower()
        lang = 'python' if ext == '.py' else 'dart' if ext == '.dart' else 'html' if ext in ('.html', '.htm') else None
        self.apply_syntax(self.left_text, c1, lang)
        self.apply_syntax(self.right_text, c2, lang)
        self.highlight_diff(c1, c2)
        self.update_status()

    # ------------------------------------------------------
    # Highlighting
    # ------------------------------------------------------
    def apply_syntax(self, text_widget, content, lang):
        # clear old tags
        for tag in ('keyword', 'string', 'comment', 'number', 'tag'):
            text_widget.tag_remove(tag, '1.0', tk.END)
        if not lang or lang not in HIGHLIGHT_RULES:
            return
        rules = HIGHLIGHT_RULES[lang]
        for tag, pattern in rules.items():
            for match in re.finditer(pattern, content, re.MULTILINE):
                start = f"1.0+{match.start()}c"
                end = f"1.0+{match.end()}c"
                text_widget.tag_add(tag, start, end)

    def highlight_diff(self, c1, c2):
        for t in (self.left_text, self.right_text):
            t.tag_remove('diff', '1.0', tk.END)
            t.tag_remove('missing', '1.0', tk.END)
        if not c1 and c2:
            self.right_text.tag_add('missing', '1.0', tk.END)
            return
        if not c2 and c1:
            self.left_text.tag_add('missing', '1.0', tk.END)
            return
        diff = list(difflib.Differ().compare(c1.splitlines(True), c2.splitlines(True)))
        l, r = 1, 1
        for line in diff:
            if line.startswith('- '):
                self.left_text.tag_add('diff', f"{l}.0", f"{l}.end")
                l += 1
            elif line.startswith('+ '):
                self.right_text.tag_add('diff', f"{r}.0", f"{r}.end")
                r += 1
            elif line.startswith('  '):
                l += 1
                r += 1

    # ------------------------------------------------------
    # Navigation and Save
    # ------------------------------------------------------
    def update_status(self):
        total = len(self.file_pairs)
        cur = self.current_index + 1
        self.status_label.config(text=f"File {cur} of {total}")

    def on_file_selected(self, e):
        self.load_file_pair(self.file_combo.current())

    def prev_file(self):
        if self.current_index > 0:
            self.file_combo.current(self.current_index - 1)
            self.load_file_pair(self.current_index - 1)

    def next_file(self):
        if self.current_index < len(self.file_pairs) - 1:
            self.file_combo.current(self.current_index + 1)
            self.load_file_pair(self.current_index + 1)

    def save_left(self):
        f1, _, rel = self.file_pairs[self.current_index]
        target = f1 or (self.dir1 / rel)
        Path(target).parent.mkdir(parents=True, exist_ok=True)
        Path(target).write_text(self.left_text.get('1.0', 'end-1c'), encoding='utf-8')
        messagebox.showinfo("Saved", f"Saved {target}")

    def save_right(self):
        _, f2, rel = self.file_pairs[self.current_index]
        target = f2 or (self.dir2 / rel)
        Path(target).parent.mkdir(parents=True, exist_ok=True)
        Path(target).write_text(self.right_text.get('1.0', 'end-1c'), encoding='utf-8')
        messagebox.showinfo("Saved", f"Saved {target}")

    def save_both(self):
        self.save_left()
        self.save_right()

    def discard_changes(self):
        self.left_text.delete('1.0', tk.END)
        self.right_text.delete('1.0', tk.END)
        self.left_text.insert('1.0', self.original_left)
        self.right_text.insert('1.0', self.original_right)
        self.highlight_diff(self.original_left, self.original_right)

    def copy_left_to_right(self):
        content = self.left_text.get('1.0', 'end-1c')
        self.right_text.delete('1.0', tk.END)
        self.right_text.insert('1.0', content)
        self.highlight_diff(content, content)

    def copy_right_to_left(self):
        content = self.right_text.get('1.0', 'end-1c')
        self.left_text.delete('1.0', tk.END)
        self.left_text.insert('1.0', content)
        self.highlight_diff(content, content)

# ------------------------------------------------------
# Entry Point
# ------------------------------------------------------
def select_directory(prompt):
    root = tk.Tk()
    root.withdraw()
    d = filedialog.askdirectory(title=prompt)
    root.destroy()
    return d

def main():
    d1 = select_directory("Select First Directory")
    if not d1: return
    d2 = select_directory("Select Second Directory")
    if not d2: return
    root = tk.Tk()
    # Default threshold is 5% (0.05) - at least 5% of lines must be different
    # You can adjust this: 0.01 = 1%, 0.10 = 10%, etc.
    DiffViewer(root, d1, d2, min_change_threshold=0.05)
    root.mainloop()

if __name__ == "__main__":
    main()