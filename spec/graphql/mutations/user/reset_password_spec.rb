# frozen_string_literal: true

RSpec.describe Mutations::User::ResetPassword do
  set_graphql_type

  let!(:user) { create(:user) }
  let(:context) { { current_user: user } }

  let(:result) do
    res = KudoOMaticSchema.execute(
        mutation_string,
        context: context,
        variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { resetPassword(
      currentPassword: "#{variables[:current_password]}"
      newPassword: "#{variables[:new_password]}"
      newPasswordConfirmation: "#{variables[:new_password]}"
    ) { user { id } } } )
  end

  context 'authenticated' do
    describe 'valid current password' do
      let(:variables) { { current_password: 'password', new_password: 'newpass' } }

      it 'can reset the password' do
        expect(result['data']['resetPassword']['user']['id'].to_i).to eq(user.id)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'invalid current password' do
      let(:variables) { { current_password: 'wrongpass', new_password: 'newpass' } }

      it 'can\'t reset the password' do
        expect(result['data']['resetPassword']).to be_nil
      end

      it 'returns errors' do
        expect(result['errors']).to_not be_empty
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }
    let(:variables) { { current_password: 'password', new_password: 'newpass' } }

    it 'can\'t reset password' do
      expect(result['data']['resetPassword']).to be_nil
    end

    it 'returns a not authorized error for Mutation.resetPassword' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.resetPassword')
    end
  end
end