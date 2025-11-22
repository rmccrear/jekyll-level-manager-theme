# frozen_string_literal: true

require "jekyll"
require "fileutils"

module Jekyll
  module Commands
    class CreateExampleLesson < Command
      class << self
        def init_with_program(prog)
          prog.command(:create_example_lesson) do |c|
            c.syntax "create-example-lesson"
            c.description "Create an example lesson with 3 levels to help you get started"
            
            c.action do |args, options|
              Jekyll::Commands::CreateExampleLesson.process(options)
            end
          end
        end
        
        def process(options)
          config = Jekyll.configuration
          site = Jekyll::Site.new(config)
          
          lessons_dir = site.config['level_manager']&.[]('lessons_dir') || '_lessons'
          lessons_path = File.join(site.source, lessons_dir)
          example_lesson_dir = File.join(lessons_path, 'example-lesson')
          
          if File.directory?(example_lesson_dir)
            Jekyll.logger.warn "CreateExampleLesson:", "Example lesson already exists at: #{example_lesson_dir}"
            Jekyll.logger.warn "CreateExampleLesson:", "Delete it first if you want to recreate it."
            return
          end
          
          Jekyll.logger.info "CreateExampleLesson:", "Creating example lesson..."
          
          # Create directory
          FileUtils.mkdir_p(example_lesson_dir)
          
          # Create lesson.yml
          lesson_yml = <<~YAML
name: example-lesson
title: "Example Lesson"
slug: example-lesson
description: "This is an example lesson with 3 levels to help you get started"
url: /example-lesson
          YAML
          
          File.write(File.join(example_lesson_dir, 'lesson.yml'), lesson_yml, encoding: 'UTF-8')
          
          # Create all-levels.md with 3 example levels
          all_levels_content = <<~MARKDOWN
# Example Lesson

This is an example lesson to help you understand the structure.

---

{% level subtitle="Getting Started" %}
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
          
          File.write(File.join(example_lesson_dir, 'all-levels.md'), all_levels_content, encoding: 'UTF-8')
          
          # Copy LESSON_PROMPT.md to project root if it exists in the gem
          copy_lesson_prompt(site.source)
          
          Jekyll.logger.info "CreateExampleLesson:", "✅ Example lesson created at: #{example_lesson_dir}"
          Jekyll.logger.info "CreateExampleLesson:", "   Run 'bundle exec jekyll build' to see it in action!"
        end
        
        def copy_lesson_prompt(site_source)
          # Find the gem root
          # The command file is in _plugins/, so go up one level to gem root
          gem_root = File.expand_path("..", __dir__)
          prompt_source = File.join(gem_root, 'LESSON_PROMPT.md')
          prompt_dest = File.join(site_source, 'LESSON_PROMPT.md')
          
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

