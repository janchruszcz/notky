# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lists', type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
  end

  describe 'POST /lists' do
    let(:valid_attributes) { { title: 'Home', user_id: user.id } }
    # let(:invalid_attributes) { { title: '', user_id: user.id } }

    context 'with valid parameters' do
      it 'creates a new list' do
        expect do
          post lists_path(format: :turbo_stream), params: { list: valid_attributes }
        end.to change(List, :count).by(1)
      end

      it 'returns a turbo stream response' do
        post lists_path(format: :turbo_stream), params: { list: valid_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include('<turbo-stream action="append" target="lists">')
        expect(response.body).to include(valid_attributes[:title])
      end
    end

    # context 'with invalid parameters' do
    #   it 'does not create a new list' do
    #     expect do
    #       post lists_path(format: :turbo_stream), params: { list: invalid_attributes }
    #     end.not_to change(List, :count)
    #   end

    #   it 'returns an unprocessable entity status' do
    #     post lists_path(format: :turbo_stream), params: { list: invalid_attributes }
    #     expect(response).to have_http_status(:unprocessable_entity)
    #   end
    # end
  end

  describe 'PATCH /lists/:id' do
    let(:list) { create(:list, user:) }
    let(:new_attributes) { { title: 'Updated Title' } }

    context 'with valid parameters' do
      it 'updates the requested list' do
        patch list_path(list, format: :turbo_stream), params: { list: new_attributes }
        list.reload
        expect(list.title).to eq('Updated Title')
      end

      it 'returns a turbo stream response' do
        patch list_path(list, format: :turbo_stream), params: { list: new_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("<turbo-stream action=\"replace\" target=\"list_#{list.id}\">")
        expect(response.body).to include('Updated Title')
      end
    end

    # context 'with invalid parameters' do
    #  it 'returns an unprocessable entity status' do
    #    patch list_path(list, format: :turbo_stream), params: { list: { title: '' } }
    #    expect(response).to have_http_status(:unprocessable_entity)
    #  end
    # end
  end

  describe 'DELETE /lists/:id' do
    let!(:list) { create(:list, user:) }

    it 'destroys the requested list' do
      expect do
        delete list_path(list, format: :turbo_stream)
      end.to change(List, :count).by(-1)
    end

    it 'returns a turbo stream response' do
      delete list_path(list, format: :turbo_stream)
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"remove\" target=\"list_#{list.id}\">")
      expect(response.body).not_to include(list.title)
    end
  end

  describe 'unauthorized access' do
    let(:other_user) { create(:user) }
    let(:other_list) { create(:list, user: other_user) }

    it 'returns unauthorized for PATCH /lists/:id' do
      patch list_path(other_list), params: { list: { title: 'New Title' } }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized for DELETE /lists/:id' do
      delete list_path(other_list)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
