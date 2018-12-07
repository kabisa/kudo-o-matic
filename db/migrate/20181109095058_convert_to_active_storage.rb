class ConvertToActiveStorage < ActiveRecord::Migration[5.2]
  require 'open-uri'

  def up
    get_blob_id = 'LASTVAL()'

    active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_blob_statement', <<-SQL)
      INSERT INTO active_storage_blobs (
        key, filename, content_type, metadata, byte_size,
        checksum, created_at
      ) VALUES ($1, $2, $3, '{}', $4, $5, $6)
    SQL

    active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_attachment_statement', <<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES ($1, $2, $3, #{get_blob_id}, $4)
    SQL

    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    transaction do
      models.each do |model|
        attachments = model.column_names.map do |c|
          if c =~ /(.+)_file_name$/
            $1
          end
        end.compact

        if attachments.blank?
          next
        end

        model.find_each.each do |instance|
          attachments.each do |attachment|
            begin
              if instance.send(attachment).path.blank?
                next
              end
            rescue
              next
            end

            active_storage_blob_statement.execute(
                key(instance, attachment),
                instance.send("#{attachment}_file_name"),
                instance.send("#{attachment}_content_type"),
                instance.send("#{attachment}_file_size"),
                checksum(instance.send(attachment)),
                instance.updated_at.iso8601
            )

            active_storage_attachment_statement.
                execute(attachment, model.name, instance.id, instance.updated_at.iso8601)
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def key(instance, attachment)
    filename = instance.send("#{attachment}_file_name")
    klass = instance.class.table_name
    id = instance.id
    id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)

    "#{klass}/#{attachment.pluralize}/#{id_partition}/original/#{filename}"
  end

  def checksum(attachment)
    url = attachment.url
    Digest::MD5.base64digest(Net::HTTP.get(URI(url)))
  end
end