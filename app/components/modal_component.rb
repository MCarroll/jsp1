class ModalComponent < JumpstartComponent
  renders_one :header
  renders_one :body
  renders_one :actions

  def initialize(size: nil, card_class: nil, container_class: nil, close_button: true)
    @size, @card_class, @container_class, @close_button = size, card_class, container_class, close_button
  end

  def container_class
    return @container_class if @container_class.present?

    case @size
    when :sm
      "max-w-sm max-h-screen w-full relative"
    when :lg
      "max-w-lg max-h-screen w-full relative"
    when :fullscreen
      "fixed top-0 left-0 w-full h-full relative"
    else # :md
      "max-w-md max-h-screen w-full relative"
    end
  end

  def card_class
    return @card_class if @card_class.present?

    case @size
    when :fullscreen
      "p-6 w-screen h-screen bg-white dark:bg-gray-900"
    else
      "p-6 bg-white rounded shadow-lg dark:bg-gray-900 dark:text-gray-200"
    end
  end

  def close_button?
    !!@close_button
  end
end
