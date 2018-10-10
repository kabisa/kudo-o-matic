# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let!(:user) { create(:user, :admin) }
  let!(:user_admin) { create(:user, :admin) }
  let!(:user_unauthorized) { create(:user)}
  let!(:team) { create(:team) }
  let!(:team2) { create(:team, name: 'The Company', slug: 'the-company') }
  let!(:balance) { create :balance, current: :current, team_id: team.id }
  let!(:goal) { create(:goal) }
  let!(:transaction_old) { create(:transaction, team_id: team.id, balance: balance, sender_id: user.id, created_at: DateTime.now - 15.minutes) }
  let!(:transaction) { create(:transaction, team_id: team.id, balance: balance, sender_id: user.id) }

  before do
    team.add_member(user)
    team.add_member(user_admin, true)
    team.add_member(user_unauthorized)
    sign_in user
  end

  describe 'GET #show' do
    context 'with a valid membership' do
      before do
        get :show, params: { id: transaction.id, team: team.slug }
      end

      it 'gets show' do
        expect(response).to render_template(:show)
      end

      it 'returns a 200 (ok) status code' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with a invalid membership' do
      before do
        get :show, params: { id: transaction.id, team: team2.slug }
      end

      it 'gets teams/access_denied' do
        expect(response).to render_template('teams/access_denied')
      end

      it 'returns a 403 (forbidden) status code' do
        expect(response).to have_http_status(403)
      end
    end

    context 'with a non-existing team' do
      before do
        get :show, params: { id: transaction.id, team: 'nonexisting' }
      end

      it 'redirects to root' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET #edit' do
    context 'as author' do
      it 'gets update' do
        get :edit, params: { id: transaction.id, team: team.slug }
        expect(response).to render_template(:edit)
      end

      it 'cant get update for transactions that are older than 15 minutes' do
        get :edit, params: { id: transaction_old.id, team: team.slug }
        expect(response).to redirect_to(root_url)
      end
    end

    context 'as team admin' do
      before do
        sign_in user_admin
        get :edit, params: { id: transaction.id, team: team.slug }
      end

      it 'gets update' do
        expect(response).to render_template(:edit)
      end

      it 'gets update for transactions that are older than 15 minutes' do
        get :edit, params: { id: transaction_old.id, team: team.slug }
        expect(response).to render_template(:edit)
      end
    end

    context 'as not author' do
      before do
        sign_in user_unauthorized
        get :edit, params: { id: transaction.id, team: team.slug }
      end

      it 'redirects to root' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE #delete' do
    context 'as author' do
      it 'deletes the transaction' do
        expect {
          delete :destroy, id: transaction.id, team: team.slug
        }.to change(Transaction, :count).by(-1)
      end

      it 'cant delete transactions that are older than 15 minutes' do
        expect {
          delete :destroy, id: transaction_old.id, team: team.slug
        }.to change(Transaction, :count).by(0)
      end
    end

    context 'as team admin' do
      before do
        sign_in user_admin
      end

      it 'deletes the transaction' do
        expect {
          delete :destroy, id: transaction.id, team: team.slug
        }.to change(Transaction, :count).by(-1)
      end

      it 'deletes transactions that are older than 15 minutes' do
        expect {
          delete :destroy, id: transaction_old.id, team: team.slug
        }.to change(Transaction, :count).by(-1)
      end
    end

    context 'as not author' do
      before do
        sign_in user_unauthorized
        delete :destroy, params: { id: transaction.id, team: team.slug }
      end

      it 'redirects to root' do
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
