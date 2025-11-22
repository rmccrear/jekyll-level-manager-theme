#!/usr/bin/env ruby
# Standalone script to build individual level files from all-levels.md
# Usage: ruby scripts/build_levels.rb [source_file] [output_dir] [file_pattern]
#
# Arguments (all optional):
#   source_file: Path to all-levels.md (default: _levels/all-levels.md)
#   output_dir: Directory for generated files (default: _levels)
#   file_pattern: Pattern for filenames (default: level-{{ number }})

require 'fileutils'
require 'yaml'

# Get arguments or use defaults
source_file_arg = ARGV[0]
output_dir_arg = ARGV[1]
file_pattern_arg = ARGV[2]

# Try to read from _config.yml if it exists
config = {}
config_file = File.join(__dir__, '..', '_config.yml')
if File.exist?(config_file)
  begin
    config = YAML.load_file(config_file)['level_manager'] || {}
  rescue
    # If config file doesn't exist or has errors, use defaults
  end
end

# Use config or arguments, with fallback defaults
SOURCE_FILE = source_file_arg || config['source_file'] || File.join(__dir__, '..', '_levels', 'all-levels.md')
OUTPUT_DIR = output_dir_arg || config['collection_dir'] || File.join(__dir__, '..', '_levels')
FILE_PATTERN = file_pattern_arg || config['file_pattern'] || 'level-{{ number }}'

def parse_level_attributes(attrs_str)
  attrs = {}
  
  # Parse: number=1 title="Level 1" subtitle="Planning" file="db-mini-project-lv-1"
  # Handle quoted values
  attrs_str.scan(/(\w+)=["']([^"']+)["']/) do |key, value|
    key = key.to_sym
    # Convert number to integer if it's a number
    attrs[key] = value.match?(/^\d+$/) ? value.to_i : value
    attrs[key.to_s] = attrs[key]  # Also store as string for compatibility
  end
  
  # Parse unquoted numbers
  attrs_str.scan(/(\w+)=(\d+)/) do |key, value|
    key = key.to_sym
    attrs[key] = value.to_i
    attrs[key.to_s] = value.to_i
  end
  
  attrs
end

def parse_level_blocks(content, file_pattern)
  levels = []
  
  # Pattern to match {% level ... %} ... {% endlevel %}
  pattern = /{%\s*level\s+([^%]+?)\s*%}(.*?){%\s*endlevel\s*%}/m
  
  level_number = 1  # Auto-number starting from 1
  
  content.scan(pattern) do |attrs_str, level_content|
    attrs = parse_level_attributes(attrs_str)
    
    # Use auto-numbering (order in file) instead of explicit number
    number = level_number
    level_number += 1
    
    # Generate filename from pattern (supports {{ number }} variable)
    filename = file_pattern.gsub('{{ number }}', number.to_s)
    
    levels << {
      number: number,
      title: "Level #{number}",  # Auto-generate title based on number
      subtitle: attrs[:subtitle] || attrs['subtitle'] || '',
      file: filename,  # Auto-generate file name based on pattern
      content: level_content.strip
    }
  end
  
  # No need to sort - already in order
  levels
end

def build_individual_levels
  unless File.exist?(SOURCE_FILE)
    puts "Error: Source file not found: #{SOURCE_FILE}"
    exit 1
  end
  
  content = File.read(SOURCE_FILE)
  
  # Remove front matter if present
  if content.start_with?('---')
    parts = content.split(/^---\s*$/, 3)
    content = parts[2].strip if parts.length >= 3
  end
  
  # Parse level blocks
  levels = parse_level_blocks(content, FILE_PATTERN)
  
  if levels.empty?
    puts "Error: No level blocks found in #{SOURCE_FILE}"
    exit 1
  end
  
  # Get URL pattern from config
  url_pattern = config['url_pattern'] || "/levels/:name.html"
  collection_name = config['collection_name'] || 'levels'
  
  # Create a dictionary of levels by subtitle for cross-referencing
  levels_by_subtitle = {}
  levels.each do |level|
    url = url_pattern.gsub(':name', level[:file]).gsub(':number', level[:number].to_s)
    levels_by_subtitle[level[:subtitle]] = {
      'number' => level[:number],
      'title' => level[:title],
      'subtitle' => level[:subtitle],
      'file' => level[:file],
      'url' => url
    }
  end
  
  puts "Found #{levels.length} levels to build..."
  
  levels.each do |level|
    filename = "#{level[:file]}.md"
    filepath = File.join(OUTPUT_DIR, filename)
    
    # Generate front matter
    front_matter = <<~YAML
---
layout: level
title: #{level[:title]}
subtitle: #{level[:subtitle]}
number: #{level[:number]}
file: #{level[:file]}
---

    YAML
    
    # Process content as Liquid template to evaluate variables like {{ level.number }}
    # This allows headings like "# Level {{ level.number }}: {{ level.subtitle }}"
    begin
      require 'liquid'
      liquid_context = Liquid::Context.new
      liquid_context['level'] = {
        'number' => number,
        'title' => "Level #{number}",
        'subtitle' => attrs[:subtitle] || attrs['subtitle'] || ''
      }
      liquid_context['level_number'] = number
      liquid_context['level_subtitle'] = attrs[:subtitle] || attrs['subtitle'] || ''
      
      # Make all levels available for cross-referencing
      liquid_context['levels_by_subtitle'] = levels_by_subtitle
      liquid_context['all_levels'] = levels_by_subtitle.values
      
      template = Liquid::Template.parse(level[:content])
      processed_content = template.render(liquid_context)
    rescue => e
      puts "Warning: Liquid parsing error: #{e.message}"
      processed_content = level[:content]
    end
    
    # Auto-generate markdown heading from number and subtitle
    heading = "# #{level[:title]}: #{level[:subtitle]}"
    
    # Remove existing heading if it matches the pattern (Level X: ...) or template pattern
    content = processed_content.strip
    # Remove heading patterns: "# Level X: ...", "# Level X", or Liquid template "# Level {{ ... }}"
    content = content.sub(/^#\s*Level\s+\d+[:\s].*?$/m, '')
    content = content.sub(/^#\s*Level\s+\d+\s*$/m, '')
    content = content.sub(/^#\s*Level\s+\{\{.*?\}\}.*?$/m, '')  # Remove Liquid template headings
    content = content.gsub(/\n{3,}/, "\n\n")  # Normalize multiple newlines
    content = content.strip  # Remove any leading/trailing whitespace
    
    # Combine front matter, auto-generated heading, and content
    file_content = front_matter + heading + "\n\n" + content + "\n"
    
    # Write file
    File.write(filepath, file_content)
    
    puts "  ✓ Generated #{filename}"
  end
  
  puts "\n✅ Successfully generated #{levels.length} individual level files!"
  puts "   Output directory: #{OUTPUT_DIR}"
end

# Run the build
build_individual_levels

