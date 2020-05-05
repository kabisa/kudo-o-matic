class PostCreator
  class PostCreateError < RuntimeError; end

  public
  def self.create_post(message, amount, sender, receivers, team)
    post = Post.new(
        message: message,
        amount: amount,
        sender: sender,
        receivers: receivers,
        team: team,
        kudos_meter: team.active_kudos_meter
    )

    if post.save
      PostMailer.new_post(post)
      GoalReacher.check!(post.team)
      SlackService.send_post_announcement(post) unless team.slack_team_id == nil
      post
    else
      raise PostCreateError, post.errors.full_messages.join(', ')
    end
  end
end
