# frozen_string_literal: true

class AddAttachmentZipToExports < ActiveRecord::Migration[5.0]
  def self.up
    change_table :exports do |t|
      t.attachment :zip
    end
  end

  def self.down
    remove_attachment :exports, :zip
  end
end
