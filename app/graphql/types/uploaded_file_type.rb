# frozen_string_literal: true

module Types
  class UploadedFileType < BaseScalar
    description 'An uploaded file'

    def self.coerce_input(file, context)
      ActionDispatch::Http::UploadedFile.new(
        filename: file.original_filename,
        type: file.content_type,
        headers: file.headers,
        tempfile: file.tempfile
      )
    end
  end
end
