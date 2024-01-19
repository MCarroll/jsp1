require "pagy/extras/array"

module Jumpstart
  class DocsController < ::ApplicationController
    def pagination
      @pagy, _ = pagy_array([nil] * 1000)
    end
  end
end
