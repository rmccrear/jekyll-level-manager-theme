module Jekyll
  class BuildLevelsGenerator < Generator
    safe true
    priority :high  # Run early, before other generators

    def generate(site)
      # Get configuration with defaults
      config = site.config['level_manager'] || {}
      
      # Check if we're in multi-lesson mode
      lessons = site.config['lessons'] || []
      
      if lessons.any?
        # Multi-lesson mode: build levels for each lesson
        lessons.each do |lesson|
          build_lesson_levels(site, lesson, config)
        end
      else
        # Single lesson mode: use configured source file
        source_file = config['source_file'] || '_levels/all-levels.md'
        all_levels_file = File.join(site.source, source_file)
        
        return unless File.exist?(all_levels_file)
        
        # Only build individual files if enabled in config
        if config['build_individual_levels'] != false
          build_individual_levels(site, all_levels_file, config, nil)
        end
      end
    end

    private

    def build_lesson_levels(site, lesson, config)
      source_file = lesson['all_levels_file']
      return unless File.exist?(source_file)
      
      # Get lesson-specific config or use defaults
      lesson_config = config.dup
      lesson_slug = lesson['slug']
      
      # Override config with lesson-specific settings
      lesson_config['collection_name'] = "#{lesson_slug}-levels"
      lesson_config['collection_dir'] = "_#{lesson_slug}-levels"
      lesson_config['url_pattern'] = "#{lesson['url']}/levels/:name.html"
      lesson_config['file_pattern'] = "#{lesson_slug}-level-{{ number }}"
      
      if lesson_config['build_individual_levels'] != false
        build_individual_levels(site, source_file, lesson_config, lesson)
      end
    end

    def build_individual_levels(site, source_file, config, lesson = nil)
      content = File.read(source_file)
      
      # Remove front matter if present
      if content.start_with?('---')
        parts = content.split(/^---\s*$/, 3)
        content = parts[2].strip if parts.length >= 3
      end
      
      # Get configuration
      collection_name = config['collection_name'] || 'levels'
      file_pattern = config['file_pattern'] || 'level-{{ number }}'
      url_pattern = config['url_pattern'] || "/#{collection_name}/:name.html"
      
      # Parse level blocks
      levels = parse_level_blocks(content, file_pattern)
      
      # Create a dictionary of levels by subtitle for cross-referencing
      levels_by_subtitle = {}
      levels.each do |level|
        # Generate URL from pattern
        url = url_pattern.gsub(':name', level[:file]).gsub(':number', level[:number].to_s)
        levels_by_subtitle[level[:subtitle]] = {
          'number' => level[:number],
          'title' => level[:title],
          'subtitle' => level[:subtitle],
          'file' => level[:file],
          'url' => url
        }
      end
      
      # Get output directory from collection or config
      collection_dir = config['collection_dir'] || "_#{collection_name}"
      output_dir = File.join(site.source, collection_dir)
      
      # Ensure output directory exists
      FileUtils.mkdir_p(output_dir) unless File.directory?(output_dir)
      
      levels.each do |level|
        filename = "#{level[:file]}.md"
        filepath = File.join(output_dir, filename)
        
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
          liquid_context = Liquid::Context.new
          liquid_context['level'] = {
            'number' => level[:number],
            'title' => level[:title],
            'subtitle' => level[:subtitle]
          }
          liquid_context['level_number'] = level[:number]
          liquid_context['level_subtitle'] = level[:subtitle]
          
          # Make all levels available for cross-referencing
          liquid_context['levels_by_subtitle'] = levels_by_subtitle
          liquid_context['all_levels'] = levels_by_subtitle.values
          
          template = Liquid::Template.parse(level[:content])
          processed_content = template.render(liquid_context)
        rescue Liquid::SyntaxError => e
          Jekyll.logger.warn "BuildLevels:", "Liquid parsing error: #{e.message}"
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
        
        Jekyll.logger.info "BuildLevels:", "Generated #{filename}"
      end
      
      Jekyll.logger.info "BuildLevels:", "Generated #{levels.length} individual level files"
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
          file: filename,
          content: level_content.strip
        }
      end
      
      # No need to sort - already in order
      levels
    end

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
  end
end

