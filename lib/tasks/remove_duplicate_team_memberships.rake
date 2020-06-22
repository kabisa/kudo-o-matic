namespace :remove_duplicate_team_memberships do
  desc 'Remove duplicate team memberships'
  task :remove => :environment do
    puts 'Removing duplicate memberships'

    TeamMember.all.find_each do |team_member|
      same_team_memberships = TeamMember.where(team_id: team_member.team_id, user_id: team_member.user_id)

      same_team_memberships[1..same_team_memberships.size].each_with_index do |membership, i|
        membership.destroy
      end
    end
  end
end
