module Jekyll
  class AllLevelsSPAGenerator < Generator
    safe true
    priority :low

    def generate(site)
      # Get configuration with defaults
      config = site.config['level_manager'] || {}
      
      # Check if we're in multi-lesson mode
      lessons = site.config['lessons'] || []
      
      if lessons.any?
        # Multi-lesson mode: create SPA for each lesson
        lessons.each do |lesson|
          source_file = lesson['all_levels_file']
          next unless File.exist?(source_file)
          
          spa_page_name = "#{lesson['slug']}-all-levels-spa.html"
          spa_url = "#{lesson['url']}/all-levels-spa.html"
          
          page = AllLevelsSPAPage.new(site, site.source, lesson['url'].sub(/^\//, ''), source_file, spa_page_name, lesson)
          site.pages << page
          
          Jekyll.logger.info "AllLevelsSPA:", "Generated #{spa_url}"
        end
      else
        # Single lesson mode
        source_file = config['source_file'] || '_levels/all-levels.md'
        all_levels_file = File.join(site.source, source_file)
        
        return unless File.exist?(all_levels_file)
        
        # Get SPA page name from config
        spa_page_name = config['spa_page_name'] || 'all-levels-spa.html'
        
        # Create SPA page
        page = AllLevelsSPAPage.new(site, site.source, '', all_levels_file, spa_page_name, nil)
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
      @lesson = lesson
      
      self.process(@name)
      
      title = lesson ? "#{lesson['title']} - All Levels" : 'All Levels - Development View'
      
      self.data = {
        'layout' => 'all-levels-spa',
        'title' => title,
        'lesson' => lesson
      }
      
      # Read the all-levels.md file content
      if File.exist?(source_file)
        content = File.read(source_file)
        
        # Remove front matter if present (lines starting with ---)
        if content.start_with?('---')
          parts = content.split(/^---\s*$/, 3)
          if parts.length >= 3
            content = parts[2].strip
          end
        end
        
        self.content = content
        
        # Reset level counter for SPA view (ensures levels are numbered 1, 2, 3...)
        Jekyll::LevelTag.reset_counter if defined?(Jekyll::LevelTag)
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

