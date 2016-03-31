require "administrate/base_dashboard"

class TransactionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    balance: Field::BelongsTo,
    activity: Field::BelongsTo,
    sender: Field::BelongsTo.with_options(class_name: "User"),
    receiver: Field::BelongsTo.with_options(class_name: "User"),
    id: Field::Number,
    from_id: Field::Number,
    to_id: Field::Number,
    amount: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :balance,
    :activity,
    :sender,
    :receiver,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :balance,
    :activity,
    :sender,
    :receiver,
    :id,
    :from_id,
    :to_id,
    :amount,
    :created_at,
    :updated_at,
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :balance,
    :activity,
    :sender,
    :receiver,
    :from_id,
    :to_id,
    :amount,
  ]

  # Overwrite this method to customize how transactions are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(transaction)
  #   "Transaction ##{transaction.id}"
  # end
end
