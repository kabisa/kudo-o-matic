# frozen_string_literal: true

class ExportService
  include Singleton

  def start_new_export(user, format)
    Export::CreateExportJob.new(user, format)
  end

  def delete_expired_exports
    Export::MaintainExportsJob.new
  end
end
