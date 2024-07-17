require 'rails_helper'

RSpec.describe 'Dashboard', type: :request do
  describe 'GET /' do
    it 'displays lists of todos' do
      list1 = List.create(title: 'Groceries')
      list2 = List.create(title: 'Home')

      todo1 = list1.todos.create(title: 'Milk')
      todo2 = list1.todos.create(title: 'Cornflakes')

      todo3 = list2.todos.create(title: 'Clean the house')
      todo4 = list2.todos.create(title: 'Wash the car')

      get '/'
      expect(response).to have_http_status(200)
      expect(response.body).to include(todo1.title)
      expect(response.body).to include(todo2.title)
      expect(response.body).to include(todo3.title)
      expect(response.body).to include(todo4.title)
    end
  end
end
