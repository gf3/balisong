module PagesHelper

  # Render a part as HTML. Name is the filename of the part, and formatter is
  # the name of the formatter that will be used to render the part as HTML,
  # something like "code" or "html" or "code(ruby)".
  # If formatter is nil it will be guessed based on the file extension.
  def render_part(page, part_name, formatter)
    if formatter.nil?
      formatter = Page.type(part_name)
      formatter_arg = nil
    elsif formatter =~ /(.*)\(([^\)]+)\)?/
      formatter = $1
      formatter_arg = $2
    else
      formatter = formatter
      formatter_arg = nil
    end

    Rails.logger.info "Rendering part: #{page}/#{part_name} with formatter #{formatter} (with arg: #{formatter_arg})"

    raw_data = page.blobs[part_name]
    raise "Can't find part '#{part_name}'" unless raw_data

    # these should be extracted somewhere to be extensible
    case formatter
    when "markdown"
      out = RDiscount.new(raw_data).to_html
    when "textile"
      out = RedCloth.new(raw_data).to_html
    when "html"
      out = raw_data
    when "text"
      out = "<pre>#{html_escape(raw_data)}</pre>"
    when "code"
      lang = formatter_arg || Page.type(part_name)
      out = "<pre><code class='#{lang}'>#{html_escape(raw_data)}<code></pre>"
    when "image"
      # TODO use url_for here
      out = "<img src='/#{page.id}/#{part_name}'>"
      skip_sub_render = true
    when "download"
      # TODO use url_for here
      out = link_to(part_name, "/#{page.id}/#{part_name}?download=true")
      skip_sub_render = true
    else
      raise "unknown formatter: #{formatter}"
    end

    # Render sub-parts recursively
    unless skip_sub_render
      # match {{ file.md }} or {{file.rb | code(ruby)}}, etc.
      regex = /\{\{\s*([\w\.-]+)\s*\|?\s*([\w\.-]+\(?[\w\.-]*\)?)?\s*\}\}/
      out = out.gsub(regex) {|match| render_part(page, $1, $2) }
    end

    return out
  end

end

