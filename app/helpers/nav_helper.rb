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
  def header_with_anchor(title, header_tag: :h2, id: nil, icon: nil, header_class: "group", link_class: "hidden align-middle group-hover:inline-block p-1", icon_class: "text-gray-500 h-4 w-4")
    id ||= title.parameterize
    icon ||= <<~LINK.html_safe
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="#{icon_class}">
        <path fill-rule="evenodd" d="M19.902 4.098a3.75 3.75 0 0 0-5.304 0l-4.5 4.5a3.75 3.75 0 0 0 1.035 6.037.75.75 0 0 1-.646 1.353 5.25 5.25 0 0 1-1.449-8.45l4.5-4.5a5.25 5.25 0 1 1 7.424 7.424l-1.757 1.757a.75.75 0 1 1-1.06-1.06l1.757-1.757a3.75 3.75 0 0 0 0-5.304Zm-7.389 4.267a.75.75 0 0 1 1-.353 5.25 5.25 0 0 1 1.449 8.45l-4.5 4.5a5.25 5.25 0 1 1-7.424-7.424l1.757-1.757a.75.75 0 1 1 1.06 1.06l-1.757 1.757a3.75 3.75 0 1 0 5.304 5.304l4.5-4.5a3.75 3.75 0 0 0-1.035-6.037.75.75 0 0 1-.354-1Z" clip-rule="evenodd" />
      </svg>
    LINK
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
