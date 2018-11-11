# frozen_string_literal: true


module Types
  TeamType = GraphQL::ObjectType.define do
    name "Team"

    field :id, !types.ID, "The Team ID"
    field :name, !types.String, "The Team Name"
    field :slug, !types.String, "The team slug (friendly id)"

    field :memberships, !types[Types::UserType] do
      description "The users that are member of the team"
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(User).load_many(obj.memberships.ids) }
    end

    field :posts, !types[Types::PostType] do
      description "The posts that belong to the team"
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Post).load_many(obj.post_ids) }
    end

    field :kudosMeters, !types[Types::KudosMeterType] do
      description "All KudosMeters that belong to the team"
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(KudosMeter).load_many(obj.kudos_meter_ids) }
    end

    field :activeKudosMeter, !Types::KudosMeterType do
      description "The active KudosMeter that belongs to the team"
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(KudosMeter).load(obj.kudos_meter_ids) }
    end

    field :goals, !types[Types::GoalType] do
      description "All goals that belong to the team"
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Goal).load_many(obj.goal_ids) }
    end

    field :activeGoals, !types[Types::GoalType] do
      description "All goals that belong to the team and are part of the active KudosMeter"
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Goal).load_many(obj.active_kudos_meter.goal_ids) }
    end
  end
end
