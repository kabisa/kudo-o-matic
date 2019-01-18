# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :user_voter, class_name: "User", foreign_key: "voter_id"
  belongs_to :post_votable, class_name: "Post", foreign_key: "votable_id"
end
