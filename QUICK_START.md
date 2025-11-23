# Quick Start with jekyll-level-manager-theme

Quick start guide to create a new course with the [jekyll-level-manager-theme](https://github.com/rmccrear/jekyll-level-manager-theme).

## Quick Start

### 1. Set up Ruby and Gemset

```bash
# Create Ruby 3.0 with gemset and auto-generate version files
rvm --ruby-version use 3.0.0@jekyll-lesson-site --create
```

### 2. Create Jekyll Site

```bash
# Install bundler
gem install bundler

# Create new Jekyll site
jekyll new my-course
cd my-course
```

### 3. Add the Theme

Edit `Gemfile` to add:

```ruby
gem "jekyll-level-manager-theme", git: "https://github.com/rmccrear/jekyll-level-manager-theme.git", branch: "main"
```

Then install:

```bash
bundle install
```

### 4. Initialize the Course

```bash
# Initialize course with all configuration files
bundle exec init-course
```

This creates:
- `_config.yml` with `level_manager` configuration
- `.ruby-version` and `.ruby-gemset` files
- `.gitignore`
- `LESSON_PROMPT.md`

### 5. Add a Lesson

```bash
# Create a lesson named "basic-lesson"
bundle exec create-example-lesson --name basic-lesson
```

### 6. Build and Serve

```bash
# Build the site (generates landing page automatically)
bundle exec jekyll build

# Serve locally
bundle exec jekyll serve

# Visit http://localhost:4000
```

## Complete Command Sequence

```bash
# 1. Set up Ruby and gemset
rvm --ruby-version use 3.0.0@jekyll-lesson-site --create

# 2. Install bundler
gem install bundler

# 3. Create Jekyll site
jekyll new my-course
cd my-course

# 4. Add theme to Gemfile (edit manually)
# gem "jekyll-level-manager-theme", git: "https://github.com/rmccrear/jekyll-level-manager-theme.git", branch: "main"

# 5. Install dependencies
bundle install

# 6. Initialize course
bundle exec init-course

# 7. Create lesson
bundle exec create-example-lesson --name basic-lesson

# 8. Build and serve
bundle exec jekyll build
bundle exec jekyll serve
```

## Next Steps

- Visit `http://localhost:4000` to see your landing page
- Edit lesson content in `_lessons/basic-lesson/all-levels.md`
- Add more lessons with `bundle exec create-example-lesson --name lesson-name`
- Customize `_config.yml` for your site

## Documentation

For detailed setup instructions, see [JEKYLL_SETUP_WORKFLOW.md](./JEKYLL_SETUP_WORKFLOW.md).

