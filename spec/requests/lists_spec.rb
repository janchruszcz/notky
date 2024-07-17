require 'rails_helper'

RSpec.describe "Lists", type: :request do
  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
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
end
