# frozen_string_literal: true

class Api::V2::TeamInvitesController < Api::V2::ApiController
  def update
    invite_id = params[:id]
    accept = params['accept']
    @invite = TeamInvite.where(id: invite_id).where(accepted_at: nil).where(declined_at: nil).first
    if @invite
      if accept
        @invite.accept
        render 'api/v2/teams/accepted', status: :ok
      else
        @invite.decline
        render 'api/v2/teams/declined', status: :ok
      end
    else
      render json: { 'errors': [
        {
          title: 'Expired invite',
          detail: 'This invite does not exist or has expired'
        }
      ] }
    end
  end
end
