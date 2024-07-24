# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard', type: :request do
  describe 'GET /' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context 'when user is signed in' do
      before do
        sign_in(user)
      end

      it 'returns a successful response' do
        get root_path
        expect(response).to have_http_status(:ok)
      end

      it 'displays lists and todos for the current user' do
        list1 = create(:list, title: 'Groceries', user:)
        list2 = create(:list, title: 'Home', user:)
        todo1 = create(:todo, title: 'Milk', list: list1)
        todo2 = create(:todo, title: 'Cornflakes', list: list1)
        todo3 = create(:todo, title: 'Clean the house', list: list2)
        todo4 = create(:todo, title: 'Wash the car', list: list2)

        get root_path
        expect(response.body).to include(list1.title)
        expect(response.body).to include(list2.title)
        expect(response.body).to include(todo1.title)
        expect(response.body).to include(todo2.title)
        expect(response.body).to include(todo3.title)
        expect(response.body).to include(todo4.title)
      end

      it 'does not display lists and todos from other users' do
        other_list = create(:list, title: 'Other User List', user: other_user)
        other_todo = create(:todo, title: 'Other User Todo', list: other_list)

        get root_path
        expect(response.body).not_to include(other_list.title)
        expect(response.body).not_to include(other_todo.title)
      end

      it 'displays the correct number of lists and todos' do
        create_list(:list, 3, user:) do |list|
          create_list(:todo, 2, list:)
        end

        get root_path
        expect(response.body).to include('3 lists')
        expect(response.body).to include('6 todos')
      end
    end

    context 'when user is not signed in' do
      it 'redirects to the sign in page' do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
