module NavHelper
  def nav_link_to(name = nil, options = {}, html_options = {}, &block)
    if block
      html_options = options
      options = name
      name = block
    end

    url = url_for(options)
    starts_with = html_options.delete(:starts_with)
    html_options[:class] = Array.wrap(html_options[:class])
    active_class = html_options.delete(:active_class) || "active"
    inactive_class = html_options.delete(:inactive_class) || ""

    paths = Array.wrap(starts_with)
    active = if paths.present?
      paths.any? { |path| request.path.start_with?(path) }
    else
      request.path == url
    end

    classes = active ? active_class : inactive_class
    html_options[:class] << classes unless classes.empty?

    html_options.except!(:class) if html_options[:class].empty?

    return link_to url, html_options, &block if block

    link_to name, url, html_options
  end

  # Generates a header with a link with an anchor for sharing
  def header_with_anchor(title, header_tag: :h2, id: nil, icon: nil, header_class: "group", link_class: "hidden align-middle group-hover:inline-block p-1", icon_class: "fill-current text-gray-500 h-4 w-4")
    id ||= title.parameterize
    icon ||= render_svg("icons/link", styles: icon_class)
    tag.send(header_tag, id: id, class: header_class) do
      tag.span(title) + link_to(icon, "##{id}", class: link_class)
    end
  end

  (1..6).each do |i|
    define_method :"h#{i}_with_anchor" do |*args, **kwargs|
      header_with_anchor(*args, **kwargs.merge(header_tag: :"h#{i}"))
    end
  end
end
