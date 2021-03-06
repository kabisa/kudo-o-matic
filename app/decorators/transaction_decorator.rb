# frozen_string_literal: true

class PostDecorator < Draper::Decorator
  delegate_all
  decorates_association :sender
  decorates_association :receiver

  def self.collection_decorator_class
    PaginatingDecorator
  end
end
