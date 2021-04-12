# frozen_string_literal: true

RSpec.describe User, type: :model do
  it "should have a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "should have valid factory aliases" do
    expect(build(:sender)).to be_valid
    expect(build(:receiver)).to be_valid
  end

  let(:user) { create(:user, :admin) }
  let(:user_2) { create(:user) }
  let(:team) { create(:team) }

  before do
    team.add_member(user)
    team.add_member(user_2)
  end

  let(:kudos_meter) { team.active_kudos_meter }
  let!(:post) { create(:post, sender: user, receivers: [user_2], team: team, kudos_meter: kudos_meter) }
  let!(:post_2) { create(:post, sender: user_2, receivers: [user], team: team, kudos_meter: kudos_meter) }

  describe "model destroy dependencies" do
    before do
      TeamMember.where(user: user).first.destroy
    end

    it "should destroy dependent SentPosts" do
      expect { user.destroy }.to change { PostReceiver.count }
    end

    it "should destroy dependent ReceivedPosts" do
      expect { user.destroy }.to change { PostReceiver.count }
    end
  end

  describe "model validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe "model associations" do
    it { is_expected.to have_many(:sent_posts).dependent(:destroy).with_foreign_key("sender_id") }
    it { is_expected.to have_many(:post_receivers).dependent(:destroy) }
    it { is_expected.to have_many(:received_posts).through(:post_receivers) }
    it { is_expected.to have_many(:memberships).with_foreign_key("user_id") }
    it { is_expected.to have_many(:teams).through(:memberships) }
    it { is_expected.to have_many(:votes).with_foreign_key("voter_id") }
    it { is_expected.to have_many(:exports).with_foreign_key("user_id") }
    it { is_expected.to have_many(:fcm_tokens) }
  end

  describe '#member_of?(team)' do
    it 'returns true if user is member of the team' do
      expect(user.member_of?(team)).to be true
    end

    it 'returns false if user is not member of the team' do
      TeamMember.where(user: user).first.destroy
      expect(user.member_of?(team)).to be false
    end
  end

  describe '#member_since(team)' do
    it 'returns DateTime if user is member of the team' do
      team.add_member(user)

      expect(user.member_since(team)).to eq(user.memberships.first.created_at)
    end

    it 'returns nil if user is not member of the team' do
      TeamMember.where(user: user).first.destroy
      expect(user.member_since(team)).to be_nil
    end
  end

  describe '#admin_of?(team)' do
    it 'returns true if user is admin of the team' do
      TeamMember.where(user: user).first.destroy
      team.add_member(user, 'admin')

      expect(user.admin_of?(team)).to be true
    end

    it 'returns false if user is not admin of the team' do
      team.add_member(user)

      expect(user.admin_of?(team)).to be false
    end
  end

  describe '#open_invites' do
    it 'returns the invites of the user' do
      invite = create(:team_invite, email: user.email, team: team)

      expect(user.open_invites).to eq([invite])
    end

    it 'returns an empty array if user has no invites' do
      expect(user.open_invites).to be_empty
    end
  end

  describe '#first_name' do
    it 'returns the first name of the user' do
      user_with_full_name = create(:user, name: "John Doe")
      expect(user_with_full_name.first_name).to eq("John")
    end

    it 'returns an empty array if user has no invites' do
      expect(user.open_invites).to be_empty
    end
  end

  describe '#picture_url' do
    it 'returns the avatar of the user' do
      user_with_avatar = create(:user, avatar_url: "/kabisa_lizard.png")
      expect(user_with_avatar.picture_url).to eq(user_with_avatar.avatar_url)
    end

    it 'returns a gravatar if user has no avatar' do
      user = create(:user, email: "my@email.com")
      gravatar = Digest::MD5::hexdigest(user.email).downcase

      expect(user.picture_url).to eq("https://gravatar.com/avatar/#{gravatar}.png?d=retro&s=200")
    end
  end

  describe '#deactivate' do
    it 'deactivates the users account' do
      expect { user_2.deactivate }.to change { user_2.deactivated_at }
    end
  end

  describe '#reactivate' do
    it 'reactivates the users account' do
      deactivated_user = create(:user, :deactivated)

      expect { deactivated_user.reactivate }.to change { deactivated_user.deactivated_at }.to(nil)
    end
  end

  describe '#deactivated?' do
    it 'returns true if users account is deactivated' do
      deactivated_user = create(:user, :deactivated)

      expect(deactivated_user.deactivated?).to be true
    end

    it 'returns false if users account is not deactivated' do
      expect(user.deactivated?).to be false
    end
  end

  describe '#multiple_teams?' do
    it 'returns true if user has multiple teams' do
      team.add_member(user)
      team_2 = create(:team)
      team_2.add_member(user)

      expect(user.multiple_teams?).to be true
    end

    it 'returns false if user has not multiple teams' do
      TeamMember.where(user: user).first.destroy
      team.add_member(user)

      expect(user.multiple_teams?).to be false
    end
  end

  describe '#active_for_authentication?' do
    it 'returns true if user can authenticate' do
      expect(user.active_for_authentication?).to be true
    end

    it 'returns false if user can not authenticate' do
      user_2.deactivate

      expect(user_2.active_for_authentication?).to be false
    end
  end

  describe '#email_required?' do
    it 'returns false if user is a virtual user' do
      user.update(virtual_user: true)
      expect(user.send(:email_required?)).to be false
    end

    it 'returns true if user is not a virtual user' do
      expect(user.send(:email_required?)).to be true
    end
  end

  describe '#password_required?' do
    it 'returns false if user is a virtual user' do
      user.update(virtual_user: true)
      expect(user.send(:password_required?)).to be false
    end

    it 'returns true if user is not a virtual user' do
      expect(user.send(:password_required?)).to be true
    end
  end

  describe '#send_welcome_email' do
    it 'triggers the method after create' do
      expect(user).to receive(:send_welcome_email)
      user.run_callbacks(:create)
    end

    it 'sends a welcome email to the user' do
      expect { user.send(:send_welcome_email) }.to change {
        ActiveJob::Base.queue_adapter.enqueued_jobs.size
      }.by(1)
    end
  end
end
