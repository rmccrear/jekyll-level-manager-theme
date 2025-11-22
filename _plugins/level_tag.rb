module Jekyll
  class LevelTag < Liquid::Block
    # Use a hash to track counters per page (keyed by page URL)
    @@level_counters = {}  # Hash to track level numbers per page
    
    def initialize(tag_name, markup, tokens)
      super
      @attrs = parse_attributes(markup)
      # Counter will be set during render when we have page context
    end
    
    # Reset counter for a specific page
    def self.reset_counter(page_key = nil)
      if page_key
        @@level_counters[page_key] = 0
      else
        @@level_counters.clear
      end
    end
    
    # Get or initialize counter for a page
    def self.get_counter(page_key)
      @@level_counters[page_key] ||= 0
      @@level_counters[page_key] += 1
      @@level_counters[page_key]
    end

    def render(context)
      @context = context
      content = super
      site = context.registers[:site]
      
      # Get page key for per-page counter
      page = context.registers[:page]
      page_key = page && page['url'] ? page['url'] : 'default'
      
      # Get or increment counter for this page
      level_num = Jekyll::LevelTag.get_counter(page_key)
      @level_number = level_num  # Store for use in render_content
      
      # Store level data in context for SPA view
      level_data = {
        'number' => level_num,
        'title' => "Level #{level_num}",  # Auto-generate title based on number
        'subtitle' => @attrs['subtitle'] || @attrs[:subtitle] || '',
        'file' => "db-mini-project-lv-#{level_num}",  # Auto-generate file name based on number
        'content' => content
      }
      
      # For SPA view, we'll render as a section with ID
      level_title = level_data['title']
      level_subtitle = level_data['subtitle']
      
      <<~HTML
        <div id="level-#{level_num}" class="level-section" data-level="#{level_num}">
          <h1 class="level-title">#{level_title}#{level_subtitle.empty? ? '' : ': ' + level_subtitle}</h1>
          #{render_content(content, site)}
        </div>
      HTML
    end

    private

    def parse_attributes(markup)
      attrs = {}
      # Parse: number=1 title="Level 1" subtitle="Planning" file="db-mini-project-lv-1"
      markup.scan(/(\w+)=["']([^"']+)["']/) do |key, value|
        attrs[key] = value
      end
      # Parse unquoted numbers
      markup.scan(/(\w+)=(\d+)/) do |key, value|
        attrs[key] = value.to_i if key == 'number'
      end
      attrs
    end

    def render_content(content, site)
      # Process Liquid tags (like {% showme %}) then convert markdown
      begin
        # Get the context from the parent render call
        context = @context || Liquid::Context.new
        
        # Make level variables available in Liquid context
        current_subtitle = @attrs['subtitle'] || @attrs[:subtitle] || ''
        # Use the level_num from the outer render method (stored in @level_number)
        current_level_num = @level_number
        
        context['level'] = {
          'number' => current_level_num,
          'title' => "Level #{current_level_num}",
          'subtitle' => current_subtitle
        }
        context['level_number'] = current_level_num
        context['level_subtitle'] = current_subtitle
        
        # Make all levels available for cross-referencing
        # Try to get from site.collections first, otherwise parse from all-levels.md
        levels_by_subtitle = {}
        
        if site.collections && site.collections['db-levels'] && site.collections['db-levels'].docs.any?
          # Use collection if available
          site.collections['db-levels'].docs.each do |doc|
            if doc.data['subtitle']
              levels_by_subtitle[doc.data['subtitle']] = {
                'number' => doc.data['number'],
                'title' => doc.data['title'],
                'subtitle' => doc.data['subtitle'],
                'file' => doc.data['file'],
                'url' => doc.url || "/db-levels/#{doc.data['file']}.html"
              }
            end
          end
        else
          # Parse from all-levels.md as fallback
          all_levels_file = File.join(site.source, '_db-levels', 'all-levels.md')
          if File.exist?(all_levels_file)
            file_content = File.read(all_levels_file, encoding: 'UTF-8')
            # Remove front matter if present
            if file_content.start_with?('---')
              parts = file_content.split(/^---\s*$/, 3)
              file_content = parts[2].strip if parts.length >= 3
            end
            
            # Parse level blocks to build dictionary
            pattern = /{%\s*level\s+([^%]+?)\s*%}(.*?){%\s*endlevel\s*%}/m
            level_num = 1
            file_content.scan(pattern) do |attrs_str, level_content|
              # Parse subtitle from attributes
              subtitle_match = attrs_str.match(/subtitle=["']([^"']+)["']/)
              if subtitle_match
                subtitle = subtitle_match[1]
                levels_by_subtitle[subtitle] = {
                  'number' => level_num,
                  'title' => "Level #{level_num}",
                  'subtitle' => subtitle,
                  'file' => "db-mini-project-lv-#{level_num}",
                  'url' => "/db-levels/db-mini-project-lv-#{level_num}.html"
                }
                level_num += 1
              end
            end
          end
        end
        
        context['levels_by_subtitle'] = levels_by_subtitle
        context['all_levels'] = levels_by_subtitle.values
        
        template = Liquid::Template.parse(content)
        liquid_output = template.render(context)
      rescue Liquid::SyntaxError => e
        Jekyll.logger.warn "LevelTag:", "Liquid parsing error: #{e.message}"
        liquid_output = content
      end
      
      converter = site.find_converter_instance(Jekyll::Converters::Markdown)
      converter.convert(liquid_output)
    end
  end
end

Liquid::Template.register_tag('level', Jekyll::LevelTag)

