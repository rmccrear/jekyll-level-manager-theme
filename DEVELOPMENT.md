# Development Guide

## Local Development Setup

When developing the theme, you can use it locally in a Jekyll site without pushing to GitHub.

### Option 1: Local Path (Recommended for Development)

In your Jekyll site's `Gemfile`:

```ruby
gem "jekyll-level-manager-theme", path: "../jekyll-level-manager-theme"
```

This allows you to:
- Edit theme files directly
- See changes immediately on `jekyll serve`
- No need to commit/push for testing

### Option 2: Git with Local Override

If you're using Git installation but want to develop locally:

```ruby
# In Gemfile, comment out the git line and use path instead:
# gem "jekyll-level-manager-theme", git: "https://github.com/yourusername/jekyll-level-manager-theme.git"
gem "jekyll-level-manager-theme", path: "../jekyll-level-manager-theme"
```

## Making Edits

All files in the theme directory are editable:

- `_plugins/*.rb` - Ruby plugins (generators, tags, filters, commands)
- `_plugins/commands/*.rb` - Command implementations
- `_layouts/*.html` - HTML layouts
- `assets/css/*.css` - Stylesheets
- `assets/js/*.js` - JavaScript
- `lib/jekyll-level-manager-theme.rb` - Gem entry point file
- `exe/*` - Executable commands

## Testing Changes

1. Make your edits to theme files
2. Restart Jekyll server: `bundle exec jekyll serve`
3. Changes should be reflected immediately

## File Structure

```
jekyll-level-manager-theme/
├── _layouts/          # Editable HTML layouts
├── _plugins/          # Editable Ruby plugins (generators, tags, filters, commands)
├── assets/            # Editable CSS/JS
├── lib/               # Editable gem entry point
├── exe/               # Editable executables
└── scripts/           # Editable build scripts
```

All files in these directories can be edited directly.

