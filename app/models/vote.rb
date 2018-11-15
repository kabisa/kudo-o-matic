# frozen_string_literal: true

# == Schema Information
#
# Table name: votes
#
#  id           :integer          not null, primary key
#  votable_type :string
#  votable_id   :integer
#  voter_type   :string
#  voter_id     :integer
#  vote_flag    :boolean
#  vote_scope   :string
#  vote_weight  :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Vote < ApplicationRecord
  belongs_to :user_voter, class_name: "User", foreign_key: "voter_id"
  belongs_to :post_votable, class_name: "Post", foreign_key: "votable_id"
end
