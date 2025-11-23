# frozen_string_literal: true

require "jekyll"
require "fileutils"
require "yaml"

module Jekyll
  module Commands
    class InitCourse < Command
      class << self
        def init_with_program(prog)
          prog.command(:init_course) do |c|
            c.syntax "init-course [OPTIONS]"
            c.description "Initialize a new Jekyll course project with jekyll-level-manager-theme"
            
            c.option "name", "-n", "--name NAME", "Project/course name (default: directory name)"
            c.option "title", "-t", "--title TITLE", "Site title (default: 'My Jekyll Site')"
            c.option "description", "-d", "--description DESC", "Site description"
            c.option "lessons-dir", "--lessons-dir DIR", "Lessons directory name (default: '_lessons')"
            c.option "landing-title", "--landing-title TITLE", "Landing page title (default: 'Available Courses')"
            c.option "gemset", "--gemset GEMSET", "RVM gemset name (default: 'jekyll-site')"
            c.option "ruby-version", "--ruby-version VERSION", "Ruby version (default: '3.0.0')"
            c.option "no-git", "--no-git", "Skip git initialization"
            c.option "force", "--force", "Overwrite existing files"
            
            c.action do |args, options|
              Jekyll::Commands::InitCourse.process(options)
            end
          end
        end
        
        def process(options = {})
          # Get current directory name as default project name
          current_dir = File.basename(Dir.pwd)
          project_name = options[:name] || options['name'] || current_dir
          
          # Set defaults
          defaults = {
            'name' => project_name,
            'title' => options[:title] || options['title'] || "My Jekyll Site",
            'description' => options[:description] || options['description'] || "A Jekyll site using the Level Manager Theme",
            'lessons_dir' => options['lessons-dir'] || '_lessons',
            'landing_title' => options['landing-title'] || 'Available Courses',
            'landing_description' => 'Choose a course to begin learning.',
            'gemset' => options[:gemset] || options['gemset'] || 'jekyll-site',
            'ruby_version' => options['ruby-version'] || '3.0.0',
            'force' => options[:force] || options['force'] || false,
            'no_git' => options['no-git'] || false
          }
          
          # Check for existing files
          files_to_create = ['Gemfile', '_config.yml', '.ruby-version', '.ruby-gemset', '.gitignore']
          existing_files = files_to_create.select { |f| File.exist?(f) }
          
          if existing_files.any? && !defaults['force']
            Jekyll.logger.warn "InitCourse:", "The following files already exist: #{existing_files.join(', ')}"
            Jekyll.logger.warn "InitCourse:", "Use --force to overwrite them."
            return
          end
          
          Jekyll.logger.info "InitCourse:", "Initializing course: #{project_name}"
          
          # Create files
          create_gemfile(defaults)
          create_config_yml(defaults)
          create_ruby_version(defaults)
          create_ruby_gemset(defaults)
          create_gitignore(defaults)
          copy_lesson_prompt
          
          # Initialize git if requested
          unless defaults['no_git']
            init_git unless File.directory?('.git')
          end
          
          Jekyll.logger.info "InitCourse:", "✅ Course initialized successfully!"
          Jekyll.logger.info "InitCourse:", ""
          Jekyll.logger.info "InitCourse:", "Next steps:"
          Jekyll.logger.info "InitCourse:", "1. rvm use #{defaults['ruby_version']}@#{defaults['gemset']} (or let .ruby-version handle it)"
          Jekyll.logger.info "InitCourse:", "2. bundle install"
          Jekyll.logger.info "InitCourse:", "3. bundle exec create-example-lesson"
          Jekyll.logger.info "InitCourse:", "4. bundle exec jekyll build"
          Jekyll.logger.info "InitCourse:", "5. bundle exec jekyll serve"
        end
        
        private
        
        def create_gemfile(options)
          gemfile_content = <<~RUBY
source "https://rubygems.org"

ruby "#{options['ruby_version']}"

gem "jekyll", ">= 3.8", "< 5.0"
gem "jekyll-level-manager-theme", git: "https://github.com/rmccrear/jekyll-level-manager-theme.git", branch: "main"
gem "rouge"
gem "rexml"
gem "webrick"

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]
          RUBY
          
          File.write('Gemfile', gemfile_content, encoding: 'UTF-8')
          Jekyll.logger.info "InitCourse:", "  ✓ Created Gemfile"
        end
        
        def create_config_yml(options)
          config_content = <<~YAML
title: "#{options['title']}"
description: "#{options['description']}"
baseurl: ""
url: "http://localhost:4000"

markdown: kramdown
highlighter: rouge

theme: jekyll-level-manager-theme

plugins:
  - jekyll-level-manager-theme

level_manager:
  lessons_dir: "#{options['lessons_dir']}"
  landing_title: "#{options['landing_title']}"
  landing_description: "#{options['landing_description']}"
  build_individual_levels: true

exclude:
  - Gemfile
  - Gemfile.lock
  - node_modules
  - vendor/bundle/
  - vendor/cache/
  - vendor/gems/
  - vendor/ruby/
  - .git
  - .gitignore
  - README.md
  - JEKYLL_SETUP_WORKFLOW.md
  - LESSON_PROMPT.md
  - .DS_Store
          YAML
          
          File.write('_config.yml', config_content, encoding: 'UTF-8')
          Jekyll.logger.info "InitCourse:", "  ✓ Created _config.yml"
        end
        
        def create_ruby_version(options)
          File.write('.ruby-version', "#{options['ruby_version']}\n", encoding: 'UTF-8')
          Jekyll.logger.info "InitCourse:", "  ✓ Created .ruby-version"
        end
        
        def create_ruby_gemset(options)
          File.write('.ruby-gemset', "#{options['gemset']}\n", encoding: 'UTF-8')
          Jekyll.logger.info "InitCourse:", "  ✓ Created .ruby-gemset"
        end
        
        def create_gitignore(options)
          gitignore_content = <<~TEXT
_site/
.sass-cache/
.jekyll-cache/
.jekyll-metadata
vendor/
.bundle/
node_modules/
*.gem
*.rbc
.DS_Store
          TEXT
          
          File.write('.gitignore', gitignore_content, encoding: 'UTF-8')
          Jekyll.logger.info "InitCourse:", "  ✓ Created .gitignore"
        end
        
        def copy_lesson_prompt
          # Find the gem root
          # This file is in _plugins/commands/, so go up two levels
          gem_root = File.expand_path("../..", __dir__)
          prompt_source = File.join(gem_root, 'LESSON_PROMPT.md')
          prompt_dest = File.join(Dir.pwd, 'LESSON_PROMPT.md')
          
          if File.exist?(prompt_source)
            unless File.exist?(prompt_dest)
              FileUtils.cp(prompt_source, prompt_dest)
              Jekyll.logger.info "InitCourse:", "  ✓ Added LESSON_PROMPT.md"
            else
              Jekyll.logger.info "InitCourse:", "  ⚠ LESSON_PROMPT.md already exists, skipping"
            end
          else
            Jekyll.logger.warn "InitCourse:", "  ⚠ LESSON_PROMPT.md not found in gem at: #{prompt_source}"
          end
        end
        
        def init_git
          unless File.directory?('.git')
            system('git init > /dev/null 2>&1')
            Jekyll.logger.info "InitCourse:", "  ✓ Initialized git repository"
          else
            Jekyll.logger.info "InitCourse:", "  ⚠ Git repository already exists"
          end
        end
      end
    end
  end
end

