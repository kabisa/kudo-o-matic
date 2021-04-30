module Types
  class ImageType < Types::BaseObject
    graphql_name "Image"

    field :image_url, String,
          null: false,
          description: 'The URL to the full sized image'
    field :image_thumbnail_url, String,
          null: false,
          description: 'The URL to a 200x160 thumbnail image (ratio is maintained)'

    def image_url
      Rails.application.routes.url_helpers.rails_blob_url(object, only_path: false)
    end

    def image_thumbnail_url
      Rails.application.routes.url_helpers.rails_representation_url(object.variant(resize: "200x160").processed, only_path: false)
    end
  end
end
