# Installation Guide

## Quick Start

Add to your Jekyll site's `Gemfile`:

```ruby
source "https://rubygems.org"

gem "jekyll", "~> 4.0"

# Install theme from GitHub
gem "jekyll-level-manager-theme", git: "https://github.com/yourusername/jekyll-level-manager-theme.git"
```

Then:

```bash
bundle install
```

That's it! The theme is now installed and ready to use.

## Installation Options

### From GitHub (Public Repo)

```ruby
gem "jekyll-level-manager-theme", git: "https://github.com/yourusername/jekyll-level-manager-theme.git"
```

### From GitHub (Private Repo)

For private repos, use SSH:

```ruby
gem "jekyll-level-manager-theme", git: "git@github.com:yourusername/jekyll-level-manager-theme.git"
```

Or HTTPS with credentials:

```ruby
gem "jekyll-level-manager-theme", git: "https://username:token@github.com/yourusername/jekyll-level-manager-theme.git"
```

### Specific Version/Branch

```ruby
# Install specific tag
gem "jekyll-level-manager-theme", git: "https://github.com/yourusername/jekyll-level-manager-theme.git", tag: "v1.0.0"

# Install specific branch
gem "jekyll-level-manager-theme", git: "https://github.com/yourusername/jekyll-level-manager-theme.git", branch: "main"
```

### Local Development

If you're developing the theme locally:

```ruby
gem "jekyll-level-manager-theme", path: "../jekyll-level-manager-theme"
```

## After Installation

1. Configure your `_config.yml` (see main README for configuration options)
2. Create your `_levels/all-levels.md` file (or your configured source file)
3. Run `bundle exec jekyll serve` to see your site

## Troubleshooting

**"Could not find gem"**
- Ensure the GitHub repo URL is correct
- For private repos, ensure you have access and are using SSH or authenticated HTTPS

**"Theme not loading"**
- Run `bundle install` to ensure dependencies are installed
- Check that Jekyll can find the gem: `bundle exec jekyll doctor`

**"Plugins not working"**
- Ensure `plugins:` is set in `_config.yml` (or empty array `plugins: []`)
- Check that the theme's `_plugins/` directory is being loaded

