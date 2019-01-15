# frozen_string_literal: true

module Types
  class MutationType < BaseObject
    ### Guideline
    field :create_guideline, mutation: Mutations::Guideline::CreateGuideline
    field :delete_guideline, mutation: Mutations::Guideline::DeleteGuideline
    field :update_guideline, mutation: Mutations::Guideline::UpdateGuideline

    ### KudosMeter
    field :create_kudos_meter, mutation: Mutations::KudosMeter::CreateKudosMeter
    field :delete_kudos_meter, mutation: Mutations::KudosMeter::DeleteKudosMeter
    field :update_kudos_meter, mutation: Mutations::KudosMeter::UpdateKudosMeter

    ### Post
    field :create_post, mutation: Mutations::Post::CreatePost
    field :delete_post, mutation: Mutations::Post::DeletePost

    ### Team
    field :create_team, mutation: Mutations::Team::CreateTeam

    ### TeamInvite
    field :create_team_invite, mutation: Mutations::TeamInvite::CreateInvite
    field :accept_team_invite, mutation: Mutations::TeamInvite::AcceptInvite
    field :decline_team_invite, mutation: Mutations::TeamInvite::DeclineInvite
    
    ### TeamMember
    field :update_team_member_role, mutation: Mutations::TeamMember::UpdateRole

    ### User
    field :forgot_password, mutation: Mutations::User::ForgotPassword
    field :new_password, mutation: Mutations::User::NewPassword
    field :reset_password, mutation: Mutations::User::ResetPassword
    field :sign_in_user, mutation: Mutations::User::SignIn
    field :sign_up_user, mutation: Mutations::User::SignUp

    ### Vote
    field :toggle_like_post, mutation: Mutations::Vote::ToggleLikePost
  end
end
