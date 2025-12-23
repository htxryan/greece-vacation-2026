#!/usr/bin/env ruby
# frozen_string_literal: true

# Jekyll Navigation Validator for Just the Docs Theme
#
# Validates that all .md files in the Jekyll site follow the navigation scheme:
# - Every page has required front matter (title, nav_order)
# - Parent references are valid (point to existing pages)
# - Pages with has_children actually have children
# - No use of grand_parent (not supported)
# - No duplicate titles (parent matching is by title)
# - All pages are reachable in the navigation hierarchy
#
# Exit codes:
#   0 - All validations passed
#   1 - Validation errors found
#   2 - Script error

require 'yaml'
require 'pathname'

# Directories/files to exclude from validation
EXCLUDE_PATTERNS = %w[
  .claude
  _site
  _layouts
  _includes
  _sass
  node_modules
  .git
  README.md
  CLAUDE.md
].freeze

class ValidationError
  attr_reader :file_path, :message, :severity

  def initialize(file_path, message, severity: :error)
    @file_path = file_path
    @message = message
    @severity = severity
  end

  def to_s
    "[#{severity.to_s.upcase}] #{file_path}: #{message}"
  end
end

class JekyllNavValidator
  attr_reader :root_dir, :pages, :titles, :errors

  def initialize(root_dir)
    @root_dir = Pathname.new(root_dir).expand_path
    @pages = {}          # file_path => front_matter hash
    @titles = {}         # title => file_path
    @errors = []
  end

  def find_jekyll_files
    files = []
    Dir.glob(@root_dir.join('**/*.md')).each do |file|
      file_path = Pathname.new(file)
      rel_path = file_path.relative_path_from(@root_dir).to_s

      # Check if file should be excluded
      should_exclude = EXCLUDE_PATTERNS.any? do |pattern|
        rel_path.start_with?(pattern) || File.basename(rel_path) == pattern
      end

      files << file_path unless should_exclude
    end
    files.sort
  end

  def parse_front_matter(content)
    return nil unless content.start_with?('---')

    # Find the closing ---
    second_marker = content.index('---', 3)
    return nil unless second_marker

    yaml_content = content[3...second_marker].strip
    begin
      YAML.safe_load(yaml_content, permitted_classes: [Symbol])
    rescue Psych::SyntaxError => e
      nil
    end
  end

  def load_pages
    find_jekyll_files.each do |file_path|
      begin
        content = File.read(file_path, encoding: 'UTF-8')
        front_matter = parse_front_matter(content)

        if front_matter.is_a?(Hash)
          @pages[file_path] = front_matter
        end
      rescue => e
        @errors << ValidationError.new(
          file_path.relative_path_from(@root_dir),
          "Failed to read file: #{e.message}"
        )
      end
    end
  end

  def validate_required_fields
    @pages.each do |file_path, front_matter|
      rel_path = file_path.relative_path_from(@root_dir)

      unless front_matter['title']
        @errors << ValidationError.new(
          rel_path,
          "Missing required 'title' in front matter"
        )
      end

      unless front_matter['nav_order']
        @errors << ValidationError.new(
          rel_path,
          "Missing required 'nav_order' in front matter"
        )
      end
    end
  end

  def build_title_index
    @pages.each do |file_path, front_matter|
      title = front_matter['title']
      next unless title

      rel_path = file_path.relative_path_from(@root_dir)

      if @titles[title]
        @errors << ValidationError.new(
          rel_path,
          "Duplicate title '#{title}' (also in #{@titles[title]})"
        )
      else
        @titles[title] = rel_path
      end
    end
  end

  def validate_no_grand_parent
    @pages.each do |file_path, front_matter|
      next unless front_matter['grand_parent']

      rel_path = file_path.relative_path_from(@root_dir)
      @errors << ValidationError.new(
        rel_path,
        "Using 'grand_parent' which is not supported - use 'parent' pointing to the child page's title instead"
      )
    end
  end

  def validate_parent_references
    @pages.each do |file_path, front_matter|
      parent = front_matter['parent']
      next unless parent

      rel_path = file_path.relative_path_from(@root_dir)

      unless @titles[parent]
        @errors << ValidationError.new(
          rel_path,
          "Parent '#{parent}' does not match any page title"
        )
        next
      end

      # Find parent's front matter and check has_children
      parent_file = @pages.find { |_, fm| fm['title'] == parent }
      if parent_file
        parent_front_matter = parent_file[1]
        unless parent_front_matter['has_children']
          @errors << ValidationError.new(
            @titles[parent],
            "Page is referenced as parent by '#{front_matter['title'] || rel_path}' but lacks 'has_children: true'"
          )
        end
      end
    end
  end

  def validate_has_children
    # Build set of all parent titles
    parent_titles = Set.new
    @pages.each_value do |front_matter|
      parent = front_matter['parent']
      parent_titles << parent if parent
    end

    # Check pages with has_children
    @pages.each do |file_path, front_matter|
      next unless front_matter['has_children']

      title = front_matter['title']
      next unless title

      unless parent_titles.include?(title)
        rel_path = file_path.relative_path_from(@root_dir)
        @errors << ValidationError.new(
          rel_path,
          "Page has 'has_children: true' but no pages reference it as parent",
          severity: :warning
        )
      end
    end
  end

  def validate_reachability
    @pages.each do |file_path, front_matter|
      title = front_matter['title']
      next unless title

      rel_path = file_path.relative_path_from(@root_dir)

      # If page has no parent, it must have nav_order to be top-level
      unless front_matter['parent']
        unless front_matter['nav_order']
          @errors << ValidationError.new(
            rel_path,
            "Page has no parent and no nav_order - will not appear in navigation"
          )
        end
        next
      end

      # Trace parent chain to ensure it reaches a top-level page
      visited = Set.new([title])
      current_parent = front_matter['parent']

      while current_parent
        if visited.include?(current_parent)
          @errors << ValidationError.new(
            rel_path,
            "Circular parent reference detected involving '#{current_parent}'"
          )
          break
        end

        unless @titles[current_parent]
          # Already reported as invalid parent
          break
        end

        visited << current_parent

        # Find parent's front matter
        parent_file = @pages.find { |_, fm| fm['title'] == current_parent }
        break unless parent_file

        current_parent = parent_file[1]['parent']
      end
    end
  end

  def validate_nav_order_uniqueness
    # Group pages by their parent
    siblings = Hash.new { |h, k| h[k] = [] }

    @pages.each do |file_path, front_matter|
      parent = front_matter['parent']
      siblings[parent] << [file_path, front_matter]
    end

    # Check for duplicate nav_order within each group
    siblings.each do |parent, pages_list|
      nav_orders = {}
      pages_list.each do |file_path, front_matter|
        nav_order = front_matter['nav_order']
        next unless nav_order

        rel_path = file_path.relative_path_from(@root_dir)

        if nav_orders[nav_order]
          context = parent ? "under parent '#{parent}'" : "at top level"
          @errors << ValidationError.new(
            rel_path,
            "Duplicate nav_order #{nav_order} #{context} (also in #{nav_orders[nav_order]})",
            severity: :warning
          )
        else
          nav_orders[nav_order] = rel_path
        end
      end
    end
  end

  def validate
    load_pages

    if @pages.empty?
      puts "Warning: No Jekyll pages found to validate"
      return true
    end

    # Run validations in order
    validate_required_fields
    build_title_index
    validate_no_grand_parent
    validate_parent_references
    validate_has_children
    validate_reachability
    validate_nav_order_uniqueness

    @errors.none? { |e| e.severity == :error }
  end

  def print_report
    if @errors.empty?
      puts "All #{@pages.size} Jekyll pages passed navigation validation"
      return
    end

    error_list = @errors.select { |e| e.severity == :error }
    warning_list = @errors.select { |e| e.severity == :warning }

    puts
    puts "Jekyll Navigation Validation Report"
    puts "=" * 50
    puts "Pages scanned: #{@pages.size}"
    puts "Errors: #{error_list.size}"
    puts "Warnings: #{warning_list.size}"
    puts

    unless error_list.empty?
      puts "ERRORS:"
      puts "-" * 50
      error_list.each do |error|
        puts "  #{error.file_path}"
        puts "    #{error.message}"
      end
      puts
    end

    unless warning_list.empty?
      puts "WARNINGS:"
      puts "-" * 50
      warning_list.each do |warning|
        puts "  #{warning.file_path}"
        puts "    #{warning.message}"
      end
      puts
    end
  end
end

def main
  # Determine root directory
  root_dir = if ARGV[0]
               File.expand_path(ARGV[0])
             else
               # Use current working directory or find project root
               dir = Dir.pwd
               while dir != File.dirname(dir)
                 if File.exist?(File.join(dir, '_config.yml')) ||
                    File.exist?(File.join(dir, 'index.md'))
                   break
                 end
                 dir = File.dirname(dir)
               end
               dir
             end

  unless File.directory?(root_dir)
    warn "Error: Directory not found: #{root_dir}"
    exit 2
  end

  puts "Validating Jekyll navigation in: #{root_dir}"

  validator = JekyllNavValidator.new(root_dir)
  success = validator.validate
  validator.print_report

  exit(success ? 0 : 1)
end

main if __FILE__ == $PROGRAM_NAME
