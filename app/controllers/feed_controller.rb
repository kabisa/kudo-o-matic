# frozen_string_literal: true

class FeedController < ApplicationController
  def index
    request.format = :atom

    @team = Team.where(slug: params[:team], rss_token: params[:rss_token]).first
    render("layouts/404", status: 404, formats: :html) && return if @team.nil?

    @posts = Post.where(team: @team).last(25)
    respond_to do |format|
      format.atom
    end
  end
end
