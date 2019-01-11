# frozen_string_literal: true

module Types
  class MutationType < BaseObject
    field :sign_up_user, mutation: Mutations::SignUpUserMutation
    field :sign_in_user, mutation: Mutations::SignInUserMutation

    field :accept_team_invite, mutation: Mutations::AcceptTeamInviteMutation
    field :decline_team_invite, mutation: Mutations::DeclineTeamInviteMutation

    field :forgot_password, mutation: Mutations::ForgotPasswordMutation
    field :new_password, mutation: Mutations::NewPasswordMutation
    field :reset_password, mutation: Mutations::ResetPasswordMutation

    field :create_post, mutation: Mutations::CreatePostMutation
    field :delete_post, mutation: Mutations::DeletePostMutation

    field :create_team, mutation: Mutations::CreateTeamMutation
    field :create_team_invite, mutation: Mutations::CreateTeamInviteMutation

    field :toggle_like_post, mutation: Mutations::ToggleLikePostMutation
  end
end
