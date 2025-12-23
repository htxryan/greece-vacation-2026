#!/usr/bin/env python3
"""
Jekyll Navigation Validator for Just the Docs Theme

Validates that all .md files in the Jekyll site follow the navigation scheme:
- Every page has required front matter (title, nav_order)
- Parent references are valid (point to existing pages)
- Pages with has_children actually have children
- No use of grand_parent (not supported)
- No duplicate titles (parent matching is by title)
- All pages are reachable in the navigation hierarchy

Exit codes:
  0 - All validations passed
  1 - Validation errors found
  2 - Script error (e.g., missing dependencies)
"""

import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Any

# Directories/files to exclude from validation
EXCLUDE_PATTERNS = [
    '.claude',
    '_site',
    '_layouts',
    '_includes',
    '_sass',
    'node_modules',
    '.git',
    'README.md',
    'CLAUDE.md',
]


def parse_front_matter(content: str) -> Optional[Dict[str, Any]]:
    """
    Parse YAML front matter from markdown content.
    Returns None if no valid front matter found.
    """
    # Match YAML front matter between --- delimiters
    match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
    if not match:
        return None

    yaml_content = match.group(1)
    front_matter: Dict[str, Any] = {}

    # Simple YAML parsing (handles the cases we need)
    for line in yaml_content.split('\n'):
        line = line.strip()
        if not line or line.startswith('#'):
            continue

        if ':' in line:
            key, value = line.split(':', 1)
            key = key.strip()
            value = value.strip()

            # Handle boolean values
            if value.lower() == 'true':
                front_matter[key] = True
            elif value.lower() == 'false':
                front_matter[key] = False
            # Handle numeric values
            elif value.isdigit():
                front_matter[key] = int(value)
            # Handle quoted strings
            elif (value.startswith('"') and value.endswith('"')) or \
                 (value.startswith("'") and value.endswith("'")):
                front_matter[key] = value[1:-1]
            else:
                front_matter[key] = value

    return front_matter


def find_jekyll_files(root_dir: Path) -> List[Path]:
    """
    Find all .md files that are part of the Jekyll site.
    Excludes files in directories matching EXCLUDE_PATTERNS.
    """
    jekyll_files = []

    for md_file in root_dir.rglob('*.md'):
        # Get relative path for checking exclusions
        rel_path = md_file.relative_to(root_dir)
        rel_path_str = str(rel_path)

        # Check if file should be excluded
        should_exclude = False
        for pattern in EXCLUDE_PATTERNS:
            if rel_path_str.startswith(pattern) or rel_path.name == pattern:
                should_exclude = True
                break

        if not should_exclude:
            jekyll_files.append(md_file)

    return sorted(jekyll_files)


class ValidationError:
    """Represents a validation error."""

    def __init__(self, file_path: Path, message: str, severity: str = 'error'):
        self.file_path = file_path
        self.message = message
        self.severity = severity  # 'error' or 'warning'

    def __str__(self) -> str:
        return f"[{self.severity.upper()}] {self.file_path}: {self.message}"


class JekyllNavValidator:
    """Validates Jekyll navigation structure."""

    def __init__(self, root_dir: Path):
        self.root_dir = root_dir
        self.pages: Dict[Path, Dict[str, Any]] = {}
        self.titles: Dict[str, Path] = {}  # title -> file path
        self.errors: List[ValidationError] = []

    def load_pages(self) -> None:
        """Load and parse all Jekyll pages."""
        jekyll_files = find_jekyll_files(self.root_dir)

        for file_path in jekyll_files:
            try:
                content = file_path.read_text(encoding='utf-8')
                front_matter = parse_front_matter(content)

                if front_matter is not None:
                    self.pages[file_path] = front_matter
            except Exception as e:
                self.errors.append(ValidationError(
                    file_path,
                    f"Failed to read file: {e}"
                ))

    def validate_required_fields(self) -> None:
        """Validate that all pages have required front matter fields."""
        for file_path, front_matter in self.pages.items():
            # Check for title
            if 'title' not in front_matter:
                self.errors.append(ValidationError(
                    file_path,
                    "Missing required 'title' in front matter"
                ))

            # Check for nav_order
            if 'nav_order' not in front_matter:
                self.errors.append(ValidationError(
                    file_path,
                    "Missing required 'nav_order' in front matter"
                ))

    def build_title_index(self) -> None:
        """Build an index of titles to file paths and check for duplicates."""
        for file_path, front_matter in self.pages.items():
            title = front_matter.get('title')
            if title:
                if title in self.titles:
                    self.errors.append(ValidationError(
                        file_path,
                        f"Duplicate title '{title}' (also in {self.titles[title].relative_to(self.root_dir)})"
                    ))
                else:
                    self.titles[title] = file_path

    def validate_no_grand_parent(self) -> None:
        """Validate that no pages use the unsupported grand_parent property."""
        for file_path, front_matter in self.pages.items():
            if 'grand_parent' in front_matter:
                self.errors.append(ValidationError(
                    file_path,
                    "Using 'grand_parent' which is not supported - use 'parent' pointing to the child page's title instead"
                ))

    def validate_parent_references(self) -> None:
        """Validate that all parent references point to existing pages."""
        for file_path, front_matter in self.pages.items():
            parent = front_matter.get('parent')
            if parent:
                if parent not in self.titles:
                    self.errors.append(ValidationError(
                        file_path,
                        f"Parent '{parent}' does not match any page title"
                    ))
                else:
                    # Check that parent has has_children: true
                    parent_path = self.titles[parent]
                    parent_front_matter = self.pages[parent_path]
                    if not parent_front_matter.get('has_children'):
                        self.errors.append(ValidationError(
                            parent_path,
                            f"Page is referenced as parent by '{front_matter.get('title', file_path.name)}' but lacks 'has_children: true'"
                        ))

    def validate_has_children(self) -> None:
        """Validate that pages with has_children actually have children."""
        # Build set of all parent titles
        parent_titles: Set[str] = set()
        for front_matter in self.pages.values():
            parent = front_matter.get('parent')
            if parent:
                parent_titles.add(parent)

        # Check pages with has_children
        for file_path, front_matter in self.pages.items():
            if front_matter.get('has_children'):
                title = front_matter.get('title')
                if title and title not in parent_titles:
                    self.errors.append(ValidationError(
                        file_path,
                        f"Page has 'has_children: true' but no pages reference it as parent",
                        severity='warning'
                    ))

    def validate_reachability(self) -> None:
        """Validate that all pages are reachable in the navigation hierarchy."""
        for file_path, front_matter in self.pages.items():
            title = front_matter.get('title')
            if not title:
                continue

            # If page has no parent, it must have nav_order to be top-level
            if 'parent' not in front_matter:
                if 'nav_order' not in front_matter:
                    self.errors.append(ValidationError(
                        file_path,
                        "Page has no parent and no nav_order - will not appear in navigation"
                    ))
            else:
                # Trace parent chain to ensure it reaches a top-level page
                visited = {title}
                current_parent = front_matter.get('parent')

                while current_parent:
                    if current_parent in visited:
                        self.errors.append(ValidationError(
                            file_path,
                            f"Circular parent reference detected involving '{current_parent}'"
                        ))
                        break

                    if current_parent not in self.titles:
                        # Already reported as invalid parent
                        break

                    visited.add(current_parent)
                    parent_path = self.titles[current_parent]
                    parent_front_matter = self.pages[parent_path]
                    current_parent = parent_front_matter.get('parent')

    def validate_nav_order_uniqueness(self) -> None:
        """Validate that nav_order is unique among siblings."""
        # Group pages by their parent
        siblings: Dict[Optional[str], List[Tuple[Path, Dict[str, Any]]]] = {}

        for file_path, front_matter in self.pages.items():
            parent = front_matter.get('parent')
            if parent not in siblings:
                siblings[parent] = []
            siblings[parent].append((file_path, front_matter))

        # Check for duplicate nav_order within each group
        for parent, pages in siblings.items():
            nav_orders: Dict[int, Path] = {}
            for file_path, front_matter in pages:
                nav_order = front_matter.get('nav_order')
                if nav_order is not None:
                    if nav_order in nav_orders:
                        context = f"under parent '{parent}'" if parent else "at top level"
                        self.errors.append(ValidationError(
                            file_path,
                            f"Duplicate nav_order {nav_order} {context} (also in {nav_orders[nav_order].relative_to(self.root_dir)})",
                            severity='warning'
                        ))
                    else:
                        nav_orders[nav_order] = file_path

    def validate(self) -> bool:
        """
        Run all validations and return True if no errors found.
        """
        self.load_pages()

        if not self.pages:
            print("Warning: No Jekyll pages found to validate")
            return True

        # Run validations in order
        self.validate_required_fields()
        self.build_title_index()
        self.validate_no_grand_parent()
        self.validate_parent_references()
        self.validate_has_children()
        self.validate_reachability()
        self.validate_nav_order_uniqueness()

        return len([e for e in self.errors if e.severity == 'error']) == 0

    def print_report(self) -> None:
        """Print validation report."""
        if not self.errors:
            print(f"All {len(self.pages)} Jekyll pages passed navigation validation")
            return

        errors = [e for e in self.errors if e.severity == 'error']
        warnings = [e for e in self.errors if e.severity == 'warning']

        print(f"\nJekyll Navigation Validation Report")
        print("=" * 50)
        print(f"Pages scanned: {len(self.pages)}")
        print(f"Errors: {len(errors)}")
        print(f"Warnings: {len(warnings)}")
        print()

        if errors:
            print("ERRORS:")
            print("-" * 50)
            for error in errors:
                rel_path = error.file_path.relative_to(self.root_dir)
                print(f"  {rel_path}")
                print(f"    {error.message}")
            print()

        if warnings:
            print("WARNINGS:")
            print("-" * 50)
            for warning in warnings:
                rel_path = warning.file_path.relative_to(self.root_dir)
                print(f"  {rel_path}")
                print(f"    {warning.message}")
            print()


def main() -> int:
    """Main entry point."""
    # Determine root directory
    if len(sys.argv) > 1:
        root_dir = Path(sys.argv[1]).resolve()
    else:
        # Use current working directory or find project root
        root_dir = Path.cwd()

        # Try to find project root by looking for _config.yml or index.md
        check_dir = root_dir
        while check_dir != check_dir.parent:
            if (check_dir / '_config.yml').exists() or \
               (check_dir / 'index.md').exists():
                root_dir = check_dir
                break
            check_dir = check_dir.parent

    if not root_dir.exists():
        print(f"Error: Directory not found: {root_dir}", file=sys.stderr)
        return 2

    print(f"Validating Jekyll navigation in: {root_dir}")

    validator = JekyllNavValidator(root_dir)
    success = validator.validate()
    validator.print_report()

    return 0 if success else 1


if __name__ == '__main__':
    sys.exit(main())
