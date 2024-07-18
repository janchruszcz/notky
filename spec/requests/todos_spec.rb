# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Todos' do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
  end

  describe 'POST /todos' do
    it 'creates a new todo' do
      list = List.create(title: 'Home', user_id: user.id)

      todo_params = { title: 'Clean the house', list_id: list.id }

      expect do
        post todos_path(format: :turbo_stream), params: { todo: todo_params }
      end.to change(Todo, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"append\" target=\"todos_#{list.id}\">")
      expect(response.body).to include(todo_params[:title])
    end
  end

  describe 'PATCH /todos/:id' do
    it 'updates an existing todo' do
      list = List.create(title: 'Groceries', user_id: user.id)

      todo = list.todos.create(title: 'Milk')
      updated_title = 'Oranges'

      patch todo_path(todo, format: :turbo_stream), params: { todo: { title: updated_title } }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"replace\" target=\"todo_#{todo.id}\">")
      expect(response.body).to include(updated_title)
    end
  end

  describe 'DELETE /todos/:id' do
    it 'deletes an existing todo' do
      list = List.create(title: 'Groceries', user_id: user.id)

      todo = list.todos.create(title: 'Milk')

      expect do
        delete todo_path(todo, format: :turbo_stream)
      end.to change(Todo, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"remove\" target=\"todo_#{todo.id}\">")
      expect(response.body).not_to include(todo.title)
    end
  end
end
