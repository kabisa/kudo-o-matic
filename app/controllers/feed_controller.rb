class FeedController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    request.format = :atom
    redirect_to root_url if Team.find_by_slug(params[:team]).nil?
    @transactions = Transaction.where(team: Team.find_by_slug(params[:team])).last(25)

    respond_to do |format|
      format.atom
    end
  end
end
