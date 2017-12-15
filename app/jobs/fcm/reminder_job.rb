Fcm::ReminderJob = Struct.new(:nil) do
  def perform
    registration_ids = FcmToken.joins(:user).where('deactivated_at IS NULL').collect(&:token).flatten.uniq

    return if registration_ids.blank?

    title = '₭udo reminder!'
    body = "Don't forget to think back about this week, because there is definitely someone who deserves a compliment!"
    event = 'reminder'

    options = {
        notification: {
            title: title,
            body: body,
            event: event,
            sound: 'default',
            badge: '1'
        },
        data: {
            title: title,
            body: body,
            event: event,
        },
        priority: 'high'
    }

    FCM_SERVICE.send(registration_ids, options)
  end

  def queue_name
    'fcm'
  end
end
