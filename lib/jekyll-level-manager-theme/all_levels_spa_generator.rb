module Jekyll
  class AllLevelsSPAGenerator < Generator
    safe true
    priority :low

    def generate(site)
      all_levels_file = File.join(site.source, '_db-levels', 'all-levels.md')
      
      return unless File.exist?(all_levels_file)
      
      # Create SPA page
      page = AllLevelsSPAPage.new(site, site.source, '', all_levels_file)
      site.pages << page
      
      Jekyll.logger.info "AllLevelsSPA:", "Generated all-levels-spa.html"
    end
  end

  class AllLevelsSPAPage < Page
    def initialize(site, base, dir, source_file)
      @site = site
      @base = base
      @dir = dir
      @name = "all-levels-spa.html"
      
      self.process(@name)
      
      self.data = {
        'layout' => 'all-levels-spa',
        'title' => 'All Levels - Development View'
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

