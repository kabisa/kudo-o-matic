class SlackWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(team_id, event)
    case event['type']
    when 'reaction_added'
      SlackService.reaction_added(team_id, event)
    when 'reaction_removed'
      SlackService.reaction_removed(team_id, event)
    else
      raise RuntimeError.new('Unsupported event')
    end
  end
end