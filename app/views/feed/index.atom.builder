# frozen_string_literal: true

atom_feed do |feed|
  feed.title("Kudos-o-Matic - #{@team.name}")
  feed.updated(@posts.max_by(&:created_at).try(:created_at))
  feed.author do |author|
    author.name "Kudos-o-Matic"
  end

  @posts.each do |post|
    feed.entry(post, url: root_url, updated: post.created_at) do |entry|
      entry.title("New post on #{request.host}")
      entry.summary("#{post.sender.name} awarded #{post.receiver_name_feed} #{number_to_kudos(post.amount)} for #{post.message}")
    end
  end
end
