# Multi-Lesson Setup Example

This theme supports multiple lessons/courses in a single Jekyll site.

## Directory Structure

```
your-jekyll-site/
├── _lessons/
│   ├── db-mini-project/
│   │   ├── lesson.yml          # Lesson metadata
│   │   └── all-levels.md       # All levels for this lesson
│   └── other-project/
│       ├── lesson.yml
│       └── all-levels.md
├── _config.yml
└── Gemfile
```

## Configuration

In `_config.yml`:

```yaml
level_manager:
  lessons_dir: "_lessons"  # Directory containing lessons
  landing_title: "Available Courses"
  landing_description: "Choose a course to begin learning."
  build_individual_levels: true
```

## Lesson Metadata

Each lesson should have a `lesson.yml` file:

```yaml
# _lessons/db-mini-project/lesson.yml
name: db-mini-project
title: "DB Mini Project"
slug: db-mini-project
description: "Learn to build a full-stack React app with Supabase"
url: /db-mini-project
```

Or you can put this in the front matter of `all-levels.md`:

```markdown
---
title: "DB Mini Project"
description: "Learn to build a full-stack React app with Supabase"
---

{% level subtitle="Planning" %}
...
{% endlevel %}
```

## URL Structure

- `/` - Landing page listing all lessons
- `/db-mini-project` - Lesson home page
- `/db-mini-project/levels/db-mini-project-level-1.html` - Individual level pages
- `/db-mini-project/all-levels-spa.html` - SPA view for the lesson

## Collections

Each lesson automatically gets its own collection:

```yaml
collections:
  db-mini-project-levels:
    output: true
    permalink: /db-mini-project/levels/:name.html
  other-project-levels:
    output: true
    permalink: /other-project/levels/:name.html
```

These are auto-generated, but you can customize them in `_config.yml` if needed.

## Single Lesson Mode

If you only have one lesson, you can still use the old single-file approach:

```yaml
level_manager:
  source_file: "_levels/all-levels.md"
  collection_name: "levels"
  # ... other config
```

The theme will automatically detect if you're using multi-lesson mode (if `_lessons/` directory exists) or single lesson mode.

