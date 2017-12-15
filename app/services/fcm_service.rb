class FcmService
  include Singleton

  def send_new_transaction(transaction)
    return unless fcm_service_configured

    Delayed::Job.enqueue Fcm::TransactionJob.new(transaction)
  end

  def send_goal_reached
    return unless fcm_service_configured

    Delayed::Job.enqueue Fcm::GoalJob.new(nil)
  end

  def send_reminder
    return unless fcm_service_configured

    Delayed::Job.enqueue Fcm::ReminderJob.new(nil)
  end

  private

  def fcm_service_configured
    FCM_SERVICE.present?
  end
end