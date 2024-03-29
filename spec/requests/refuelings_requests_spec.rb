# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefuelingsController, type: :request do
  before do
    sign_in user
  end

  let(:user) { create(:user) }

  describe '#index' do
    context 'when user is NOT logged in' do
      before { sign_out user }

      it 'renders login form' do
        get root_path

        expect(response.status).to eq 302
        follow_redirect!

        expect(response.body).to include 'You need to sign in or sign up before continuing.'
        expect(response.body).to include 'Log in'
        expect(response.body).not_to include 'Edit account'
      end
    end

    context 'when user is logged in' do
      it 'renders index page' do
        get root_path

        expect(response.status).to eq 200
        expect(response.body).to include 'Edit account'
        expect(response.body).to include 'Log out'
      end

      context 'with refuelings' do
        let!(:ref1) { create(:refueling, user: user, created_at: Date.yesterday) }
        let!(:ref2) { create(:refueling, user: user, liters: 20, created_at: Date.current) }
        let!(:ref3) { create(:refueling, liters: 400, created_at: Date.current) }

        it 'displays only self refuelings' do
          get root_path

          expect(response.body).to include ref1.liters.to_s
          expect(response.body).to include ref2.liters.to_s
          expect(response.body).not_to include ref3.liters.to_s
        end
      end
    end
  end

  describe '#new' do
    it 'displays new refueling form for current user' do
      get new_refueling_path

      expect(response.status).to eq 200
      expect(response.body).to include 'New refueling'
    end
  end

  describe '#create' do
    context 'with valid params' do
      it 'creates refueling for current user and returns 302' do
        expect {
          post refuelings_path, params: {
            refueling: {
              liters: 30,
              kilometers: 600,
              cost: 150
            }
          }
        }.to change{ Refueling.count }.by(1)

        expect(response.status).to eq 302
        follow_redirect!

        expect(response.body).to include 'Refueling was created'
        expect(response.body).to include '30'
        expect(response.body).to include '600'
        expect(response.body).to include '150'
      end
    end

    context 'with invalid params' do
      it 'renders form with error messages and returns 200' do
        expect {
          post refuelings_path, params: {
            refueling: {
              liters: '',
              kilometers: 600,
              cost: 150
            }
          }
        }.not_to change{ Refueling.count }

        expect(response.status).to eq 200
        expect(response.body).to include 'Liters is not a number and can\'t be blank'
      end
    end
  end

  describe '#update' do
    let!(:refueling) { create(:refueling, user: user) }

    context 'with valid params' do
      it 'updates refueling and returns 302' do
        put refueling_path(refueling), params: {
          refueling: {
            liters: 30,
            kilometers: 600,
            cost: 150
          }
        }

        expect(response.status).to eq 302
        follow_redirect!

        expect(response.body).to include 'Refueling was updated'
        expect(refueling.reload.liters).to eq 30
        expect(refueling.kilometers).to eq 600
        expect(refueling.cost).to eq 150
      end
    end

    context 'with invalid params' do
      it 'renders form with error messages and returns 200' do
        expect {
          put refueling_path(refueling), params: {
            refueling: {
              liters: '',
              kilometers: 600,
              cost: 150
            }
          }
        }.not_to change{ refueling }

        expect(response.status).to eq 200
        expect(response.body).to include 'Liters is not a number and can\'t be blank'
      end
    end

    context 'someone elses refueling' do
      let!(:refueling) { create(:refueling) }

      it 'displays error message and returns 302' do
        put refueling_path(refueling), params: {
          refueling: {
            liters: '',
            kilometers: 600,
            cost: 150
          }
        }

        expect(response.status).to eq 302
        follow_redirect!

        expect(response.body).to include 'Resource not found!'
      end
    end
  end

  describe '#destroy' do
    let!(:refueling) { create(:refueling, user: user) }

    it 'removes refueling and returns 302' do
      delete refueling_path(refueling)

      expect(response.status).to eq 302
      follow_redirect!

      expect(response.body).to include 'Refueling was deleted'
    end

    context 'someone elses refueling' do
      let!(:refueling) { create(:refueling) }

      it 'displays error message and returns 302' do
        delete refueling_path(refueling)

        expect(response.status).to eq 302
        follow_redirect!

        expect(response.body).to include 'Resource not found!'
      end
    end
  end
end
