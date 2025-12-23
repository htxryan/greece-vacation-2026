#!/bin/bash
# Cross-platform wrapper for Jekyll navigation validation
# This script runs the Ruby validator

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

ruby "$SCRIPT_DIR/validate-jekyll-nav.rb" "$PROJECT_ROOT"
