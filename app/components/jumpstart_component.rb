class ApplicationComponent
  # Content is the value of the block given to the component
  attr_accessor :content

  def self.renders_one(name)
    attr_accessor name

    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{name}?
        @#{name}.present?
      end
    CODE
  end

  def self.renders_many(name)
    attr_writer name

    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{name}
        @#{name} || []
      end

      def #{name}?
        @#{name}.present?
      end
    CODE
  end

  # Captures content to be stored later
  def capture_for(name, value = nil, &block)
    value ||= @view_context.capture(&block)
    value = send(name) + [value] if send(name).is_a? Array
    send(:"#{name}=", value)
  end

  # Triggered by Rails' render call
  def render_in(view_context, &block)
    @view_context = view_context
    @content = @view_context.capture(self, &block) if block
    render
  end

  # Handles rendering of the component. Override this to handle rendering differently
  def render
    @view_context.render partial_path, component: self
  end

  def partial_path
    "components/#{component_path}"
  end

  # Scope::MyModalComponent => "components/scope/my_modal"
  def component_path
    self.class.name.delete_suffix("Component").underscore
  end
end
