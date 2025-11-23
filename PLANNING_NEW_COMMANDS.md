# Planning: New Commands for jekyll-level-manager-theme

## Feature 1: `init-course` Command

### Purpose
Create a new Jekyll course project from scratch with all necessary configuration files.

### Command Structure
```bash
bundle exec init-course [OPTIONS]
```

### Implementation Plan

#### 1. Command Registration
**File**: `_plugins/init_course_command.rb`
- Register command with Jekyll CLI
- Handle options and arguments
- Call processing method

**File**: `_plugins/commands/init_course.rb`
- Implement the command logic
- Create all necessary files

**File**: `exe/init-course`
- Executable wrapper for the command

#### 2. Files to Create

**Gemfile**
- Source: `https://rubygems.org`
- Ruby version: `3.0.0`
- Dependencies:
  - `jekyll` (>= 3.8, < 5.0)
  - `jekyll-level-manager-theme` (from GitHub, branch: "main")
  - `rouge`
  - `rexml`
  - `webrick`
  - Platform-specific gems (tzinfo, wdm, etc.)

**`_config.yml`**
- Basic site configuration
- Theme configuration
- `level_manager` configuration with defaults:
  - `lessons_dir: "_lessons"`
  - `landing_title: "Available Courses"`
  - `landing_description: "Choose a course to begin learning."`
  - `build_individual_levels: true`
- Exclude list

**`.ruby-version`**
- Contains: `3.0.0`

**`.ruby-gemset`**
- Contains: `jekyll-site` (or configurable)

**`.gitignore`**
- Jekyll defaults (_site, .sass-cache, etc.)
- Gemfile.lock (optional - might want to include it)
- .jekyll-cache
- .ruby-version and .ruby-gemset (optional - usually committed)
- Vendor directories

**`LESSON_PROMPT.md`**
- Copy from gem's LESSON_PROMPT.md

**`README.md`** (optional)
- Basic project description
- Setup instructions
- Links to documentation

#### 3. Command Options

```bash
--name, -n NAME          # Project/course name (default: directory name)
--title, -t TITLE        # Site title (default: "My Jekyll Site")
--description, -d DESC   # Site description (default: "A Jekyll site using the Level Manager Theme")
--lessons-dir DIR        # Lessons directory name (default: "_lessons")
--landing-title TITLE    # Landing page title (default: "Available Courses")
--gemset GEMSET          # RVM gemset name (default: "jekyll-site")
--ruby-version VERSION   # Ruby version (default: "3.0.0")
--no-git                 # Skip git initialization
--force                  # Overwrite existing files
```

#### 4. Workflow

1. Check if we're in a directory (can be empty or have files)
2. Check for existing files (warn if files exist unless --force)
3. Create all files based on options
4. Copy LESSON_PROMPT.md from gem
5. Optionally initialize git repository
6. Print success message with next steps

#### 5. Directory Structure Created

```
course-name/
├── .ruby-version
├── .ruby-gemset
├── Gemfile
├── _config.yml
├── .gitignore
├── LESSON_PROMPT.md
├── README.md (optional)
└── .git/ (if git init)
```

#### 6. Next Steps Message

After initialization, show:
```
✅ Course initialized successfully!

Next steps:
1. rvm use 3.0.0@jekyll-site (or let .ruby-version handle it)
2. bundle install
3. bundle exec create-example-lesson
4. bundle exec jekyll build
5. bundle exec jekyll serve
```

---

## Feature 2: `create-example-lesson` with Name Parameter

### Purpose
Allow users to specify a custom name for the lesson instead of always using "example-lesson".

### Command Structure
```bash
bundle exec create-example-lesson [--name NAME] [--title TITLE] [--description DESC]
```

### Implementation Plan

#### 1. Update Command Registration

**File**: `_plugins/create_example_lesson_command.rb`
- Add option parsing for `--name`, `--title`, `--description`
- Pass options to processing method

#### 2. Update Command Implementation

**File**: `_plugins/commands/create_example_lesson.rb`

**Changes needed:**

1. **Accept options parameter**
   ```ruby
   def process(options = {})
     # Extract lesson name from options
     lesson_name = options[:name] || options['name'] || 'example-lesson'
     lesson_title = options[:title] || options['title'] || generate_title_from_name(lesson_name)
     lesson_description = options[:description] || options['description'] || default_description
   ```

2. **Generate slug from name**
   ```ruby
   def generate_slug(name)
     name.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
   end
   ```

3. **Use dynamic names in directory and files**
   - Directory: `_lessons/{lesson_name}/`
   - lesson.yml: Use lesson_name, title, description
   - all-levels.md: Use lesson_title in content

4. **Validate lesson name**
   - Check if it's a valid directory name
   - Check if directory already exists
   - Warn if invalid characters

#### 3. Command Options

```bash
--name, -n NAME          # Lesson name/slug (default: "example-lesson")
--title, -t TITLE        # Lesson title (default: generated from name)
--description, -d DESC   # Lesson description (default: generic description)
```

#### 4. Examples

```bash
# Default behavior (creates "example-lesson")
bundle exec create-example-lesson

# Custom name
bundle exec create-example-lesson --name "react-basics"

# Full customization
bundle exec create-example-lesson \
  --name "react-basics" \
  --title "React Basics" \
  --description "Learn the fundamentals of React"
```

#### 5. Generated Files Structure

**Before (hardcoded):**
```
_lessons/example-lesson/
  ├── lesson.yml (name: example-lesson, title: "Example Lesson")
  └── all-levels.md (title: "Example Lesson")
```

**After (dynamic):**
```
_lessons/{lesson_name}/
  ├── lesson.yml (name: {lesson_name}, title: {lesson_title})
  └── all-levels.md (title: {lesson_title})
```

#### 6. Name Validation

```ruby
def valid_lesson_name?(name)
  # Must be valid directory name
  return false if name.nil? || name.empty?
  return false if name.length > 255
  return false if /[<>:"|?*\x00-\x1f]/.match?(name)
  return false if name.start_with?('.') || name.end_with?('.')
  true
end
```

---

## Implementation Steps

### Phase 1: `init-course` Command

1. Create `_plugins/init_course_command.rb`
2. Create `_plugins/commands/init_course.rb`
3. Create `exe/init-course` executable
4. Update `jekyll-level-manager-theme.gemspec`:
   - Add `init-course` to executables
   - Include new plugin files
5. Test the command
6. Update documentation

### Phase 2: Enhanced `create-example-lesson` Command

1. Update `_plugins/create_example_lesson_command.rb`:
   - Add option parsing for `--name`, `--title`, `--description`
2. Update `_plugins/commands/create_example_lesson.rb`:
   - Accept options parameter
   - Generate dynamic names
   - Validate lesson name
   - Use dynamic names in file generation
3. Update `exe/create-example-lesson` (if needed)
4. Test with various names
5. Update documentation

### Phase 3: Integration

1. Update workflow documentation
2. Update README.md in gem
3. Update examples

---

## File Templates

### Gemfile Template

```ruby
source "https://rubygems.org"

ruby "3.0.0"

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
```

### _config.yml Template

```yaml
title: "{{ title }}"
description: "{{ description }}"
baseurl: ""
url: "http://localhost:4000"

markdown: kramdown
highlighter: rouge

theme: jekyll-level-manager-theme

plugins:
  - jekyll-level-manager-theme

level_manager:
  lessons_dir: "{{ lessons_dir }}"
  landing_title: "{{ landing_title }}"
  landing_description: "{{ landing_description }}"
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
```

---

## Testing Checklist

### init-course Command
- [ ] Creates all files correctly
- [ ] Handles existing files (warn/force)
- [ ] Options work correctly
- [ ] Git initialization optional
- [ ] Works in empty directory
- [ ] Works in existing directory (with --force)

### create-example-lesson with Name
- [ ] Default name works (example-lesson)
- [ ] Custom name works (--name option)
- [ ] Title and description options work
- [ ] Name validation works
- [ ] Prevents overwriting existing lessons
- [ ] Generates valid slugs from names
- [ ] Handles special characters in names

---

## Documentation Updates Needed

1. **README.md** - Add both commands to commands section
2. **JEKYLL_SETUP_WORKFLOW.md** - Update to use `init-course` command
3. **INSTALLATION.md** - Add `init-course` as quick start option
4. **QUICK_START.md** - Add quick start to docs (create in gem repository)
5. **llm.txt** - Update with new commands

