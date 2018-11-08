# frozen_string_literal: true

class RemoveDelayedJobsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :delayed_jobs
  end
end
