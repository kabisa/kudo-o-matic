# frozen_string_literal: true

RSpec.describe Mutations::User::NewPassword do
  set_graphql_type

  let!(:user) { create(:user) }
  let(:context) { {} }
  let(:variables) { { reset_password_token: user.send_reset_password_instructions, password: 'newpass' } }

  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { newPassword(
      resetPasswordToken: "#{variables[:reset_password_token]}"
      password: "#{variables[:password]}"
      passwordConfirmation: "#{variables[:password]}"
    ) { user { id } } } )
  end

  describe 'new password' do
    it 'returns the user' do
      expect(result['data']['newPassword']['user']['id'].to_i).to eq(user.id)
    end

    it 'returns no errors' do
      expect(result['errors']).to be_nil
    end
  end

  describe 'invalid reset password token' do
    let(:variables) { { reset_password_token: 'faketoken', password: 'newpass' } }

    it 'doesn\'t reset the password' do
      expect(result['data']['forgotPassword']).to be_nil
      expect(result['errors'].first['message']).to eq('reset_password_token: is invalid')
    end
  end
end