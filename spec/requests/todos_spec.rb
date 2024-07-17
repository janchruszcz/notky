require 'rails_helper'

RSpec.describe "Todos", type: :request do
  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
  end

  describe "POST /todos" do
    it "creates a new todo" do
      list = List.create(title: "Home")

      todo_params = { title: "Clean the house", list_id: list.id }

      expect {
        post todos_path(format: :turbo_stream), params: { todo: todo_params }
      }.to change(Todo, :count).by(1)

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"append\" target=\"todos_#{list.id}\">")
      expect(response.body).to include(todo_params[:title])
    end
  end

  describe "PATCH /todos/:id" do
    it "updates an existing todo" do
      list = List.create(title: "Groceries")

      todo = list.todos.create(title: "Milk")
      updated_title = "Oranges"

      patch todo_path(todo, format: :turbo_stream), params: { todo: { title: updated_title } }

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"replace\" target=\"todo_#{todo.id}\">")
      expect(response.body).to include(updated_title)
    end
  end

  describe "DELETE /todos/:id" do
    it "deletes an existing todo" do
      list = List.create(title: "Groceries")

      todo = list.todos.create(title: "Milk")

      expect {
        delete todo_path(todo, format: :turbo_stream)
      }.to change(Todo, :count).by(-1)

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"remove\" target=\"todo_#{todo.id}\">")
      expect(response.body).not_to include(todo.title)
    end
  end
end
