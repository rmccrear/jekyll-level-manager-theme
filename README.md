# Jekyll Level Manager Theme

A Jekyll theme for managing structured content with auto-numbering, cross-referencing, and a single-page development view.

## Features

- **Single Source of Truth**: Write all content in one markdown file (`all-levels.md`)
- **Auto-numbering**: Levels are automatically numbered based on their order
- **Cross-referencing**: Reference other levels by subtitle using Liquid templates
- **SPA Development View**: Fast single-page view for development
- **SEO-friendly Individual Pages**: Automatically generated individual pages for production
- **Custom Liquid Tags**: `{% level %}` and `{% showme %}` tags for structured content

## Installation

### Quick Install

Add to your Jekyll site's `Gemfile`:

```ruby
gem "jekyll-level-manager-theme", git: "https://github.com/yourusername/jekyll-level-manager-theme.git"
```

Then run `bundle install`.

**That's it!** The theme is automatically available. Jekyll will load the plugins from the gem.

See [INSTALLATION.md](INSTALLATION.md) for detailed installation options including:
- Private repository setup
- Specific version/branch installation
- Local development setup

## Configuration

### Single Lesson Mode

For a single lesson/course:

```yaml
level_manager:
  source_file: "_levels/all-levels.md"
  collection_name: "levels"
  collection_dir: "_levels"
  file_pattern: "level-{{ number }}"
  url_pattern: "/levels/:name.html"
  spa_page_name: "all-levels-spa.html"
  build_individual_levels: true
```

### Multi-Lesson Mode

For multiple lessons/courses:

```yaml
level_manager:
  lessons_dir: "_lessons"  # Directory containing lesson folders
  landing_title: "Available Courses"
  landing_description: "Choose a course to begin learning."
  build_individual_levels: true
```

Then create lesson directories:

```
_lessons/
  db-mini-project/
    lesson.yml          # Lesson metadata
    all-levels.md      # All levels for this lesson
  other-project/
    lesson.yml
    all-levels.md
```

Each `lesson.yml` should contain:

```yaml
name: db-mini-project
title: "DB Mini Project"
slug: db-mini-project
description: "Learn to build a full-stack React app with Supabase"
url: /db-mini-project
```

See [EXAMPLE_MULTI_LESSON.md](EXAMPLE_MULTI_LESSON.md) for detailed setup instructions.

## Usage

### Creating Levels

Create a file `_levels/all-levels.md` (or your configured source file) with content like:

```markdown
{% level subtitle="Planning" %}
# Level {{ level.number }}: {{ level.subtitle }}

**Goal:** Plan your project.

For setup, see [{{ levels_by_subtitle["Project Setup"].title }}: {{ levels_by_subtitle["Project Setup"].subtitle }}]({{ levels_by_subtitle["Project Setup"].url }}).

{% showme "Example" %}
```markdown
# Example content
```
{% endshowme %}

### ✅ Check

1. You have a plan
2. You understand the requirements
{% endlevel %}

{% level subtitle="Project Setup" %}
# Level {{ level.number }}: {{ level.subtitle }}

**Goal:** Set up your project.

## Instructions

1. Create a new project
2. Install dependencies

{% endlevel %}
```

### The `{% level %}` Tag

The `{% level %}` tag wraps content for a single level. It requires only the `subtitle` parameter:

```liquid
{% level subtitle="Your Subtitle Here" %}
  <!-- Your level content here -->
{% endlevel %}
```

**Auto-generated properties:**
- `number`: Sequential number based on order in file
- `title`: "Level {number}"
- `file`: Generated from `file_pattern` configuration

**Available variables in level content:**
- `{{ level.number }}` - Current level number
- `{{ level.title }}` - Current level title
- `{{ level.subtitle }}` - Current level subtitle
- `{{ levels_by_subtitle["Subtitle"] }}` - Access other levels by subtitle
- `{{ all_levels }}` - Array of all levels

### The `{% showme %}` Tag

The `{% showme %}` tag creates a collapsible details/summary section:

```liquid
{% showme "Title" %}
Your markdown content here
{% endshowme %}
```

### Cross-referencing Levels

Reference other levels by their subtitle:

```markdown
See [{{ levels_by_subtitle["Project Setup"].title }}: {{ levels_by_subtitle["Project Setup"].subtitle }}]({{ levels_by_subtitle["Project Setup"].url }})
```

Each level in `levels_by_subtitle` has:
- `number` - Level number
- `title` - Level title
- `subtitle` - Level subtitle
- `file` - Filename
- `url` - Relative URL

## Building Individual Files

The theme automatically builds individual markdown files during Jekyll build. You can also build them manually:

```bash
ruby scripts/build_levels.rb [source_file] [output_dir] [file_pattern]
```

All arguments are optional and will use values from `_config.yml` if not provided.

## Layouts

### `default.html`

The default layout includes:
- Sidebar navigation with all levels
- Link to SPA view
- Main content area

### `level.html`

Layout for individual level pages:
- Level navigation (quick jump between levels)
- Level content with Liquid processing

### `all-levels-spa.html`

Layout for the single-page development view:
- Show All / Collapse All controls
- Quick jump navigation
- All levels in one page

## Development

### Project Structure

```
jekyll-level-manager-theme/
├── _layouts/
│   ├── default.html
│   ├── level.html
│   └── all-levels-spa.html
├── _plugins/
│   ├── level_tag.rb
│   ├── showme_tag.rb
│   ├── liquid_markdown_filter.rb
│   ├── build_levels_generator.rb
│   └── all_levels_spa_generator.rb
├── assets/
│   ├── css/
│   │   ├── style.css
│   │   └── all-levels-spa.css
│   └── js/
│       └── all-levels-spa.js
├── scripts/
│   └── build_levels.rb
├── jekyll-level-manager-theme.gemspec
└── README.md
```

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

