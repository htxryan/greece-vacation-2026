#!/usr/bin/env ruby
# frozen_string_literal: true

# Jekyll Navigation Validator for Just the Docs Theme
#
# Validates that all .md files in the Jekyll site follow the navigation scheme:
# - Every page has required front matter (title)
# - nav_order is ONLY allowed on the "Home" page (alphabetical sorting used elsewhere)
# - Parent references are valid (point to existing pages)
# - No use of grand_parent (not supported)
# - No duplicate titles (parent matching is by title)
# - All pages are reachable in the navigation hierarchy
#
# Exit codes:
#   0 - All validations passed
#   2 - Validation errors found (blocking - Claude will see and react to errors)
#   3 - Script error

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
    end
  end

  def validate_nav_order_restricted
    @pages.each do |file_path, front_matter|
      next unless front_matter['nav_order']

      title = front_matter['title']
      next if title == 'Home'

      rel_path = file_path.relative_path_from(@root_dir)
      @errors << ValidationError.new(
        rel_path,
        "nav_order is only allowed on 'Home' page - use alphabetical sorting for all other pages"
      )
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

  def validate_reachability
    @pages.each do |file_path, front_matter|
      title = front_matter['title']
      next unless title

      # Top-level pages (no parent) are valid - they'll be sorted alphabetically
      next unless front_matter['parent']

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

  def validate
    load_pages

    if @pages.empty?
      puts "Warning: No Jekyll pages found to validate"
      return true
    end

    # Run validations in order
    validate_required_fields
    validate_nav_order_restricted
    build_title_index
    validate_no_grand_parent
    validate_parent_references
    validate_reachability

    @errors.none? { |e| e.severity == :error }
  end

  def print_report
    if @errors.empty?
      puts "All #{@pages.size} Jekyll pages passed navigation validation"
      return
    end

    error_list = @errors.select { |e| e.severity == :error }
    warning_list = @errors.select { |e| e.severity == :warning }

    # Write to stderr when there are errors (for hook integration)
    out = error_list.empty? ? $stdout : $stderr

    out.puts
    out.puts "Jekyll Navigation Validation Report"
    out.puts "=" * 50
    out.puts "Pages scanned: #{@pages.size}"
    out.puts "Errors: #{error_list.size}"
    out.puts "Warnings: #{warning_list.size}"
    out.puts

    unless error_list.empty?
      out.puts "ERRORS:"
      out.puts "-" * 50
      error_list.each do |error|
        out.puts "  #{error.file_path}"
        out.puts "    #{error.message}"
      end
      out.puts
    end

    unless warning_list.empty?
      out.puts "WARNINGS:"
      out.puts "-" * 50
      warning_list.each do |warning|
        out.puts "  #{warning.file_path}"
        out.puts "    #{warning.message}"
      end
      out.puts
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
    exit 3
  end

  puts "Validating Jekyll navigation in: #{root_dir}"

  validator = JekyllNavValidator.new(root_dir)
  success = validator.validate
  validator.print_report

  exit(success ? 0 : 2)
end

main if __FILE__ == $PROGRAM_NAME
