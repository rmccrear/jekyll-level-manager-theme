# frozen_string_literal: true

require "jekyll"
require "fileutils"
require "yaml"

module Jekyll
  module Commands
    class CreateExampleLesson < Command
      class << self
        def init_with_program(prog)
          prog.command(:create_example_lesson) do |c|
            c.syntax "create-example-lesson [OPTIONS]"
            c.description "Create an example lesson with 3 levels to help you get started"
            
            c.option "name", "-n", "--name NAME", "Lesson name/slug (default: 'example-lesson')"
            c.option "title", "-t", "--title TITLE", "Lesson title (default: generated from name)"
            c.option "description", "-d", "--description DESC", "Lesson description"
            
            c.action do |args, options|
              Jekyll::Commands::CreateExampleLesson.process(options)
            end
          end
        end
        
        def process(options = {})
          # Extract lesson name from options
          lesson_name = options[:name] || options['name'] || 'example-lesson'
          lesson_title = options[:title] || options['title'] || generate_title_from_name(lesson_name)
          lesson_description = options[:description] || options['description'] || "This is an example lesson with 3 levels to help you get started"
          
          # Generate slug from name
          lesson_slug = generate_slug(lesson_name)
          
          # Validate lesson name
          unless valid_lesson_name?(lesson_name)
            Jekyll.logger.error "CreateExampleLesson:", "Invalid lesson name: #{lesson_name}"
            Jekyll.logger.error "CreateExampleLesson:", "Lesson name must be a valid directory name."
            return
          end
          
          # Get lessons directory from config if available, otherwise use default
          source_dir = Dir.pwd
          config_file = File.join(source_dir, '_config.yml')
          lessons_dir = '_lessons'
          
          if File.exist?(config_file)
            begin
              config = YAML.load_file(config_file) || {}
              lessons_dir = config.dig('level_manager', 'lessons_dir') || '_lessons'
            rescue => e
              Jekyll.logger.warn "CreateExampleLesson:", "Could not read _config.yml: #{e.message}"
            end
          end
          
          lessons_path = File.join(source_dir, lessons_dir)
          lesson_dir = File.join(lessons_path, lesson_slug)
          
          if File.directory?(lesson_dir)
            Jekyll.logger.warn "CreateExampleLesson:", "Lesson already exists at: #{lesson_dir}"
            Jekyll.logger.warn "CreateExampleLesson:", "Delete it first if you want to recreate it."
            return
          end
          
          Jekyll.logger.info "CreateExampleLesson:", "Creating lesson: #{lesson_title}..."
          
          # Create directory
          FileUtils.mkdir_p(lesson_dir)
          
          # Create lesson.yml
          lesson_yml = <<~YAML
name: #{lesson_slug}
title: "#{lesson_title}"
slug: #{lesson_slug}
description: "#{lesson_description}"
url: /#{lesson_slug}
          YAML
          
          File.write(File.join(lesson_dir, 'lesson.yml'), lesson_yml, encoding: 'UTF-8')
          
          # Create all-levels.md with 3 example levels
          all_levels_content = <<~MARKDOWN
# #{lesson_title}

#{lesson_description}

---

{% level subtitle="Getting Started" %}
# Level {{ level.number }}: Getting Started

**Goal:** Learn the basics of this lesson.

**User Story:** As a learner, I want to understand the fundamentals so that I can progress.

## What You'll Do

This is the first level. It introduces the basic concepts.

## Instructions

1. Read through this level carefully
2. Follow the instructions step by step
3. Complete the check at the end

## ✅ Check

- [ ] You understand the basics
- [ ] You're ready for the next level

---
{% endlevel %}

{% level subtitle="Building Skills" %}
# Level {{ level.number }}: Building Skills

**Goal:** Develop your skills further.

**User Story:** As a learner, I want to practice what I've learned so that I can improve.

## What You'll Do

This is the second level. It builds on what you learned in Level 1.

## Instructions

1. Review Level 1 concepts
2. Practice the new skills
3. Apply what you've learned

## 💡 Code Hints

Here's a helpful hint:

\`\`\`javascript
// Example code snippet
function example() {
  return "Hello, World!";
}
\`\`\`

## ✅ Check

- [ ] You've practiced the skills
- [ ] You understand the concepts
- [ ] You're ready for the final level

---
{% endlevel %}

{% level subtitle="Mastery" %}
# Level {{ level.number }}: Mastery

**Goal:** Master the concepts and complete the lesson.

**User Story:** As a learner, I want to demonstrate mastery so that I can move on to more advanced topics.

## What You'll Do

This is the final level. It brings everything together.

## Instructions

1. Review all previous levels
2. Complete the final project
3. Reflect on what you've learned

## ✅ Check

- [ ] You've completed all tasks
- [ ] You understand all concepts
- [ ] You're ready for the next lesson!

---

**Congratulations!** You've completed the example lesson! 🎉
{% endlevel %}
          MARKDOWN
          
          File.write(File.join(lesson_dir, 'all-levels.md'), all_levels_content, encoding: 'UTF-8')
          
          # Copy LESSON_PROMPT.md to project root if it exists in the gem
          copy_lesson_prompt(source_dir)
          
          Jekyll.logger.info "CreateExampleLesson:", "✅ Lesson created at: #{lesson_dir}"
          Jekyll.logger.info "CreateExampleLesson:", "   Run 'bundle exec jekyll build' to see it in action!"
        end
        
        private
        
        def generate_slug(name)
          name.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
        end
        
        def generate_title_from_name(name)
          name.split(/[-_\s]+/).map(&:capitalize).join(' ')
        end
        
        def valid_lesson_name?(name)
          return false if name.nil? || name.empty?
          return false if name.length > 255
          return false if /[<>:"|?*\x00-\x1f]/.match?(name)
          return false if name.start_with?('.') || name.end_with?('.')
          true
        end
        
        def copy_lesson_prompt(source_dir)
          # Find the gem root
          # The command file is in _plugins/commands/, so go up two levels to gem root
          gem_root = File.expand_path("../..", __dir__)
          prompt_source = File.join(gem_root, 'LESSON_PROMPT.md')
          prompt_dest = File.join(source_dir, 'LESSON_PROMPT.md')
          
          if File.exist?(prompt_source)
            unless File.exist?(prompt_dest)
              FileUtils.cp(prompt_source, prompt_dest)
              Jekyll.logger.info "CreateExampleLesson:", "✅ Added LESSON_PROMPT.md to project root"
            else
              Jekyll.logger.warn "CreateExampleLesson:", "LESSON_PROMPT.md already exists in project root, skipping"
            end
          else
            Jekyll.logger.warn "CreateExampleLesson:", "LESSON_PROMPT.md not found in gem at: #{prompt_source}"
          end
        end
      end
    end
  end
end

