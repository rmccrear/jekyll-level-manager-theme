module Jekyll
  module LiquidMarkdownFilter
    def liquid_markdownify(input)
      return input if input.nil? || input.empty?
      
      content = input.to_s
      
      # Get context from the filter call
      context = @context
      site = context.registers[:site]
      
      # Reset level counter for this page before parsing (ensures each page starts at 1)
      # Get page URL from context for per-page counter
      page = context.registers[:page]
      page_key = page && page['url'] ? page['url'] : 'default'
      Jekyll::LevelTag.reset_counter(page_key) if defined?(Jekyll::LevelTag)
      
      begin
        # First, render as Liquid template to process tags like {% showme %}
        template = Liquid::Template.parse(content)
        liquid_output = template.render(context)
      rescue Liquid::SyntaxError => e
        # If Liquid parsing fails, just use the content as-is and convert to markdown
        Jekyll.logger.warn "LiquidMarkdownFilter:", "Liquid parsing error: #{e.message}"
        liquid_output = content
      end
      
      # Then convert markdown to HTML
      converter = site.find_converter_instance(Jekyll::Converters::Markdown)
      html_output = converter.convert(liquid_output)
      
      html_output
    end
  end
end

Liquid::Template.register_filter(Jekyll::LiquidMarkdownFilter)

