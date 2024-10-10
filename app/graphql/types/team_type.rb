# frozen_string_literal: true

module Types
  class TeamType < Types::BaseObject
    graphql_name 'Team'

    field :id, ID, null: false
    field :name, String,
          null: false,
          description: 'The name of the team'
    field :slack_team_id, String,
          null: true,
          description: 'The slack id of the team'
    field :slug, String,
          null: false,
          description: 'The slug (friendly id) of the team'
    field :users, [UserType],
          null: false,
          description: 'The users that are member of the team',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(User).load_many(obj.user_ids) }
    field :posts, Connections::PostsConnection,
          null: false,
          description: 'The posts that belong to the team' do
            argument :order_by, String, required: false, default_value: "created_at desc"
          end

    def posts(order_by:)
      result = object.posts
      result = result.where(kudos_meter_id: active_kudos_meter.id)
      result = result.order(order_by) unless order_by.blank?
      result
    end

    field :kudos_meters, [Types::KudosMeterType],
          null: false,
          description: 'All KudosMeters that belong to the team' do
            argument :order_by, String, required: false, default_value: "created_at desc"
          end

    def kudos_meters(order_by:)
      result = object.kudos_meters
      result = result.order(order_by) unless order_by.blank?
      result
    end

    field :active_kudos_meter, Types::KudosMeterType,
          null: false,
          description: 'The active KudosMeter that belongs to the team',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(KudosMeter).load(obj.active_kudos_meter.id) }
    field :goals, [Types::GoalType],
          null: false,
          description: 'All goals that belong to the team',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Goal).load_many(obj.goal_ids) }
    field :active_goals, [Types::GoalType],
          null: false,
          description: 'All goals that belong to the team and are part of the active KudosMeter',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Goal).load_many(obj.active_kudos_meter.goal_ids) }

    def active_goals
      object.active_kudos_meter.goals
    end

    field :memberships, [Types::TeamMemberType],
          null: false,
          description: 'The members of the team' do
            argument :order_by, String, required: false, default_value: "name"
          end

    def memberships(order_by:)
      result = object.memberships
      if order_by.include? 'name'
        result = result.joins(:user).order(order_by)
      elsif order_by.blank?
        result
      else
        result = result.order(order_by)
      end
      result
    end

    field :team_invites, [Types::TeamInviteType],
          null: false,
          description: 'The invites send by the team' do
            argument :order_by, String, required: false, default_value: "sent_at desc"
          end

    def team_invites(order_by:)
      result = object.team_invites
      result = result.order(order_by) unless order_by.blank?
      result
    end

    field :guidelines, [Types::GuidelineType],
          null: false,
          description: 'All guidelines that belong to the team' do
            argument :order_by, String, required: false, default_value: "kudos asc"
          end

    def guidelines(order_by:)
      result = object.guidelines
      result = result.order(order_by) unless order_by.blank?
      result
    end

    field :created_at, GraphQL::Types::ISO8601DateTime,
          null: false,
          description: 'The time the team was created'
    field :updated_at, GraphQL::Types::ISO8601DateTime,
          null: false,
          description: 'The time the team was last updated'
  end
end
