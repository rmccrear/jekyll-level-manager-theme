module Jekyll
  class AllLevelsSPAGenerator < Generator
    safe true
    priority :low

    def generate(site)
      # Get configuration with defaults
      config = site.config['level_manager'] || {}
      
      # Check if we're in multi-lesson mode
      if site.config['lessons'] && !site.config['lessons'].empty?
        # Multi-lesson mode: create SPA page for each lesson
        site.config['lessons'].each do |lesson|
          all_levels_file = lesson['all_levels_file']
          next unless File.exist?(all_levels_file)
          
          # Get SPA page name from config
          spa_page_name = config['spa_page_name'] || 'all-levels-spa.html'
          
          # Create SPA page (dir is the lesson slug, page_name is just the filename)
          page = AllLevelsSPAPage.new(site, site.source, lesson['slug'], all_levels_file, spa_page_name, lesson)
          site.pages << page
          
          Jekyll.logger.info "AllLevelsSPA:", "Generated #{spa_page_name} for lesson #{lesson['slug']}"
        end
      else
        # Single-lesson mode: use old behavior
        source_file = config['source_file'] || '_levels/all-levels.md'
        all_levels_file = File.join(site.source, source_file)
        
        return unless File.exist?(all_levels_file)
        
        # Get SPA page name from config
        spa_page_name = config['spa_page_name'] || 'all-levels-spa.html'
        
        # Create SPA page
        page = AllLevelsSPAPage.new(site, site.source, '', all_levels_file, spa_page_name)
        site.pages << page
        
        Jekyll.logger.info "AllLevelsSPA:", "Generated #{spa_page_name}"
      end
    end
  end

  class AllLevelsSPAPage < Page
    def initialize(site, base, dir, source_file, page_name = "all-levels-spa.html", lesson = nil)
      @site = site
      @base = base
      @dir = dir
      @name = page_name
      
      self.process(@name)
      
      # Set title based on lesson
      title = lesson ? "#{lesson['title']} - All Levels" : 'All Levels - Development View'
      
      self.data = {
        'layout' => 'all-levels-spa',
        'title' => title
      }
      
      # Store lesson info for Liquid templates
      if lesson
        self.data['lesson'] = lesson
        self.data['lesson_slug'] = lesson['slug']
      end
      
      # Reset level counter for this specific page (ensures levels are numbered 1, 2, 3...)
      # Use the page URL as the key for per-page counting
      page_url = "/#{dir}/#{page_name}".gsub(/\/+/, '/')
      Jekyll::LevelTag.reset_counter(page_url) if defined?(Jekyll::LevelTag)
      
      # Read the all-levels.md file content
      if File.exist?(source_file)
        content = File.read(source_file, encoding: 'UTF-8')
        
        # Remove front matter if present (lines starting with ---)
        if content.start_with?('---')
          parts = content.split(/^---\s*$/, 3)
          if parts.length >= 3
            content = parts[2].strip
          end
        end
        
        self.content = content
      else
        self.content = "# All Levels\n\nContent file not found: #{source_file}"
      end
      
      self.ext = '.md'
    end

    def read_yaml(base, name, opts = {})
      self.data ||= {}
    end
    
    def extname
      '.md'
    end
  end
end

