# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-level-manager-theme"
  spec.version       = "1.0.0"
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]

  spec.summary       = "A Jekyll theme for managing structured content with auto-numbering and cross-referencing"
  spec.description   = "A Jekyll theme that provides a single-file content management system with automatic level numbering, cross-referencing, and SPA development view."
  spec.homepage      = "https://github.com/yourusername/jekyll-level-manager-theme"
  spec.license       = "MIT"

  # GitHub Packages metadata
  spec.metadata      = {
    "source_code_uri" => "https://github.com/yourusername/jekyll-level-manager-theme",
    "github_repo" => "https://github.com/yourusername/jekyll-level-manager-theme"
  }

  spec.files         = Dir["{_layouts,_plugins,assets,lib}/**/*"] + 
                       ["jekyll-level-manager-theme.gemspec", "LESSON_PROMPT.md"]
  spec.bindir        = "exe"
  spec.executables   = ["create-example-lesson", "init-course"]
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ">= 3.8", "< 5.0"
  spec.add_dependency "liquid", "~> 4.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end

