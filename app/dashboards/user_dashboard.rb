require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    sent_transactions: Field::HasMany.with_options(class_name: "Transaction"),
    received_transactions: Field::HasMany.with_options(class_name: "Transaction"),
    id: Field::Number,
    name: Field::String,
    slack_name: Field::String,
    email: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :slack_name,
    :sent_transactions,
    :received_transactions,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :slack_name,
    :created_at,
    :updated_at,
    :sent_transactions,
    :received_transactions,
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :email,
    :slack_name
  ]

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(user)
    user.name
  end
end
