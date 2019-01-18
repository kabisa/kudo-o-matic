# frozen_string_literal: true

# Encodes User preferences to JSON data
module PreferencesCoder
  module_function

  def load(data)
    data || {}
  end

  def dump(data)
    data || {}
  end
end
