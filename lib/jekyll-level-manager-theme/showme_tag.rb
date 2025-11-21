module Jekyll
  class ShowMeTag < Liquid::Block
    def initialize(tag_name, title, tokens)
      super
      # Remove quotes from title if present
      @title = title.strip.gsub(/^["']|["']$/, '')
    end

    def render(context)
      content = super  # Get the block content
      
      # Get the site and markdown converter
      site = context.registers[:site]
      converter = site.find_converter_instance(Jekyll::Converters::Markdown)
      
      # Process the content as markdown
      html_content = converter.convert(content)
      
      # Wrap in details/summary structure
      <<~HTML
        <details>
          <summary>Show Me: #{@title}</summary>
          
          #{html_content}
        </details>
      HTML
    end
  end
end

Liquid::Template.register_tag('showme', Jekyll::ShowMeTag)

