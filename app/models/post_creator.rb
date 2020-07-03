class PostCreator
  class PostCreateError < RuntimeError; end

  def self.create_post(message, amount, sender, receivers, team, send_slack_announcement = true)
    post = Post.new(
        message: message,
        amount: amount,
        sender: sender,
        receivers: receivers,
        team: team,
        kudos_meter: team.active_kudos_meter
    )

    begin
      ActiveRecord::Base.transaction do
        post.save!
        GoalReacher.check!(post.team)
      end
    rescue ActiveModel::RecordInvalid => e
      raise PostCreateError(post.errors.full_messages.join(', '))
    rescue Exception => e
      raise PostCreateError(e.message)
    end

    PostMailer.new_post(post)

    if send_slack_announcement && !team.slack_team_id.blank?
      SlackService.send_post_announcement(post)
    end

    post
  end
end
