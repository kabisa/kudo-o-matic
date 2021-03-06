# frozen_string_literal: true

module Types
  class MutationType < BaseObject
    ### Guideline
    field :create_guideline, mutation: Mutations::Guideline::CreateGuideline
    field :delete_guideline, mutation: Mutations::Guideline::DeleteGuideline
    field :update_guideline, mutation: Mutations::Guideline::UpdateGuideline

    ### Goal
    field :create_goal, mutation: Mutations::Goal::CreateGoal
    field :delete_goal, mutation: Mutations::Goal::DeleteGoal
    field :update_goal, mutation: Mutations::Goal::UpdateGoal

    ### KudosMeter
    field :create_kudos_meter, mutation: Mutations::KudosMeter::CreateKudosMeter
    field :delete_kudos_meter, mutation: Mutations::KudosMeter::DeleteKudosMeter
    field :update_kudos_meter, mutation: Mutations::KudosMeter::UpdateKudosMeter
    field :set_active_kudos_meter, mutation: Mutations::KudosMeter::SetActiveKudosMeter

    ### Post
    field :create_post, mutation: Mutations::Post::CreatePost
    field :delete_post, mutation: Mutations::Post::DeletePost

    ### Team
    field :create_team, mutation: Mutations::Team::CreateTeam
    field :remove_slack, mutation: Mutations::Team::RemoveSlack
    field :update_team, mutation: Mutations::Team::UpdateTeam

    ### TeamInvite
    field :create_team_invite, mutation: Mutations::TeamInvite::CreateInvite
    field :delete_team_invite, mutation: Mutations::TeamInvite::DeleteInvite
    field :accept_team_invite, mutation: Mutations::TeamInvite::AcceptInvite
    field :decline_team_invite, mutation: Mutations::TeamInvite::DeclineInvite
    
    ### TeamMember
    field :delete_team_member, mutation: Mutations::TeamMember::DeleteMember
    field :update_team_member_role, mutation: Mutations::TeamMember::UpdateRole

    ### User
    field :disconnect_slack, mutation: Mutations::User::DisconnectSlack
    field :forgot_password, mutation: Mutations::User::ForgotPassword
    field :new_password, mutation: Mutations::User::NewPassword
    field :reset_password, mutation: Mutations::User::ResetPassword
    field :sign_in_user, mutation: Mutations::User::SignIn
    field :sign_up_user, mutation: Mutations::User::SignUp

    ### Vote
    field :toggle_like_post, mutation: Mutations::Vote::ToggleLikePost
  end
end
