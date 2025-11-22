# frozen_string_literal: true

require "jekyll"

module Jekyll
  module LevelManagerTheme
    VERSION = "1.0.0"
  end
end

# Load all plugins
# Use __dir__ which works in Ruby 2.0+
# __dir__ is now lib/, so go up one level to find _plugins
gem_root = File.expand_path("..", __dir__)
plugin_dir = File.join(gem_root, "_plugins")
if File.directory?(plugin_dir)
  # Load plugin files
  Dir[File.join(plugin_dir, "*.rb")].sort.each do |file|
    require file
  end
  
  # Load command files (commands are in _plugins with _command suffix)
  Dir[File.join(plugin_dir, "*_command.rb")].sort.each do |file|
    require file
  end
else
  # Fallback: try to find the directory relative to this file
  # This handles cases where __dir__ might not work as expected
  require_relative "../_plugins/lessons_generator"
  require_relative "../_plugins/build_levels_generator"
  require_relative "../_plugins/all_levels_spa_generator"
  require_relative "../_plugins/level_tag"
  require_relative "../_plugins/showme_tag"
  require_relative "../_plugins/liquid_markdown_filter"
end

