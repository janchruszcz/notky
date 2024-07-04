require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  
  describe "GET /" do
    it "displays lists of todos" do
      list1 = List.create(title: "Groceries")
      list2 = List.create(title: "Home")

      todo1 = list1.todos.create(title: "Milk")
      todo2 = list1.todos.create(title: "Cornflakes")

      todo3 = list2.todos.create(title: "Clean the house")
      todo4 = list2.todos.create(title: "Wash the car")

      get "/"
      expect(response).to have_http_status(200)
      expect(response.body).to include(todo1.title)
      expect(response.body).to include(todo2.title)
      expect(response.body).to include(todo3.title)
      expect(response.body).to include(todo4.title)
    end
  end

  describe "POST /lists" do
    it "creates a new list" do
      list_params = { title: "Home" }

      expect {
        post lists_path(format: :turbo_stream), params: { list: list_params }
      }.to change(List, :count).by(1)

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('<turbo-stream action="append" target="lists">')
      expect(response.body).to include(list_params[:title])

    end
  end

  describe "DELETE /lists/:id" do
    it "deletes an existing list" do
      list = List.create(title: "Home")
      
      expect {
        delete list_path(list, format: :turbo_stream)
      }.to change(List, :count).by(-1)

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("<turbo-stream action=\"remove\" target=\"list_#{list.id}\">")
      expect(response.body).not_to include(list.title)
    end
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