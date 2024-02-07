class ScaffoldGenerator < Rails::Generators::NamedBase
  hook_for :scaffold, in: :rails, default: true, type: :boolean

  def add_to_navigation
    append_to_file "app/views/shared/_left_nav.html.erb" do
      "<%= nav_link_to \"#{plural_table_name.titleize}\", #{index_helper(type: :path)}, class: \"nav-link\" %>\n"
    end
  end

  def turbo_refreshes
    # Scaffold generator will have already removed this file on revoke
    return if behavior == :revoke

    inject_into_class File.join("app/models", class_path, "#{file_name}.rb"), class_name do
      "  broadcasts_refreshes\n"
    end
  end
end
