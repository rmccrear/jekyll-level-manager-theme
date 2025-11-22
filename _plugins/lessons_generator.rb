require 'yaml'
require 'fileutils'

module Jekyll
  class LessonsGenerator < Generator
    safe true
    priority :high  # Run early, before level generators

    def generate(site)
      # Get configuration
      config = site.config['level_manager'] || {}
      lessons_dir = config['lessons_dir'] || '_lessons'
      lessons_path = File.join(site.source, lessons_dir)
      
      return unless File.directory?(lessons_path)
      
      # Find all lesson directories
      lessons = find_lessons(lessons_path, config)
      
      return if lessons.empty?
      
      # Create landing page
      create_landing_page(site, lessons, config)
      
      # Create lesson home pages
      lessons.each do |lesson|
        create_lesson_home_page(site, lesson, config)
      end
      
      # Store lessons in site config for use by other generators
      site.config['lessons'] = lessons
      
      Jekyll.logger.info "LessonsGenerator:", "Found #{lessons.length} lessons"
    end

    private

    def find_lessons(lessons_path, config)
      lessons = []
      
      Dir.glob(File.join(lessons_path, '*')).each do |lesson_dir|
        next unless File.directory?(lesson_dir)
        
        lesson_name = File.basename(lesson_dir)
        all_levels_file = File.join(lesson_dir, 'all-levels.md')
        
        # Read lesson metadata from all-levels.md front matter or lesson.yml
        lesson_config_file = File.join(lesson_dir, 'lesson.yml')
        lesson_metadata = {}
        
        if File.exist?(lesson_config_file)
          begin
            lesson_metadata = YAML.load_file(lesson_config_file) || {}
          rescue => e
            Jekyll.logger.warn "LessonsGenerator:", "Error reading #{lesson_config_file}: #{e.message}"
          end
        end
        
        # Also check front matter of all-levels.md
        if File.exist?(all_levels_file)
          content = File.read(all_levels_file, encoding: 'UTF-8')
          if content.start_with?('---')
            parts = content.split(/^---\s*$/, 3)
            if parts.length >= 2
              begin
                front_matter = YAML.load(parts[1]) || {}
                lesson_metadata.merge!(front_matter)
              rescue => e
                Jekyll.logger.warn "LessonsGenerator:", "Error parsing front matter: #{e.message}"
              end
            end
          end
        end
        
        # Default values
        lesson_metadata['name'] ||= lesson_name
        lesson_metadata['title'] ||= lesson_name.split('-').map(&:capitalize).join(' ')
        lesson_metadata['slug'] ||= lesson_name
        lesson_metadata['url'] ||= "/#{lesson_name}"
        lesson_metadata['description'] ||= "Lesson: #{lesson_metadata['title']}"
        
        lessons << {
          'name' => lesson_metadata['name'],
          'title' => lesson_metadata['title'],
          'slug' => lesson_metadata['slug'],
          'url' => lesson_metadata['url'],
          'description' => lesson_metadata['description'],
          'dir' => lesson_dir,
          'all_levels_file' => all_levels_file
        }
      end
      
      lessons.sort_by { |l| l['name'] }
    end

    def create_landing_page(site, lessons, config)
      landing_page = LessonsLandingPage.new(site, site.source, '', lessons, config)
      site.pages << landing_page
    end

    def create_lesson_home_page(site, lesson, config)
      lesson_page = LessonHomePage.new(site, site.source, lesson['url'].sub(/^\//, ''), lesson, config)
      site.pages << lesson_page
    end
  end

  class LessonHomePage < Page
    def initialize(site, base, dir, lesson, config)
      @site = site
      @base = base
      @dir = dir
      @name = "index.html"
      
      self.process(@name)
      
      self.data = {
        'layout' => 'lesson-home',
        'title' => lesson['title'],
        'lesson' => lesson
      }
      
      # Generate content
      content = <<~MARKDOWN
# #{lesson['title']}

#{lesson['description']}

## Getting Started

This lesson contains multiple levels. Start with Level 1 and work through them sequentially.

## Quick Links

- [View All Levels (SPA)](#{lesson['url']}/all-levels-spa.html) - Fast development view
- [Level 1](#{lesson['url']}/levels/#{lesson['slug']}-level-1.html) - Start here
      MARKDOWN
      
      self.content = content
      self.ext = '.md'
    end

    def read_yaml(base, name, opts = {})
      self.data ||= {}
    end
    
    def extname
      '.md'
    end
  end

  class LessonsLandingPage < Page
    def initialize(site, base, dir, lessons, config)
      @site = site
      @base = base
      @dir = dir
      @name = "index.html"
      
      self.process(@name)
      
      self.data = {
        'layout' => 'lessons-landing',
        'title' => config['landing_title'] || 'Lessons',
        'lessons' => lessons
      }
      
      # Generate content
      content = <<~MARKDOWN
# #{config['landing_title'] || 'Lessons'}

#{config['landing_description'] || 'Select a lesson to begin.'}

## Available Lessons

#{lessons.map { |lesson| 
  "- [#{lesson['title']}](#{lesson['url']}) - #{lesson['description']}"
}.join("\n")}
      MARKDOWN
      
      self.content = content
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

