class FeedController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    request.format = :atom
    @team = Team.where(slug: params[:team], rss_token: params[:rss_token]).first
    render('layouts/404', status: 404, formats: :html) && return if @team.nil?

    @transactions = Transaction.where(team: @team).last(25)
    respond_to do |format|
      format.atom
    end
  end
end
