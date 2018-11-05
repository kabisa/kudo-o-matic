# frozen_string_literal: true

module ApplicationHelper
  def number_to_kudos(number)
    options = {
      precision: 0,
      unit: "₭",
      separator: ",",
      delimiter: ".",
      format: "%n %u",
    }

    number_to_currency(number, options)
  end
end
