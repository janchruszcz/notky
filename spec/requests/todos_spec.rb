# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Todos', type: :request do
  let(:user) { create(:user) }
  let(:list) { create(:list, user:) }

  before do
    login_as(user, scope: :user)
  end

  describe 'POST /todos' do
    let(:valid_attributes) { { title: 'Clean the house', list_id: list.id } }
    # let(:invalid_attributes) { { title: '', list_id: '' } }

    context 'with valid parameters' do
      it 'creates a new todo' do
        expect do
          post todos_path(list, format: :turbo_stream), params: { todo: valid_attributes }
        end.to change(Todo, :count).by(1)
      end

      it 'returns a turbo stream response' do
        post todos_path(list, format: :turbo_stream), params: { todo: valid_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("<turbo-stream action=\"append\" target=\"todos_#{list.id}\">")
        expect(response.body).to include(valid_attributes[:title])
      end
    end

    # context 'with invalid parameters' do
    #  it 'does not create a new todo' do
    #    expect do
    #      post todos_path(list, format: :turbo_stream), params: { todo: invalid_attributes }
    #    end.not_to change(Todo, :count)
    #  end

    #  it 'returns an unprocessable entity status' do
    #    post todos_path(list, format: :turbo_stream), params: { todo: invalid_attributes }
    #    expect(response).to have_http_status(:unprocessable_entity)
    #  end
    # end
  end

  describe 'PATCH /todos/:id' do
    let(:todo) { create(:todo, list:) }
    let(:new_attributes) { { title: 'Updated Todo' } }

    context 'with valid parameters' do
      it 'updates the requested todo' do
        patch todo_path(todo, format: :turbo_stream), params: { todo: new_attributes }
        todo.reload
        expect(todo.title).to eq('Updated Todo')
      end

      it 'returns a turbo stream response' do
        patch todo_path(todo, format: :turbo_stream), params: { todo: new_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("<turbo-stream action=\"replace\" target=\"todo_#{todo.id}\">")
        expect(response.body).to include('Updated Todo')
      end
    end

    context 'with invalid parameters' do
      it 'returns an unprocessable entity status' do
        patch todo_path(todo, format: :turbo_stream), params: { todo: { title: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /todos/:id' do
    let!(:todo) { create(:todo, list:) }

    it 'destroys the requested todo' do
      expect do
        delete todo_path(todo, format: :turbo_stream)
      end.to change(Todo, :count).by(-1)
    end

    it 'returns a turbo stream response' do
      delete todo_path(todo, format: :turbo_stream)
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"remove\" target=\"todo_#{todo.id}\">")
      expect(response.body).not_to include(todo.title)
    end
  end

  describe 'PATCH /todos/:id/toggle' do
    let(:todo) { create(:todo, list:, completed: false) }

    it 'toggles the completed status of the todo' do
      patch toggle_todo_path(todo, format: :turbo_stream)
      todo.reload
      expect(todo.completed).to be true
    end

    it 'returns a turbo stream response' do
      patch toggle_todo_path(todo, format: :turbo_stream)
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"replace\" target=\"todo_#{todo.id}\">")
    end
  end

  describe 'unauthorized access' do
    let(:other_user) { create(:user) }
    let(:other_list) { create(:list, user: other_user) }
    let(:other_todo) { create(:todo, list: other_list) }

    it 'returns unauthorized for PATCH /todos/:id' do
      patch todo_path(other_todo), params: { todo: { title: 'New Title' } }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized for DELETE /todos/:id' do
      delete todo_path(other_todo)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized for PATCH /todos/:id/toggle' do
      patch toggle_todo_path(other_todo)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
