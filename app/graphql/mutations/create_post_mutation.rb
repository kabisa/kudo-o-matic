module Mutations
  class CreatePostMutation < BaseMutation
    null true

    argument :message, String, required: false, description: 'The reason you are giving kudos'
    argument :amount, Int, required: false, description: 'The amount of kudos you want to give'
    argument :receiver_ids, [ID], required: false, description: 'The existing users'
    argument :null_receivers, [String], required: false, description: 'The non-existing users'
    argument :team_id, ID, required: false, description: 'The team the post belongs to'

    field :post, Types::PostType, null: true
    field :errors, [String], null: false

    def resolve(**kwargs)
      team = Team.find(kwargs[:team_id])
      receivers = []
      receiver_ids = kwargs[:receiver_ids]

      unless receiver_ids.blank?
        receiver_ids.each do |receiver|
          receivers << User.find(receiver)
        end
      end

      null_receivers = kwargs[:null_receivers]

      unless null_receivers.blank?
        null_receivers.each do |receiver|
          user = User.new(
            name: receiver,
            virtual_user: true
          )

          user.save
          team.add_member(user)
          receivers << user
        end
      end

      post = Post.new(
        message: kwargs[:message],
        amount: kwargs[:amount],
        sender: context[:current_user],
        receivers: receivers,
        team: team,
        kudos_meter: team.active_kudos_meter
      )

      if post.save
        PostMailer.new_post(post)
        GoalReacher.check!(team)
        { post: post, errors: [] }
      else
        { post: nil, errors: post.errors.full_messages }
      end
    end
  end
end