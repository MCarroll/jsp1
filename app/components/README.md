# UI Components

Jumpstart Pro includes a handful of UI components you can use out of the box.

## Philosophy

Our components require no dependencies out of the box. This makes maintaining and upgrading our components very easy as the only dependency is on Rails views which aren't likely to change the basic features we're using.

For advanced components, we recommend viewcomponent.org

## Usage

To render a component, instantiate the class and pass in any arguments to customize it.

Components may capture content for a specific slot. To provide HTML for the slot, use `component.capture_for` and pass it a block.

```erb
<%= render SlideoverComponent.new do |component| %>
  <button class="btn btn-secondary" data-action="slideover#show:prevent">Open Slideover</button>

  <% component.capture_for :panel do %>
    <h4 class="mt-0">This is the panel content.</h4>
  <% end %>
<% end %>
```

The `content` of a component is the output of the main block. In this case, the `<button>` tag for opening the Slideover.

## Creating your own components

Components are standard Ruby objects so you can add your own attributes, methods and logic.

```ruby
class MyComponent < JumpstartComponent
  attr_reader :close_button

  # Saves a single value
  renders_one :panel

  # Saves an array of values
  renders_many :todos

  def initialize(close_button: true)
    @close_button = @close_button
  end

  def should_render_close_button?
    !!@close_button
  end
end
```

### Slots

`renders_one` and `renders_many` allow you to dynamically capture HTML to be rendered later.

Users can provide a value to a slot using `component.capture_for(name)`

* For `renders_one` slots, this will set the value (overriding previous values).
* For `renders_many` slots, this will append the value to the array.

Capture a simple value:
```erb
<%= component.capture_for :panel, "Value" %>
```

Capture HTML with a block:
```erb
<%= component.capture_for :panel do %>
  Value
<% end %>
```

Captures for `renders_many` will be added to an array:
```erb
<%= component.capture_for :items, "1" %>
<%= component.capture_for :items, "2" %>
<%= component.capture_for :items, "3" %>
<%= component.capture_for :items, "4" %>
```

Components can ask if the slot has a value. This is helpful if you wish to hide or show something based upon a value's presence.

```erb
<%= if component.item? %><% end %>
<%= if component.items? %><% end %>
```

### Content

A special attribute called `content` is included by default. Content is the output of the block passed to `render` by the user. This is useful for things like modals that need a visible button to open the modal.

```erb
<%= render ModalComponent.new do |component| %>
  <button>Open Modal</button>

  <% component.capture_for :body do %>
    This is the modal body.
  <% end %>
<% end %>
```

The component would choose where to render `content` and insert the `body` capture into the relevant part of the modal. See our built-in ModalComponent for a full example.

### Rendering

Components use `render_in(view_context)` that's built-in to Rails.

```erb
<%= render SlideoverComponent.new do |component| %>
<% end %>
```

By default, components will render a partial with a matching name. In this case, it will render `app/views/components/_slideover.html.erb`

The component instance will be passed as a local variable to the partial. You can use this to reference slots, attributes, and methods needed for rendering your component.

For example, `MyComponent` defined above has a custom close button attribute, a panel slot, and todo slots that we can render out:

```erb
<div>
  <% component.should_render_close_button? %>
    <button>Close</button>
  <% end %>

  <%= component.panel %>

  <ul>
    <%= component.todos.each do |todo| %>
      <li><%= todo %></li>
    <% end %>
  </ul>
</div>
```

You can override the `render` method in your component to customize how the component is rendered.
