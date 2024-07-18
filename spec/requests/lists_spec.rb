# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lists', type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
  end

  describe 'POST /lists' do
    it 'creates a new list' do
      list_params = { title: 'Home', user_id: user.id }

      expect do
        post lists_path(format: :turbo_stream), params: { list: list_params }
      end.to change(List, :count).by(1)

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('<turbo-stream action="append" target="lists">')
      expect(response.body).to include(list_params[:title])
    end
  end

  describe 'DELETE /lists/:id' do
    it 'deletes an existing list' do
      list = List.create(title: 'Home', user_id: user.id)

      expect do
        delete list_path(list, format: :turbo_stream)
      end.to change(List, :count).by(-1)

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"remove\" target=\"list_#{list.id}\">")
      expect(response.body).not_to include(list.title)
    end
  end
end
